#import "lib/stp2024.typ"
#include "title.typ"

#show: stp2024.template

#stp2024.full_outline()
#pagebreak()

= Цель работы
Целью данной лабораторной работы является изучение механизмов возникновения уязвимостей типа "переполнение буфера" в
различных областях памяти (стек и куча), а также освоение практических навыков разработки защищенного программного
обеспечения. В задачи работы входит исследование небезопасных функций языка программирования C, демонстрация
последствий эксплуатации ошибок переполнения и реализация защитных механизмов с использованием безопасных альтернатив
стандартных функций работы со строками.

Конечным результатом работы должно быть программное средство, наглядно демонстрирующее разницу между уязвимым и
защищенным кодом при манипуляции данными в памяти.

= Ход работы
В ходе выполнения работы было разработано программное обеспечение на языке C, реализующее четыре сценария работы с
памятью: два сценария для стека (уязвимый и безопасный) и два сценария для кучи (уязвимый и безопасный).

Переполнение буфера возникает, когда программа записывает данные за пределы выделенного блока памяти. Это может
привести к повреждению соседних данных, изменению логики выполнения программы или выполнению произвольного кода
злоумышленника.

== Переполнение буфера в стеке
Стек используется для хранения локальных переменных и адресов возврата функций. Переполнение в этой области особенно
опасно, так как позволяет перезаписать адрес возврата, передавая управление на вредоносный код.

#enum(
  [В уязвимой реализации использовалась функция strcpy, которая не проверяет длину копируемой строки относительно
  размера целевого буфера. При передаче строки, длина которой превышает 16 байт, происходит выход за границы массива
  buffer.],
  [В защищенной реализации была применена функция strncpy. Данная функция принимает в качестве аргумента максимальное
  количество байт для копирования, что предотвращает выход за пределы выделенной области. Дополнительно был явно
  добавлен терминальный нулевой символ для обеспечения корректности строки.]
)
Пример работы уязвимой и защищённой реализации представлен на рисунке @stack.
#figure(
  image("img/stack.png", width: 60%),
  caption: [Демонстрация переполнения стека],
)<stack>

== Переполнение буфера в куче
Куча (heap) используется для динамического выделения памяти во время выполнения программы с помощью функций malloc или
calloc. Хотя в куче отсутствуют адреса возврата функций, переполнение здесь может привести к перезаписи служебных
структур аллокатора или соседних объектов данных.

#enum(
  [Уязвимый пример демонстрирует, как при последовательном выделении двух блоков памяти переполнение первого блока
  приводит к модификации содержимого второго блока. Это было реализовано с помощью strcpy и длинной исходной строки.],
  [Для защиты кучи в работе была использована функция snprintf. Она является более современной и безопасной
  альтернативой, так как гарантирует запись не более указанного количества байт и всегда завершает строку нулевым
  символом, если размер буфера больше нуля.]
)
Пример работы уязвимой и защищённой реализации представлен на рисунке @heap.
#figure(
  image("img/heap.png", width: 60%),
  caption: [Демонстрация переполнения кучи и искажения данных в соседнем блоке],
)<heap>

== Анализ защитных механизмов
Помимо использования безопасных функций, современные операционные системы и компиляторы предоставляют системные уровни
защиты:
#list(
  [ASLR (Address Space Layout Randomization): Рандомизация расположения областей памяти затрудняет предсказание
  адресов для атаки.],
  [Stack Canaries: Специальные значения в стеке, проверка которых перед выходом из функции позволяет обнаружить факт
  переполнения.],
  [NX/DEP (No-Execute / Data Execution Prevention): Помечает области данных как неисполняемые, предотвращая запуск кода
  непосредственно из стека или кучи.]
)

В рамках данной работы основной акцент был сделан на уровне реализации прикладного кода, что является первым и наиболее
важным рубежом обороны.

#pagebreak()

