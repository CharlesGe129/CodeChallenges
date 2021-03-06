'''
Have the function LetterCapitalize(str) take the str parameter being passed and capitalize the first letter
of each word. Words will be separated by only one space.

Use the Parameter Testing feature in the box below to test your code with different arguments
'''


def LetterCapitalize(str):
    return ' '.join([s[0].upper() + s[1:] for s in str.split(" ")])
