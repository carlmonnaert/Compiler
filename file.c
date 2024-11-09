int test2(int x){
    return x+1;
}


int test(int x){
    return test2(x);
}

int main(int argc) {
    int z = test(5);
    print_int(z);
    return 0;
}