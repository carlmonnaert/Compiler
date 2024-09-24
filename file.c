int x;
int y;
int f(int a) {
    y = 42 + 2 *a;
    return y;
}
int main(int argc) {
    x = f(4);
    print(x);
}