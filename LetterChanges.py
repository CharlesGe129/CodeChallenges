def LetterChanges(str):
    rs = ''
    package = 'abcdefghijklmnopqrstuvwxyz'
    for i in range(len(str)):
        index = package.find(str[i].lower())
        flag = True if str[i].isupper() else False
        if index >= 0:
            index = index + 1 if index < 25 else 0
            temp = package[index]
        else:
            temp = str[i]
        if temp in 'aeiou' or flag:
            temp = temp.upper()
        rs += temp
    return rs
