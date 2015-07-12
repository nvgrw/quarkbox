os = require "os"
cp = require "child_process"
ph = require "path"
fs = require "fs"
packagePath = atom.packages.resolvePackagePath("quarkbox")

registerDefaults = ->
    switch os.platform()
        when "darwin" # Mac OS
            atom.config.setDefaults("quarkbox", "dosBoxExecutable": "/Applications/DOSBox.app/Contents/MacOS/DOSBox");
        when "win32" # Windows
            atom.config.setDefaults("quarkbox", "dosBoxExecutable": "%ProgramFiles(x86)%\\DOSBox-0.74\\DOSBox.exe");
        else # Possibly Linux, but I don't know the install directory
            atom.config.setDefaults("quarkbox", "dosBoxExecutable": "/");

quark = {
    kTPPath: ph.join(packagePath, ph.join("TP", "BIN"))
    kUtilPath: ph.join(packagePath, ph.join("UTIL"))
    kOutPath: ph.join(packagePath, ph.join("UTIL", "STDOUT"))
    kActionPath: ph.join(packagePath, ph.join("UTIL", "ACTION"))

    runAfterErrorCheck: false

    verifyFileType: (showErrorMessage = false) ->
        editor = atom.workspace.getActiveTextEditor()
        if editor
            path = editor.getPath()
            if path != null and ph.extname(path).toLowerCase() == ".pas"
                progName = ph.basename(path, ph.extname(path))
                newProgName = progName.replace(/\s/g, "_");
                if progName != newProgName # If there are spaces, we rename the file to have underscores. Also remove the original.
                    newPath = ph.join(ph.dirname(path), newProgName + ph.extname(path))
                    editor.saveAs(newPath)
                    fs.unlinkSync(path)
                    path = newPath;
                return [true, path]
        if showErrorMessage
            alert "Make sure that you are editing a TurboPascal .PAS file!"
        [false]

    launchDOS: (path, append, callback) ->
        dosexc = atom.config.get "quarkbox.dosBoxExecutable"
        config = ""
        if atom.config.get "quarkbox.overrideConfiguration"
            config = "-conf \"" + (atom.config.get "quarkbox.customConfigurationPath") + "\""

        cp.exec "\"#{dosexc}\" \
            " + config + " \
            -c \"MOUNT C \\\"#{@kTPPath}\\\"\" \
            -c \"MOUNT T \\\"#{@kUtilPath}\\\"\" \
            -c \"MOUNT A \\\"#{ph.dirname(path)}\\\"\" \
            -c \"A:\" " + append, {cwd: ph.dirname(path)}, callback

    getProgName: (path) ->
        progName = ph.basename(path, ph.extname(path))
        if progName.length > 8
            progName = progName.substr(0, 6) + "~1"
        progName

    build: (path) ->
        progName = quark.getProgName path
        if atom.config.get "quarkbox.saveBeforeBuild"
            editor = atom.workspace.getActiveTextEditor()
            if editor
                editor.save()

        quark.launchDOS path,
            "-c \"C:\\TPC.EXE \\\"#{progName}\\\" > T:\\STDOUT\" \
            -c \"EXIT\"", (err, sout, serr) =>
                if !err
                    quark.analyzeOutput(path)

    run: (path) ->
        progName = quark.getProgName path
        pause = ""
        if atom.config.get "quarkbox.pauseAfterRun"
            pause = "-c \"PAUSE\" "
        quark.launchDOS path,
            "-c \"@ECHO OFF\" \
            -c \"CLS\" \
            -c \"A:\\#{progName}.EXE\" " + pause + "-c \"EXIT\"", (err, sout, serr) =>

    analyzeOutput: (path) ->
        contents = fs.readFileSync @kOutPath, {encoding:"utf-8"}
        fs.unlinkSync(quark.kOutPath)

        errorMatch = contents.match(/Error\s[0-9]+:(.+)/i)
        lineNumberMatch = contents.match(/\(([0-9]+)\):/i)

        if errorMatch == null and lineNumberMatch == null
            if quark.runAfterErrorCheck
                quark.run(path)
        else
            errorMatch = errorMatch[0]
            lineNumberMatch = parseInt lineNumberMatch[0].substr(1, lineNumberMatch[0].length - 3)
            lastLine = contents.split("\n")
            lastLine = lastLine[lastLine.length - 1]
            errorX = lastLine.indexOf("^")

            if quark.verifyFileType(false)[0]
                editor = atom.workspace.getActiveTextEditor()
                editor.moveToTop()
                editor.moveDown(lineNumberMatch-1)
                if errorX >= 0
                    editor.moveRight(errorX)
                else
                    editor.moveToBeginingOfWord()
                editor.selectToEndOfLine()

            alert "Pascal compilation error:\n#{errorMatch}\n\nAn approximation of the affected area has been highlighted."
            atom.workspace.open(path)
}

module.exports =
    config:
        saveBeforeBuild:
            type: "boolean"
            default: true
            description: "Automatically saves file once build process started."
        pauseAfterRun:
            type: "boolean"
            default: true
            description: "Executes PAUSE after run to prevent DOSBox window from closing."
        dosBoxExecutable:
            type: "string"
            title: "DOSBox Executable"
            default: "/"
            description: "Path to the DOSBox executable. If you have a custom install location this will need to be changed, otherwise the defaults should suffice."
        overrideConfiguration:
            type: "boolean"
            default: false
            description: "(Optional) Override the configuration with a custom dosbox.conf file."
        customConfigurationPath:
            type: "string"
            description: "(Optional) Only necessary if overriding configuration."
            default: ""

    activate: (state) ->
        registerDefaults()
        atom.commands.add "atom-workspace", "quarkbox:buildrun", => @buildandrun()
        atom.commands.add "atom-workspace", "quarkbox:build", => @build()
        atom.commands.add "atom-workspace", "quarkbox:run", => @run()

    preInvoke: (postInvocation) ->
        if (verified = quark.verifyFileType(true))[0]
            postInvocation verified[1]

    build: ->
        quark.runAfterErrorCheck = false
        @preInvoke(quark.build)

    run: ->
        quark.runAfterErrorCheck = false
        @preInvoke(quark.run)

    buildandrun: ->
        quark.runAfterErrorCheck = true
        @preInvoke(quark.build)
