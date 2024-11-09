int test2(int x){
    return x + 1;
}

int test(int x, int y){
    return test2(x+y);
}


int binop(int x, int y){
    int z ;
    z = x - y; 
    return test(z, y);
}


int main(int argc) {
    int z = binop(10, 30);
    print_int(z);
    return 0;
}