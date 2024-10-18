def fact(n):
    if n > 0:
        return n * fact(n-1)
    return 1

print(fact(5))

def myrange(n):
    if n > 1 :
        return (myrange(n-1)+[n-1])
    return [0]

print(myrange(5))


for x in ["Je", 5 , False , None]:
    if type(x) == "<class 'str'>" or type(x) == "<class 'int'>":
        print(x)

def complex(x,y,z):
    print(x)
    print(y)
    print(z)
    if x == 0 and y == 0 and z == 0:
        return [x,y,z]
    elif x > 0:
        return complex(x-1,y,z)
    else :
        return complex(y,z,x)

complex(2,2,2)