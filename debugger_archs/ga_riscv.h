#include <stdint.h>

static inline void invalidate_tlb(void)
{
    __asm__ __volatile__("sfence.vma x0, x0" ::: "memory");
}

static inline void sync(void)
{
    __asm__ __volatile__("fence iorw, iorw" ::: "memory");
}

static inline void iciallu(void)
{
    __asm__ __volatile__("fence.i" ::: "memory");
}

static inline void cache_flush(void)
{
    sync();
    iciallu();
    invalidate_tlb();
}
