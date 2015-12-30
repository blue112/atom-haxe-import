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

        if !editor.lineTextForBufferRow(0).match(/^import/)
            imp += "\n"

        editor.setTextInBufferRange([[0, 0], [0, 0]], imp)
