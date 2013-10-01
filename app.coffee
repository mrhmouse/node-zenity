{ spawn } = require 'child_process'

class Command
	constructor: ( options... ) ->
		@process = spawn 'zenity', options

	send: ( data, f ) =>
		buffer = new Buffer data.toString() + '\n\n'
		@process.stdin.write buffer, f
		return

	receive: ( f ) =>
		@process.stdout.on 'data', f
		return

	close: ( f ) =>
		if f? and typeof f is 'function'
			@process.on 'close', ( code ) ->
				status =
					ok: code is 0
					cancel: code is 1
					timeout: code is 5
				f status
		else
			@process.stdin.end f
		return

extend = ( name ) ->
	class CommandSubtype extends Command
		constructor: ( options... ) ->
			super "--#{ name }", options...

for own key, name of {
Calendar: 'calendar'
Entry: 'entry'
Error: 'error'
FileSelection: 'file-selection'
Info: 'info'
List: 'list'
Notification: 'notification'
Progress: 'progress'
Question: 'question'
TextInfo: 'text-info'
Warning: 'warning'
Scale: 'scale'
ColorSelection: 'color-selection'
Password: 'password'
Forms: 'forms'
} then module.exports[key] = extend name
