import socket
import hashlib
import time

PORT = 65432


def solve_pow(challenge, difficulty):
    print(f"[*] Solving challenge of difficulty {difficulty}...")
    prefix = '0' * int(difficulty)
    nonce = 0
    start_time = time.time()

    while True:
        res = hashlib.sha256(f"{challenge}{nonce}".encode()).hexdigest()
        if res.startswith(prefix):
            end_time = time.time()
            print(f"[+] Solved in {end_time - start_time:.4f} s. Nonce: {nonce}")
            return str(nonce)
        nonce += 1


def run_client():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(('127.0.0.1', PORT))

        resp = s.recv(1024).decode().strip()
        if "CHALLENGE" in resp:
            try:
                parts = resp.split(":")
                challenge = parts[1]
                diff = parts[2]
                nonce = solve_pow(challenge, diff)

                s.sendall(f"SOLVE:{nonce}".encode())

                final_resp = s.recv(1024).decode()
                print(f"[*] Server response: {final_resp}")
            except (IndexError, ValueError):
                print(f"[!] Invalid server response: {resp}")
        else:
            print(f"[*] Server response: {resp}")

    except ConnectionRefusedError:
        print("[!] Error: Nothing listening on port {PORT}.")
    except Exception as ex:
        print(f"[!] Error: {ex}")
    finally:
        s.close()


if __name__ == "__main__":
    run_client()
