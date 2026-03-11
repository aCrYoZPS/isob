import common


class KerberosClient:
    def __init__(self, client_id, password):
        self.client_id = client_id
        self.key = common.generate_key_from_password(password)
        self.tgt = None
        self.session_key_client_tgs = None
        self.service_ticket = None
        self.session_key_client_server = None

    def request_tgt(self, kdc_instance):
        preauth_data = {
            "timestamp": common.get_timestamp(),
            "client_id": self.client_id
        }
        preauth_encrypted = common.KerberosMessage(self.key).encrypt(preauth_data)

        as_rep_encrypted = kdc_instance.as_service(self.client_id, preauth_encrypted)

        if isinstance(as_rep_encrypted, dict) and "error" in as_rep_encrypted:
            print(f"[{self.client_id}] AS error: {as_rep_encrypted['error']}")
            return False

        try:
            as_rep = common.KerberosMessage(self.key).decrypt(as_rep_encrypted)
            self.session_key_client_tgs = as_rep["session_key_client_tgs"].encode()
            self.tgt = as_rep["tgt"]
            print(f"[{self.client_id}] Successfully obtained TGT.")
            return True
        except Exception as e:
            print(f"[{self.client_id}] AS Authentication failed: {e}")
            return False

    def request_service_ticket(self, kdc_instance, service_id):
        if not self.tgt:
            return False

        authenticator_data = {
            "client_id": self.client_id,
            "timestamp": common.get_timestamp(),
        }
        authenticator_encrypted = common.KerberosMessage(self.session_key_client_tgs).encrypt(authenticator_data)

        tgs_rep_encrypted = kdc_instance.tgs_service(self.tgt, authenticator_encrypted, service_id)

        try:
            tgs_rep = common.KerberosMessage(self.session_key_client_tgs).decrypt(tgs_rep_encrypted)
            self.session_key_client_server = tgs_rep["session_key_client_server"].encode()
            self.service_ticket = tgs_rep["service_ticket"]
            print(f"[{self.client_id}] Successfully obtained Service Ticket for {service_id}.")
            return True
        except Exception as e:
            print(f"[{self.client_id}] TGS Request failed: {e}")
            return False

    def authenticate_with_server(self, service_id):
        if not self.service_ticket:
            return None

        authenticator_data = {
            "client_id": self.client_id,
            "timestamp": common.get_timestamp(),
        }
        authenticator_encrypted = common.KerberosMessage(self.session_key_client_server).encrypt(authenticator_data)

        return {
            "service_ticket": self.service_ticket,
            "authenticator": authenticator_encrypted
        }

    def encrypt_message(self, message):
        if not self.session_key_client_server:
            return None
        data = {
            "client_id": self.client_id,
            "message": message,
            "timestamp": common.get_timestamp(),
        }
        return common.KerberosMessage(self.session_key_client_server).encrypt(data)

    def decrypt_message(self, encrypted_message):
        if not self.session_key_client_server:
            return None
        return common.KerberosMessage(self.session_key_client_server).decrypt(encrypted_message)
