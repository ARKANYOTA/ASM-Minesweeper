num1 = bin(int(input("num1 : "),16))
num2 = bin(int(input("num2 : "),16))
num3 = bin(int(input("num3 : "),16))


num1 = ("0"*64+num1[2:])[-64:]
num2 = ("0"*64+num2[2:])[-64:]
num3 = ("0"*64+num3[2:])[-64:]

l = [num1,num2,num3]

for k in range(0,8) :
    print("")
    for j in range(0,8) :
        s =0 
        for i in range(0,3) :
            s += int(l[i][k*8+j])*(2**i)
        print(s, end=" ")

print("")


for k in range(0,8) :
    print("")
    for j in range(0,8) :
        s = int(l[0][k*8+j])
        print(s, end=" ")


print("")


for k in range(0,8) :
    print("")
    for j in range(0,8) :
        s = int(l[1][k*8+j])
        print(s, end=" ")

print("")


for k in range(0,8) :
    print("")
    for j in range(0,8) :
        s = int(l[2][k*8+j])
        print(s, end=" ")






