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
_Python_, осуществляющее шифрование и дешифрование текстовых файлов шифрами Цезаря и Виженера.

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

Исходный код класса, реализующего шифр Цезаря представлен в листинге @caesar_code.

#stp2024.listing[Реализация шифра Цезаря на _Python_][
```
class Caesar:
    alphabets: list = [
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

    @classmethod
    def chipher_file(cls, source_file_name: str, key: int, target_file_name: str | None = None):
        with open(source_file_name, "r") as f:
            content = f.read()

        encrypted_text = cls.chipher(content, key)

        if target_file_name is None:
            p = Path(source_file_name)
            target_file_name = f"{p.stem}_encrypted{p.suffix}"

        with open(target_file_name, "w") as f:
            f.write(encrypted_text)

    @classmethod
    def dechipher_file(cls, source_file_name: str, key: int, target_file_name: str | None = None):
        with open(source_file_name, "r") as f:
            content = f.read()

        decrypted_text = cls.dechipher(content, key)

        if target_file_name is None:
            p = Path(source_file_name)
            target_file_name = f"{p.stem}_decrypted{p.suffix}"

        with open(target_file_name, "w") as f:
            f.write(decrypted_text)
```
]
<caesar_code>

Результат работы данной программы представлен на рисунке @caesar_result.

#figure(
  caption: [Результат работы программы, реализующей шифр Виженера],
  image(
    width: 70%,
    "img/caesar_result.png"
  )
) <caesar_result>

Таким образом была показана работоспособность программного средства, а также была проверена правильность выполнения
шифрования и дешифрования шифром Цезаря.

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
Виженера состоит в том, что его ключ повторяется, то есть для исходного текста длины _n_ ключ длины 
_m_ будет повторён $ceil(n/m)$ раз, последнее из повторений может быть неполным.

Исходный код класса, реализующего шифр Виженера представлен в листинге @vigenere_code.

#stp2024.listing[Реализация шифра Виженера на _Python_][
  ```
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

    @classmethod
    def chipher_file(cls, source_file_name: str, key: str, target_file_name: str | None = None):
        with open(source_file_name, "r") as f:
            content = f.read()

        encrypted_text = cls.chipher(content, key)

        if target_file_name is None:
            p = Path(source_file_name)
            target_file_name = f"{p.stem}_encrypted{p.suffix}"

        with open(target_file_name, "w") as f:
            f.write(encrypted_text)

    @classmethod
    def dechipher_file(cls, source_file_name: str, key: str, target_file_name: str | None = None):
        with open(source_file_name, "r") as f:
            content = f.read()

        decrypted_text = cls.dechipher(content, key)

        if target_file_name is None:
            p = Path(source_file_name)
            target_file_name = f"{p.stem}_decrypted{p.suffix}"

        with open(target_file_name, "w") as f:
            f.write(decrypted_text)

  ```
] <vigenere_code>

Результат работы данной программы представлен на рисунке @vigenere_result.

#figure(
  caption: [Результат работы программы, реализующей шифр Виженера],
  image(
    width: 70%,
    "img/vigenere_result.png"
  )
) <vigenere_result>

Таким образом была показана работоспособность программного средства, а также была проверена правильность выполнения
шифрования и дешифрования шифром Виженера.

#pagebreak()


#stp2024.heading_unnumbered[Заключение]
В ходе выполнения работы были изучены и реализованы классические алгоритмы симметричного шифрования — шифр Цезаря и
шифр Виженера. На первом этапе была разработана программная логика для шифра Цезаря, основанная на циклическом сдвиге
алфавита на фиксированный ключ. Затем был реализован более сложный многоалфавитный шифр Виженера, где в качестве ключа
использовалось кодовое слово. Использование ключевой фразы позволило значительно повысить криптостойкость системы за 
счёт нейтрализации частотного анализа, характерного для простых моноалфавитных подстановок.

После реализации алгоритмов было проведено тестирование на различных наборах данных. С помощью контрольных примеров
проверялась корректность процессов зашифрования и расшифрования: текст, прошедший полный цикл преобразований, полностью
соответствовал исходному сообщению. Особое внимание было уделено обработке пограничных случаев, таких как использование
символов в разных регистрах, пробелов и знаков препинания, что подтвердило стабильность работы алгоритмов в различных условиях.

В результате выполнения работы были успешно освоены основные элементы классической криптографии. Все цели, поставленные
перед началом лабораторной работы, были достигнуты: программные модули продемонстрировали полную работоспособность и
корректность математических преобразований. Были выполнены ключевые операции по манипуляции алфавитными индексами и
работе с циклическими сдвигами. Проверка результатов показала, что реализованные методы обеспечивают надёжную (в рамках
данных алгоритмов) передачу зашифрованной информации и её точное восстановление при наличии верного ключа.
