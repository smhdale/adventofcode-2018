helpers = require './helpers'

TEST_DIR = '15_tests/'
TESTS = [
  27730
  18740
  28944
]

# Sorts points in "reading" order
readingOrder = (a, b) ->
  if a.y is b.y then a.x - b.x else a.y - b.y

pointCompare = (target) ->
  str = target.toString()
  (point) -> point.toString() is str

# A* pathfinding
aStarPath = (board, units, start, end, limit) ->
  open = [ new AStarPoint start.x, start.y, null, 0 ]
  closed = []
  bestPath = null

  while open.length
    open.sort (a, b) -> a.f - b.f
    parent = open.shift()

    for child in parent.pointsAround().filter (c) -> board.isOpen c, units
      compareFn = pointCompare child
      heuristic = child.manhattanDistTo end
      childPoint = new AStarPoint child.x, child.y, parent, heuristic

      # Fail if path too long
      if childPoint.length > limit then continue

      # Check if path has reached target
      if compareFn end
        if not bestPath then bestPath = childPoint
        else
          isShorter = childPoint.length <= bestPath.length
          isPreferred = readingOrder(firstMoveInPath(childPoint), firstMoveInPath(bestPath)) < 0
          if isShorter and isPreferred
            bestPath = childPoint
      else
        childF = childPoint.f()

        # Check for existing nodes
        overlaps = [ ...open, ...closed ].filter compareFn
        if childF < Math.min ...(o.heuristic + o.length for o in overlaps)
          open.push childPoint

    closed.push parent

  # if bestPath then bestPath else null
  bestPath

firstMoveInPath = (path) ->
  ref = path
  ref = ref.parent while ref.length > 1
  ref

# A simple X,Y point
class Point
  constructor: (@x, @y) ->

  moveTo: (point) ->
    @x = point.x
    @y = point.y

  pointsAround: ->
    for d in [[ 0, -1 ], [ -1, 0 ], [ 1, 0 ], [ 0, 1 ]]
      new Point @x + d[0], @y + d[1]

  manhattanDistTo: ({ x, y }) ->
    Math.abs(x - @x) + Math.abs(y - @y)

  toString: ->
    "#{@x},#{@y}"

class AStarPoint extends Point
  constructor: (x, y, @parent, @heuristic = 0) ->
    super x, y
    @length = if @parent then @parent.length + 1 else 0

  f: ->
    @length + @heuristic

# A unit with attack health points, and a team
class Unit extends Point
  constructor: (x, y, @team) ->
    super x, y
    @hp = 200
    @ap = 3
    @alive = yes

  takeDamage: (damage) ->
    @hp -= damage
    if @hp <= 0 then @alive = no

  attack: (unit) ->
    unit.takeDamage @ap

  findInAttackRange: (enemies) ->
    toAttack = null
    for point in @pointsAround()
      enemy = enemies.find pointCompare point
      if not toAttack or (enemy and enemy.hp < toAttack.hp)
        toAttack = enemy
    toAttack

  findPotentialTargets: (board, units) ->
    # Identify targets
    targets = units.filter ({ team }) => team isnt @team

    # Find all potential points around all targets
    potentials = []
    potentials.push ...unit.pointsAround() for unit in targets

    # Find all non-walls and non-occupied points
    potentials.filter (point) -> board.isOpen point, units

  # Take a turn, using game board as input
  # Returns true if the turn was successful
  playTurn: (board, units) ->
    started = Date.now()

    # Living units
    living = units.filter ({ alive }) -> alive

    # If there are no enemies, end turn
    enemies = living.filter ({ team }) => team isnt @team
    if enemies.length is 0 then return no

    # First, check for a target in range
    toAttack = @findInAttackRange enemies

    # If no enemies in range, move
    if not toAttack
      # Find potential places to move towards
      targets = @findPotentialTargets board, living

      # Sort by closest Manhattan distance for speed
      targets.sort (a, b) => @manhattanDistTo(a) - @manhattanDistTo b

      shortestLength = Infinity
      shortestPath = null
      currentTarget = null

      for target in targets
        # Get best path to all targets
        path = aStarPath board, living, @, target, shortestLength

        # if paths
        #   moves = (paths.map firstMoveInPath).sort readingOrder

        if path
          if path.length < shortestLength
            shortestPath = path
            shortestLength = path.length
            currentTarget = target
          else if path.length is shortestLength
            if readingOrder(target, currentTarget) < 0
              shortestPath = path
              currentTarget = target
            # Is this target closer in reading order?
          # Is this the quickest path to any target?
          # distToTarget = paths[0].length
          # if distToTarget > shortestPath then continue

          # Determine first move of each path
          # firstMoves = (firstMoveInPath path for path in paths)


          # Overwrite or add to the potential moves list
          # if distToTarget < shortestPath
          #   shortestPath = distToTarget
          #   moves = firstMoves
          # else if distToTarget is shortestPath
          #   moves.push ...firstMoves

      # if moves.length
      #   move = moves
      #     .sort readingOrder
      #     .shift()
      #   @moveTo move
      #   toAttack = @findInAttackRange enemies
      if shortestPath
        @moveTo firstMoveInPath shortestPath
        toAttack = @findInAttackRange enemies

    # Check if we moved close enough to attack
    if toAttack then @attack toAttack

    # Round was successful
    # console.log 'turn took', Date.now() - started, 'ms'
    yes

# Keeps track of open and wall squares
class Board
  wall: '#'
  open: ' '

  constructor: (board) ->
    @width = board[0].length
    @height = board.length
    @squares = for row in board
      for square in row
        square isnt @wall

  isOpen: (point, units = []) ->
    @squares[point.y][point.x] and !units.find pointCompare point

  print: (units) ->
    toPrint = for row in @squares
      for square in row
        if square then @open else @wall
    for unit in units
      toPrint[unit.y][unit.x] = unit.team

    console.log row.join '' for row in toPrint

# Battle simulator!
class Game
  constructor: (data) ->
    # Create board
    @board = new Board data
    @round = 0

    # Find units on the board
    @units = []
    for row, y in data
      for square, x in row
        if square in [ 'E', 'G' ]
          @units.push new Unit x, y, square

  # Attempts to play a full turn, returning true on success
  playTurn: ->
    # Sort units to determine turn order
    @units.sort readingOrder
    # console.log @round + 1

    # Let each unit play its turn
    for unit, i in @getLivingUnits()
      # End turn if unit's turn failed
      if not unit.playTurn @board, @units
        # Combat is over
        return no

    ++@round

  getLivingUnits: ->
    @units.filter ({ alive }) -> alive

  remainingHealth: ->
    (hp for { hp } in @getLivingUnits()).reduce (a, b) -> a + b

  print: ->
    console.log 'Round', @round
    @board.print @getLivingUnits()
    console.log ''

## PART 1 SOLUTION ##
day15 = ->
  # Run tests
  for expected, i in TESTS
    g = new Game [ ...helpers.inputLines TEST_DIR + i ]
    while yes
      if not g.playTurn() then break
    #   g.print()
    # g.print()
    result = g.remainingHealth() * g.round
    passed = if result is expected then 'passed!' else 'failed.'
    console.log "Test #{i + 1} #{passed} (returned #{result}, expected #{expected})"

  g = new Game [ ...helpers.inputLines '15' ]
  g.print()
  while yes
    if not g.playTurn() then break
    g.print()
  g.print()

  g.remainingHealth() * g.round

## PART 2 SOLUTION ##
day15_adv = ->

console.log day15()
console.log day15_adv()
