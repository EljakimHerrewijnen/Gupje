#include <unistd.h>

void invalidate_tlb()
{
    asm(
        "dsb sy\n"
        "tlbi alle3\n"
        "dsb sy\n"
        "isb\n"
    );
}

void sync()
{
    asm(
        "dsb sy\n"
        "isb\n"
    );
}

void iciallu(void)
{
    __asm__ __volatile__("ic iallu\n\t" : : :"memory");
    __asm__ __volatile__("ic ialluis\n\t" : : :"memory");
}

void cache_flush(){
    // invalidate_tlb();
    sync();
    iciallu();
}