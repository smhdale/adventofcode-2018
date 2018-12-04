helpers = require './helpers'

# Find index of highest array element
indexOfMax = (arr) -> arr.indexOf Math.max ...arr

# Basic parsing
parseLine = (line) ->
  [ , date, text ] = line.match /\[(.*?)\] (.*)/
  return
    text: text
    date: new Date date

parseInput = () ->
  # Get all lines, then sort by date
  lines = [...helpers.input '4', parseLine].sort (a, b) -> a.date - b.date

  guards = {}
  guardId = null
  sleptAt = 0
  for { date, text } in lines
    if text.startsWith 'Guard'
      guardId = Number text.match /\d+/
    else if text is 'falls asleep'
      sleptAt = date.getMinutes()
    else
      # Guard has woken up
      wokeAt = date.getMinutes()

      # Create this guard if it doesn't exist already
      if not guards.hasOwnProperty guardId then guards[guardId] =
        freq: Array(60).fill 0
        total: 0

      # Count total minutes slept and overall frequency
      guards[guardId].total += wokeAt - sleptAt
      guards[guardId].freq[min]++ for min in [sleptAt...wokeAt]

  # Return parsed guards data
  guards

day4 = () ->
  guards = parseInput()

  # Which guard slept longest?
  sleepiestGuardId = -1
  mostTimeSlept = -1
  for id, data of guards
    if data.total > mostTimeSlept
      mostTimeSlept = data.total
      sleepiestGuardId = id

  # Return guard ID * their sleepiest minute
  sleepiestGuardId * indexOfMax guards[sleepiestGuardId].freq

day4_adv = () ->
  guards = parseInput()

  # Which minute was slept through the most by a single guard?
  mostSleptThrough = -1
  guardId = -1
  minute = -1
  for id, data of guards
    highestMinute = Math.max ...data.freq
    if highestMinute > mostSleptThrough
      mostSleptThrough = highestMinute
      guardId = id
      minute = indexOfMax data.freq

  # Return guard Id * that minute
  guardId * minute

console.log day4()
console.log day4_adv()
