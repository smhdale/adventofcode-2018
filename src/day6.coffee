helpers = require './helpers'

# Parse "x, y" to { x, y }
parseCoords = (coord) ->
  [ , x, y ] = coord.match(/(\d+), (\d+)/).map Number
  { x, y }

# Get the minimum and maximum x and y values from a list of coords
getBounds = (coords) ->
  xVals = coords.map (c) -> c.x
  yVals = coords.map (c) -> c.y
  return
    x1: Math.min ...xVals
    y1: Math.min ...yVals
    x2: Math.max ...xVals
    y2: Math.max ...yVals

# Calculate the Manhattan distance between two coords
manhattanDist = (c1, c2) -> Math.abs(c1.x - c2.x) + Math.abs(c1.y - c2.y)


## PART 1 SOLUTION ##
day6 = ->
  coords = [ ...helpers.inputLines '6', parseCoords ]
  { x1, y1, x2, y2 } = getBounds coords

  # Track the size of every coord's area
  areaSizes = Array(coords.length).fill 0
  disqualified = new Set

  for y in [ y1..y2 ]
    for x in [ x1..x2 ]
      # Find closest coordinate
      closest = Infinity
      closestCoord = -1
      for coord, i in coords
        dist = manhattanDist coord, { x, y }
        if dist < closest
          closest = dist
          closestCoord = i

      # Disqualify regions touching the grid border
      if x in [ x1, x2 ] or y in [ y1, y2 ]
        disqualified.add closestCoord
      else areaSizes[closestCoord]++

  # Return size of the largest region not disqualified
  Math.max ...areaSizes.filter (_, i) -> not disqualified.has i

## PART 2 SOLUTION ##
day6_adv = ->
  coords = [ ...helpers.inputLines '6', parseCoords ]
  { x1, y1, x2, y2 } = getBounds coords

  maxTotalDist = 10000
  targetRegionSize = 0

  for y in [ y1..y2 ]
    for x in [ x1..x2 ]
      totalDist = coords.reduce ((sum, coord) -> sum + manhattanDist coord, { x, y }), 0
      if totalDist < maxTotalDist then targetRegionSize++

  # Return total area of target region
  targetRegionSize

console.log day6()
console.log day6_adv()
