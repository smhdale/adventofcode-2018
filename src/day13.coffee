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
    @active = yes

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

  getPos: -> "#{@x},#{@y}"
  remove: -> @active = no

class Tracks
  constructor: (@tracks, @carts) ->
    @width = Math.max ...(line.length for line in @tracks)

  trackAt: (x, y) -> @tracks[y][x]
  activeCarts: -> @carts.filter (cart) -> cart.active
  sortPos: ({ x, y }) -> x + y * @width

  moveCarts: (remove = no) ->
    @carts.sort (a, b) => @sortPos(a) - @sortPos(b)

    for cart in @activeCarts()
      cart.move()
      pos = cart.getPos()

      # Check for collision first
      for other in @activeCarts()
        if cart.id isnt other.id and pos is other.getPos()
          if not remove then return pos else
            # Remove the carts that crashed, don't stop simulation
            cart.remove()
            other.remove()

      # Handle next piece of track
      cart.handleTrack @trackAt cart.x, cart.y

    # Stop when there's only one cart left
    cartsLeft = @activeCarts()
    if remove and cartsLeft.length is 1 then cartsLeft[0].getPos() else null

## PART 1 SOLUTION ##
day13 = (withRemoval = no) ->
  input = [ ...helpers.inputLines '13' ]

  # Create carts
  carts = []
  for line, y in input
    for track, x in line when CARTS.has track
      carts.push new Cart x, y, CARTS.get track

  # Create and run simulation
  sim = new Tracks input, carts
  collision = sim.moveCarts withRemoval until collision
  collision

## PART 2 SOLUTION ##
day13_adv = -> day13 yes

console.log day13()
console.log day13_adv()