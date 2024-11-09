
int pow(int x, int y) {
    if(y <= 0) {
        print_int(x);
    }else{
        print_int(-x);
    }
    return 0;
}

int fact(int n) {
    if(n == 1) {
        return 1;
    }else{
        return n * fact(n-1);
    }
}



    int main() {
        if(1){
            print_int(1);
            if(1){
                print_int(2);
            }else{
                print_int(3);
            }
        }
        print_int(0);
        
        return 0;
    }
