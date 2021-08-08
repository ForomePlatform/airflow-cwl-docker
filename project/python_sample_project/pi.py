import sys


def calculate(n:int) -> float:
    k = 1
    s = 0

    for i in range(n):
        if i % 2 == 0:
            s += 4/k
        else:
            s -= 4/k
        k += 2
    return s


if __name__ == '__main__':
    print(calculate(int(sys.argv[1])))
