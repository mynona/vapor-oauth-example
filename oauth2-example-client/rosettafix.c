// clang rosettafix.c -O2 -shared -o /usr/local/lib/rosettafix.so
// echo '/usr/local/lib/rosettafix.so' > /etc/ld.so.preload

extern void *dlsym(void * __restrict, const char * __restrict);

void __attribute__((constructor)) overrideSwift(int argc, const char **argv) {
    void (* __attribute__((swiftcall)) sym)(const char **, int) =
        dlsym(0L, "_swift_stdlib_overrideUnsafeArgvArgc");
    if (sym) {
        (*sym)(argv, argc);
    }
}