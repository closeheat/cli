inquirer = require('inquirer')
fs = require('fs.extra')
path = require('path')
ghdownload = require('github-download')
_ = require 'lodash'
Q = require 'q'
homePath = require('home-path')
mkdirp = require('mkdirp')
dirmr = require('dirmr')

module.exports =
class Creator
  create: (name) ->
    @src = process.cwd()
    @tmp_dir = "#{homePath()}/.closeheat/tmp/creations/353cleaned5sometime/"

    inquirer.prompt [
      {
        message: 'Framework to use?'
        name: 'framework'
        type: 'list'
        choices: [
          {
            name: 'Angular.js'
            value: 'angular'
          }
          {
            name: 'React.js'
            value: 'react'
          }
          {
            name: 'Ember.js'
            value: 'ember'
          }
          {
            name: 'None'
            value: 'none'
          }
        ],
      }
      {
        message: 'Template?'
        name: 'template'
        type: 'list'
        choices: [
          {
            name: 'Bootstrap'
            value: 'bootstrap'
          }
          {
            name: 'None'
            value: 'none'
          }
        ],
      }
      {
        message: 'Javascript preprocessor?'
        name: 'javascript'
        type: 'list'
        default: 'none'
        choices: [
          {
            name: 'CoffeeScript'
            value: 'coffeescript'
          }
          {
            name: 'None'
            value: 'none'
          }
        ],
      }
      {
        message: 'HTML preprocessor?'
        name: 'html'
        type: 'list'
        default: 'none'
        choices: [
          {
            name: 'Jade'
            value: 'jade'
          }
          {
            name: 'None'
            value: 'none'
          }
        ]
      }
      {
        message: 'CSS preprocessor?'
        name: 'css'
        type: 'list'
        default: 'none'
        choices: [
          {
            name: 'SCSS'
            value: 'scss'
          }
          {
            name: 'None'
            value: 'none'
          }
        ]
      }
    ], (answers) =>
      @createFromSettings(name, answers)

  createFromSettings: (name, answers) ->
    app_dir = path.join(process.cwd(), name)
    parts_dir = path.join(@tmp_dir, 'parts')
    whole_dir = path.join(@tmp_dir, 'whole')

    if fs.existsSync parts_dir
      fs.rmrfSync(parts_dir)

    if fs.existsSync whole_dir
      fs.rmrfSync(whole_dir)

    mkdirp parts_dir, (err) =>
      mkdirp whole_dir, (err2) =>
        if err or err2
          console.log err
          console.log err2

        framework_dir = path.join(@tmp_dir, 'parts', answers.framework)
        template_dir = path.join(@tmp_dir, 'parts', answers.template)

        @downloadAndAdd(framework_dir, answers.framework).then =>
          @downloadAndAdd(template_dir, answers.template).then =>
            console.log 'before m'
            console.log template_dir
            console.log whole_dir
            dirmr([template_dir, framework_dir]).join(whole_dir)
            console.log 'merged'

  downloadAndAdd: (tmp, part) ->
    deferred = Q.defer()

    console.log "installing #{part}"
    ghdownload(user: 'closeheat', repo: "template-#{part}", ref: 'master', tmp)
      .on('dir', (dir) ->
        console.log "dir")
      .on 'error', (err) ->
        console.log(err)
      .on 'end', ->
        console.log('donw')
        deferred.resolve(true)

    deferred.promise

#     url = 'https://api.github.com/search/repositories?sort=stars&order=desc&q=closeheat'
#
#     request = require 'request'
#
#     Spinner = require './spinner'
#     Spinner.start('Creating a directory')
#
#     request {
#       method: 'GET'
#       headers: 'User-Agent': 'closeheat'
#       url: url
#     }, (error, response, body) ->
#       chalk = require('chalk')
#       util = require('util')
#
#       Spinner.stop("App with name \"#{chalk.yellow(name)}\" is ready.")
#
#       start_cmd = chalk.yellow("cd #{name} && closeheat server")
#       util.puts "  Run \"#{start_cmd}\" to start it."
#
#       process.exit(0)
