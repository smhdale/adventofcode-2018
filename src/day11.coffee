SERIAL = 9221
GRID_SIZE = 300

# Calculates cell power given coord and serial
getCellPower = (x, y, serial) ->
  rackId = x + 10
  power = (rackId * y + serial) * rackId
  hundreds = power % 1000 / 100 | 0
  hundreds - 5

# Generates the power cell grid given a serial no.
getPowerGrid = (size, serial) ->
  for y in [1..GRID_SIZE]
    for x in [1..GRID_SIZE]
      getCellPower x, y, SERIAL

# Adds power of all cells in subgrid of given size
getSubgridPower = (grid, x, y, size) ->
  power = 0
  for j in [y...y + size]
    for i in [x...x + size]
      power += grid[j][i]
  power


## PART 1 SOLUTION ##
day11 = ->
  grid = getPowerGrid GRID_SIZE, SERIAL

  subgridSize = 3
  highestPower = 0
  coord = [ 0, 0 ]

  # Check every subgrid
  for y in [0..GRID_SIZE - subgridSize]
    for x in [0..GRID_SIZE - subgridSize]
      power = getSubgridPower grid, x, y, subgridSize
      if power > highestPower
        highestPower = power
        coord = [ x + 1, y + 1 ]

  coord.join ','

## PART 2 SOLUTION ##
day11_adv = ->
  grid = getPowerGrid GRID_SIZE, SERIAL

  highestPower = 0
  best = [ 0, 0, 0 ]

  # Try every possible subgrid of every size
  # This may take a while...
  for size in [1..GRID_SIZE]
    for y in [0..GRID_SIZE - size]
      for x in [0..GRID_SIZE - size]
        power = getSubgridPower grid, x, y, size
        if power > highestPower
          highestPower = power
          best = [ x + 1, y + 1, size ]

  best.join ','

console.log day11()
console.log day11_adv()
