def PentagonalNumber(num):
    return 1 if num == 1 else PentagonalNumber(num-1) + 5 * num - 5


[print(PentagonalNumber(i)) for i in range(1, 10)]