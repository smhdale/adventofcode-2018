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
  bounds = { h: Infinity }
  state = null

  for i in [0...100000]
    thisState = lights.map (light) -> light.move()
    thisBounds = getBounds thisState
    if thisBounds.h < bounds.h
      bounds = thisBounds
      state = thisState
    else if thisBounds.h > bounds.h then break
  
  grid = (' ' for x in [0..bounds.w] for y in [0..bounds.h])
  grid[y - bounds.y][x - bounds.x] = '#' for { x, y } in state

  console.log 'Seconds taken: ' + i + '\n'
  (row.join '' for row in grid).join '\n'

console.log day10()