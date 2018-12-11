SERIAL = 9221
GRID_SIZE = 300

getCellPower = (x, y, serial) ->
  rackId = x + 10
  power = (rackId * y + serial) * rackId
  hundreds = power % 1000 / 100 | 0
  hundreds - 5

getCellGrid = ->
  for y in [1..GRID_SIZE]
    for x in [1..GRID_SIZE]
      getCellPower x, y, SERIAL


## PART 1 SOLUTION ##
day11 = ->
  grid = getCellGrid()

  highestPower = 0
  coord = [ 0, 0, 0 ]

  for y in [0..GRID_SIZE - 3]
    for x in [0..GRID_SIZE - 3]
      power = 0
      for j in [y..y + 2]
        for i in [x..x + 2]
          power += grid[j][i]
      if power > highestPower
        highestPower = power
        coord = [ x + 1, y + 1 ]

  coord.join ','

## PART 2 SOLUTION ##
day11_adv = ->
  grid = getCellGrid()

  highestPower = 0
  best = [ 0, 0, 0 ]

  for size in [1..GRID_SIZE]
    for y in [0..GRID_SIZE - size]
      for x in [0..GRID_SIZE - size]
        power = 0
        for j in [y...y + size]
          for i in [x...x + size]
            power += grid[j][i]
        if power > highestPower
          highestPower = power
          best = [ x + 1, y + 1, size ]

  best.join ','

console.log day11()
console.log day11_adv()