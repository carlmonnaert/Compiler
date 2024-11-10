
// Test AND operator
int test_and(int a, int b) {
    return a && b; // Returns 1 if both a and b are true (non-zero)
}

// Test OR operator
int test_or(int a, int b) {
    return a || b; // Returns 1 if either a or b is true (non-zero)
}

// Test NOT operator
int test_not(int a) {
    return !a; // Returns 1 if a is false (zero)
}

// Global variables to track function calls
int a_calls = 0;
int b_calls = 0;
int c_calls = 0;
int d_calls = 0;

// Function a() with side effect
int a() {
    a_calls = a_calls + 1;
    return a_calls % 2 == 1; // True on odd calls, false on even
}

// Function b() with side effect
int b() {
    b_calls = b_calls + 1;
    return b_calls % 3 != 0; // False every third call
}

// Function c() with side effect
int c() {
    c_calls = c_calls + 1;
    return 1; // Always true
}

// Function d() with side effect
int d() {
    d_calls = d_calls + 1;
    return 0; // Always false
}

// Combined tests for AND, OR, and NOT
int test_logical_operations() {
    // Combined expressions
    int a = 20;
    int b = -1;
    int c = 2;
    print_int(test_and(a, b));

    // (a AND b) OR (NOT c)
    print_int(test_or(test_and(a, b), test_not(c)));

    // (a OR b) AND (c NOT)
    print_int(test_and(test_or(a, b), test_not(c)));

    // (NOT a) OR (b AND c)
    print_int(test_or(test_not(a), test_and(b, c)));

    // ((a OR b) AND NOT (b OR c))
    print_int(test_and(test_or(a, b), test_not(test_or(b, c))));

    return 0;
}

int main() {
    test_logical_operations();
    // Reset counters
    a_calls = 0;
    b_calls = 0;
    c_calls = 0;
    d_calls = 0;
    
    // Complex logical expression with &&, ||, and !
    int result = (a() && b()) || (!c() && d()) || (a() && (!b() || c()) && d());
    print_int(result);

    // Display the function call counts
    print_int(a_calls);
    print_int(b_calls);
    print_int(c_calls);
    print_int(d_calls);

    return 0;
}
