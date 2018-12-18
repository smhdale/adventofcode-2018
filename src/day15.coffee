helpers = require './helpers'

# Sorts points in "reading" order
readingOrder = (a, b) ->
  if a.y is b.y then a.x - b.x else a.y - b.y

distanceThenReading = (a, b) ->
  if a.distance isnt b.distance then a.distance - b.distance else
    readingOrder a.point, b.point

# Checks if a path can be made between two points
inSameRegion = (game, start, end) ->
  open = [ start ]
  closed = new Set()
  closed.add start.toString()

  while open.length
    node = open.shift()
    if node.is end then return yes

    for nextNode in node.neighbours().filter (n) -> game.isOpen n
      if not closed.has nextNode.toString()
        open.push nextNode
        closed.add nextNode.toString()
  no

firstStep = (path) ->
  ref = path
  ref = ref.parent while ref.length > 1
  ref

# A* pathfinding
aStarPath = (game, start, end) ->
  startId = start.toString()
  startPoint = new PriorityPoint start.x, start.y, 0
  open = [ startPoint ]

  costs = new Map()
  costs.set startId, 0

  while open.length
    open.sort (a, b) -> a.f - b.f
    node = open.shift()
    nodeId = node.toString()
    if node.is end then return costs.get nodeId

    for point in node.neighbours().filter (p) -> game.isOpen p
      cost = 1 + costs.get nodeId
      heuristic = point.manhattanDistTo end
      nextNode = new PriorityPoint point.x, point.y, cost + heuristic
      nextId = nextNode.toString()

      if not costs.has(nextId) or cost < costs.get nextId
        costs.set nextId, cost
        open.push nextNode

# A simple X,Y point
class Point
  constructor: (@x, @y) ->

  moveTo: (point) ->
    @x = point.x
    @y = point.y

  neighbours: ->
    for d in [[ 0, -1 ], [ -1, 0 ], [ 1, 0 ], [ 0, 1 ]]
      new Point @x + d[0], @y + d[1]

  manhattanDistTo: ({ x, y }) ->
    Math.abs(x - @x) + Math.abs(y - @y)

  is: (other) ->
    @toString() is other.toString()

  toString: ->
    "#{@x},#{@y}"

class PriorityPoint extends Point
  constructor: (x, y, @f) -> super x, y

# A unit with attack health points, and a team
class Unit extends Point
  constructor: (x, y, @team, @ap = 3) ->
    super x, y
    @hp = 200
    @alive = yes

  takeDamage: (damage) ->
    @hp -= damage
    if @hp <= 0 then @alive = no

  attack: (unit) ->
    unit.takeDamage @ap

  findInAttackRange: (enemies) ->
    enemies = @neighbours()
      .map (p) -> enemies.find (e) -> e.is p
      .filter Boolean
      .sort (a, b) -> a.hp - b.hp

    if enemies.length then enemies[0] else null

  findPotentialMoves: (game) ->
    # Identify targets
    targets = game.getLivingUnits().filter ({ team }) => team isnt @team

    # Find all potential points around all targets
    potentials = []
    for unit in targets
      potentials.push ...unit.neighbours().filter (point) ->
        game.isOpen point

    # Find points that are accessible and aren't walls or units
    potentials.filter (point) => inSameRegion(game, @, point)

  # Take a turn, using game board as input
  # Returns true if the turn was successful
  playTurn: (game) ->
    # started = Date.now()
    if not @alive then return yes

    # Living units
    living = game.getLivingUnits()

    # If there are no enemies, end turn
    enemies = living.filter ({ team }) => team isnt @team
    if enemies.length is 0 then return no

    # First, check for a target in range
    toAttack = @findInAttackRange enemies

    # If no enemies in range, move
    if not toAttack
      # Find potential places to move towards
      moves = @findPotentialMoves game

      if moves.length
        withDistances = moves
          .map (point) =>
            distance = aStarPath game, @, point
            { point, distance }
          .sort distanceThenReading
        target = withDistances[0]

        # Find best way to move to it
        fromNeighbour = @neighbours()
          .filter (point) ->
            game.isOpen(point) and inSameRegion(game, point, target.point)
          .find (point) ->
            distance = aStarPath game, point, target.point
            distance < target.distance

        @moveTo fromNeighbour
        toAttack = @findInAttackRange enemies

    # Try attacking again
    if toAttack then @attack toAttack
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
    @squares[point.y][point.x] and !units.find (unit) -> unit.is point

  print: (units) ->
    toPrint = for row in @squares
      for square in row
        if square then @open else @wall
    for unit in units
      toPrint[unit.y][unit.x] = unit.team

    console.log row.join '' for row in toPrint

# Battle simulator!
class Game
  constructor: (board, @elfAp) ->
    # Create board
    @board = new Board board
    @round = 0

    # Find units on the board
    @units = []
    for row, y in board
      for square, x in row
        if square in [ 'E', 'G' ]
          ap = if square is 'E' then @elfAp else 3
          @units.push new Unit x, y, square, ap

    @numElves = @countElves()

  # Attempts to play a full turn, returning true on success
  playTurn: ->
    # Sort units to determine turn order
    @units.sort readingOrder

    # Let each unit play its turn
    for unit in @units
      if unit.alive and not unit.playTurn @
        return no
      if @elfAp > 3 and @countElves() < @numElves
        throw new Error 'An elf died!'

    ++@round

  isOpen: (point) ->
    @board.isOpen point, @getLivingUnits()

  countElves: ->
    @getLivingUnits()
      .filter ({ team }) -> team is 'E'
      .length

  getLivingUnits: ->
    @units.filter ({ alive }) -> alive

  remainingHealth: ->
    (hp for { hp } in @getLivingUnits()).reduce (a, b) -> a + b

  print: ->
    console.log 'Round', @round
    @board.print @getLivingUnits()
    console.log ''

  getOutcome: ->
    hpLeft = @remainingHealth()
    "Round: #{@round}, HP left: #{hpLeft}, answer: #{hpLeft * @round}"


## PART 1 SOLUTION ##
day15 = ->
  g = new Game [ ...helpers.inputLines '15' ]
  while yes
    if not g.playTurn() then break
  g.getOutcome()

## PART 2 SOLUTION ##
day15_adv = ->
  board = [ ...helpers.inputLines '15' ]
  attackPower = 14
  while attackPower
    g = new Game board, attackPower
    console.log "Giving elves #{attackPower} AP..."
    try
      while yes
        if not g.playTurn() then break
      return g.getOutcome()
    catch err
      console.log "#{attackPower} AP wasn't enough!"
      attackPower++

# console.log day15()
console.log day15_adv()
