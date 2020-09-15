#include <stdio.h>
#include <stdint.h>

int main() {
    uint32_t n = 999999;
    for(; n != -1; --n) {
        printf("Hello, this is iteration number: %    d\n", n);
    }

    return 0;
}

