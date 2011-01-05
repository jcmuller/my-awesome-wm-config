-- aweswt.lua
local io     = io
local table  = table
local pairs  = pairs
local awful  = awful
local client = client
local string = string
local USE_T  = true

module("aweswt")

function get_out (a)
	local  f = io.popen (a)
	t = {}
	for line in f:lines() do
		table.insert(t, line )
	end
	return t
end

function get_input (a)
	local dmenu = "dmenu -nf '#888888' -nb '#222222' -sf '#ffffff' -sb '#285577' -p 'application:'  -i"
	s1 = 'echo -e "' .. a .. '" | ' .. dmenu
	return get_out(s1)
end

function switch()
	local clients = client.get()

	if table.getn(clients) == 0 then 
		return
	end

	local m1 = ""
	local t2 = {}
	local tmp

	for i, c in pairs(clients) do
		if USE_T then
			tmp = i..':'..string.sub(c['name'], 1, 20)
		else
			tmp = i..':'..c['instance']..'.'..c['class']
		end

		m1 = m1..tmp..'\n'

		t2[tmp] = c
	end

	local t6 = t2[get_input(m1)[1]]
	if t6 then
		local ctags = t6:tags()
		awful.tag.viewonly(ctags[1])
		client.focus = t6
		t6:raise()
	end
end

