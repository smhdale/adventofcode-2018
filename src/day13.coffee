helpers = require './helpers'

CARTS = new Map()
CARTS.set '^', 0
CARTS.set '>', 1
CARTS.set 'v', 2
CARTS.set '<', 3

CORNERS = new Map()
CORNERS.set '/', [ 1, 0, 3, 2 ]
CORNERS.set '\\', [ 3, 2, 1, 0 ]

class Cart
  constructor: (@x, @y, @dir) ->
    @id = @getPos()
    @nextTurn = 0
    @alive = yes

  move: ->
    switch @dir
      when 0 then @y--
      when 1 then @x++
      when 2 then @y++
      when 3 then @x--

  handleTrack: (track) ->
    if CORNERS.has track
      @dir = CORNERS.get(track)[@dir]
    else if track is '+'
      @dir = (@dir + (@nextTurn - 1)) %% 4
      @nextTurn = (@nextTurn + 1) % 3

  getPos: ->
    "#{@x},#{@y}"

  remove: ->
    @alive = no

class Tracks
  constructor: (@tracks, @carts) ->
    @width = Math.max ...(line.length for line in @tracks)

  trackAt: (x, y) ->
    @tracks[y][x]

  sortPos: ({ x, y }) ->
    x + y * @width

  activeCarts: ->
    @carts.filter (cart) -> cart.alive

  moveCarts: (remove = no) ->
    @carts.sort (a, b) => @sortPos(a) - @sortPos(b)

    for cart, i in @carts
      if cart.alive
        cart.move()
        pos = cart.getPos()

        # Check for collision first
        for other in @activeCarts().filter (c) -> cart.id isnt c.id
          if pos is other.getPos()
            if remove
              # Remove the carts that crashed, don't stop simulation
              cart.remove()
              other.remove()
            else
              # Stop simulation on first crash
              return pos

        # Handle this track
        cart.handleTrack @trackAt cart.x, cart.y

    # Stop when there's only one cart left
    cartsLeft = @activeCarts()
    if remove and cartsLeft.length is 1 then return cartsLeft[0].getPos()
    null

## PART 1 SOLUTION ##
day13 = (removeCarts = no) ->
  input = [ ...helpers.inputLines '13' ]

  # Create carts
  carts = []
  for line, y in input
    for track, x in line
      if CARTS.has track
        carts.push new Cart x, y, CARTS.get track

  # Create and run simulation
  sim = new Tracks input, carts

  collision = no
  while not collision
    collision = sim.moveCarts removeCarts

  collision

## PART 2 SOLUTION ##
day13_adv = -> day13 yes

console.log day13()
console.log day13_adv()