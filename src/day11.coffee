SERIAL = 9221
GRID_SIZE = 300

# Calculates cell power given coord and serial
getCellPower = (x, y, serial) ->
  rackId = x + 10
  power = (rackId * y + serial) * rackId
  hundreds = power % 1000 / 100 | 0
  hundreds - 5

# Generate the power cell grid
GRID =
  for y in [1..GRID_SIZE]
    for x in [1..GRID_SIZE]
      getCellPower x, y, SERIAL

# Adds power of all cells in subgrid of given size
getSubgridPower = (x, y, size) ->
  power = 0
  for j in [y...y + size]
    for i in [x...x + size]
      power += GRID[j][i]
  power


## PART 1 SOLUTION ##
day11 = ->
  highestPower = 0
  coord = [ 0, 0 ]
  subgridSize = 3

  # Check every subgrid
  for y in [0..GRID_SIZE - subgridSize]
    for x in [0..GRID_SIZE - subgridSize]
      power = getSubgridPower x, y, subgridSize
      if power > highestPower
        highestPower = power
        coord = [ x + 1, y + 1 ]

  coord.join ','

## PART 2 SOLUTION ##
day11_adv = ->
  highestPower = 0
  best = [ 0, 0, 0 ]

  # Try every possible grid size
  # This may take a while...
  for size in [1..GRID_SIZE]
    for y in [0..GRID_SIZE - size]
      for x in [0..GRID_SIZE - size]
        power = getSubgridPower x, y, size
        if power > highestPower
          highestPower = power
          best = [ x + 1, y + 1, size ]

  best.join ','

console.log day11()
console.log day11_adv()