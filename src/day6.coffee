helpers = require './helpers'

parseCoords = (coord) ->
  [ , x, y ] = coord.match(/(\d+), (\d+)/).map Number
  { x, y }

getBounds = (coords) ->
  xVals = coords.map (c) -> c.x
  yVals = coords.map (c) -> c.y
  return
    xMin: Math.min ...xVals
    yMin: Math.min ...yVals
    xMax: Math.max ...xVals
    yMax: Math.max ...yVals

manhattanDist = (c1, c2) -> Math.abs(c1.x - c2.x) + Math.abs(c1.y - c2.y)


## PART 1 SOLUTION ##
day6 = () ->
  coords = [...helpers.inputLines '6', parseCoords]
  { xMin, xMax, yMin, yMax } = getBounds coords

  # Find largest areas
  areaSizes = Array(coords.length).fill 0
  disqualified = new Set
  for y in [yMin..yMax]
    for x in [xMin..xMax]
      # Find closest coordinate
      closest = Infinity
      closestCoord = -1
      for coord, i in coords
        dist = manhattanDist coord, { x, y }
        if dist < closest
          closest = dist
          closestCoord = i
      # Record closest
      areaSizes[closestCoord]++
      if x is xMin or x is xMax or y is yMin or y is yMax
        disqualified.add closestCoord

  Math.max ...areaSizes.filter (_, i) -> not disqualified.has i

## PART 2 SOLUTION ##
day6_adv = () ->
  coords = [...helpers.inputLines '6', parseCoords]
  { xMin, xMax, yMin, yMax } = getBounds coords

  maxTotalDist = 10000
  targetRegionSize = 0
  for y in [yMin..yMax]
    for x in [xMin..xMax]
      totalDist = (manhattanDist coord, { x, y } for coord in coords).reduce (a, b) -> a + b
      if totalDist < maxTotalDist then targetRegionSize++

  targetRegionSize

console.log day6()
console.log day6_adv()
