class Solution1:
    def uniqueLetterString(self, S):
        num = 0
        for each in self.gen_sub(S):
            num += self.eliminate_duplicate(each)
            print(num)
        return self.modolo(num)

    @staticmethod
    def eliminate_duplicate(string):
        checked = [False for each in string]
        num = 0
        for i in range(len(string)):
            uni_flag = True
            if checked[i]:
                continue
            for j in range(i+1, len(string)):
                if string[i] == string[j]:
                    checked[j] = True
                    uni_flag = False
            num += 1 if uni_flag else 0
        return num

    @staticmethod
    def gen_sub(string):
        for i in range(1, len(string)+1):
            for j in range(len(string)-i+1):
                yield string[j:j+i]

    @staticmethod
    def modolo(num):
        rs = ''
        return num


class Solution(object):
    def uniqueLetterString(self, S):
        if not S:
            return 0
        total = 1
        increment = [3 for x in range(26)]
        lastpos = [[-1, -1] for x in range(26)]
        increment[ord(S[0]) - ord('A')] = 1
        lastpos[ord(S[0]) - ord('A')] = [-1, 0]

        for i in range(1, len(S)):
            print(f"i = {i}, letter = {S[i]}")
            print(f"increment = {increment}")
            print(f"lastpos = {lastpos}")
            p = ord(S[i]) - ord('A')
            total += increment[p]
            llast, last = lastpos[p]
            lastpos[p] = [last, i]
            extra = - (last << 1) + llast + 1
            print(f"total += {increment[p]}, llast = {llast}, last = {last}, lastpos[{S[i]}] update to [{last}, {i}]"
                  f", extra = {extra}")
            print(f"normal increment = {+ i + extra}, special = {- i + last + 1}")

            for idx in range(26):
                if idx != p:
                    increment[idx] += + i + extra
                else:
                    increment[idx] += - i + last + 1
        return total


a = Solution().uniqueLetterString("ABCA")
print(a)