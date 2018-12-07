helpers = require './helpers'

parseLine = (line) ->
  split = line.split ' '
  step: split[7]
  prereq: split[1]

generateDependencies = (data) ->
  deps = new Map()
  for { step, prereq } in data
    if not deps.has step then deps.set step, new Set()
    deps.get(step).add prereq
  deps

findNoDependencies = (data) ->
  noDeps = new Set()
  steps = data.map (s) -> s.step
  noDeps.add prereq for { prereq } in data when prereq not in steps
  [ ...noDeps ]

# Simple worker class
class Worker
  constructor: () ->
    @idle = true
    @workingOn = null
    @timeLeft = 0

  startWork: (workOn) ->
    @idle = false
    @workingOn = workOn
    @timeLeft = Worker.calcWorkTime workOn

  doWork: () ->
    if --@timeLeft or @idle then null else
      @idle = true
      @workingOn

  @calcWorkTime: (ch) -> ch.charCodeAt() - 4


## PART 1 SOLUTION ##
day7 = () ->
  data = [ ...helpers.inputLines '7', parseLine ]
  deps = generateDependencies data
  queue = findNoDependencies data
  order = []

  # Work out order of steps
  while queue.length
    queue.sort()

    # Complete the next step in the queue
    if done = queue.shift()
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
  data = [ ...helpers.inputLines '7', parseLine ]
  deps = generateDependencies data
  queue = findNoDependencies data

  workers = Array.from { length: 5 }, () -> new Worker()

  timeTaken = 0
  while deps.size
    timeTaken++
    queue.sort()

    # Give queue items to workers if we can
    for worker in workers
      if queue.length and worker.idle
        worker.startWork queue.shift()

    # Do work
    workingOn = workers.map (worker) -> worker.workingOn
    workDone = workers
      .map (worker) -> worker.doWork()
      .filter Boolean

    if workDone.length
      deps.delete work for work in workDone

      # Delete finished work from all prereq lists
      for [ step, prereqs ] from deps.entries()
        prereqs.delete work for work in workDone
        # Don't add anything workers are working on to the queue
        if prereqs.size is 0 and step not in [ ...queue, ...workingOn ]
          queue.push step

  timeTaken

console.log day7()
console.log day7_adv()
