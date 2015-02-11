gulp = require 'gulp'
git = require 'gulp-git'
Q = require 'q'
q = require('bluebird')
callback = require 'gulp-callback'
gutil = require 'gulp-util'

module.exports =
class Deployer
  ALL_FILES = '**'

  deploy: ->
    @addEverything().then =>
      console.log 'All files added.'
      @commit('Deploy via CLI').then(=>
        console.log 'Commited.'
        console.log 'Pushing to Github.'
        @pushToMainBranch().then (branch)=>
          console.log "Pushed to brach #{branch} on Github."
          @showDeployLog()

        ).catch (e) ->
        console.log 'No files to deploy.'

  addEverything: ->
    new q (resolve, reject) ->
      gulp
        .src(ALL_FILES)
        .pipe(stream = git.add())
        .on('error', reject)
        .on('end', resolve)

      stream.resume()

  commit: (msg) ->
    new q (resolve, reject) ->
      gulp
        .src(ALL_FILES)
        .pipe(stream = git.commit(msg))
        .on('error', reject)
        .on('end', resolve)

      stream.resume()

  pushToMainBranch: ->
    new q (resolve, reject) =>
      @getMainBranch().then (main_branch) =>
        @push(main_branch).then ->
          resolve(main_branch)

  getMainBranch: ->
    new q (resolve, reject) ->
      resolve('master')

  push: (branch) ->
    new q (resolve, reject) ->
      git.push 'origin', branch, args: '--quiet', (err) ->
        throw err if err

        resolve()

  showDeployLog: ->
    console.log('Deploying to closeheat.')
    console.log('............ SOME LOG HERE ..........')
    console.log('Should be done.')
