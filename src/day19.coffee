helpers = require './helpers'

parseLine = (line) ->
  [ instruction, ...args ] = line.split ' '
  { instruction, args: args.map Number }

parseInput = ->
  [ pointer, ...commands ] = [ ...helpers.inputLines '19' ]
  pointer: Number pointer.match /\d+/
  commands: commands.map parseLine

class Device
  @commands = [
    'addr', 'addi'
    'mulr', 'muli'
    'banr', 'bani'
    'borr', 'bori'
    'setr', 'seti'
    'gtir', 'gtri', 'gtrr'
    'eqir', 'eqri', 'eqrr'
  ]

  constructor: (@pointer, @commands) ->
    @mem = Array(6).fill 0

  # Run the program until instruction pointer
  # points outside commands list
  run: (breakAt = -1) ->
    while yes
      ptr = @get @pointer
      if ptr >= @commands.length or ptr is breakAt then break

      { instruction, args } = @commands[ptr]
      @[instruction] ...args
      @set @pointer, 1 + @get @pointer
    return

  get: (reg) -> @mem[reg]
  set: (reg, val) -> @mem[reg] = val

  # Addition
  addr: (a, b, out) -> @set out, @get(a) + @get b
  addi: (a, b, out) -> @set out, b + @get a

  # Multiplication
  mulr: (a, b, out) -> @set out, @get(a) * @get b
  muli: (a, b, out) -> @set out, b * @get a

  # Bitwise and
  banr: (a, b, out) -> @set out, @get(a) & @get b
  bani: (a, b, out) -> @set out, b & @get a

  # Bitwise or
  borr: (a, b, out) -> @set out, @get(a) | @get b
  bori: (a, b, out) -> @set out, b | @get a

  # Assignment
  setr: (a, b, out) -> @set out, @get a
  seti: (a, b, out) -> @set out, a

  # Greater-than testing
  gtir: (a, b, out) -> @set out, Number a > @get b
  gtri: (a, b, out) -> @set out, Number b < @get a
  gtrr: (a, b, out) -> @set out, Number @get(a) > @get b

  # Equality testing
  eqir: (a, b, out) -> @set out, Number a is @get b
  eqri: (a, b, out) -> @set out, Number b is @get a
  eqrr: (a, b, out) -> @set out, Number @get(a) is @get b


## PART 1 SOLUTION ##
day19 = ->
  { pointer, commands } = parseInput()

  device = new Device(pointer, commands)
  device.run()
  device.get 0

## PART 2 SOLUTION ##
day19_adv = ->
  { pointer, commands } = parseInput()

  device = new Device(pointer, commands)
  device.set 0, 1
  device.run 35
  # Device stops running once we have our value in R5
  findFactorsOf = device.get 5
  factors = (i for i in [1..findFactorsOf] when findFactorsOf % i is 0)
  factors.reduce (a, b) -> a + b

console.log day19()
console.log day19_adv()
