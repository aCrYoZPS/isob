#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void vulnerable_stack_demo() {
  char buffer[16];
  char *secret_data = "SENSITIVE_STACK_DATA";
  char *overflow_source = "This string is way longer than sixteen bytes!";

  printf("\n--- Vulnerable Stack Overflow Demo ---\n");
  printf("Buffer address: %p\n", (void *)buffer);
  printf("Secret data address: %p\n", (void *)secret_data);
  printf("Secret data before: %s\n", secret_data);

  strcpy(buffer, overflow_source);

  printf("Buffer content: %s\n", buffer);
}

void safe_stack_demo() {
  char buffer[16];
  char *secret_data = "SENSITIVE_STACK_DATA";
  char *overflow_source = "This string is way longer than sixteen bytes!";

  printf("\n--- Safe Stack Demo (Using strncpy) ---\n");
  printf("Buffer address: %p\n", (void *)buffer);
  printf("Secret data address: %p\n", (void *)secret_data);
  printf("Secret data before: %s\n", secret_data);

  strncpy(buffer, overflow_source, sizeof(buffer) - 1);
  buffer[sizeof(buffer) - 1] = '\0';

  printf("Buffer content: %s\n", buffer);
  printf("Secret data after:  %s\n", secret_data);
}

void vulnerable_heap_demo() {
  char *buffer1 = (char *)malloc(16);
  char *buffer2 = (char *)malloc(16);
  char *overflow_source = "This string overflows buffer1 and hits buffer2!";

  if (buffer1 == NULL || buffer2 == NULL)
    return;

  strcpy(buffer2, "Original Heap Data");

  printf("\n--- Vulnerable Heap Overflow Demo ---\n");
  printf("Buffer1 address: %p\n", (void *)buffer1);
  printf("Buffer2 address: %p\n", (void *)buffer2);
  printf("Buffer2 before overflow: %s\n", buffer2);

  strcpy(buffer1, overflow_source);

  printf("Buffer1 content: %s\n", buffer1);
  printf("Buffer2 after overflow:  %s\n", buffer2);

  free(buffer1);
  free(buffer2);
}

void safe_heap_demo() {
  char *buffer1 = (char *)malloc(16);
  char *buffer2 = (char *)malloc(16);
  char *overflow_source = "This string overflows buffer1 and hits buffer2!";

  if (buffer1 == NULL || buffer2 == NULL)
    return;

  strcpy(buffer2, "Original Heap Data");

  printf("\n--- Safe Heap Demo (Using snprintf) ---\n");
  printf("Buffer1 address: %p\n", (void *)buffer1);
  printf("Buffer2 address: %p\n", (void *)buffer2);
  printf("Buffer2 before demo: %s\n", buffer2);

  snprintf(buffer1, 16, "%s", overflow_source);

  printf("Buffer1 content: %s\n", buffer1);
  printf("Buffer2 after demo:  %s\n", buffer2);

  free(buffer1);
  free(buffer2);
}

int main(int argc, char *argv[]) {
  int choice = 0;

  if (argc > 1) {
    choice = atoi(argv[1]);
  } else {
    printf("Lab 5: Buffer Overflow Protection\n");
    printf("1. Vulnerable Heap Demo\n");
    printf("2. Safe Heap Demo\n");
    printf("3. Vulnerable Stack Demo (CAUTION: Likely to crash)\n");
    printf("4. Safe Stack Demo\n");
    printf("Select option (1-4): ");
    if (scanf("%d", &choice) != 1)
      return 1;
  }

  switch (choice) {
  case 1:
    vulnerable_heap_demo();
    break;
  case 2:
    safe_heap_demo();
    break;
  case 3:
    vulnerable_stack_demo();
    break;
  case 4:
    safe_stack_demo();
    break;
  default:
    printf("Invalid choice.\n");
    break;
  }

  return 0;
}
