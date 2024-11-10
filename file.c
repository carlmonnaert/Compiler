int a;

int test(int* a){
    *a = 10;
    return 0;
}


int main() {
    int* ptr;
    ptr = &a;
    test(ptr);
    print_int(a);
    

    return 0;
}
