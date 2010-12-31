--MyAW - My Awesome Widgets

local awful = require("awful")
local awful = require("awful")
local placement = require("awful.placement")
local naughty = require("naughty")
local pairs = pairs
local mouse = mouse
local screen = screen
local os = os
local math = math
local string = string
local image = image
local beautiful = beautiful

module("myaw")

--================= Calendar widget

-- Variables
calendar = {}
calendar.actions = {}
calendar.options = {}
calendar.options.position = naughty.config.presets.normal.position or "top_right"

-- Implementation
local calendar_impl = {}
--calendar_impl.saved_naughty_pos = naughty.config.presets.normal.position
calendar_impl.offset = 0
function calendar_impl.show(offset)
    if offset == nil then
	    offset = 0
    end

    local tmp = calendar_impl.offset
    calendar_impl.hide()
    local datespec = os.date("*t")
    calendar_impl.offset = tmp - offset
    datespec = datespec.year * 12 + datespec.month - 1 + calendar_impl.offset
    datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
    local cal = awful.util.pread("cal -m " .. datespec)
    cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
    today = os.date("%e")
    year = os.date("%Y")
--    cal = string.gsub(cal, "[ \n^]" .. today .. "[ \n$]", "<span weight=\"bold\">%1</span>")
--    cal = string.gsub(cal, "[ \n^]" .. today .. "[ \n$]", "<span color=\""..bright_color.."\" bgcolor=\"#5e656f\">%1</span>")
    cal = string.gsub(cal, "[ \n^]" .. today .. "[ \n$]", "<span bgcolor=\"#5e656f\">%1</span>")
    cal = string.gsub(cal, ".*%s%d%d%d%d", "    <span weight=\"bold\">%1</span>")
--    cal = string.gsub(cal, ".*%s%d%d%d%d", "    <span color=\""..bright_color.."\">%1</span>")

    
    calendar_impl.saved_naughty_pos = naughty.config.presets.normal.position
    naughty.config.presets.normal.position = calendar.options.position
    calendar_impl.nf = naughty.notify({
    text = string.format('<span font_desc="%s">%s</span>', "monospace",  cal),
    timeout = 0, hover_timeout = 0.5,
    width = 160,
    })
    naughty.config.presets.normal.position = calendar_impl.saved_naughty_pos
end
function calendar_impl.hide()
    if calendar_impl.nf ~= nil then
        naughty.destroy(calendar_impl.nf)
	calendar_impl.nf = nil
        calendar_impl.offset = 0
    end
end


-- Public interface
function calendar.actions.show()
	calendar_impl.show(0)
end
function calendar.actions.prev()
	calendar_impl.show(-1)
end
function calendar.actions.next()
	calendar_impl.show(1)
end
function calendar.actions.hide()
	calendar_impl.hide()
end

----========== Coverart widget

-- Variables
coverart = {}
coverart.actions = {}
coverart.options = {}
coverart.options.position = naughty.config.presets.normal.position or "bottom_left"

-- Implementation and public interface
function coverart.actions.update()
	local img = awful.util.pread("/home/anton/coverart.sh")
	coverart.image = image(img)
	coverart.text = awful.util.pread("/home/anton/mpdinfo.sh")
end

function coverart.actions.show()
	coverart.saved_naughty_pos = naughty.config.presets.normal.position
	naughty.config.presets.normal.position = coverart.options.position
	coverart.nf = naughty.notify({icon = coverart.image, icon_size = 100, text = coverart.text})
    	naughty.config.presets.normal.position = coverart.saved_naughty_pos
end

function coverart.actions.popup()
	coverart.actions.update()
	coverart.actions.show()
end

function coverart.actions.hide()
    if coverart.nf ~= nil then
	    naughty.destroy(coverart.nf)
    end
end
