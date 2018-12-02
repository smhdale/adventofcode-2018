helpers = require './helpers'

day2 = () ->
  twos = 0
  threes = 0
  for id from helpers.input '2'
    set = [...new Set id]
    counts = (id.split(c).length - 1 for c in set)
    twos += 2 in counts
    threes += 3 in counts
  twos * threes

day2_adv = () ->
  ids = [...helpers.input '2']
  for id, i in ids[..-2]
    for other in ids[i + 1..]
      overlap = (c for c, i in id when other[i] is c).join ''
      if id.length - overlap.length is 1 then return overlap

console.log day2()
console.log day2_adv()
