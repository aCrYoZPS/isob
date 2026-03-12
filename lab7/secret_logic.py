fibonacci_mem = [0, 1]


def calculate_nth_fibonacci(n):
    """Calculate the n-th Fibonacci number using recursion."""
    if len(fibonacci_mem) > n:
        return fibonacci_mem[n]
    cur_len = len(fibonacci_mem)
    while cur_len <= n:
        fibonacci_mem.append(fibonacci_mem[cur_len - 2] + fibonacci_mem[cur_len - 1])
        cur_len = len(fibonacci_mem)

    return fibonacci_mem[n]


def main():
    print("Welcome to the Secret Fibonacci Calculator!")
    user_input = 10
    result = calculate_nth_fibonacci(user_input)
    print(f"The result for {user_input} is: {result}")


if __name__ == "__main__":
    main()
