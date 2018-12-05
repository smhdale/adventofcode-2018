helpers = require './helpers'

alphabet = 'abcdefghijklmnopqrstuvwxyz'
regex = new RegExp ((a + (b = a.toUpperCase()) + '|' + b + a for a in alphabet).join '|'), 'g'

reduce = (polymer) -> (polymer = polymer.replace regex, '' while regex.test polymer).pop()

day5 = () ->
  polymer = reduce [...helpers.input '5'][0]
  polymer.length

day5_adv = () ->
  polymer = [...helpers.input '5'][0]
  shortest = polymer.length

  for c in alphabet
    remover = new RegExp c, 'ig'
    reduced = reduce polymer.replace remover, ''
    shortest = Math.min reduced.length, shortest

  shortest

console.log day5()
console.log day5_adv()
