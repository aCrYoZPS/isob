from pathlib import Path


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


def main():
    plaintext = input("Текст для шифрования:")
    key = int(input("Ключ:"))
    encrypted_text = Caesar.chipher(plaintext, key)
    print(f"Зашифрованный текст: {encrypted_text}")
    print(f"Расшифрованный текст: {Caesar.dechipher(encrypted_text, key)}")

    # p_t = "посольство Венгрии"
    # key = 17
    # v_key = "Будапешт"
    # c_t = Caesar.chipher(p_t, key)
    # n_p_t = Caesar.dechipher(c_t, key)
    # print(c_t)
    # print(n_p_t)
    #
    # c_t = Vigenere.chipher(p_t, v_key)
    # n_p_t = Vigenere.dechipher(c_t, v_key)
    # print(c_t)
    # print(n_p_t)


if __name__ == "__main__":
    main()
