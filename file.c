int x;  // Déclaration de la variable globale x
int y;  // Déclaration de la variable globale y

int main() {
    // Affectation de valeurs initiales aux variables
    x = 5;
    y = 20;
    
    // Affichage des valeurs de x et y
    print_int(x);  // Affiche la valeur de x (5)
    print_int(y);  // Affiche la valeur de y (20)
    
    // Modification des variables
    x = x + 10;  // x devient 15
    y = y - 5;   // y devient 15
    
    // Affichage des nouvelles valeurs
    print_int(x);  // Affiche la valeur de x (15)
    print_int(y);  // Affiche la valeur de y (15)
    
    return 0;
}
