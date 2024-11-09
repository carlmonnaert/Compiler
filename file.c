
int test(int x, int y, int z, int w) {
    return w;
}


int main(int argc) {
    int z = test(0, 1, 2, 3);
    print_int(z);
    return 0;
}