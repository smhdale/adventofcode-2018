helpers = require './helpers'

## PART 1 SOLUTION ##
day2 = () ->
  twos = 0
  threes = 0
  for id from helpers.inputLines '2'
    counts = (id.split(c).length - 1 for c in [...new Set id])
    twos += 2 in counts
    threes += 3 in counts
  twos * threes

## PART 2 SOLUTION ##
day2_adv = () ->
  ids = [...helpers.inputLines '2']
  for id, i in ids[..-2]
    for other in ids[i + 1..]
      overlap = (c for c, j in id when other[j] is c).join ''
      if id.length - overlap.length is 1 then return overlap

console.log day2()
console.log day2_adv()
