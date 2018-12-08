helpers = require './helpers'

class Node
  constructor: (@children, @meta) ->

nodeLength = (arr) ->
  # Figure out node length
  [ numChildren, numMeta ] = arr
  length = 2
  for child in [0...numChildren]
    length += nodeLength arr[length..]
  length + numMeta

parseNode = (arr) ->
  [ numChildren, numMeta ] = arr
  meta = arr[-numMeta..]
  childInd = 2
  children = []
  for i in [0...numChildren]
    childLen = nodeLength arr[childInd..]
    children.push parseNode arr[childInd...childInd + childLen]
    childInd += childLen
  new Node children, meta

sumMeta = (node) ->
  node.meta
    .concat (sumMeta child for child in node.children)
    .reduce (a, b) -> a + b

sumMetaAdvanced = (node) ->
  if node.children.length
    # If node has children, sum children with indexes from node meta
    node.meta
      .filter (n) -> n > 0 and n <= node.children.length
      .map (n) -> sumMetaAdvanced node.children[n - 1]
      .reduce (a, b) -> a + b
  else
    # Return sum of node's metadata
    node.meta.reduce (a, b) -> a + b


## PART 1 SOLUTION ##
day8 = () ->
  data = helpers.input '8'
    .split ' '
    .map Number

  root = parseNode data
  sumMeta root

## PART 2 SOLUTION ##
day8_adv = () ->
  data = helpers.input '8'
    .split ' '
    .map Number

  root = parseNode data
  sumMetaAdvanced root


console.log day8()
console.log day8_adv()
