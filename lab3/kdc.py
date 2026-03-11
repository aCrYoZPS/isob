import common

KEYS = {
    "client1": common.generate_key_from_password("password123"),
    "tgs": common.generate_key_from_password("tgs_secret_key"),
    "app_server": common.generate_key_from_password("server_secret_key"),
}


class KDC:
    def __init__(self):
        self.tgs_key = KEYS["tgs"]

    def as_service(self, client_id, encrypted_timestamp, service_id_requested="tgs"):
        if client_id not in KEYS:
            return {"error": "Client not found"}

        try:
            preauth_data = common.KerberosMessage(KEYS[client_id]).decrypt(encrypted_timestamp)
            if not common.verify_timestamp(preauth_data.get("timestamp")):
                return {"error": "Invalid preauth timestamp"}
        except Exception:
            return {"error": "Pre-authentication failed"}

        session_key_client_tgs = common.Fernet.generate_key()

        tgt_data = {
            "client_id": client_id,
            "session_key_client_tgs": session_key_client_tgs.decode(),
            "timestamp": common.get_timestamp(),
            "expiration": common.get_timestamp(3600),
        }
        tgt_encrypted = common.KerberosMessage(self.tgs_key).encrypt(tgt_data)

        as_rep_data = {
            "session_key_client_tgs": session_key_client_tgs.decode(),
            "tgt": tgt_encrypted
        }
        as_rep_encrypted = common.KerberosMessage(KEYS[client_id]).encrypt(as_rep_data)

        return as_rep_encrypted

    def tgs_service(self, tgt_token, authenticator_token, service_id_requested):
        try:
            tgt = common.KerberosMessage(self.tgs_key).decrypt(tgt_token)
        except Exception:
            return {"error": "Invalid TGT"}

        session_key_client_tgs = tgt["session_key_client_tgs"].encode()

        try:
            authenticator = common.KerberosMessage(session_key_client_tgs).decrypt(authenticator_token)
        except Exception:
            return {"error": "Invalid Authenticator"}

        if authenticator["client_id"] != tgt["client_id"]:
            return {"error": "Client ID mismatch"}
        if not common.verify_timestamp(authenticator["timestamp"]):
            return {"error": "Stale authenticator"}

        session_key_client_server = common.Fernet.generate_key()

        if service_id_requested not in KEYS:
            return {"error": "Service not found"}

        service_ticket_data = {
            "client_id": tgt["client_id"],
            "session_key_client_server": session_key_client_server.decode(),
            "timestamp": common.get_timestamp(),
            "expiration": common.get_timestamp(3600),
        }
        service_ticket_encrypted = common.KerberosMessage(KEYS[service_id_requested]).encrypt(service_ticket_data)

        tgs_rep_data = {
            "session_key_client_server": session_key_client_server.decode(),
            "service_ticket": service_ticket_encrypted
        }
        tgs_rep_encrypted = common.KerberosMessage(session_key_client_tgs).encrypt(tgs_rep_data)

        return tgs_rep_encrypted
