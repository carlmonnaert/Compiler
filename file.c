int both_positive(int a, int b) {
    if (a > 0 && b > 0) {
        return 1; // Retourne 1 si a et b sont tous deux positifs
    }
    return 0;
}

int either_positive(int a, int b) {
    if (a > 0 || b > 0) {
        return 1; // Retourne 1 si au moins l'un des deux est positif
    }
    return 0;
}

int main() {
    print_int(both_positive(3, 4));    // Devrait afficher 1 (les deux positifs)
    print_int(both_positive(3, -4));   // Devrait afficher 0 (l'un est négatif)
    print_int(either_positive(3, -4)); // Devrait afficher 1 (un est positif)
    print_int(either_positive(-3, -4)); // Devrait afficher 0 (aucun n'est positif)
    return 0;
}
