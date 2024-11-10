
void testCalculs() {
    int a = 8;
    int b = 4;
    int result;

    result = a + b;
    print_int(result);

    result = a - b;
    print_int(result);

    result = a * b;
    print_int(result);

    if (b != 0) {
        result = a / b;
        print_int(result);
    } else {
        print_int(0);  
    }
}

void testBool() {
    int a = 5;
    int b = 10;
    int c = 5;
    int result;

    if (a == c && b > a) {
        result = 1; // Vrai
    } else {
        result = 0; // Faux
    }
    print_int(result);

    if (a == c || b < a) {
        result = 1; // Vrai
    } else {
        result = 0; // Faux
    }
    print_int(result);

}

// Fonction qui teste l'incrémentation d'une variable
void incrementerCompteur() {
    int compteur = 0;
    compteur = compteur + 1 ;
    print_int(compteur);

    compteur = compteur + 1 ;
    print_int(compteur);

    compteur = compteur + 1 ;
    print_int(compteur);
}

void testFonctions() {
    testCalculs();
    testBool();
    incrementerCompteur();
}

int main() {
    testFonctions();
    return 0;
}