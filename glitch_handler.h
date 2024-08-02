#include <stdint.h>

extern void glitch_registers_loop();
extern void glitch_out_loop();

int glitch_main(uintptr_t cmd_handler){
    uint32_t tx_err_code;
    char data[0x20];
    usb_log("GlAs", &tx_err_code);  // Send glitcher magic

    while(1){
        recv_data(&data, 4);
        if(data[0] == 'P' && data[1] == 'I' && data[2] == 'N' && data[3] == 'G'){
            //PING
            data[1] = 'O';
            send(&data, 4, &tx_err_code);
        }
        if(data[0] == 'D' && data[1] == 'E' && data[2] == 'B' && data[3] == 'G'){
            //DEBG: Jump to debugger
            void (*debg)() = ((void *) cmd_handler);
            debg();
        }
        if(data[0] == 'S' && data[1] == 'E' && data[2] == 'T' && data[3] == 'P'){
            //SETP setup triggers
            setup_trigger();
        }
        if(data[0] == 'G' && data[1] == 'L' && data[2] == 'I' && data[3] == '1'){
            glitch_registers_loop();
        }
        if(data[0] == 'G' && data[1] == 'L' && data[2] == 'I' && data[3] == '2'){
            glitch_out_loop();
        }
    }   

    return 0;
}