module.exports =
    activate: ->
        atom.workspaceView.command "quarkbox:build", => @build

    build: ->
        console.log "It sure works tehee"