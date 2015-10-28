expect = require('chai').expect
_ = require 'lodash'

split = (stdout) ->
  result = stdout.replace('\r-', '').replace('\r', '')
  result = result.split(/\n/)
  result = _.reject result, (line) -> line == '-'
  result = _.reject result, (line) -> _.isEmpty(_.trim(line))
  _.compact(result)

module.exports = (stdout, expected) ->
  expected_lines = expected.split('\n')
  actual_lines = split(stdout)

  _.each actual_lines, (line, index) ->
    expect(line).to.eql(expected_lines[index])

  console.log stdout
  expect(actual_lines.length).to.eql(expected_lines.length)
