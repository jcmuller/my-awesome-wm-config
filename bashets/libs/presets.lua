-----------------------------------------------------------------------
-- Presets - forget about config syntax changes headache!
-- Simply a collection of common reusable snippets and best practices
-- All rights goes to original authors, but the copyright is for me :)
--
-- @author Anton Lobov &lt;ahmad200512@yandex.ru&gt;
-- @copyright 2009 Anton Lobov
-- @license GPLv2
-- @release for Awesome 3.4
----------------------------------------------------------------------

local awful = require("awful")
local type = type
local io = io
local os = os
local print = print
local beautiful = beautiful
local string = string

module("presets")

-- Things that could change
local theme_path1 = "/usr/share/awesome/themes/"
local theme_path2 = os.getenv("HOME") .. "/.config/awesome/themes/"

function locale()
	os.setlocale(os.getenv("LANG"))
end

function set_theme(theme, path)
	if path == nil then
		path = theme_path1 .. theme .. "/theme.lua"
		fl = io.open(path, "r")
		if (fl ~= nil) then
			io.close(fl)
		else
			path = theme_path2 .. theme .. "/theme.lua"
			fl = io.open(path, "r")
			if (fl ~= nil) then
				io.close(fl)
			else
				return print("E: presets: \"" .. path .. "\" is invalid theme path")
			end
		end
	else
		if string.find(path, '/$') == nil then
			path = path .. "/"
		end
		path = path .. theme .. "/theme.lua"
		fl = io.open(path, "r")
		if (fl ~= nil) then
			io.close(fl)
		else
			return print("E: presets: \"" .. path .. "\" is invalid theme path")
		end
	end
	if beautiful ~= nil then
		beautiful.init(path)
	else
		print("W: presets: setting theme with unloaded beautiful")
	end
end

function run_once(app)
	appname = string.gmatch(app, "(%w+)")()
	awful.util.spawn_with_shell("pgrep -u $USER -x " .. appname .. " || " .. app .. "")
end

function autorun(apps, flag)
	if flag == nil or flag == true then
		for idx = 1, #apps do
			run_once(apps[idx])
		end
	end
end

function runner(cmd)
	return function()
		awful.util.spawn_with_shell(cmd)
	end
end
