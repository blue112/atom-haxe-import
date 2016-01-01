{CompositeDisposable, Point} = require 'atom'

module.exports = HaxeImport =
  haxeImportView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'haxe-import:import': => @import()

  deactivate: ->
    @subscriptions.dispose()

  import: ->
    if editor = atom.workspace.getActiveTextEditor()
        point = editor.getCursorBufferPosition()
        line = editor.lineTextForBufferRow(point.row)
        reg = /([a-z.]+)\.([A-Z][a-z]+)/
        matches = line.match(reg)
        if matches == null
          return 0

        startPos = line.search(reg)
        r = [[point.row, startPos], [point.row, startPos + matches[1].length + 1]]
        editor.setTextInBufferRange(r, "")

        # Add import
        imp = "import "+matches[0]+";\n"
        if editor.getText().match(new RegExp(imp))
            return

        editor.scan(new RegExp(matches[0], "g"), (o) ->
            o.replace(matches[2])
        )

        impMatch = editor.getText().search(/\nimport/)
        if impMatch != -1
          lineAt = editor.getText().substr(0, impMatch).split("\n").length
          editor.setTextInBufferRange([[lineAt, 0], [lineAt, 0]], imp)
          return

        # Let's check if there's a package line
        lineToAdd = 0
        packMatch = editor.getText().search(/\npackage/)
        if (packMatch == -1)
          packMatch = editor.getText().search(/^package/)

        if packMatch == -1
          editor.setTextInBufferRange([[0, 0], [0, 0]], imp)
        else
          lineAt = editor.getText().substr(0, packMatch).split("\n").length + 1

          imp = imp + "\n"

          editor.setTextInBufferRange([[lineAt, 0], [lineAt, 0]], imp)
