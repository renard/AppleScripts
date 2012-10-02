-- -*- applescript -*-
(*

Find Safari Tabs -- Switch from Safari tabs like Emacs buffers.

Copyright © 2010 Sebastien Gross <seb•ɑƬ•chezwam•ɖɵʈ•org>
Author: Sebastien Gross <seb•ɑƬ•chezwam•ɖɵʈ•org>
Keywords: Safari, tabs
Created: 2012-08-21
Last changed: 2012-10-02 10:10:28
Licence: WTFPL, grab your copy here: http://sam.zoy.org/wtfpl/

Commentary:

This script is meant to be run with an Automator Application Service.

- Create a new Automator Service.
- Be sure the service is set to receive no input and is defined to be run in
  Safari.App.
- Drag a "Run AppleScript" block into the workflow.
- Copy that file in the "Run AppleScript" block.
- Save project as "Find Safari Tab"
- Open the System Preference panel and search for Keyboard / Keyboard
  Shortcuts.
- Select the "Service" item.
- Assign a keyboard shortcut to the "Find Safari Tab" Service.


Known limitation:

- works only within the current Safari window

  *)

on run {input, parameters}
	tell application "Safari"
		
		set question to display dialog ("Find Safari tab matching both URL or name:") default answer "" with title "Safari tab switch"
		set searchpat to text returned of question
		
		if ((button returned of question) is not "OK") or (searchpat is "") then
			return 0
		end if
		
		set text_list to {}
		set sep to " "

		set w to window 1
		repeat with t in tabs of window 1
			set tabName to name of t
			try
				set tabURL to URL of t
			on error errmsg
				set tabURL to ""
			end try
			try
				if (searchpat is in tabURL) then
				   set end of text_list to tabURL & sep & (id of w as string) & sep & (index of t as string)
				else if (searchpat is in tabName) then
				   set end of text_list to tabName & sep & (id of w as string) & sep & (index of t as string)
				end if
			end try
		end repeat		
		
		if (count of text_list) = 0 then
			return 0
		end if
		
		set AppleScript's text item delimiters to sep
		if (count of text_list) = 1 then
			set ret_str to text items of (text_list as string)
		else
			set ret to choose from list of text_list with prompt "The following tabs match, please select one:" with title "Safari tab switch"
			if ret is false then
				return 0
			end if
			set ret_str to text items of (ret as string)
		end if
		
		set w to (item 2 of ret_str) as integer
		set t to (item 3 of ret_str) as integer
		set current tab of window id w to tab t of window id w
		set index of window id w to 1
	end tell
	return input
end run
