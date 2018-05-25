'''
Have the function LongestWord(sen) take the sen parameter being passed and return the largest word in the string.
If there are two or more words that are the same length, return the first word from the string with that length.
Ignore punctuation and assume sen will not be empty.

Use the Parameter Testing feature in the box below to test your code with different arguments.
'''


def LongestWord(sen):
    rs = ""
    cur = ""
    j = 0
    package = 'pyfgcrlaoeuidhtnsqjkxbmwvzPYFGCRLAOEUIDHTNSQJKXBMWVZ1234567890'
    for i in range(len(sen)):
        if sen[i] in package:
            cur += sen[i]
            j += 1
        else:
            if len(cur) > len(rs):
                rs = cur
            cur = ""
            j = 0
    if len(cur) > len(rs):
        rs = cur
    return rs
