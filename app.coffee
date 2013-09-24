{ exec } = require 'child_process'

module.exports = Zenity = {}

ZENITY = 'zenity'

run = ( mode, opts, callback ) ->
	exec "#{ ZENITY } #{ mode } #{ opts.join ' ' }", callback

bind = ( name, map, handler ) -> ( o, callback ) ->
	opts = []
	if typeof o is 'object'
		for own key, getter of map
			if o[key]?
				opts.push getter o[key]
	else unless typeof callback is 'function'
		callback = o
	run "--#{ name }", opts, ( error, stdout ) ->
		throw error if error?
		if handler? and callback?
			process.nextTick -> handler stdout, callback

	return

fix = ( text ) ->
	fixed = text.replace '"', '\\"'
	fixed = fixed.replace '\n', '\\n'
	"\"#{ fixed }\""

Zenity.calendar = bind 'calendar',
	text: ( v ) -> "--text=#{ fix v }"
	day: ( v ) -> "--day=#{ v }"
	month: ( v ) -> "--month=#{ v }"
	year: ( v ) -> "--year=#{ v }"
	dateFormat: ( v ) -> "--date-format=#{ fix v }"
	( date, cb ) -> cb new Date date.toString()

Zenity.entry = bind 'entry',
	text: ( v ) -> "--text=#{ fix v }"
	entryText: ( v ) -> "--entry-text=#{ fix v }"
	hideText: -> '--hide-text'
	( answer, cb ) -> cb answer

Zenity.error = bind 'error',
	text: ( v ) -> "--text=#{ fix v }"
	noWrap: -> '--no-wrap'
	noMarkup: -> '--no-markup'

Zenity.fileSelection = bind 'file-selection',
	filename: ( v ) -> "--filename=#{ fix v }"
	multiple: -> '--multiple'
	directory: -> '--directory'
	save: -> '--save'
	separator: ( v ) -> "--separator=#{ fix v }"
	confirmOverwrite: -> '--confirm-overwrite'
	fileFilter: ( v ) -> "--file-filter=#{ fix v }"
	( file, cb ) -> cb file

Zenity.info = bind 'info',
	text: ( v ) -> "--text=#{ fix v }"
	noWrap: -> '--no-wrap'
	noMarkup: -> '--no-markup'

Zenity.question = bind 'question',
	text: ( v ) -> "--text=#{ fix v }"
	noWrap: -> '--no-wrap'
	noMarkup: -> '--no-markup'
	okLabel: ( v ) -> "--ok-label=#{ fix v }"
	cancelLabel: ( v ) -> "--cancel-label=#{ fix v }"

Zenity.textInfo = bind 'text-info',
	filename: ( v ) -> "--filename=#{ fix v }"
	editable: -> '--editable'
	checkbox: ( v ) -> "--checkbox=#{ fix v }"
	okLabel: ( v ) -> "--ok-label=#{ fix v }"
	cancelLabel: ( v ) -> "--cancel-label=#{ fix v }"

Zenity.warning = bind 'warning',
	text: ( v ) -> "--text=#{ fix v }"
	noWrap: -> '--no-wrap'
	noMarkup: -> '--no-markup'

Zenity.colorSelection = bind 'color-selection',
	color: ( v ) -> "--color=#{ v }"
	showPalette: -> '--show-palette'

Zenity.password = bind 'password',
	username: -> '--username'

# Progress & notification are interactive

# Zenity.scale = bind 'scale',

# Zenity.list = bind 'list',

# Zenity.forms = bind 'forms',
