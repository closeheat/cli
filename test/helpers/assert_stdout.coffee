expect = require('chai').expect
_ = require 'lodash'
ansiRegex = require('ansi-regex')()
EMPTY_STRING = /^\s*$/
INCOMPLETE_ANSWERS = /(.+)\((.+)\)\s?([^\s]+)/

split = (stdout) ->
  result = stdout.replace('\r-', '').replace('\r', '')
  result = result.split(/\n/)
  result = _.reject result, (line) -> line == '-'
  result = _.reject result, (line) -> _.isEmpty(_.trim(line))
  result = _.map result, (line) ->
    prompt_states = _.compact(line.split(ansiRegex))
    prompt_states = _.reject prompt_states, (s) -> s.match(EMPTY_STRING)
    return line unless prompt_states[0][0] == '?'

    prompt_states = _.reject prompt_states, (s) -> s.match(INCOMPLETE_ANSWERS)

    [empty, ..., filled] = prompt_states
    [empty, filled]

  _.uniq(_.map(_.flatten(_.compact(result)), _.trimRight))

module.exports = (stdout, expected) ->
  expected_lines = expected.split('\n')
  actual_lines = split(stdout)

  _.each actual_lines, (line, index) ->
    expect(line).to.eql(expected_lines[index])

  return if actual_lines.length == expected_lines.length

  console.log('ACTUAL:')
  console.log(actual_lines)
  console.log('EXPECTED:')
  console.log(expected_lines)
  expect(actual_lines.length).to.eql(expected_lines.length)
