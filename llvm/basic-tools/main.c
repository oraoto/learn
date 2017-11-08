#include <stdio.h>

extern int add(int);

int main() {
    int a= add(2);
    printf("%d\n", a);
    return 0;
}

// Convert to LLVM bitcode: clang -emit-llvm -c main.c

// Link: llvm-link main.bc add.bc -o output.bc

// Run: lli output.bc

// Compile to asm: llc output.bc -o output.s