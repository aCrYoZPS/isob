import common

SERVER_KEY = common.generate_key_from_password("server_secret_key")


class ApplicationServer:
    def __init__(self, service_id):
        self.service_id = service_id
        self.key = SERVER_KEY

    def verify_request(self, ap_req):
        service_ticket_token = ap_req["service_ticket"]
        authenticator_token = ap_req["authenticator"]

        try:
            service_ticket = common.KerberosMessage(self.key).decrypt(service_ticket_token)
        except Exception:
            return {"error": "Invalid Service Ticket"}

        session_key_client_server = service_ticket["session_key_client_server"].encode()

        try:
            authenticator = common.KerberosMessage(session_key_client_server).decrypt(authenticator_token)
        except Exception:
            return {"error": "Invalid Authenticator"}

        if authenticator["client_id"] != service_ticket["client_id"]:
            return {"error": "Client ID mismatch"}
        if not common.verify_timestamp(authenticator["timestamp"]):
            return {"error": "Stale authenticator"}

        ap_rep_data = {
            "timestamp": authenticator["timestamp"],
            "status": "Authenticated"
        }
        ap_rep_encrypted = common.KerberosMessage(session_key_client_server).encrypt(ap_rep_data)

        return {"success": True, "client_id": service_ticket["client_id"], "ap_rep": ap_rep_encrypted, "session_key": session_key_client_server}

    def echo_service(self, encrypted_message, session_key):
        try:
            message_data = common.KerberosMessage(session_key).decrypt(encrypted_message)
            original_text = message_data.get("message", "")

            response_data = {
                "echo": f"Server says: {original_text}",
                "timestamp": common.get_timestamp()
            }
            return common.KerberosMessage(session_key).encrypt(response_data)
        except Exception as e:
            return {"error": f"Failed to process echo request: {e}"}
