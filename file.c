int test_continue_after_instruction() {
    int i = 0;
    while (i < 5) {
        i = i + 1;
        print_int(i);  // Affiche i avant le continue
        if (i == 3) {
            continue;  // Ignore la suite de la boucle lorsque i == 3
        }
        print_int(i * 10);  // Cette ligne est ignorée lorsque i == 3
    }
    return 0;
}



int main() {
    test_continue_after_instruction();
    return 0;
}