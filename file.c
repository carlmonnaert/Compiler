int complex_check(int a, int b) {
    if ((a > 0 && b < 0) || (! (a == 0) && b > -10)) {
        return 1; // Retourne 1 si l'une des conditions est remplie
    }
    return 0; // Sinon, retourne 0
}

int main() {
    print_int(complex_check(10, -3));   // Devrait afficher 1 (a est positif et b est négatif)
    print_int(complex_check(0, -5));    // Devrait afficher 0 (a == 0, donc aucune condition remplie)
    print_int(complex_check(-10, -20)); // Devrait afficher 0 (aucune condition remplie)
    print_int(complex_check(0, 5));     // Devrait afficher 0 (a est positif, mais b n'est pas négatif)
    print_int(complex_check(2, -8));    // Devrait afficher 1 (a est positif et b est négatif)
    return 0;
}
