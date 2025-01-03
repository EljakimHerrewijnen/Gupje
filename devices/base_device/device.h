
void send(void *buffer, uint32_t size, uint32_t *num_xfer){
    // TODO implement
}

int recv(void *buffer, uint32_t size, uint32_t *num_xfer){
    // TODO implement
    return 0;
}

void recv_data(void *data, uint32_t len) {
    uint32_t rx_err_code;
    uint32_t xfer = 0;
    while(1) {
        recv(data, len, &xfer);
        if(xfer >= len) {
            break;            
        }
    }
}

int mystrlen(char *data) {
    int i=0;
    while(1) {
        if(data[i++] == '\0'){
            break;
        }
    }
    return i-1;
}

void usb_log(char * msg, uint32_t * error){
    send(msg, mystrlen(msg), error);
}

void concrete_main(uint32_t debugger){
    // TODO device specific code
}