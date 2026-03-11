from kdc import KDC
from client import KerberosClient
from server import ApplicationServer
import common


def run_kerberos_demo():
    print("--- 1. Initialization ---")
    kdc_instance = KDC()
    client = KerberosClient("client1", "password123")
    server = ApplicationServer("app_server")

    print("\n--- 2. AS Service: Requesting TGT with Pre-Auth ---")
    if not client.request_tgt(kdc_instance):
        return

    print("\n--- 3. TGS Service: Requesting Service Ticket ---")
    if not client.request_service_ticket(kdc_instance, "app_server"):
        return

    print("\n--- 4. Client to Server Authentication (AP_REQ) ---")
    ap_req = client.authenticate_with_server("app_server")
    print(f"Client prepared AP_REQ for server: {list(ap_req.keys())}")

    print("\n--- 5. Server Verifying Request ---")
    result = server.verify_request(ap_req)

    if "success" in result:
        print(f"SUCCESS: Server authenticated client \"{result['client_id']}\"")
        print("\n--- 6. Mutual Authentication ---")
        ap_rep_token = result["ap_rep"]
        try:
            ap_rep = common.KerberosMessage(client.session_key_client_server).decrypt(ap_rep_token)
            print(f"Client verified server response: {ap_rep}")
        except Exception as e:
            print(f"Client failed to verify server response: {e}")

        print("\n--- 7. Secured Echo Service ---")
        session_key = result["session_key"]
        message_to_send = "Hello Kerberos protected service!"
        print(f"Client sending message: \"{message_to_send}\"")

        encrypted_message = client.encrypt_message(message_to_send)
        encrypted_response = server.echo_service(encrypted_message, session_key)

        try:
            decrypted_response = client.decrypt_message(encrypted_response)
            print(f"SUCCESS: Client received echo response: \"{decrypted_response['echo']}\"")
        except Exception as e:
            print(f"FAILURE: Client failed to decrypt echo response: {e}")
    else:
        print(f"FAILURE: Server authentication failed: {result.get('error')}")


if __name__ == "__main__":
    run_kerberos_demo()
