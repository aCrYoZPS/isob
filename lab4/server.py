import socket
import hashlib
import secrets
import threading
import time
from collections import defaultdict

PORT = 65432
DIFFICULTY = 4
CONN_TIMEOUT = 5.0
RATE_LIMIT_WINDOW = 10
MAX_REQ_PER_WINDOW = 3

request_history = defaultdict(list)
history_lock = threading.Lock()


def is_rate_limited(ip):
    now = time.time()
    with history_lock:
        request_history[ip] = [t for t in request_history[ip] if now - t < RATE_LIMIT_WINDOW]
        if len(request_history[ip]) >= MAX_REQ_PER_WINDOW:
            return True
        request_history[ip].append(now)
        return False


def verify_pow(challenge, nonce):
    prefix = '0' * DIFFICULTY
    attempt = f"{challenge}{nonce}".encode()
    result = hashlib.sha256(attempt).hexdigest()
    return result.startswith(prefix)


def handle_client(conn, addr):
    ip = addr[0]
    print(f"[*] New connection: {addr}")

    try:
        if is_rate_limited(ip):
            print(f"[!] Rate limit for {ip} exceeded")
            conn.sendall(b"ERROR: Rate limit exceeded. Try again later.")
            return

        challenge = secrets.token_hex(16)
        conn.sendall(f"CHALLENGE:{challenge}:{DIFFICULTY}".encode())

        conn.settimeout(CONN_TIMEOUT)
        data = conn.recv(1024).decode().strip()

        if data.startswith("SOLVE:"):
            try:
                nonce = data.split(":")[1]
            except IndexError:
                conn.sendall(b"ERROR: Malformed SOLVE message.")
                return

            if verify_pow(challenge, nonce):
                print(f"[+] {ip} successfully solved PoW!")
                conn.sendall(b"SUCCESS: Welcome to the protected resource!")
            else:
                print(f"[-] {ip} sent wrong nonce.")
                conn.sendall(b"ERROR: Invalid PoW solution.")
        else:
            conn.sendall(b"ERROR: Protocol violation.")

    except socket.timeout:
        print(f"[!] {ip} exceeded timeout.")
    except Exception as ex:
        print(f"[!] Error from {ip}: {ex}")
    finally:
        conn.close()


def start_server():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        server.bind(('0.0.0.0', PORT))
    except PermissionError:
        print(f"[!] Error: Port {PORT} is taken or requires root access.")
        return

    server.listen(100)
    print(f"=== Server started on port {PORT} ===")
    print(f"=== Difficulty: {DIFFICULTY}, limit: {MAX_REQ_PER_WINDOW} in {RATE_LIMIT_WINDOW}s ===")

    while True:
        try:
            conn, addr = server.accept()
            client_thread = threading.Thread(target=handle_client, args=(conn, addr))
            client_thread.daemon = True
            client_thread.start()
        except KeyboardInterrupt:
            print("[!] Stopping server...")
            break
        except Exception as ex:
            print(f"[!] Error on accept: {ex}")

    server.close()


if __name__ == "__main__":
    start_server()
