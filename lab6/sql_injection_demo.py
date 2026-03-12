import sqlite3
import os


def init_db(db_name="users.db"):
    if os.path.exists(db_name):
        os.remove(db_name)

    conn = sqlite3.connect(db_name)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL,
            email TEXT
        )
    ''')

    users = [
        ('admin', 'p@ssword123', 'admin@example.com'),
        ('alice', 'alice_secret', 'alice@example.com'),
        ('bob', 'bob_secure', 'bob@example.com')
    ]
    cursor.executemany('INSERT INTO users (username, password, email) VALUES (?, ?, ?)', users)
    conn.commit()
    conn.close()


def vulnerable_get_user(username):
    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()
    query = f"SELECT * FROM users WHERE username = '{username}'"
    print(f"[LOG] SQL (vulnerable): {query}")

    try:
        cursor.execute(query)
        result = cursor.fetchall()
        return result
    except Exception as ex:
        return f"Error: {ex}"
    finally:
        conn.close()


def secure_get_user(username):
    conn = sqlite3.connect("users.db")
    cursor = conn.cursor()
    query = "SELECT * FROM users WHERE username = ?"
    print(f"[LOG] SQL (secure): {query} with param: '{username}'")

    try:
        cursor.execute(query, (username,))
        result = cursor.fetchall()
        return result
    except Exception as ex:
        return f"Error: {ex}"
    finally:
        conn.close()


def run_demo():
    init_db()
    attack_payload = "' OR '1'='1"
    print("--- Vulnerable ---")
    print("--- 1. Search existing user: 'alice' ---")
    print(f"Result: {vulnerable_get_user('alice')}")
    print(f"--- 2. Attack (Payload: {attack_payload}) ---")
    vuln_res = vulnerable_get_user(attack_payload)
    if isinstance(vuln_res, list):
        for row in vuln_res:
            print(f"  - {row}")
    else:
        print(f"  {vuln_res}")

    print("--- Protected ---")
    print("--- 1. Search existing user: 'alice' ---")
    print(f"Result: {secure_get_user('alice')}\n")
    print(f"--- 2. Attack (Payload: {attack_payload}) ---")
    sec_res = secure_get_user(attack_payload)
    print(f"  - {sec_res}")


if __name__ == "__main__":
    run_demo()
