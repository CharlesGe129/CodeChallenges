'''
Have the function AlphabetSoup(str) take the str string parameter being passed and return the string with the
letters in alphabetical order (ie. hello becomes ehllo). Assume numbers and punctuation symbols will not be
included in the string.

Use the Parameter Testing feature in the box below to test your code with different arguments.
'''


def AlphabetSoup(str):
    return ''.join(sorted(str))
