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
	error: code not in [ 0, 1, 5 ]

# Pass only the status to a callback
statusOnly = ( status, stdout, cb ) -> cb status

# Do some transformation on the output and pass it on
transform = ( f ) -> ( status, stdout, cb ) -> cb status, f stdout

# Pass arguments unchanged to a callback
passThrough = transform ( v ) -> v

# Wrap a commandline argument and pass as an option
option = ( name ) -> ( v ) -> "--#{ name }=#{ fix v }"

# A commandline flag (no argument)
flag = ( name ) -> "--#{ name }"

Zenity.calendar = bind 'calendar',
	text: option 'text'
	day: option 'day'
	month: option 'month'
	year: option 'year'
	dateFormat: option 'date-format'
	transform ( date ) -> new Date date.toString()

Zenity.entry = bind 'entry',
	text: option 'text'
	entryText: option 'entry-text'
	hideText: flag 'hide-text'
	passThrough

Zenity.error = bind 'error',
	text: option 'text'
	noWrap: flag 'no-wrap'
	noMarkup: flag 'no-markup'
	statusOnly

Zenity.fileSelection = bind 'file-selection',
	filename: option 'filename'
	multiple: flag 'multiple'
	directory: flag 'directory'
	save: flag 'save'
	separator: option 'separator'
	confirmOverwrite: flag 'confirm-overwrite'
	fileFilter: option 'file-filter'
	passThrough

Zenity.info = bind 'info',
	text: option 'text'
	noWrap: flag 'no-wrap'
	noMarkup: flag 'no-markup'
	statusOnly

Zenity.question = bind 'question',
	text: option 'text'
	noWrap: flag 'no-wrap'
	noMarkup: flag 'no-markup'
	okLabel: option 'ok-label'
	cancelLabel: option 'cancel-label'
	statusOnly

Zenity.textInfo = bind 'text-info',
	filename: option 'filename'
	editable: flag 'editable'
	checkbox: option 'checkbox'
	okLabel: option 'ok-label'
	cancelLabel: option 'cancel-label'
	statusOnly

Zenity.warning = bind 'warning',
	text: option 'text'
	noWrap: flag 'no-wrap'
	noMarkup: flag 'no-markup'
	statusOnly

Zenity.colorSelection = bind 'color-selection',
	color: option 'color'
	showPalette: flag 'show-palette'
	passThrough

Zenity.password = bind 'password',
	username: flag 'username'
	passThrough

Zenity.scale = bind 'scale',
	text: ( v ) -> "--text=#{ fix v }"
	value: ( v ) -> "--value=#{ fix v }"
	minValue: ( v ) -> "--min-value=#{ fix v }"
	maxValue: ( v ) -> "--max-value=#{ fix v }"
	step: ( v ) -> "--step=#{ fix v }"
	printPartial: -> '--print-partial'
	hideValue: -> '--hide-value'
	passThrough

Zenity.forms = bind 'forms',
	text: ( v ) -> "--text=#{ fix v }"
	separator: ( v ) -> "--separator=#{ fix v }"
	dateFormat: ( v ) -> "--forms-date-format=#{ fix v }"
	entries: ( entries ) ->
		entries.map(( e ) -> "--add-entry=#{ fix e }")
			.join ' '
	passwords: ( entries ) ->
		entries.map(( e ) -> "--add-password=#{ fix e }")
			.join ' '
	calendars: ( entries ) ->
		entries.map(( e ) -> "--add-calendar=#{ fix e }")
			.join ' '

# Zenity.list = bind 'list',

# Progress & notification are interactive
