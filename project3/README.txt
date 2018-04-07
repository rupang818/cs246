Jihoon Kim
Nov 18, 2017

CS246 - Project 3

For Task 4, some more intuitions about a corrected spelling of the word have been implemented.

Between the "word" and "correction":

- As suggested by the project description, the substitution between vowels is more likely than any other combinations (i.e. consonants -> vowel)

- If the first characters are the same (since one is less likely to make a typo on the first character of any word), the correction is more likely. Furthermore, a "graduatedScoring" have been implemented recursively. It basically determines how many letters from the beginning continuously match, and returns higher score for those pairs who match more words. The weight for each matching character is increased 2x.

- If the word occurence count is an outlier (i.e. the occurs 79809, and is short), return EM of 0.0. The intuition is that, since this word already occurs many times, the EM of 0.0 will be compensated by the calculateLM due to its highness in occurence

- If the edit distance is shorter, more likely a match. If the edit distance is long, but the word & correction are of the same length, assign high score. If the edit distance is long, but the word & correction are NOT of the same length, severely penalize the graduated scoring to return much smaller value

With these techniques, I was able to raise the accuracy by about 4.5% from ~74% to 78.49% (5.66% unknown). 

The ceiling of the accuracy being much less than 100% have been accounted by several facts, including:
- Some words don't exist in the dictionary (unknown)
- Some corrections are not so clear among candidates (ambiguity)
- Some required the edit distance to encompass more than just two
- ... and others