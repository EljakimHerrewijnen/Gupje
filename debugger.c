#include <stdint.h>
#include "device.h"


// These functions must be included in your device.h and device.c files
// extern void send(void*addr, uint32_t size, void *return_addr); //from device to host
// extern int recv(void *data, uint32_t len, uint32_t max_len, uint32_t *err_code, uint32_t type); //from host to device
// extern void recv_data(void *data, uint32_t len);
// extern int mystrlen(char *data);
// extern void usb_log(char * msg, uint32_t * error);

#if INTPTR_MAX == INT32_MAX
    #define BIT32
#elif INTPTR_MAX == INT64_MAX
    #define BIT64
#else
    #error "Environment not 32 or 64-bit."
#endif

#ifdef __aarch64__
#include "debugger_archs/ga_arm64.h"
#elif __arm__
#include "debugger_archs/ga_arm.h"
#elif __thumb__
#include "debugger_archs/ga_arm_thumb.h"
#else
#error "Unsupported architecture"
#endif

#ifdef GLITCH_ENABLE
#include "glitch_handler.h"
#endif

// Functions that are implemented in assembly, based on the architecture
extern void restore_and_jump();
extern void debugger_dump_special_regs();
extern void sync_debugger();
extern void debugger_sync_special_regs();
extern void restore_and_return();

extern int debugger_storage;

// Custom block sizes should be somewhat supported.
#ifdef GUPJE_BLOCK_SIZE
#else
#define GUPJE_BLOCK_SIZE 0x100
#endif


