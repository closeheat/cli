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

  _.each split(stdout), (line, index) ->
    expect(line).to.eql(expected_lines[index])
