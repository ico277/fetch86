#include <stdio.h>
#include <stdint.h>

uint32_t sdbm_hash(char*);

int main(int argc, char** argv) {
    for (size_t i = 1; i < argc; i++) {
        char* arg = argv[i];
        printf("'%s'\t0x%08X\n", arg, sdbm_hash(arg));
    } 
    return 0;
}
