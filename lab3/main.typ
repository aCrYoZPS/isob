#import "lib/stp2024.typ"
#include "title.typ"

#show: stp2024.template

#stp2024.full_outline()
#pagebreak()

= Цель работы
Целью данной лабораторной работы является изучение базовых принципов идентификации и аутентификации пользователей и 
протокола Kerberos. Задачи включают изучение протокола Kerberos, проектирование программной реализации данного
протокола и тестирование разработанного программного средства.

Конечным результатом данной лабораторной работы должна быть разработанная программная реализация протокола Kerberos,
осуществляющая аутентификацию пользователей. 

= Ход работы
В ходе выполнения работы было создано программное средство на языке программирования
Python, реализующее протокол Kerberos. Для работы Kerberos необходимы 3 сущности:
#enum(
[KDC (Key Distribution Center -- Центр Распределения Ключей), который служит доверенным третьим лицом, хранящим
секретные ключи всех клиентов и серверов и состоит из двух сущностей: AS (Authentication
Service -- Сервис Аутентификации), который производит собственно аутентификацию пользователя, и TGS (Ticket Granting
Service -- Сервис Выдачи Мандатов), который выдаёт мандаты для определённых серверов приложений.],
[Клиент, который отправляет запросы на доступ к серверу приложения.],
[Сервер приложения, который предоставляет какую-либо услугу клиенту.]
)

При аутентификации с использованием Kerberos происходит 3 обмена сообщениями:
1. Обмен с AS.
2. Обмен с TGS.
3. Обмен с сервером приложения.

== Обмен с AS
Цель данного этапа -- подтверждение личности клиента и выдача ему TGT (Ticket Granting Ticket -- мандат для получения
мандатов). Данный обмен происходит в 3 этапа:
#enum(
  [Клиент формирует запрос, содержащий данные для предварительной аутентификации (метку времени, зашифрованную
   ключом, полученным хешированием пароля) и идентификатор пользователя.],
  [AS находит ключ для данного идентификатора пользователя, расшифровывает данные для предварительной аутентификации и
   проверяет метку времени для предотвращения атак повторного воспроизведения],
  [AS формирует ответ, содержащий Клиент-TGS сессионный ключ, зашифрованный ключом клиента, и мандат для получения
   мандатов, зашифрованный ключом TGS.]
)

== Обмен с TGS
Цель данного этапа -- получение клиентом мандата для конкретного сервера приложения. Данный обмен также происходит в 3
этапа:
#enum(
  [Клиент формирует запрос, содержащий TGT и данные для аутентификации (метку времени и идентификатор пользователя,
   зашифрованные Клиент-TGS сессионным ключом).],
  [TGS расшифровывает TGT собственным секретным ключом, получает оттуда Клиент-TGS сессионный ключ, которым
   расшифровывает аутентификационные данные и подтверждает личность клиента],
  [TGS формирует ответ, содержащий Клиент-Сервер сессионный ключ, зашифрованный Клиент-TGS ключом, и мандат для сервера
   приложения, содержащий идентификатор пользователя и Клиент-Сервер сессионный ключ, зашифрованный ключом сервера
   приложения.]
)

== Обмен с сервером приложения
Цель данного этапа -- получение клиентом услуги от сервера приложения. Данный обмен также происходит в 3
этапа:
#enum(
  [Клиент формирует запрос, содержащий мандат для данного сервера приложения и данные для аутентификации (аналогичные
   данным для аутентификации обмена с TGS).],
  [Сервер приложения расшифровывает мандат собственным секретным ключом, получает оттуда Клиент-Сервер сессионный ключ,
   которым расшифровывает аутентификационные данные и подтверждает личность клиента],
  [Сервер возвращает сообщение, зашифрованное Клиент-Сервер сессионным ключом для подтверждения собственной личности.]
)

Таким образом был пошагово рассмотрен протокол аутентификации Kerberos. Исходный код программного продукта,
реализующего данный протокол представлен в приложении А.

#pagebreak()


#stp2024.heading_unnumbered[Заключение]
В ходе выполнения работы были изучены и реализованы основные принципы протокола Kerberos для идентификации и
аутентификации пользователей. На первом этапе была разработана программная логика центра распределения ключей (KDC),
включая генерацию мандата для получения мандатов (TGT) на основе симметричного шифрования с использованием временных
меток. Затем был реализован более сложный многоэтапный процесс аутентификации, где в качестве ключа применялись
долгосрочные секретные ключи пользователей и сервисов. Использование временных мандатов и шифрования сессионных ключей
позволило значительно повысить стойкость системы за счёт нейтрализации атак повторного воспроизведения и подмены,
характерных для простых методов аутентификации.

После реализации протокола было проведено тестирование на различных наборах данных. С помощью контрольных примеров
проверялась корректность процессов аутентификации и выдачи сервисных билетов: клиент, прошедший полный цикл
взаимодействия с KDC и сервером приложения, успешно получал доступ к ресурсам. 

В результате выполнения работы были успешно освоены основные элементы протокола Kerberos. Все цели, поставленные перед
началом лабораторной работы, были достигнуты: программные модули продемонстрировали полную работоспособность и
корректность криптографических преобразований. Были выполнены ключевые операции по генерации и проверке мандатов,
манипуляции временными метками и управлению сессионными ключами. Проверка результатов показала, что реализованный
протокол обеспечивает надёжную (в рамках симметричной криптографии) идентификацию и аутентификацию пользователей с
взаимной верификацией сторон.


#stp2024.appendix(type: [обязательное], title: [Листинг программного кода])[
  #stp2024.listing[Класс, реализующий роль клиента в Kerberos][
    ```
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
    ```
  ] 
  #stp2024.listing[Класс, реализующий роль сервера приложения в Kerberos][
    ```
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
    ```
  ] 

  #stp2024.listing[Класс, реализующий роль KDC в Kerberos][
    ```
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
    ```
  ] 
]
