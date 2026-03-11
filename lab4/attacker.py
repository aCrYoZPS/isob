import socket
import threading
import time


def attack_once(thread_id):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.settimeout(2.0)
        s.connect(('127.0.0.1', 65432))

        resp = s.recv(1024).decode().strip()
        print(f"[Thread {thread_id}] recieved {resp}, ignoring...")

        time.sleep(1)
    except Exception as ex:
        print(f"Encountered exception: {ex}")
        pass
    finally:
        s.close()


def run_attack():
    print("[!] Attacking (20 threads)...")
    threads = []
    for i in range(20):
        t = threading.Thread(target=attack_once, args=(i,))
        threads.append(t)
        t.start()
        time.sleep(0.05)

    for t in threads:
        t.join()
    print("[!] Attack complete.")


if __name__ == "__main__":
    run_attack()
