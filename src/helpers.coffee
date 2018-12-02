fs = require 'fs'

getFileLines = (day) ->
  fs.readFileSync "./input/#{day}.sdx", 'utf-8'
    .split '\n'
    .map (l) -> l.trim()
    .filter Boolean

input = (day, cast = String) -> yield cast line for line in getFileLines day
inputLoop = (day, cast = String) -> yield from input day, cast while 1

module.exports = {
  input,
  inputLoop
}