#stp2024.heading_unnumbered[Заключение]
В ходе выполнения лабораторной работы были детально изучены причины и последствия возникновения ошибок переполнения
буфера в стеке и куче. Экспериментальным путем было подтверждено, что использование устаревших функций, таких как
strcpy, представляет серьезную угрозу безопасности, так как они полностью полагаются на корректность входных данных и
не выполняют проверку границ.

Реализованные "безопасные" версии функций продемонстрировали устойчивость к попыткам записи избыточного объема данных.
Использование strncpy и snprintf позволило ограничить запись размером выделенного буфера, сохранив целостность
окружающих данных в памяти.

В результате работы были достигнуты все поставленные цели: разработано демонстрационное программное средство, проведен
сравнительный анализ подходов к работе с памятью и освоены методы предотвращения распространенных уязвимостей. Данный
опыт является критически важным для разработки системного и сетевого программного обеспечения, где ошибки управления
памятью остаются одной из наиболее часто эксплуатируемых категорий уязвимостей.

#pagebreak()

#stp2024.appendix(type: [обязательное], title: [Листинг программного кода])[
  #stp2024.listing[Исходный код программы демонстрации переполнения буфера][
    ```
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void vulnerable_stack_demo() {
  char buffer[16];
  char *secret_data = "SENSITIVE_STACK_DATA";
  char *overflow_source = "This string is way longer than sixteen bytes!";

  printf("
--- Vulnerable Stack Overflow Demo ---
");
  printf("Buffer address: %p
", (void *)buffer);
  printf("Secret data address: %p
", (void *)secret_data);
  printf("Secret data before: %s
", secret_data);

  strcpy(buffer, overflow_source);

  printf("Buffer content: %s
", buffer);
}

void safe_stack_demo() {
  char buffer[16];
  char *secret_data = "SENSITIVE_STACK_DATA";
  char *overflow_source = "This string is way longer than sixteen bytes!";

  printf("
--- Safe Stack Demo (Using strncpy) ---
");
  printf("Buffer address: %p
", (void *)buffer);
  printf("Secret data address: %p
", (void *)secret_data);
  printf("Secret data before: %s
", secret_data);

  strncpy(buffer, overflow_source, sizeof(buffer) - 1);
  buffer[sizeof(buffer) - 1] = '\0';

  printf("Buffer content: %s
", buffer);
  printf("Secret data after:  %s
", secret_data);
}

void vulnerable_heap_demo() {
  char *buffer1 = (char *)malloc(16);
  char *buffer2 = (char *)malloc(16);
  char *overflow_source = "This string overflows buffer1 and hits buffer2!";

  if (buffer1 == NULL || buffer2 == NULL)
    return;

  strcpy(buffer2, "Original Heap Data");

  printf("
--- Vulnerable Heap Overflow Demo ---
");
  printf("Buffer1 address: %p
", (void *)buffer1);
  printf("Buffer2 address: %p
", (void *)buffer2);
  printf("Buffer2 before overflow: %s
", buffer2);

  strcpy(buffer1, overflow_source);

  printf("Buffer1 content: %s
", buffer1);
  printf("Buffer2 after overflow:  %s
", buffer2);

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

  printf("
--- Safe Heap Demo (Using snprintf) ---
");
  printf("Buffer1 address: %p
", (void *)buffer1);
  printf("Buffer2 address: %p
", (void *)buffer2);
  printf("Buffer2 before demo: %s
", buffer2);

  snprintf(buffer1, 16, "%s", overflow_source);

  printf("Buffer1 content: %s
", buffer1);
  printf("Buffer2 after demo:  %s
", buffer2);

  free(buffer1);
  free(buffer2);
}

int main(int argc, char *argv[]) {
  int choice = 0;

  if (argc > 1) {
    choice = atoi(argv[1]);
  } else {
    printf("Lab 5: Buffer Overflow Protection
");
    printf("1. Vulnerable Heap Demo
");
    printf("2. Safe Heap Demo
");
    printf("3. Vulnerable Stack Demo (CAUTION: Likely to crash)
");
    printf("4. Safe Stack Demo
");
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
    printf("Invalid choice.
");
    break;
  }

  return 0;
}
    ```
  ]
]
