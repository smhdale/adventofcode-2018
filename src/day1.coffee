helpers = require './helpers'

day1 = () -> [...helpers.input '1', Number].reduce (a, b) -> a + b

day1_adv = () ->
  freq = 0
  seen = []
  for n from helpers.inputLoop '1', Number
    freq += n
    if freq in seen then return freq
    seen.push freq
  freq

console.log day1()
console.log day1_adv()
