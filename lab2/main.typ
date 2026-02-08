#import "lib/stp2024.typ"
#include "title.typ"

#show: stp2024.template

#outline()
#pagebreak()

= Цель работы
Целью данной лабораторной работы является изучение базовых принципов
криптографии на примере простых алфавитных шифров: шифра Виженера и шифра Цезаря.
Задачи включают изучение шифров Цезаря и Виженера, проектирование и реализацию 
программного средства шифрования и дешифрования текстовых файлов при помощи шифров,
перечисленных выше и тестирование разработанного программного средства.

Конечным результатом данной лабораторной работы должна быть разработанная программа, осуществляющая
шифрование и дешифрование текстовых файлов указанными шифрами. 

= Ход работы
В ходе выполнения работы было создано программное средство на языке программирования
Python, осуществляющее шифрование и дешифрование текстовых файлов шифрами Цезаря и Виженера.

== Шифр Цезаря

Шифр Цезаря -- разновидность шифра подстановки, в котором каждый символ в открытом тексте
заменяется символом, находящимся на некоторое постоянное число позиций левее или правее него в алфавите.
К примеру при шифровании слова "шифр" с ключом 17 зашифрованный текст будет иметь вид "ищеб".
Принцип работы шифра Цезаря наглядно представлен на рисунке @caesar

#figure(
caption: [Принцип работы шифра Цезаря],
  image(
    width: 100%,
    "img/caesar.png"
  )
)<caesar>

== Шифр Виженера
Шифр Виженера -- разновидность шифра подстановки, в котором каждый символ в открытом тексте
заменяется символом, позиция которого в алфавите вычисляется с помощью соответствующей буквы
ключа. К примеру при шифровании фразы "посольство Венгрии" ключом "Будапешт" зашифрованный текст
будет иметь вид "рвхоыбйегв Ёеэзиый". На рисунке @vigenere представлен квадрат Виженера,
позволяющий облегчить ручное шифрование и расшифрование сообщений, зашифрованных шифром Виженера.

#figure(
  caption: [Квадрат Виженера],
  image(
    width: 70%,
    "img/vigenere.png"
  )
) <vigenere>

Шифр Виженера «размывает» характеристики частотностей появления символов в тексте,
но некоторые особенности появления символов в тексте остаются. Главный недостаток шифра 
Виженера состоит в том, что его ключ повторяется.

== Разработка программного средства
После изучения обоих метдов шифрования было разработано программное средство на языке
программирования Python. Его исходный код представлен в листинге.


```
class Caesar:
    alphabets: list[str] = [
        "abcdefghijklmnopqrstuvwxyz",
        "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
    ]

    @classmethod
    def __inner_chipher(cls, text: str, key: int, mode: str = "chipher"):
        result = ""
        if mode == "dechipher":
            key *= -1

        for c in text:
            found = False
            for alphabet in cls.alphabets:
                alphabet_lower = alphabet.lower()
                alphabet_upper = alphabet.upper()
                if c in alphabet_lower:
                    idx = alphabet_lower.index(c)
                    new_idx = (idx + key) % len(alphabet_lower)
                    result += alphabet_lower[new_idx]
                    found = True
                    break

                elif c in alphabet_upper:
                    idx = alphabet_upper.index(c)
                    new_idx = (idx + key) % len(alphabet_upper)
                    result += alphabet_upper[new_idx]
                    found = True
                    break

            if not found:
                result += c

        return result

    @classmethod
    def chipher(cls, plaintext: str, key: int) -> str:
        return cls.__inner_chipher(plaintext, key)

    @classmethod
    def dechipher(cls, chiphered_text: str, key: int) -> str:
        return cls.__inner_chipher(chiphered_text, key, "dechipher")


class Vigenere:
    @classmethod
    def chipher(cls, plaintext: str, key: str) -> str:
        return cls.__inner_chipher(plaintext, key)

    @classmethod
    def dechipher(cls, chiphered_text: str, key: str) -> str:
        return cls.__inner_chipher(chiphered_text, key, "dechipher")

    @classmethod
    def __inner_chipher(cls, text: str, key: str, mode: str = "chipher"):
        latin = "abcdefghijklmnopqrstuvwxyz"
        cyrillic = "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"

        latin_map = {char: index for index, char in enumerate(latin)}
        cyrillic_map = {char: index for index, char in enumerate(cyrillic)}

        result = []
        key_index = 0
        key = key.lower()

        def get_shift(k_char):
            if k_char in latin_map:
                return latin_map[k_char]
            elif k_char in cyrillic_map:
                return cyrillic_map[k_char]
            return 0

        for char in text:
            lower_char = char.lower()

            if lower_char in latin_map:
                alphabet = latin
                idx = latin_map[lower_char]
                mod = 26
            elif lower_char in cyrillic_map:
                alphabet = cyrillic
                idx = cyrillic_map[lower_char]
                mod = 33
            else:
                result.append(char)
                continue

            k_char = key[key_index % len(key)]
            shift = get_shift(k_char)

            if mode == 'chipher':
                new_idx = (idx + shift) % mod
            elif mode == 'dechipher':
                new_idx = (idx - shift) % mod
            else:
                raise ValueError("Mode must be 'chipher' or 'dechipher'")

            new_char = alphabet[new_idx]
            if char.isupper():
                new_char = new_char.upper()

            result.append(new_char)

            key_index += 1

        return "".join(result)


def main():
    p_t = "посольство Венгрии"
    key = 17
    v_key = "Будапешт"
    c_t = Caesar.chipher(p_t, key)
    n_p_t = Caesar.dechipher(c_t, key)
    print(c_t)
    print(n_p_t)

    c_t = Vigenere.chipher(p_t, v_key)
    n_p_t = Vigenere.dechipher(c_t, v_key)
    print(c_t)
    print(n_p_t)


if __name__ == "__main__":
    main()
```

#pagebreak()


#stp2024.heading_unnumbered[Заключение]
В ходе выполнения работы была разработана и настроена виртуальная компьютерная сеть в GNS3,
включающая два маршрутизатора, два коммутатора и 4 компьютера. Сначала была определена топология
сети, в которой два маршрутизатора подключены между собой, к каждому из них подключён коммутатор,
а к каждому коммутатору подключены 2 компьютера. Затем была настроена IP-адресация для всех
устройств, что включало назначение статических IP-адресов компьютерам и интерфейсам маршрутизаторов,
а также настройку шлюзов по умолчанию. Это обеспечило корректное разделение сети на две и возможность
маршрутизации между ними.

После настройки сети было проведено тестирование связи между
устройствами с использованием команд ping и trace. Эти команды позволили
проверить доступность устройств в разных сетях и проследить маршрут
прохождения пакетов между ними, выявив возможные проблемы в
маршрутизации или настройках сети. Результаты подтвердили, что все
устройства корректно обмениваются данными и маршрутизаторы правильно
передают пакеты между сетями.

В результате выполнения работы была успешно настроена
функциональная и стабильная сеть, обеспечивающая корректный обмен
данными между всеми устройствами. Все цели, поставленные перед началом выполненя лабораторной работы, были успешно достигнуты, и сеть продемонстрировала свою
работоспособность в плане маршрутизации пакетов. Были выполнены
основные операции по настройке IP-адресации и маршрутизации для
обеспечения взаимодействия между устройствами в разных сетях. Для
проверки работоспособности сети использовалась команда ping.
Результаты показали, что настроенная сеть функционирует корректно,
обеспечивая стабильную передачу данных между всеми компьютерами.
