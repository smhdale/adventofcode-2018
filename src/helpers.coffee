fs = require 'fs'

getFile = (day) -> fs.readFileSync "./input/#{day}.sdx", 'utf-8'

# Input for just returning file contents

input = (day, cast = String) -> getFile(day).trim()

# Input for files with multiple lines

getFileLines = (day) ->
  getFile day
    .split '\n'
    .map (l) -> l.trim()
    .filter Boolean

inputLines = (day, cast = String) -> yield cast line for line in getFileLines day
inputLinesLoop = (day, cast = String) -> yield from inputLines day, cast while 1

module.exports = {
  input,
  inputLines,
  inputLinesLoop
}
