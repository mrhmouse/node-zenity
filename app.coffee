{ exec } = require 'child_process'

module.exports = Zenity = {}

ZENITY = 'zenity'

# Run a command
run = ( mode, opts, callback ) ->
	exec "#{ ZENITY } #{ mode } #{ opts.join ' ' }", callback

# Bind a name and some options to a handler
bind = ( name, map, handler ) -> ( o, callback ) ->
	opts = []
	if typeof o is 'object'
		for own key, getter of map
			if o[key]?
				opts.push getter o[key]
	else unless typeof callback is 'function'
		callback = o
	run "--#{ name }", opts, ( error, stdout ) ->
		code = unless error?
			0
		else
			error.code

		if handler? and callback?
			process.nextTick -> handler ( status code ), stdout, callback
	return

# Fix the spaces in a string for the commandline
fix = ( text ) ->
	fixed = text.replace '"', '\\"'
	fixed = fixed.replace '\n', '\\n'
	"\"#{ fixed }\""

# Make a zenity status code human readable
status = ( code ) ->
	cancel: code is 1
	timeout: code is 5
	success: code is 0

# Pass only the status to a callback
statusOnly = ( status, stdout, cb ) -> cb status

# Pass arguments unchanged to a callback
passThrough = ( status, stdout, cb ) -> cb status, stdout

Zenity.calendar = bind 'calendar',
	text: ( v ) -> "--text=#{ fix v }"
	day: ( v ) -> "--day=#{ v }"
	month: ( v ) -> "--month=#{ v }"
	year: ( v ) -> "--year=#{ v }"
	dateFormat: ( v ) -> "--date-format=#{ fix v }"
	( status, date, cb ) ->
		cb status, new Date date.toString()

Zenity.entry = bind 'entry',
	text: ( v ) -> "--text=#{ fix v }"
	entryText: ( v ) -> "--entry-text=#{ fix v }"
	hideText: -> '--hide-text'
	passThrough

Zenity.error = bind 'error',
	text: ( v ) -> "--text=#{ fix v }"
	noWrap: -> '--no-wrap'
	noMarkup: -> '--no-markup'
	statusOnly

Zenity.fileSelection = bind 'file-selection',
	filename: ( v ) -> "--filename=#{ fix v }"
	multiple: -> '--multiple'
	directory: -> '--directory'
	save: -> '--save'
	separator: ( v ) -> "--separator=#{ fix v }"
	confirmOverwrite: -> '--confirm-overwrite'
	fileFilter: ( v ) -> "--file-filter=#{ fix v }"
	passThrough

Zenity.info = bind 'info',
	text: ( v ) -> "--text=#{ fix v }"
	noWrap: -> '--no-wrap'
	noMarkup: -> '--no-markup'
	statusOnly

Zenity.question = bind 'question',
	text: ( v ) -> "--text=#{ fix v }"
	noWrap: -> '--no-wrap'
	noMarkup: -> '--no-markup'
	okLabel: ( v ) -> "--ok-label=#{ fix v }"
	cancelLabel: ( v ) -> "--cancel-label=#{ fix v }"
	statusOnly

Zenity.textInfo = bind 'text-info',
	filename: ( v ) -> "--filename=#{ fix v }"
	editable: -> '--editable'
	checkbox: ( v ) -> "--checkbox=#{ fix v }"
	okLabel: ( v ) -> "--ok-label=#{ fix v }"
	cancelLabel: ( v ) -> "--cancel-label=#{ fix v }"
	statusOnly

Zenity.warning = bind 'warning',
	text: ( v ) -> "--text=#{ fix v }"
	noWrap: -> '--no-wrap'
	noMarkup: -> '--no-markup'
	statusOnly

Zenity.colorSelection = bind 'color-selection',
	color: ( v ) -> "--color=#{ v }"
	showPalette: -> '--show-palette'
	passThrough

Zenity.password = bind 'password',
	username: -> '--username'
	passThrough

# Progress & notification are interactive

# Zenity.scale = bind 'scale',

# List takes arguments without flags
# Zenity.list = bind 'list',

# Zenity.forms = bind 'forms',
