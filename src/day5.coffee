helpers = require './helpers'

# Alphabet of units in the polymer
alphabet = 'abcdefghijklmnopqrstuvwxyz'

# Generates polymer pairs to reduce
pairs = (c) ->
  up = c.toUpperCase()
  c + up + '|' + up + c

# Reduces a polymer by removing matching unit pairs
reduce = (polymer) ->
  # Unit pair detector regex
  regex = new RegExp (pairs c for c in alphabet).join('|'), 'g'

  # Reduce the polymer while pairs exist
  while regex.test polymer
    polymer = polymer.replace regex, ''

  # Return the final polymer
  polymer

# Removes faulty units from a polymer
removeFaulty = (polymer, unit) ->
  regex = new RegExp unit, 'ig'
  polymer.replace regex, ''


## PART 1 SOLUTION ##
day5 = () -> (reduce helpers.input '5').length

## PART 2 SOLUTION ##
day5_adv = () ->
  polymer = helpers.input '5'
  shortest = polymer.length

  # Generate polymers assuming each unit is faulty, then find the shortest
  reduced = (reduce removeFaulty polymer, unit for unit in alphabet)
  Math.min ...(poly.length for poly in reduced)

console.log day5()
console.log day5_adv()
