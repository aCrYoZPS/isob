class Caesar:
    @classmethod
    def chipher(cls, plaintext:str, key: int) -> str:
        result = ""
        for c in plaintext:
            result += chr((ord(c) + key))
        
        return result

    @classmethod
    def dechipher(cls, chiphered_text: str, key: int) -> str:
        result = ""
        for c in chiphered_text:
            result += chr(ord(c) - key)
        
        return result

class Visener:
    @classmethod
    def chipher(cls, plaintext: str, key:str) -> str:
        pass

    def dechipher(cls, chiphered_text: str, key:str) -> str:
        pass

def main():
    pass

if __name__ == "__main__":
    main()
