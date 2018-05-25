'''
Have the function LetterChanges(str) take the str parameter being passed and modify it using the following
algorithm. Replace every letter in the string with the letter following it in the alphabet (ie. c becomes
d, z becomes a). Then capitalize every vowel in this new string (a, e, i, o, u) and finally return this
modified string.

Use the Parameter Testing feature in the box below to test your code with different arguments.
'''


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
