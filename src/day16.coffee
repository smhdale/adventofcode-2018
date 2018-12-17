helpers = require './helpers'

# Converts a string of separated digits to an array
splitDigits = (str) ->
  str.match(/\d+/g).map Number

# Parses an operation sample
parseSample = (sample) ->
  [ before, inst, after ] = sample
    .split '\n'
    .map splitDigits
  return
    before: before
    after: after
    inst:
      opcode: inst[0]
      args: inst[1..]

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

  constructor: -> @mem = Array(4).fill 0
  resetMemory: -> @mem.fill 0
  setMemory: (values) -> @mem = values[..]
  getMemory: -> @mem.join()

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
day16 = ->
  data = helpers.input '16'
  [ ...samples, _ ] = data.split /\n{2,}/

  ambiguousSamples = 0
  device = new Device()

  for { before, inst, after } in samples.map parseSample
    # How many commands generate matching output?
    matches = Device.commands.map (cmd) ->
      device.setMemory before
      device[cmd] ...inst.args
      device.getMemory() is after.join()

    # Increment ambiguous samples on 3+ matches
    if matches.filter(Boolean).length > 2
      ambiguousSamples++

  ambiguousSamples

## PART 2 SOLUTION ##
day16_adv = ->
  data = helpers.input '16'
  [ ...samples, program ] = data.split /\n{2,}/

  # Determine which opcode represents each command
  opcodes = Array.from Device.commands, -> new Set()
  device = new Device()

  for { before, inst, after } in samples.map parseSample
    # How many commands generate matching output?
    for cmd, i in Device.commands
      device.setMemory before
      device[cmd] ...inst.args
      if device.getMemory() is after.join()
        opcodes[inst.opcode].add cmd

  # Map commmands to opcodes
  commands = new Map()
  while opcodes.some (set) -> set.size
    # Find a command that definitely matches an opcode
    definite = opcodes.findIndex (set) -> set.size is 1
    command = [ ...opcodes[definite] ][0]

    # No other codes can be this command!
    opcodes.forEach (set) -> set.delete command
    commands.set definite, command

  # Run the sample program
  device.resetMemory()
  for [ op, ...args ] in program.split('\n').map splitDigits
    device[commands.get op] ...args
  device.get 0

console.log day16()
console.log day16_adv()
