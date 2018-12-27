helpers = require './helpers'

unseenCoords = (coords, seen) ->
	coords.filter (c) -> not seen.has c.id

class Coord
	constructor: (@arr) ->
		@id = @arr.join ','
		@constellation = null

	manhattanDistTo: (other) ->
		@arr.reduce ((tot, n, i) -> tot + Math.abs n - other.arr[i]), 0


## PART 1 SOLUTION ##
day25 = ->
	coords = for line from helpers.inputLines '25'
		new Coord line.split(',').map Number
	constellations = 0
	seen = new Set()

	while seen.size < coords.length
		point = unseenCoords(coords, seen).pop()
		thisConstellation = constellations++
		seen.add point.id

		nearby = [ point ]
		while nearby.length
			next = nearby.pop()
			newCoords = unseenCoords coords, seen
				.filter (c) -> next.manhattanDistTo(c) <= 3

			# Mark all newly found coords as seen
			seen.add c.id for c in newCoords

			# Add them to this constellation
			nearby.push ...newCoords

	# Return number of constellations counted
	constellations


console.log day25()
