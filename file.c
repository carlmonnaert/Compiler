
int f(int a){
    return g(a) + 3 ;
}

int g(int a){
    return a + 1;
}

int main(int argc) {
    print(f(5));


    return 0;
}