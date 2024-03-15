#include <stdio.h>

int main() {
    int *ptr; // Declare a pointer to an integer
    ptr = 34;
    //int num = 10; // Declare an integer variable

    //ptr = &num; // Assign the address of num to ptr

    // printf("Value of num: %d\n", num);
    // printf("Address of num: %p\n", &num);
    printf("Value of ptr: %p\n", ptr);
    printf("Value pointed by ptr: %d\n", *ptr);

    return 0;
}
