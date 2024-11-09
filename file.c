int x;

int f(int a){
    x = 1;
    return 0;
}

int main() {
    print_int(x);
    f(0);
    print_int(x);

    return 0;
}