__attribute__((section(".init")))
int debugger_main(void){
    #ifdef DEVICE_SETUP
    #ifdef BIT64
    uint64_t *val = (uint64_t *)((uint64_t)debugger_storage);

    // 0xfc0
    if(val[504] == (uint64_t)0x77){
        void (*custom_func)() = (void*)val[505]; //0xfc8
        // custom_func();
    }
    else{
        device_setup();
    }
    #endif
    // TODO other architectures
    #endif

    #ifdef BIT64
    uint64_t mem_off;
    #else
    uint32_t mem_off;
    #endif
    uint32_t tx_err_code;
    uint32_t mem_sz;
    uint32_t blk_sz;
    char cmd[12];
    char data[0x20];
    usb_log("GiAs", &tx_err_code);

    while(1){
        recv_data(&data, 4);
        // PING, PEEK, HWIO, POKE, SELF, MAIN, FLUSH, JUMP, SYNC, SYNS, SPEC, ERET, REST, RET, TEST
        if(data[0] == 'P' && data[1] == 'I' && data[2] == 'N' && data[3] == 'G'){
            data[1] = 'O';
            send(&data, 4, &tx_err_code);
        }
        else if(data[0] == 'P' && data[1] == 'E' && data[2] == 'E' && data[3] == 'K') {
            // PEEK, dump memory
            recv_data(&data, 12); // Receive uint64_t size and and uint32_t offset
            #ifdef BIT64
            mem_off = *(uint64_t *)data;
            mem_sz = *(uint32_t *)(data+8);
            #else
            // For ARM and Thumb Mode
            // Receive uint32_t size and and uint32_t offset
            mem_off = *(uint32_t *)data;
            mem_sz = *(uint32_t *)(data+4);
            #endif

            for(unsigned int i=0;i<=mem_sz;i+=GUPJE_BLOCK_SIZE) {
                if((mem_sz - i) < GUPJE_BLOCK_SIZE) {
                    blk_sz = mem_sz - i;
                } else {
                    blk_sz = GUPJE_BLOCK_SIZE;
                }
                send((void *)(mem_off+i), blk_sz, &tx_err_code);
                recv_data(&data, 4);
                if(!(data[0] == 'A' && data[1] == 'C' && data[2] == 'K')) {
                    break;
                }
            }
        }
        else if(data[0] == 'H' && data[1] == 'W' && data[2] == 'I' && data[3] == 'O') {
            //HWIO, write byte by byte
            recv_data(&data, 0x20); 
            mem_off = *(uint32_t *)data;
            mem_sz = *(uint32_t *)(data+8);
            // Data is stored in the rest of the data buffer
            // No error checking on size, be carefull!
            for(unsigned int i=0;i<mem_sz;i++) {
                *((uint8_t *)(mem_off+i)) = data[12+i];
            }
            usb_log("OK", &tx_err_code);
        }
        else if(data[0] == 'P' && data[1] == 'O' && data[2] == 'K' && data[3] == 'E') {
            #ifdef BIT64
            recv_data(&data, 12); // Receive uint64_t size and and uint32_t offset
            mem_off = *(uint64_t *)data;
            mem_sz = *(uint32_t *)(data+8);
            #else
            // For ARM and Thumb mode
            recv_data(&data, 12); // Receive uint32_t size and and uint32_t offset
            mem_off = *(uint32_t *)data;
            mem_sz = *(uint32_t *)(data+4);
            #endif

            for(unsigned int i=0;i < mem_sz; i += GUPJE_BLOCK_SIZE) {
                if((mem_sz - i) < GUPJE_BLOCK_SIZE) {
                    blk_sz = mem_sz - i;
                } else {
                    blk_sz = GUPJE_BLOCK_SIZE;
                }
                recv_data((void *) (mem_off + i), blk_sz);
                usb_log("OK", &tx_err_code);
                recv_data(&data, 4);

                if(!(data[0] == 'A' && data[1] == 'C' && data[2] == 'K')) {
                    break;
                }
            }
        }
        else if(data[0] == 'S' && data[1] == 'E' && data[2] == 'L' && data[3] == 'F') {
            #ifdef BIT64
            mem_off = (uint64_t) &debugger_main;
            #else
            mem_off = (uint32_t) &debugger_main;
            #endif
            send(&mem_off, sizeof(mem_off), &tx_err_code);
        }
        else if(data[0] == 'M' && data[1] == 'A' && data[2] == 'I' && data[3] == 'N') {
            #ifdef BIT64
            mem_off = (uint64_t) &debugger_main;
            #else
            mem_off = (uint32_t) &debugger_main;
            #endif
            concrete_main(mem_off);
        }
        else if(data[0] == 'F' && data[1] == 'L' && data[2] == 'S' && data[3] == 'H') {
            // TODO, flush specific cache (code/data)
            #ifdef BIT64
            cache_flush();
            #else
            // Todo for ARM and Thumb
            #endif
        }
        else if(data[0] == 'J' && data[1] == 'U' && data[2] == 'M' && data[3] == 'P') {
            //JUMP == jump to function using provided pointer
            #ifdef BIT64
            recv_data(&data, 8);
            mem_off = *(uint64_t *)data;
            void (*custom_func)() = (void*)mem_off; //mem_off;
            custom_func();
            #else
            recv_data(&data, 4);
            mem_off = *(uint32_t *)data;
            void (*custom_func)() = (void*)mem_off; //mem_off;
            custom_func();
            #endif
        }
        else if(data[0] == 'S' && data[1] == 'Y' && data[2] == 'N' && data[3] == 'C') {
            //SYNC: Synchronize registers from memory with actual registers
            sync_debugger();
        }
        else if(data[0] == 'S' && data[1] == 'Y' && data[2] == 'N' && data[3] == 'S') {
            //SYNS: Synchronize special registers
            debugger_sync_special_regs();
        }
        else if(data[0] == 'S' && data[1] == 'P' && data[2] == 'E' && data[3] == 'C') {
            //SPEC dump special registers
            debugger_dump_special_regs();
        }
        else if(data[0] == 'E' && data[1] == 'R' && data[2] == 'E' && data[3] == 'T') {
            #ifdef __aarch64__
            __asm__ __volatile__("ERET\n\t");
            #endif
        }
        else if(data[0] == 'R' && data[1] == 'E' && data[2] == 'S' && data[3] == 'T') {
            //REST restore stack and jump
            restore_and_jump();
        }
        else if(data[0] == 'R' && data[1] == 'R' && data[2] == 'E' && data[3] == 'T') {
            // TODO Remove or change?
            restore_and_return();
            return 0;
        }
        else if(data[0] == 'T' && data[1] == 'E' && data[2] == 'S' && data[3] == 'T') {
            // Implement any test function here
            #ifdef __aarch64__
            __asm__ __volatile__("SVC 0x0\n\t");
            // disable_mmu();
            #endif
        }
        #ifdef GLITCH_ENABLE
        else if(data[0] == 'G' && data[1] == 'L' && data[2] == 'I' && data[3] == 'T') {
            #ifdef __aarch64__
            mem_off = (uint64_t) &debugger_main;
            #else
            mem_off = (uint32_t) &debugger_main;
            #endif
            glitch_main(mem_off);
        }
        #endif
    }
    return 0;
}

int main(void){
    debugger_main();
    return 0;
}