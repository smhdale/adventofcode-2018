helpers = require './helpers'

## PART 1 SOLUTION ##
day1 = () -> [...helpers.inputLines '1', Number].reduce (a, b) -> a + b

## PART 2 SOLUTION ##
day1_adv = () ->
  freq = 0
  seen = new Set()
  for n from helpers.inputLoop '1', Number
    freq += n
    if seen.has freq then return freq
    seen.add freq

console.log day1()
console.log day1_adv()
