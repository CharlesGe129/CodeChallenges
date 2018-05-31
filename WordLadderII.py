'''

Given two words (beginWord and endWord), and a dictionary's word list, find all shortest transformation sequence(s) from beginWord to endWord, such that:

Only one letter can be changed at a time
Each transformed word must exist in the word list. Note that beginWord is not a transformed word.
Note:

Return an empty list if there is no such transformation sequence.
All words have the same length.
All words contain only lowercase alphabetic characters.
You may assume no duplicates in the word list.
You may assume beginWord and endWord are non-empty and are not the same.
Example 1:

Input:
beginWord = "hit",
endWord = "cog",
wordList = ["hot","dot","dog","lot","log","cog"]

Output:
[
  ["hit","hot","dot","dog","cog"],
  ["hit","hot","lot","log","cog"]
]
Example 2:

Input:
beginWord = "hit"
endWord = "cog"
wordList = ["hot","dot","dog","lot","log"]

Output: []

Explanation: The endWord "cog" is not in wordList, therefore no possible transformation.

'''

class Solution_without_time_improvement:
    def findLadders(self, beginWord, endWord, wordList):
        if endWord not in wordList:
            return []
        wordList.remove(beginWord) if beginWord in wordList else None
        min_len = len(wordList) + 1
        temp = [each.copy() for each in self.recursion(beginWord, endWord, wordList, [beginWord])]
        for each in temp:
            min_len = len(each) if len(each) < min_len else min_len
        rs = list()
        for each in temp:
            if len(each) == min_len:
                rs.append(each)
        return rs

    def recursion(self, begin_word, end_word, word_list, result):
        for next_word in self.find_distance_1(begin_word, word_list):
            if next_word == end_word:
                result.append(end_word)
                yield result
                result.remove(end_word)
            temp_list = word_list.copy()
            temp_list.remove(next_word)
            result.append(next_word)
            # print(f"next={next_word}, new={temp_list}, rs={result}")
            yield from self.recursion(next_word, end_word, temp_list, result)
            result.remove(next_word)

    def find_distance_1(self, begin_word, word_list):
        for each in word_list:
            if self.dis_1(begin_word, each):
                yield each

    def dis_1(self, word1, word2):
        flag = False
        for i in range(len(word1)):
            if word1[i] != word2[i] and not flag:
                flag = True
            elif word1[i] != word2[i] and flag:
                return False
        return flag


a = Solution_without_time_improvement()
begin_word = "hit"
end_word = 'cog'
word_list = ["hot", "dot", "dog", "lot", "log", "cog"]
rs = a.findLadders(begin_word, end_word, word_list)
print(rs)
begin_word = "hot"
end_word = 'dog'
word_list = ["hot", "dot", "dog"]
rs = a.findLadders(begin_word, end_word, word_list)
print(rs)
# begin_word = 'qa'
# end_word = 'sq'
# word_list = ["si","go","se","cm","so","ph","mt","db","mb","sb","kr","ln","tm","le","av","sm","ar","ci","ca","br","ti","ba","to","ra","fa","yo","ow","sn","ya","cr","po","fe","ho","ma","re","or","rn","au","ur","rh","sr","tc","lt","lo","as","fr","nb","yb","if","pb","ge","th","pm","rb","sh","co","ga","li","ha","hz","no","bi","di","hi","qa","pi","os","uh","wm","an","me","mo","na","la","st","er","sc","ne","mn","mi","am","ex","pt","io","be","fm","ta","tb","ni","mr","pa","he","lr","sq","ye"]
# rs = a.findLadders(begin_word, end_word, word_list)
# print(rs)
