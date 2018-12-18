helpers = require './helpers'

coordToStr = (x, y) -> "#{x},#{y}"
strToCoord = (str) -> str.split(',').map Number

class Acreage
  open: '.'
  trees: '|'
  lumber: '#'

  constructor: (data) ->
    @grid = new Map()
    @width = data[0].length
    @height = data.length
    @timeElapsed = 0
    @seen = []

    for line, y in data
      for acre, x in line
        id = coordToStr x, y
        @grid.set id, acre

  acresAround: (x, y) ->
    myId = coordToStr x, y
    acres = []
    for j in [y - 1..y + 1]
      for i in [x - 1..x + 1]
        id = coordToStr i, j
        if id isnt myId and @grid.has id
          acres.push @grid.get id
    acres

  grow: (limit = 0) ->
    nextGeneration = new Map()

    for y in [0...@height]
      for x in [0...@width]
        id = coordToStr x, y
        acre = @grid.get id
        totals = @countTotals @acresAround x, y

        switch acre
          when Acreage::open
            # Open space becomes trees if there are 3+ trees around
            if totals[Acreage::trees] > 2
              acre = Acreage::trees
          when Acreage::trees
            # Trees become lumber if there is 3+ lumber around
            if totals[Acreage::lumber] > 2
              acre = Acreage::lumber
          else
            # Lumber becomes open when 0 lumber or 0 trees around
            if not (totals[Acreage::trees] * totals[Acreage::lumber])
              acre = Acreage::open

        nextGeneration.set id, acre


    if limit > 0
      asString = @toString()
      previousIndex = @seen.indexOf asString

      if previousIndex > -1
        cycle = @timeElapsed - previousIndex
        @timeElapsed += cycle while @timeElapsed < limit - cycle

      @seen.push @toString()

    @grid = new Map nextGeneration
    @timeElapsed++

  countTotals: (arr = null) ->
    if not arr then arr = [ ...@grid.values() ]
    totals = {
      [Acreage::open]: 0,
      [Acreage::trees]: 0,
      [Acreage::lumber]: 0
    }
    totals[acre]++ for acre in arr
    totals

  toString: ->
    [ ...@grid.values() ].join ''

## PART 1 SOLUTION ##
day18 = ->
  data = [ ...helpers.inputLines '18' ]
  acreage = new Acreage data
  acreage.grow() while acreage.timeElapsed < 10

  totals = acreage.countTotals()
  totals[Acreage::lumber] * totals[Acreage::trees]

## PART 2 SOLUTION ##
day18_adv = ->
  data = [ ...helpers.inputLines '18' ]
  limit = 1000000000
  acreage = new Acreage data
  while acreage.timeElapsed < limit
    acreage.grow limit

  totals = acreage.countTotals()
  totals[Acreage::lumber] * totals[Acreage::trees]

console.log day18()
console.log day18_adv()
