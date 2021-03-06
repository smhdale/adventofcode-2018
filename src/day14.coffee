helpers = require './helpers'

NUM_RECIPES = 793031

class Recipes
  constructor: ->
    @elves = [ 0, 1 ]
    @scores = [ 3, 7 ]

  addRecipes: ->
    combined = @elves.reduce ((total, elf) => total + @scores[elf]), 0
    @scores.push ...(Number digit for digit in String combined)

  moveElves: ->
    @elves = @elves.map (elf) => (elf + @scores[elf] + 1) % @scores.length

  next: ->
    @addRecipes()
    @moveElves()

  lastN: (n) ->
    @scores[-n..].join ''


## PART 1 SOLUTION ##
day14 = ->
  recipes = new Recipes()
  recipes.next() while recipes.scores.length < NUM_RECIPES + 10
  recipes.lastN 10

## PART 2 SOLUTION ##
day14_adv = ->
  recipes = new Recipes()
  target = String NUM_RECIPES
  searchArea = target.length + 1
  foundAt = -1

  while foundAt < 0
    recipes.next()
    foundAt = recipes.lastN(searchArea).indexOf target

  recipes.scores.length - searchArea + foundAt

console.log day14()
console.log day14_adv()
