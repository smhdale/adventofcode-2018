helpers = require './helpers'

# Splits a string on '|' chars not wrapped in brackets
splitTopLevel = (str) ->
    bracketLevel = 0
    groups = []
    group = ''
    chars = [ ...str ]
    while ch = chars.shift()
      if ch is '|' and not bracketLevel
        groups.push group
        group = ''
      else
        group += ch
        if ch is '(' then bracketLevel++
        else if ch is ')' then bracketLevel--
    groups.concat [ group ]

# A directions node containing steps and branches
class Node
  reNode: /^((?:[NEWS]*(?:\([NEWS]*\|\))?)*)(?:\((.*)\))?/
  reLoop: /\(([NEWS]*)\|\)/g
  reNotDir: /[^NEWS]/g

  constructor: (str) ->
    [ _, steps, branches ] = str.match(Node::reNode) or []

    # Save directional steps as string, both with and without loops
    @steps = (steps or '').replace Node::reLoop, ''
    @stepsWithLoops = (steps or '').replace Node::reNotDir, ''

    # Add any branches
    @branches = if not branches then [] else
      (new Node branch for branch in splitTopLevel branches)

  # Find the maximum steps from this node to any leaf node
  maxLength: ->
    @steps.length + Math.max ...(node.maxLength() for node in @branches), 0

# A building that can generate a floor plan and min distance
# to any room when given a directions node
class Building
  constructor: (root) ->
    @rooms = new Map()
    @x = 0
    @y = 0
    @setRoomDistance 0
    @traverse @x, @y, root

  move: (dir) ->
    switch (dir)
      when 'N' then @y--
      when 'E' then @x++
      when 'W' then @x--
      else @y++

  pos: -> "#{@x},#{@y}"
  getRoomDistance: -> @rooms.get @pos()
  setRoomDistance: (doors) -> @rooms.set @pos(), doors

  traverse: (x, y, node, doorsSoFar = 0) ->
    # Start movement from these coords
    @x = x
    @y = y

    # Iterate over the node's directions, including any loops
    for step, i in [ ...node.stepsWithLoops ]
      @move step
      roomDistance = @getRoomDistance()
      thisDistance = doorsSoFar + i + 1
      if not roomDistance or thisDistance < roomDistance
        @setRoomDistance thisDistance

    # Record final position, traverse all branch nodes from there
    branchX = @x
    branchY = @y
    for branch in node.branches
      @traverse branchX, branchY, branch, doorsSoFar + node.steps.length


## PART 1 SOLUTION ##
day20 = ->
  path = helpers.input('20')[1..-2]
  root = new Node path
  root.maxLength()

## PART 2 SOLUTION ##
day20_adv = ->
  path = helpers.input('20')[1..-2]
  root = new Node path
  map = new Building root

  [ ...map.rooms.values()]
    .filter (distance) -> distance >= 1000
    .length

console.log day20()
console.log day20_adv()
