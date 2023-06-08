# Github

## The problem
### Build a chain of similar followers

- Github API
- Input: search “query” and “limit”
- First, return the information about the first found user
- Then get followers of the user
- Select the user whose username is closest the initial username (Levenshtein distance)
- Return the information about the “closest” user
- Repeat the “followers” step for the “closest” user
- Return not more than “limit” results

## Solution

![Solution](Github-solution.png "Solution")
