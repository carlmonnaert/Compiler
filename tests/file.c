int x;
int y;
int f(int a) {
    int y;
    y = 42 + 2 * a;
    return y;
}
int main(int argc) {
    x = 42 + 1;
    y = f(42 + 6);
    print(y+x);
    return y;
}