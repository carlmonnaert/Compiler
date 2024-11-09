int func1() {
    return 42;
}



int func3(int a) {
    return a * 2;
}




int func9(int a, int b) {
    int result;
    result = func3(a) + func3(b); 
    return result;
}



int func12(int a, int b) {
    return func9(func3(a), func3(b));  
}










int main(int argc) {
    print_int(func12(21, 21));
    return 0;
}