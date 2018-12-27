helpers = require './helpers'

class Coord
	constructor: (@arr) ->
		@id = @arr.join ','
		@constellation = null

	manhattanDistTo: (other) ->
		@arr.reduce ((tot, n, i) -> tot + Math.abs n - other.arr[i]), 0

coords = for line from helpers.inputLines '25b'
	new Coord line.split(',').map Number


## PART 1 SOLUTION ##
day25 = ->
#	constellations = 0
#	for coord, i in coords
#		for other in coords[i + 1..]
#			if coord.manhattanDistTo(other) <= 3
#				constellation = coord.constellation or other.constellation or ++constellations
#				coord.constellation = constellation
#				other.constellation = constellation
#	constellations

	constellations = 0
	seen = new Set()
	while seen.size < coords.length
		unseen = coords.filter (c) -> not seen.has c.id
		next = unseen.pop()
		next.constellation = ++constellations
		seen.add next.id
		for coord in unseen
			if next.manhattanDistTo(coord) <= 3
				coord.constellation = next.constellation
				seen.add coord.id
	constellations

console.log day25()
