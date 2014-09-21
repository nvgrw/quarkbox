os = require "os"
cp = require "child_process"
ph = require "path"
fs = require "fs"

switch os.platform()
    when "darwin" # Mac OS
        atom.config.setDefaults("quarkbox", DosBoxExecutable: "/Applications/DOSBox.app/Contents/MacOS/DOSBox");
    when "win32" # Windows
        atom.config.setDefaults("quarkbox", DosBoxExecutable: "C:\\Program Files (x86)\\DOSBox-0.74");
    else # Possibly Linux, but I don't know the install directory
        atom.config.setDefaults("quarkbox", DosBoxExecutable: "/");

quark = {
    kTPPath: ph.join(atom.packages.resolvePackagePath("quarkbox"), ph.join("TP", "BIN"))
    kUtilPath: ph.join(atom.packages.resolvePackagePath("quarkbox"), ph.join("UTIL"))
    kOutPath: ph.join(atom.packages.resolvePackagePath("quarkbox"), ph.join("UTIL", "STDOUT"))
    kActionPath: ph.join(atom.packages.resolvePackagePath("quarkbox"), ph.join("UTIL", "ACTION"))

    runAfterErrorCheck: false

    verifyFileType: (showErrorMessage = false) ->
        editor = atom.workspace.getActiveTextEditor()
        if editor
            path = editor.getPath()
            if path != null and ph.extname(path).toLowerCase() == ".pas"
                return [true, path]
        if showErrorMessage
            alert "Make sure that you are compiling a .pas file!"
        [false]

    build: (path) ->
        progName = ph.basename(path, ph.extname(path))
        dosexc = atom.config.get "quarkbox.DosBoxExecutable"
        cp.exec "#{dosexc} \
            -c \"MOUNT C #{@kTPPath}\" \
            -c \"MOUNT T #{@kUtilPath}\" \
            -c \"MOUNT A #{ph.dirname(path)}\" \
            -c \"A:\" \
            -c \"C:\\TPC.EXE #{progName} > T:\\STDOUT\" \
            -c \"EXIT\"",
            {cwd: ph.dirname(path)}, (err, sout, serr) =>
                if !err
                    @analyzeOutput(path)

    run: (path) ->
        progName = ph.basename(path, ph.extname(path))
        dosexc = atom.config.get "quarkbox.DosBoxExecutable"
        cp.exec "#{dosexc} \
            -c \"MOUNT C #{@kTPPath}\" \
            -c \"MOUNT T #{@kUtilPath}\" \
            -c \"MOUNT A #{ph.dirname(path)}\" \
            -c \"A:\" \
            -c \"@ECHO OFF\" \
            -c \"CLS\" \
            -c \"A:\\#{progName}\" \
            -c \"PAUSE\" \
            -c \"EXIT\"",
            {cwd: ph.dirname(path)}, (err, sout, serr) =>

    analyzeOutput: (path) ->
        contents = fs.readFileSync @kOutPath, {encoding:"utf-8"}
        fs.unlink(@kOutPath)

        errorMatch = contents.match(/Error\s[0-9]+:(.+)/i)
        lineNumberMatch = contents.match(/\(([0-9]+)\):/i)

        if errorMatch == null and lineNumberMatch == null
            if @runAfterErrorCheck
                @run(path)
        else
            errorMatch = errorMatch[0]
            lineNumberMatch = parseInt lineNumberMatch[0].substr(1, lineNumberMatch[0].length - 3)
            lastLine = contents.split("\n")
            lastLine = lastLine[lastLine.length - 1]
            errorX = lastLine.indexOf("^")

            if @verifyFileType(false)[0]
                editor = atom.workspace.getActiveTextEditor()
                editor.moveToTop()
                editor.moveDown(lineNumberMatch-1)
                if errorX >= 0
                    editor.moveRight(errorX)
                else
                    editor.moveToBeginingOfWord()
                editor.selectToEndOfLine()

            alert "Pascal compilation error:\n#{errorMatch}\n\nThe affected area has been highlighted"
            atom.workspace.open(path)
}

module.exports =
    activate: ->
        atom.workspaceView.command "quarkbox:buildandrun", => @buildandrun()
        atom.workspaceView.command "quarkbox:build", => @build()

    buildInvoke:->
        if (verified = quark.verifyFileType(true))[0]
            quark.build verified[1]

    buildandrun: ->
        quark.runAfterErrorCheck = true
        @buildInvoke()

    build: ->
        quark.runAfterErrorCheck = false
        @buildInvoke()