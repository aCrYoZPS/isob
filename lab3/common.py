import json
import base64
from datetime import datetime, timedelta
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC


def generate_key_from_password(password: str, salt: bytes = b"static_salt") -> bytes:
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,
        salt=salt,
        iterations=100000,
    )
    key = base64.urlsafe_b64encode(kdf.derive(password.encode()))

    return key


class KerberosMessage:
    def __init__(self, key: bytes):
        self.fernet = Fernet(key)

    def encrypt(self, data: dict) -> str:
        json_data = json.dumps(data).encode()
        return self.fernet.encrypt(json_data).decode()

    def decrypt(self, token: str) -> dict:
        decrypted_data = self.fernet.decrypt(token.encode())
        return json.loads(decrypted_data.decode())


def get_timestamp(offset_seconds=0):
    dt = datetime.now() + timedelta(seconds=offset_seconds)
    return dt.isoformat()


def verify_timestamp(timestamp_str, window_seconds=300):
    try:
        ts = datetime.fromisoformat(timestamp_str)
        now = datetime.now()
        return abs((now - ts).total_seconds()) < window_seconds
    except Exception:
        return False
