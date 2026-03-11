#import "lib/stp2024.typ"
#include "title.typ"

#show: stp2024.template

#stp2024.full_outline()
#pagebreak()

= Цель работы
Целью данной лабораторной работы является изучение и реализация методов защиты от сетевых атак, направленных на 
исчерпание ресурсов при установке TCP-соединений и на прикладном уровне. Задачи включают изучение механизмов
ограничения частоты запросов (Rate Limiting) и алгоритмов доказательства выполнения работы (Proof of Work), 
проектирование и программную реализацию защищённого сервера и клиента, а также тестирование устойчивости системы
к имитируемой атаке.

Конечным результатом лабораторной работы является программная система, состоящая из сервера с многоуровневой защитой,
легитимного клиента и атакующего скрипта, демонстрирующая эффективность применённых мер.

= Ход работы
В ходе выполнения работы была разработана программная система на языке Python, реализующая механизмы защиты от DoS-атак.
Система включает в себя три основных компонента:
#enum(
[Сервер, осуществляющий мониторинг входящих соединений, ограничение частоты запросов по IP-адресу и проверку
доказательства выполнения работы (PoW) перед предоставлением доступа к ресурсу.],
[Клиент, способный корректно взаимодействовать с протоколом защиты, включая решение криптографических задач (PoW),
выдаваемых сервером.],
[Атакующий (скрипт), имитирующий многопоточную атаку на сервер с целью обхода или исчерпания его ресурсов.]
)

Процесс установления защищённого соединения включает следующие этапы:
1. Предварительная проверка (Rate Limiting).
2. Выдача и решение криптографической задачи (PoW).
3. Верификация решения и предоставление доступа.


== Ограничение частоты запросов (Rate Limiting)
Первым эшелоном защиты является механизм ограничения частоты запросов. Для каждого входящего IP-адреса сервер
хранит историю меток времени последних подключений. Если количество запросов от одного IP за определённое временное
окно (например, 10 секунд) превышает заданный лимит, сервер немедленно разрывает соединение с ошибкой. Данный метод
эффективен против простых атак перебором и примитивных попыток затопления трафиком (flooding) с одного адреса.
Фрагмент журнала событий сервера при попытке атаки представлен на рисунке @rate_limit.

#figure(
  image("img/rate_limit_log.png", width: 73%),
  caption: [Логи сервера при ограничении частоты запросов],
) <rate_limit>

== Доказательство выполнения работы (Proof of Work)
Для защиты от более сложных атак и распределённых запросов используется механизм PoW на основе алгоритма SHA-256.
Процесс реализован следующим образом:
#enum(
  [Сервер генерирует случайный токен (challenge) и отправляет его клиенту вместе с параметром сложности (количеством
   требуемых нулевых битов в начале хеша).],
  [Клиент должен найти такое число (nonce), чтобы хеш от конкатенации челленджа и этого числа удовлетворял условию
   сложности.],
  [Сервер проверяет полученное решение за константное время, в то время как поиск решения требует от клиента
   значительных вычислительных затрат.],
)
Процесс решения задачи клиентом представлен на рисунке @pow.
#figure(
  image("img/pow.png", width: 80%),
  caption: [Процесс решения криптографической задачи клиентом],
)<pow>

Использование PoW вынуждает атакующего тратить вычислительные ресурсы на каждое соединение, что делает атаку экономически
невыгодной или технически невозможной при больших масштабах.

== Тестирование системы
Для проверки эффективности защиты был использован скрипт-атакующий, запускающий 20 параллельных потоков для агрессивного
подключения к серверу. 
#list(
[Механизм Rate Limiting успешно заблокировал попытки превышения лимита запросов с одного IP-адреса.],
[Механизм PoW обеспечил защиту от быстрой обработки запросов, так как каждое соединение требовало времени на вычисления.],
[Легитимный клиент, выполняющий все требования протокола, успешно получал доступ к ресурсу после решения задачи.]
)

Исходный код программных модулей представлен в приложении А.

#pagebreak()

#stp2024.heading_unnumbered[Заключение]
В ходе выполнения лабораторной работы были изучены и практически реализованы ключевые методы защиты сетевых сервисов
от атак при установке соединений. Реализованная комбинация Rate Limiting и Proof of Work показала высокую эффективность
в противодействии попыткам исчерпания ресурсов сервера.

На первом этапе был внедрён механизм ограничения частоты запросов, который позволил отсечь избыточную нагрузку от
отдельных узлов сети. Второй этап — внедрение PoW — позволил защитить прикладной уровень от автоматизированных запросов,
перекладывая вычислительную нагрузку на сторону клиента. Это создаёт асимметрию затрат: проверка решения сервером
практически мгновенна, тогда как генерация решения требует от клиента реальных затрат времени и энергии.

Результаты тестирования подтвердили работоспособность системы. Атаки, имитируемые многопоточным скриптом, были успешно
нейтрализованы, при этом сохранилась доступность сервиса для добросовестных пользователей. Все поставленные цели были
достигнуты, а реализованные механизмы продемонстрировали надёжность и масштабируемость в рамках учебной задачи.

#stp2024.appendix(type: [обязательное], title: [Листинг программного кода])[
  #stp2024.listing[Реализация защищённого сервера][
    ```
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
    try:
        if is_rate_limited(ip):
            conn.sendall(b"ERROR: Rate limit exceeded. Try again later.")
            return

        challenge = secrets.token_hex(16)
        conn.sendall(f"CHALLENGE:{challenge}:{DIFFICULTY}".encode())

        conn.settimeout(CONN_TIMEOUT)
        data = conn.recv(1024).decode().strip()

        if data.startswith("SOLVE:"):
            nonce = data.split(":")[1]
            if verify_pow(challenge, nonce):
                conn.sendall(b"SUCCESS: Welcome to the protected resource!")
            else:
                conn.sendall(b"ERROR: Invalid PoW solution.")
    finally:
        conn.close()

def start_server():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(('0.0.0.0', PORT))
    server.listen(100)
    while True:
        conn, addr = server.accept()
        threading.Thread(target=handle_client, args=(conn, addr), daemon=True).start()
    ```
  ]

  #stp2024.listing[Реализация легитимного клиента][
    ```
import socket
import hashlib
import time

def solve_pow(challenge, difficulty):
    prefix = '0' * int(difficulty)
    nonce = 0
    while True:
        res = hashlib.sha256(f"{challenge}{nonce}".encode()).hexdigest()
        if res.startswith(prefix):
            return str(nonce)
        nonce += 1

def run_client():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(('127.0.0.1', 65432))
    resp = s.recv(1024).decode().strip()
    if "CHALLENGE" in resp:
        parts = resp.split(":")
        nonce = solve_pow(parts[1], parts[2])
        s.sendall(f"SOLVE:{nonce}".encode())
        print(f"Server response: {s.recv(1024).decode()}")
    s.close()
    ```
  ]

  #stp2024.listing[Реализация атакующего скрипта][
    ```
import socket
import threading
import time

def attack_once(thread_id):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(('127.0.0.1', 65432))
        resp = s.recv(1024).decode().strip()
        time.sleep(1)
    finally:
        s.close()

def run_attack():
    threads = []
    for i in range(20):
        t = threading.Thread(target=attack_once, args=(i,))
        threads.append(t)
        t.start()
        time.sleep(0.05)
    for t in threads: t.join()
    ```
  ]
]
