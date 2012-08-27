-- -*- applescript -*-
(*

Find iTerm Session -- Switch to iTerm session like Emacs buffers.

Copyright © 2010 Sebastien Gross <seb•ɑƬ•chezwam•ɖɵʈ•org>
Author: Sebastien Gross <seb•ɑƬ•chezwam•ɖɵʈ•org>
Keywords: Google Chrome, tabs
Created: 2012-08-21
Last changed: 2012-08-27 18:53:15
Licence: WTFPL, grab your copy here: http://sam.zoy.org/wtfpl/

Commentary:

This script is meant to be run with an Automator Application Service.

- Create a new Automator Service.
- Be sure the service is set to receive no input and is defined to be run in
  iTerm.App.
- Drag a "Run AppleScript" block into the workflow.
- Copy that file in the "Run AppleScript" block.
- Save project as "iTerm Find Session"
- Open the System Preference panel and search for Keyboard / Keyboard
  Shortcuts.
- Select the "Service" item.
- Assign a keyboard shortcut to the "iTerm Find Session" Service.

*)

on run {input, parameters}
	
	
	tell application "iTerm"
		
		set question to display dialog ("Find iTerm session with name matches:") default answer "" with title "iTerm Session switch"
		set searchpat to text returned of question
		
		if ((button returned of question) is not "OK") or (searchpat is "") then
			return 0
		end if
		
		set s_list to {}
		set sep to " "
		repeat with t in terminals
			tell t
				repeat with s in sessions
					set _name to (get name of s)
					set _tty to (get tty of s)
					-- Would be better to find window 1
					-- and session number like in expose
					--
					-- Following leads to an error:
					-- set _number to (number of s)
					-- error "iTerm got an error: AppleEvent handler failed." number -10000
					if (searchpat is in _name) then
						set end of s_list to (_tty as string) & sep & _name
					end if
				end repeat
			end tell
		end repeat
		
		
		if (count of s_list) = 0 then
			return 0
		end if
		
		set AppleScript's text item delimiters to sep
		if (count of s_list) = 1 then
			set ret_str to text items of (s_list as string)
		else
			set ret to choose from list of s_list with prompt "The following sessions match, please select one:" with title "iTerm Session switch"
			if ret is false then
				return 0
			end if
			set ret_str to text items of (ret as string)
		end if
		set s_tty to (item 1 of ret_str)
		
		-- display dialog "Wanted tty: " & s_tty
		repeat with t in terminals
			tell t
				repeat with s in sessions
					if (get tty of s) = s_tty then
						-- display dialog "SElecting " & (get tty of s) & " (" & s_tty & ")"
						select s
						return
					end if
				end repeat
			end tell
		end repeat
		
	end tell
	return input
end run
