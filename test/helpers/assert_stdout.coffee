expect = require('chai').expect
_ = require 'lodash'
ansiRegex = require('ansi-regex')()

split = (stdout) ->
  result = stdout.replace('\r-', '').replace('\r', '')
  result = result.split(/\n/)
  result = _.reject result, (line) -> line == '-'
  result = _.reject result, (line) -> _.isEmpty(_.trim(line))
  result = _.map result, (line) ->
    return line unless line[0] == '?'

    prompt_states = _.compact(line.split(ansiRegex))
    return new Error("Error in prompt states: #{JSON.stringify(prompt_states)}") if prompt_states.length <= 2

    [empty, ..., filled] = prompt_states
    [empty, filled]

  _.map(_.flatten(_.compact(result)), _.trimRight)

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
