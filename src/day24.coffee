md5 = require 'md5'
helpers = require './helpers'

findModifier = (line, modifier) ->
  regex = new RegExp modifier + ' to (.*?)[;)]'
  if not regex.test line then undefined else
    line.match(regex)[1].split ', '

parseGroup = (team) -> (line) ->
  [ units, hp, ap, initiative ] = line.match(/\d+/g).map Number
  attackType = line.match(/(\w+)\sdamage/)[1]
  weakTo = findModifier line, 'weak'
  immuneTo = findModifier line, 'immune'
  new Group team, units, hp, ap, attackType, initiative, weakTo, immuneTo

parseInput = ->
  data = helpers.input('24').split '\n\n'
  immune: data[0].split('\n')[1..].map parseGroup 'Immune System'
  infection: data[1].split('\n')[1..].map parseGroup 'Infection'

# A group of units
class Group
  constructor: (@team, @units, @hp, @ap, @attackType, @initiative, weakTo = [], immuneTo = []) ->
    @id = md5 JSON.stringify arguments
    @weakTo = new Set weakTo
    @immuneTo = new Set immuneTo
    @target = null

  setTarget: (target) -> @target = target
  getEffectivePower: -> @units * @ap

  calcDamageFrom: (attacker) ->
    baseDamage = attacker.getEffectivePower()
    if @immuneTo.has attacker.attackType then 0
    else if @weakTo.has attacker.attackType then baseDamage * 2
    else baseDamage

  takeDamageFrom: (attacker) ->
    damage = @calcDamageFrom attacker
    unitsKilled = Math.floor damage / @hp
    @units = Math.max 0, @units - unitsKilled
    unitsKilled

# An army of groups of units
class Army
  constructor: (@groups, boost = 0) ->
    @team = @groups[0].team
    if boost
      @groups.forEach (g) -> g.ap += boost

  groupsWithUnits: ->
    @groups.filter (g) -> g.units > 0

  unitsLeft: ->
    @groups.reduce ((total, g) -> total + g.units), 0

  targetingOrder: ->
    @groupsWithUnits().sort (a, b) ->
      aPower = a.getEffectivePower()
      bPower = b.getEffectivePower()
      bPower - aPower or b.initiative - a.initiative

  highestDamage: (attacker, targeted) ->
    @groupsWithUnits()
      .filter (g) ->
        g.calcDamageFrom(attacker) and not targeted.has g.id
      .sort (a, b) ->
        aDamage = a.calcDamageFrom attacker
        bDamage = b.calcDamageFrom attacker
        aPower = a.getEffectivePower()
        bPower = b.getEffectivePower()
        bDamage - aDamage or bPower - aPower or b.initiative - a.initiative

  setTargets: (army) ->
    moves = []
    targeted = new Set()
    for group, i in @targetingOrder()
      targets = army.highestDamage group, targeted
      if targets.length
        group.setTarget targets[0]
        moves.push group
        targeted.add group.target.id
    moves

# Simulates a fight between the teams
fight = (boost = 0) ->
  { immune, infection } = parseInput()
  immArmy = new Army immune, boost
  infArmy = new Army infection
  round = 1

  while yes
    # Return if one team has no units left
    immLeft = immArmy.unitsLeft()
    infLeft = infArmy.unitsLeft()
    if (immLeft * infLeft) is 0
      team = if immLeft then immArmy.team else infArmy.team
      return { team, units: immLeft | infLeft }

    # Target enemy groups!
    moves = [
      ...immArmy.setTargets infArmy
      ...infArmy.setTargets immArmy
    ]
    # Detect when no groups can attack any other groups
    if moves.length is 0 then return { error: 'Stalemate' }

    damageThisRound = 0
    for group in moves.sort (a, b) -> b.initiative - a.initiative
      if group.units > 0
        damageThisRound += group.target.takeDamageFrom group

    # Detect when groups can't do enough damage to kill anything
    if damageThisRound is 0 then return { error: 'Stalemate' }


## PART 1 SOLUTION ##
day24 = ->
  { team, units } = fight()
  "#{team} wins with #{units} units left"

## PART 2 SOLUTION ##
day24_adv = ->
  boost = 50
  while yes
    { team, units, error } = fight boost
    if team is 'Immune System' then break
    boost++
  "#{team} wins with a boost of #{boost} AP and #{units} units left"


console.log day24()
console.log day24_adv()
