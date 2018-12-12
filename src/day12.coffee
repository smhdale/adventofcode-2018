helpers = require './helpers'

ALIVE = '#'
DEAD = '.'

# Stores map of pots with plants in them
class Pots
  constructor: (state) ->
    @min = 0
    @max = state.length - 1
    @rules = new Set()
    @state = new Set (i for pot, i in state when pot is ALIVE)

  # Adds a rule for whether a plant survives in the next generation
  addRule: (rule) ->
    [ condition, outcome ] = rule.split ' => '
    if outcome is ALIVE
      @rules.add (Number plant is ALIVE for plant in condition).join ''

  # Gets a segment of the pots map
  segment: (x, len = 5) ->
    [0...len]
      .map (i) => Number @state.has x + i
      .join ''

  # Progresses to the next generation of plants
  grow: () ->
    checked = new Set()
    newState = new Set()
    for plant in [ ...@state ]
      for x in [plant - 2..plant + 2] when not checked.has x
        checked.add x
        if @rules.has @segment x - 2
          newState.add x
    @state = newState

  # Returns sum of the indexes of all living plants
  sumAliveIndexes: () ->
    [ ...@state ].reduce (a, b) -> a + b

# Sets up pots and runs n generations of growing
growPlants = (generations, logging = false) ->
  [ state, ...rules ] = [ ...helpers.inputLines '12' ]

  # Set up pots
  pots = new Pots state.slice 15
  pots.addRule rule for rule in rules

  # Grow some plants!
  lastSum = 0
  for i in [1..generations]
    pots.grow()

    # Watch console for a repeating difference in sums,
    # then just extrapolate that out for the answer
    if logging
      thisSum = pots.sumAliveIndexes()
      console.log i, thisSum, thisSum - lastSum
      lastSum = thisSum

  # Return sum of indexes of all pots with living plants
  pots.sumAliveIndexes()


## PART 1 SOLUTION ##
day12 = -> growPlants 20

## PART 2 SOLUTION ##
day12_adv = -> growPlants 200, yes #50000000000

console.log day12()
console.log day12_adv()
