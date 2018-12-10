helpers = require './helpers'

# Class to track and move a light
class Light
  constructor: (@x, @y, @dx, @dy) ->
  move: ->
    @x += @dx
    @y += @dy
    { x: @x, y: @y }

# Parse input
parseLine = (line) -> new Light ...(line.match(/-?\d+/g).map Number)

# Get the bounds of a group of lights
getBounds = (points) ->
  [ xMin, ..., xMax ] = (x for { x } in points).sort (a, b) -> a - b
  [ yMin, ..., yMax ] = (y for { y } in points).sort (a, b) -> a - b
  return
    x: xMin
    y: yMin
    w: xMax - xMin
    h: yMax - yMin


## PART 1 & 2 SOLUTION ##
day10 = ->
  lights = [...helpers.inputLines '10', parseLine]
  smallestHeight = Infinity
  state = null
  bounds = null
  seconds = 0

  while yes
    seconds++
    newState = lights.map (light) -> light.move()
    newBounds = getBounds newState

    # Find the second where the total height is smallest
    if newBounds.h < smallestHeight
      smallestHeight = newBounds.h
      state = newState
      bounds = newBounds
    else if newBounds.h > smallestHeight
      # Height started increasing, lights are probably spreading out
      break

  # Create a grid to display the message
  grid = (' ' for x in [0..bounds.w] for y in [0..bounds.h])
  grid[y - bounds.y][x - bounds.x] = '#' for { x, y } in state

  "Time elapsed: #{seconds}s\n\n" + (row.join '' for row in grid).join '\n'

console.log day10()