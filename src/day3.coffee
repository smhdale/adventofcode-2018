helpers = require './helpers'

parseRect = (line) ->
  [ , id, x, y, w, h ] = line
    .match /#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/
    .map Number
  return
    id: id
    x1: x
    y1: y
    x2: x + w - 1
    y2: y + h - 1

getOverlap = (r1, r2) ->
  if r1.x1 > r2.x2 || r2.x1 > r1.x2 || r1.y1 > r2.y2 || r2.y1 > r1.y2 then false else
    x1: Math.max r1.x1, r2.x1
    y1: Math.max r1.y1, r2.y1
    x2: Math.min r1.x2, r2.x2
    y2: Math.min r1.y2, r2.y2

getOverlaps = (rects) ->
  overlaps = []
  for r1, i in rects[..-2]
    for r2 in rects[i + 1..]
      if overlap = getOverlap r1, r2 then overlaps.push overlap
  overlaps


## PART 1 SOLUTION ##
day3 = () ->
  # Calculate overlaps of all cuts
  overlaps = getOverlaps [...helpers.inputLines '3', parseRect]

  # Count all coordinates in all overlaps
  coords = new Set()
  for { x1, y1, x2, y2 } in overlaps
    for x in [x1..x2]
      for y in [y1..y2]
        coords.add "#{x},#{y}"
  coords.size

## PART 2 SOLUTION ##
day3_adv = () ->
  rects = [...helpers.inputLines '3', parseRect]
  overlaps = getOverlaps rects
  (rects.find (r1) -> overlaps.every (r2) -> !getOverlap r1, r2).id

console.log day3()
console.log day3_adv()
