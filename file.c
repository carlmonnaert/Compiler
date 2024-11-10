int main() {
    int i = -10;
    // La boucle s'exécute tant que i est inférieur à 0, i est incrémenté de 2 à chaque itération
    while (i < 0) {
        print_int(i);
        i = i + 2;  // i est incrémenté de 2
    }
    return 0;
}
