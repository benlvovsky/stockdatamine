import unittest

# Here's our "unit".
def featureSelectExcluded(n):
    return n % 2 == 1

# Here's our "unit tests".
class IsOddTests(unittest.TestCase):

    def testOne(self):
        self.failUnless(featureSelectExcluded(1))

    def testTwo(self):
        self.failIf(featureSelectExcluded(2))

def main():
    unittest.main()

if __name__ == '__main__':
    main()
