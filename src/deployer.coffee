gulp = require 'gulp'
git = require 'gulp-git'
Q = require 'q'
callback = require 'gulp-callback'

module.exports =
class Deployer
  ALL_FILES = './**/*.*'

  deploy: ->
    @addEverything().then =>
      @commit('Deploying').then =>
        @pushToMainBranch().then =>
          @showDeployLog()

  addEverything: ->
    deferred = Q.defer()

    gulp
      .src(ALL_FILES)
      .pipe(git.add())
      .pipe(callback(-> deferred.resolve()))

    deferred.promise

  commit: (msg) ->
    deferred = Q.defer()

    console.log 'commiting'
    stream = gulp
      .src(ALL_FILES)
      .pipe(git.commit(msg))

    stream.on 'end', ->
      console.log 'abc'
      deferred.resolve()

    deferred.promise

  pushToMainBranch: ->
    deferred = Q.defer()

    getMainBranch().then (main_branch) ->
      console.log "got #{main_branch}"
      push(main_branch).then ->
        deferred.resolve()

    deferred.promise
  getMainBranch: ->
    deferred = Q.defer()

    # get main branch from backend
    deferred.resolve('master')

    deferred.promise

  push: (branch) ->
    deferred = Q.defer()

    console.log "pushing #{branch}"
    git.push 'origin', branch, (err) ->
      throw err if err
      console.log 'done'

      deferred.resolve()

    deferred.promise

  showDeployLog: ->
    console.log('Deploying....')
    console.log('Should be done.')
