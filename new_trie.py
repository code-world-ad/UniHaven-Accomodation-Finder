class TrieNode:    
 
    #Constructor, Time O(1), Space O(1), 128 is constant
    def __init__(self, c):
        self.children = [None]*128 #don't use 26 if there is space or other special characters
        self.isEnd = False
        self.data = c
		   		
class Trie:
 
    #Constructor, Time O(1), Space O(1)
    def __init__(self):
        self.root = TrieNode('')
 
    #inserts a word into the trie, Iteration, 
	#Time O(s), Space O(s), s is word length
    def insert(self, college_name):
        node = self.root
        college_name = college_name.lower()
        for char in college_name:  # Ensure only alphanumeric characters are considered
                if node.children[ord(char)] is None:
                    node.children[ord(char)] = TrieNode(char)
                node = node.children[ord(char)]
        node.isEnd = True
 
    #returns all words with given prefix
    #Time O(n), Space O(n), n is number of nodes included(prefix and branches) 
    '''
    def autocomplete(self, prefix):
        node = self.root
        res = []
        for ch in prefix:
            node = node.children[ord(ch)]
            if node == None:
                return []  
            node = node.children[ord(ch)]
        self.helper(node, res, prefix)
        return res'''

    def autocomplete(self, prefix):
        node = self.root
        res = []
        for ch in prefix:
            node = node.children[ord(ch)]
            if node == None:
                return []  
        self.helper(node, res, prefix)
        return res
    
    def helper(self, node, res, prefix):
        if node.isEnd:
            res.append(prefix)
        for i, child in enumerate(node.children):
            if child:
                self.helper(child, res, prefix + chr(i))

if __name__ == '__main__':
    t= Trie()
    t.insert('anna university')
    t.insert('annamalai uni')
    t.insert('anamika uni')
    print(t.autocomplete('ann'))