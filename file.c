int t[1000];
int b[1000];
int i;
int main() {
    i = 0;
    while(i < 1000) {
        t[i] = i;
        b[i] = i * 10;
        i = i + 1;
    }
    i = 0;
    while(i < 5) {
        print_int(t[i]);
        print_int(b[i]);
        i = i + 1;
    }
    
    return 0;
}
