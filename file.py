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