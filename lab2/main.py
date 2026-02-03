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
        pass

    @classmethod
    def chipher(cls, plaintext: str, key: int) -> str:
        return cls.__inner_chipher(plaintext, key)

    @classmethod
    def dechipher(cls, chiphered_text: str, key: int) -> str:
        return cls.__inner_chipher(chiphered_text, key, "dechipher")


class Visener:
    @classmethod
    def chipher(cls, plaintext: str, key: str) -> str:
        pass

    def dechipher(cls, chiphered_text: str, key: str) -> str:
        pass


def main():
    p_t = "эЁюя aBc"
    key = 1
    c_t = Caesar.chipher(p_t, key)
    n_p_t = Caesar.dechipher(c_t, key)
    print(c_t)
    print(n_p_t)


if __name__ == "__main__":
    main()
