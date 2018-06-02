'''

You are given two non-empty linked lists representing two non-negative integers. The digits are stored in reverse order and each of their nodes contain a single digit. Add the two numbers and return it as a linked list.

You may assume the two numbers do not contain any leading zero, except the number 0 itself.

Example

Input: (2 -> 4 -> 3) + (5 -> 6 -> 4)
Output: 7 -> 0 -> 8
Explanation: 342 + 465 = 807.

'''

# Definition for singly-linked list.
class ListNode:
    def __init__(self, x):
        self.val = x
        self.next = None


class Solution:
    def addTwoNumbers(self, l1, l2):
        carry = 0
        rs = ListNode(0)
        cur = rs
        cur_l1 = l1
        cur_l2 = l2
        while True:
            a = cur_l1.val if cur_l1 is not None else 0
            b = cur_l2.val if cur_l2 is not None else 0
            cur.val = a + b + carry
            if cur.val > 9:
                cur.val %= 10
                carry = 1
            else:
                carry = 0
            cur_l1 = cur_l1.next if cur_l1 is not None else None
            cur_l2 = cur_l2.next if cur_l2 is not None else None
            if cur_l1 is None and cur_l2 is None:
                if carry == 1:
                    cur.next = ListNode(1)
                break
            cur.next = ListNode(0)
            cur = cur.next
        return rs

l1 = ListNode(2)
a = l1
a.next = ListNode(4)
a = a.next
a.next = ListNode(3)

l2 = ListNode(5)
b = l2
b.next = ListNode(6)
b = b.next
b.next = ListNode(4)

rs = Solution().addTwoNumbers(l1, l2)
while rs is not None:
    print(rs.val)
    rs = rs.next



l1 = ListNode(5)

l2 = ListNode(5)

rs = Solution().addTwoNumbers(l1, l2)
while rs is not None:
    print(rs.val)
    rs = rs.next


