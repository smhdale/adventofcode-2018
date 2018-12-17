helpers = require './helpers'

splitNums = (str, sep = '..') ->
  str
    .split sep
    .map Number

toRange = (arr) ->
  min = Math.min ...arr
  max = Math.max ...arr
  [min..max]

parseLine = (line) ->
    xr = splitNums line.match(/x=([\d.]+)/)[1]
    yr = splitNums line.match(/y=([\d.]+)/)[1]
    points = []
    for x in toRange xr
      points.push ...({ x, y } for y in toRange yr)
    points

pStr = ({ x, y }) ->
  "#{x},#{y}"

class Droplet
  constructor: (pos) ->
    @x = pos.x
    @y = pos.y
    @path = [ pStr pos ]

  # Checks
  posAbove: -> { x: @x, y: @y - 1 }
  posBelow: -> { x: @x, y: @y + 1 }
  posLeft:  -> { x: @x - 1, y: @y }
  posRight: -> { x: @x + 1, y: @y }

  getPos: -> { x: @x, y: @y }
  logPos: -> @path.push pStr @

  # Movement
  setPos: ({ x, y }) ->
    @x = x
    @y = y
  down: ->
    @y++
    @logPos()
  left: ->
    @x--
    @logPos()
  right: ->
    @x++
    @logPos()

class FlowSim
  constructor: (@spring, @clay, @range) ->
    @seen = new Set()
    @water = new Set()

  blocked: (point) ->
    str = pStr point
    @clay.has(str) or @water.has str

  addPath: (path) ->
    numSeen = @seen.size
    @seen.add point for point in path
    return @seen.size > numSeen

  dripAt: (pos) ->
    if not pos then return false

    drop = new Droplet pos
    dripLeft = null
    dripRight = null

    # Droplet falls down
    while not @blocked drop.posBelow()
      drop.down()
      # Drop fell out of bounds
      if drop.posBelow().y > @range.max
        return @addPath drop.path
    hitGroundAt = drop.getPos()

    # Spread out left until a wall or it can fall again
    while @blocked(drop.posBelow()) and not @blocked drop.posLeft()
      drop.left()
      if not @blocked drop.posBelow()
        dripLeft = drop.posBelow()
        break

    # Reset to where it hit the ground and move right this time
    drop.setPos hitGroundAt
    while @blocked(drop.posBelow()) and not @blocked drop.posRight()
      drop.right()
      if not @blocked drop.posBelow()
        dripRight = drop.posBelow()
        break

    foundNewPath = @addPath drop.path
    if dripLeft or dripRight
      return foundNewPath or @dripAt(dripLeft) or @dripAt(dripRight)
    else
      # Become still water
      drop.setPos hitGroundAt
      while not @blocked drop.posLeft()
        drop.left()
        @water.add pStr drop
      drop.setPos hitGroundAt
      while not @blocked drop.posRight()
        drop.right()
        @water.add pStr drop

      drop.setPos hitGroundAt
      @water.add pStr drop
      return @dripAt drop.posAbove()

  # Drip some water from the spring
  drip: ->
    @dripAt
      x: @spring.x
      y: Math.max @spring.y, @range.min

  getCoverage: ->
    total: @seen.size
    remaining: @water.size

  print: ->
    for y in [0..14]
      row = for x in [494..507]
        str = pStr { x, y }
        if @clay.has str then '#'
        else if @water.has str then '~'
        else if @seen.has str then '|'
        else '.'
      console.log row.join ''

parseInput = ->
  min = Infinity
  max = -Infinity
  clay = new Set()
  for line from helpers.inputLines '17', parseLine
    for point in line
      clay.add pStr point
      min = Math.min min, point.y
      max = Math.max max, point.y
  { clay, range: { min, max } }


## PART 1 & 2 SOLUTION ##
day17 = ->
  spring = { x: 500, y: 0 }
  { clay, range } = parseInput()
  sim = new FlowSim spring, clay, range

  didDrip = yes
  didDrip = sim.drip() while didDrip

  sim.getCoverage()

console.log day17()
