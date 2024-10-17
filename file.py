if True:
    print("True")


if False:
    print("False")
else:
    print("True")


x = 5
if x < 5:
    x = 3
    print("Less than 5")
else:
    print("Greater than 5")
if x == 3:
    print("x is 3")


x = 10
if x > 5:
    if x > 7:
        print("Greater than 7")
    else:
        print("Between 5 and 7")
else:
    print("5 or less")


a = 10
b = 20
if a < b:
    print("a is less than b")


x = 10
if x % 2 == 0:
    print("Even")
else:
    print("Odd")


i = 0
while i < 5:
    print(i)
    i = i + 1



i = 0
while i < 5:
    if i % 2 == 0:
        print("Even")
        print(i)
    else:
        print("Odd")
        print(i)
    i = i + 1


i = 5
while i > 0:
    print(i)
    i = i - 1


x = True
if x and not False:
    print("Boolean expression is True")


s = "hello"
if s == "hello":
    print("It's hello")
else:
    print("It's something else")


x = 10
y = 20
if x < y and y < 30:
    print("Both conditions are True")
