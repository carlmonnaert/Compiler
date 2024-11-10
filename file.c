
// Fonction de test de la factorielle
int factorial(int n) {
    if (n <= 1) {
        return 1;
    } else {
        return n * factorial(n - 1);
    }
}

// Fonction de test pour le calcul de la puissance
int power(int base, int exp) {
    if (exp == 0) {
        return 1;
    } else {
        return base * power(base, exp - 1);
    }
}

// Fonction de test pour le calcul de la suite de Fibonacci
int fibonacci(int n) {
    if (n <= 1) {
        return n;
    } else {
        return fibonacci(n - 1) + fibonacci(n - 2);
    }
}

// Fonction de test pour vérifier si un nombre est pair
int is_even(int n) {
    if (n == 0) {
        return 1;
    } else {
        return is_odd(n - 1);
    }
}

// Fonction de test pour vérifier si un nombre est impair
int is_odd(int n) {
    if (n == 0) {
        return 0;
    } else {
        return is_even(n - 1);
    }
}

// Fonction pour calculer la somme des chiffres d'un nombre
int sum_of_digits(int n) {
    if (n == 0) {
        return 0;
    } else {
        return (n % 10) + sum_of_digits(n / 10);
    }
}

// Fonction pour tester si un nombre est un palindrome (en utilisant la récurrence)
int is_palindrome_helper(int n, int temp) {
    if (n == 0) {
        return temp;
    } else {
        return is_palindrome_helper(n / 10, temp * 10 + (n % 10));
    }
}

int is_palindrome(int n) {
    if (n == is_palindrome_helper(n, 0)) {
        return 1;
    } else {
        return 0;
    }
}

int main() {
    // Tests des fonctions récursives

    print_int(factorial(5));  // 120
    print_int(factorial(0));  // 1


    print_int(power(2, 3));  // 8
    print_int(power(5, 0));  // 1

    print_int(fibonacci(6));  // 8
    print_int(fibonacci(7));  // 13


    print_int(is_even(4));  // 1 (true)
    print_int(is_even(7));  // 0 (false)
    print_int(is_odd(4));   // 0 (false)
    print_int(is_odd(7));   // 1 (true)

 
    print_int(sum_of_digits(123));  // 6
    print_int(sum_of_digits(999));  // 27


    print_int(is_palindrome(121));  // 1 (true)
    print_int(is_palindrome(123));  // 0 (false)

    return 0;
}
