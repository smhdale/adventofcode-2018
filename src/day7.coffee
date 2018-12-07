helpers = require './helpers'

parseLine = (line) ->
  split = line.split ' '
  step: split[7]
  prereq: split[1]

generateDependencies = () ->
  deps = new Map()
  for { step, prereq } from helpers.inputLines '7', parseLine
    if not deps.has step then deps.set step, new Set()
    deps.get(step).add prereq
  deps


## PART 1 SOLUTION ##
day7 = () ->
  deps = generateDependencies()

  # Find steps with no dependencies
  steps = [ ...deps.keys() ]
  queue = ([ ...prereqs ] for prereqs from deps.values())
    .flat()
    .filter (prereq) -> prereq not in steps
  queue = [ ...new Set queue ]
  order = []

  # Work out order of steps
  while queue.length
    queue.sort()

    # Complete the next step in the queue
    done = queue.shift()
    order.push done
    deps.delete done

    # Add steps with no dependencies to queue
    for [ step, prereqs ] from deps.entries()
      prereqs.delete done
      if prereqs.size is 0 and step not in queue
        queue.push step

  order.join ''

## PART 2 SOLUTION ##
day7_adv = () ->

console.log day7()
console.log day7_adv()
