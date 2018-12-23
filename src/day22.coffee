helpers = require './helpers'

parseInput = ->
  [ depth, x, y ] = helpers.input '22'
    .match /\d+/g
    .map Number
  { depth, target: new Point x, y }

class Point
  constructor: (@x, @y) ->

  up: -> new Point @x, @y - 1
  left: -> new Point @x - 1, @y

  toString: -> "#{@x},#{@y}"
  is: (other) -> @toString() is other.toString()

class Caves
  origin: new Point 0, 0

  geoX: 16807
  geoY: 48271
  depthModulo: 20183

  constructor: (@depth, @target) ->
    @geoIndexes = new Map()
    @erosionLevels = new Map()
    @riskLevels = new Map()

  getGeoIndex: (point) ->
    pointStr = point.toString()
    if @geoIndexes.has pointStr
      @geoIndexes.get pointStr
    else
      if point.is(Caves::origin) or point.is @target
        geoIndex = 0
      else if point.x is 0
        geoIndex = point.y * Caves::geoY
      else if point.y is 0
        geoIndex = point.x * Caves::geoX
      else
        left = point.left().toString()
        up = point.up().toString()
        geoIndex = @erosionLevels.get(left) * @erosionLevels.get up

      @geoIndexes.set pointStr, geoIndex
      geoIndex

  getErosionLevel: (point) ->
    pointStr = point.toString()
    if @erosionLevels.has pointStr
      @erosionLevels.get pointStr
    else
      geoIndex = @getGeoIndex point
      erosionLevel = (geoIndex + @depth) % Caves::depthModulo
      @erosionLevels.set pointStr, erosionLevel
      erosionLevel

  assessRisk: (point) ->
    pointStr = point.toString()
    if @riskLevels.has pointStr
      @riskLevels.get pointStr
    else
      risklevel = @getErosionLevel(point) % 3
      @riskLevels.set pointStr, risklevel
      risklevel

  assessArea: (target = @target, risk = 0, origin = Caves::origin) ->
    # Work along row first
    for x in [origin.x..target.x]
      risk += @assessRisk new Point x, origin.y

    # Work down column
    if origin.y < target.y
      for y in [origin.y + 1..target.y]
        risk += @assessRisk new Point origin.x, y

    # If we're at target row or col, we're done
    if origin.x is target.x or origin.y is target.y
      risk
    else
      # Otherwise, move further towards target
      @assessArea target, risk, new Point(
        Math.min origin.x + 1, target.x
        Math.min origin.y + 1, target.y
      )

class Climber
  equipment: [
    'none',
    'torch',
    'gear'
  ]

  constructor: (@caves, @target) ->
    @gear = 1

## PART 1 SOLUTION ##
day22 = ->
  { depth, target } = parseInput()
  caves = new Caves depth, target
  caves.assessArea()

day22_adv = ->
  # { depth, target } = parseInput()
  # caves = new Caves depth, target
  depth = 510
  target = new Point 10, 10
  caves = new Caves depth, target

  caves.assessArea new Point target.x * 2, target.y * 2
  climber = new Climber caves.riskLevels, target

  climber.caves.riskLevels.size

console.log day22()
# console.log day22_adv()
