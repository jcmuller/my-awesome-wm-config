-- {{{ Libraries 
-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Revelation (https://github.com/bioe007/awesome-configs/blob/master/revelation.lua)
require("revelation")

--added by me
require("vicious")
--require("bashets")
require("aweswt")
-- support for awesome-client
require("awful.remote")
-- }}}
-- {{{ Variable Definitions
-- Themes define colours, icons, and wallpapers
--beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/default/theme.lua")
--beautiful.init("/usr/share/awesome/themes/sky/theme.lua")
--beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal         = "gnome-terminal"
terminal_xfce    = "xfce4-terminal"
terminal_sak     = "sakura"
editor           = "gvim"
browser_chrome   = "google-chrome"
browser_firefox  = "firefox"
position_firefox = "position_firefox.sh"
capture_task     = "capture_task.sh"
suspend          = "/usr/sbin/pm-suspend"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

local home   = os.getenv("HOME")
local exec   = awful.util.spawn
local sexec  = awful.util.spawn_with_shell

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
    awful.layout.suit.max,
    awful.layout.suit.floating,
    awful.layout.suit.magnifier,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max.fullscreen
}
-- }}}
-- {{{ Tags
-- Define a tag table which hold all screen tags.
labels1 = { "1", "2", "3", "4", "5", "6", "7"}

--tags = {}
--tags[1] = awful.tag(labels1, 1, awful.layout.suit.magnifier)
--tags[2] = awful.tag(labels2, 2, awful.layout.suit.floating)

tags = {
	settings = {
		{
			names  = labels1,
			layout = {
				layouts[3],
				layouts[1],
				layouts[3],
				layouts[2],
				layouts[2],
				layouts[3],
				layouts[3],
			}
		},
	}
}

for s = 1, screen.count() do
	tags[s] = awful.tag(tags.settings[s].names, s, tags.settings[s].layout)
end

--for s = 1, screen.count() do
--    -- Each screen has its own tag table.
--    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
--end
-- }}}
-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "xautolock lock now", "xautolock -enable; xautolock -locknow" },
   { "xlock", "xlock +usefirst -echokey '*' -echokeys -timeout 3 -lockdelay 5 -mode blank" },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu.new({
	auto_expand = true,
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "open firefox", browser_firefox },
		{ "open chrome", browser_chrome },
		{ "suspend", suspend },
		{ "open sakura", terminal_sak },
		{ "open xfce terminal", terminal_xfce },
		{ "open terminal", terminal },
	}
})

mylauncher = awful.widget.launcher({
	image = image(beautiful.awesome_icon),
	menu = mymainmenu
})

mpdmenu = awful.menu.new({
	auto_expand = true,
	items = {
		{ "toggle", "mpc toggle" },
		{ "pause",  "mpc pause"  },
		{ "play",   "mpc play"   },
		{ "next",   "mpc next"   },
		{ "prev",   "mpc prev"   },
		{ "choose", "mpc_dmenu"  },
		{ "MPD", ""  },
	}
})

pianobarmenu = awful.menu.new({
	auto_expand = true,
	items = {
		{ "toggle", "pianobar-toggle" },
		{ "status", "pianobar-status" },
		{ "pause",  "pianobar-pause" },
		{ "next",   "pianobar-next" },
		{ "love",   "pianobar-love" },
 		{ "ban",    "pianobar-ban" },
		{ "pianobar", ""  },
	}
})

-- }}}
-- {{{ Reusable separator
separator = widget({ type = "imagebox" })
separator.image = image(beautiful.widget_sep)
-- }}}
--{{{ Debug function
function dbg(vars)
	local text = ""
	for i=1, #vars do text = text .. vars[i] .. " | " end
	naughty.notify({ text = text, timeout = 0 })
end
--}}}
-- {{{ Wibox
-- {{{ Clock 
-- Create a textclock widget
myclock = awful.widget.textclock({ align = "right" }, " %a %D %I:%M%P %Z ")

awful.tooltip({
	objects = { myclock },
	timer_function = function ()
		return awful.util.pread("calendar2.pl")
	end,
})

local calendar = nil
function toggle_calendar()
	if not calendar then
		calendar = naughty.notify({
			text = awful.util.pread("calendar2.pl"),
			timeout = 0,
			title = "Calendar",
			run = function()
				hide_calendar()
			end
		})
	else
		hide_calendar()
	end
end

function hide_calendar()
	--clockclicked = false
	naughty.destroy(calendar)
	calendar = nil
end

--local clockclicked = false
myclock:buttons(awful.util.table.join(awful.button({}, 1, toggle_calendar)))

--myclock:add_signal("mouse::enter", show_calendar)
--myclock:add_signal("mouse::leave", function ()
--	if not clockclicked then
--		hide_calendar()
--	end
--end)
-- }}}
-- {{{ Systray 
-- Create a systray
mysystray = widget({ type = "systray" })
-- }}}
-- {{{ Task bar 
-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({        }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({        }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({        }, 4, awful.tag.viewnext),
                    awful.button({        }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))
-- }}}
-- {{{ Set Up
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        myclock, separator,
        s == 1 and mysystray or nil,
        s == 1 and separator or nil,
        mytasklist[s], separator,
        layout = awful.widget.layout.horizontal.rightleft
    }

end
-- }}}
-- }}}
-- {{{ My Wibox
------------------------------------
-- {{{ Functions that pop up
local topnotification = nil
function show_top_output()
	if not topnotification then
		topnotification = naughty.notify({
			text = awful.util.pread("top -bn1 | head -20"),
			timeout = 0,
			title = "Status",
			run = function()
				naughty.destroy(topnotification)
				topnotification = nil
			end
		})
	else
		naughty.destroy(topnotification)
		topnotification = nil
	end
end

local dfnotification = nil
function show_df_output()
	if not dfnotification then
		dfnotification = naughty.notify({
			text = awful.util.pread("df -P | sort -k5nr | fmt_sizes_df.pl"),
			timeout = 0,
			title = "File System",
			run = function()
				naughty.destroy(dfnotification)
				dfnotification = nil
			end
		})
	else
		naughty.destroy(dfnotification)
		dfnotification = nil
	end
end

	naughty.notify({
		text = content,
		timeout = 0,
		font = "Terminus 9",
		title = "File System"
	})
end

function show_mpd_menu()
	awful.menu.menu_keys.down  = { "Down",  "j" }
	awful.menu.menu_keys.up    = { "Up",    "k" }
	awful.menu.menu_keys.left  = { "Left",  "h" }
	awful.menu.menu_keys.right = { "Right", "l" }
	mpdmenu:toggle({ keygrabber = true })
end

function show_pianobar_menu()
	awful.menu.menu_keys.down  = { "Down",  "j" }
	awful.menu.menu_keys.up    = { "Up",    "k" }
	awful.menu.menu_keys.left  = { "Left",  "h" }
	awful.menu.menu_keys.right = { "Right", "l" }
	pianobarmenu:toggle({ keygrabber = true })
end

-- }}}
-- {{{ set vicious caching
vicious.cache(vicious.widgets.mem)
vicious.cache(vicious.widgets.cpu)
vicious.cache(vicious.widgets.cpufreq)
vicious.cache(vicious.widgets.uptime)
vicious.cache(vicious.widgets.fs)
vicious.cache(vicious.widgets.volume)
-- }}}
-- {{{ Battery 
baticon = widget({ type = "imagebox" })
baticon.image = image(beautiful.widget_bat)

batterywidget = widget({type = "textbox", name = "batterywidget", align="right"})
vicious.register(batterywidget, vicious.widgets.bat, "$1 $2% $3 ", 61, "BAT0")
 
batterybar = awful.widget.progressbar()
-- Progressbar properties
batterybar:set_width(8)
batterybar:set_vertical(true)
batterybar:set_background_color("#494B4F")
batterybar:set_border_color(nil)
batterybar:set_color("#AECF96")
batterybar:set_gradient_colors({ "#AECF96", "#88A175", "#FF5656" })
vicious.register(batterybar, vicious.widgets.bat, "$2", 61, "BAT0")

-- }}}
-- {{{ MPD
-- Initialize widget
mpdicon = widget({ type = "imagebox" })
mpdicon.image = image(beautiful.widget_music)

mpdwidget = widget({ type = "textbox" })
-- Register widget
--vicious.register(mpdwidget, vicious.widgets.mpd,
--    function (widget, args)
--        if args["{state}"] == "Stop" then 
--            return " - "
--        else 
--            return ' ' .. args["{Artist}"]..' (' .. args["{Album}"] .. ') - '.. args["{Title}"]
--        end
--    end, 10)
-- }}}
-- {{{ Memory & Swap
-- Initialize widget
memicon = widget({ type = "imagebox" })
memicon.image = image(beautiful.widget_mem)

memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, "$1% ($2MB/$3MB) ", 30)
--
-- Initialize widget
membar = awful.widget.progressbar()
-- Progressbar properties
membar:set_vertical(true)
--membar:set_ticks(true)
membar:set_width(8)
membar:set_background_color("#494B4F")
membar:set_border_color(nil)
membar:set_color("#AECF96")
membar:set_gradient_colors({ "#AECF96", "#88A175", "#FF5656" })
-- Register widget
vicious.register(membar, vicious.widgets.mem, "$1", 30)

-- Initialize widget
swapwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(swapwidget, vicious.widgets.mem, " <span color='yellow'>SW</span>: $5% ", 30)
--vicious.register(swapwidget, vicious.widgets.mem, " <b>SW</b>: $5% ($6<i>MB</i>/$7<i>MB</i>)", 13)

-- Initialize widget
swapbar = awful.widget.progressbar()
-- Progressbar properties
swapbar:set_vertical(true)
swapbar:set_width(8)
swapbar:set_background_color("#494B4F")
swapbar:set_border_color(nil)
swapbar:set_color("#AECF96")
swapbar:set_gradient_colors({ "#AECF96", "#88A175", "#FF5656" })
-- Register widget
vicious.register(swapbar, vicious.widgets.mem, "$5", 30)
-- }}}
-- {{{ CPU Info (usage & freq)
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.widget_cpu)

cpuwidget = widget({ type = "textbox" })
cpuwidget.width, cpuwidget.align = 30, "right"
vicious.register(cpuwidget, vicious.widgets.cpu, "$1% ", 10)

cpubar = awful.widget.graph()
cpubar:set_width(40)
cpubar:set_background_color("#494B4F")
cpubar:set_color("#FF5656")
cpubar:set_gradient_colors({ "#FF5656", "#88A175", "#AECF96" })
vicious.register(cpubar, vicious.widgets.cpu, "$1 ", 10)

cpufreq = widget({ type = "textbox" })
cpufreq.width, cpufreq.align = 50, "right"
vicious.register(cpufreq, vicious.widgets.cpufreq, "$1MHz ", 10, "cpu0")

-- }}}
-- {{{ Thermal
tempicon = widget({ type = "imagebox" })
tempicon.image = image(beautiful.widget_temp)

homeweather = widget({ type = "textbox" })
vicious.register(homeweather, vicious.widgets.weather, "<span color='yellow'>TET</span>: ${tempf}F", 300, "KTEB")

--coretemp = widget({ type = "textbox" })
--vicious.register(coretemp, vicious.widgets.thermal, "core: $1C", 3, "core")

--proctemp = widget({ type = "textbox" })
--vicious.register(proctemp, vicious.widgets.thermal, "proc: $1C", "proc")

--systemp = widget({ type = "textbox" })
--vicious.register(systemp, vicious.widgets.thermal, "sys: $1C", "sys")
-- }}}
-- {{{ Uptime
uptimewidget = widget({ type = "textbox" })
vicious.register(uptimewidget, vicious.widgets.uptime,
	function (widget, args)
		return string.format(" <span color='yellow'>UPT</span>: %2d<i>d</i> %02d<i>h</i> %02d<i>m</i>", args[1], args[2], args[3])
	end, 60)
	--
-- }}}
-- {{{ Load
loadwidget = widget({ type = "textbox" })
vicious.register(loadwidget, vicious.widgets.uptime,
	function (widget, args)
		return string.format(" <span color='yellow'>LD</span>: %0.2f %0.2f %0.2f", args[4], args[5], args[6])
	end, 60)
	--
-- }}}
-- {{{ FS
fsicon = widget({ type = "imagebox" })
fsicon.image = image(beautiful.widget_fs)
-- Initialize widget
fs = {
	r = awful.widget.progressbar(),
	h = awful.widget.progressbar(),
	s = awful.widget.progressbar(),
}
-- fs progressbar properties
for _, w in pairs(fs) do
	w:set_vertical(true)
	w:set_width(8)
	w:set_border_color(beautiful.border_widget)
	w:set_background_color(beautiful.fg_off_widget)
	w:set_gradient_colors({ beautiful.fg_widget,
		beautiful.fg_center_widget, beautiful.fg_end_widget
	})
	-- Register buttons
	w.widget:buttons(awful.util.table.join(awful.button(     { }, 1, show_df_output)))
end

vicious.register(fs.r, vicious.widgets.fs, "${/ used_p}",            599)
vicious.register(fs.h, vicious.widgets.fs, "${/home used_p}",        599)
vicious.register(fs.s, vicious.widgets.fs, "${/share used_p}", 599)
-- }}}
-- {{{ Weather
--ww = widget({type="textbox", name="ww"})
--bashets.register_async(ww, "forecast.sh", ' <span face="ConkyWeather" font="10" color="' .. bright_color .. '" weight="bold" rise="-1400">$1</span><span font="5"> </span><span rise="1400">$2</span>', 3600)
-- }}}
-- {{{ Volume 
volicon = widget({ type = "imagebox" })
volicon.image = image(beautiful.widget_vol)
--volicon.bg = 'white'
-- Initialize widgets
volbar    = awful.widget.progressbar()
volwidget = widget({ type = "textbox" })
-- Progressbar properties
volbar:set_vertical(true)
--volbar:set_ticks(true)
volbar:set_width(8)
--volbar:set_ticks_size(2)
volbar:set_background_color(beautiful.fg_off_widget)
volbar:set_gradient_colors({ beautiful.fg_widget,
   beautiful.fg_center_widget, beautiful.fg_end_widget
}) 
vicious.register(volbar,    vicious.widgets.volume,  "$1",  5, "Master")
vicious.register(volwidget, vicious.widgets.volume, " $1% ", 5, "Master")
-- }}}
-- {{{ Network usage
dnicon = widget({ type = "imagebox" })
upicon = widget({ type = "imagebox" })
dnicon.image = image(beautiful.widget_net)
upicon.image = image(beautiful.widget_netup)
-- Initialize widget
netwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(netwidget, vicious.widgets.net, '<span color="'
  .. beautiful.fg_netdn_widget ..'">${eth1 down_kb}</span> <span color="'
  .. beautiful.fg_netup_widget ..'">${eth1 up_kb}</span>', 5)
-- }}}
-- {{{ Register buttons

-- widgets that pop out 'top' output
widgets = {
	cpufreq,
	cpuicon,
	cpuwidget,
	loadwidget,
	memicon,
	memwidget,
	swapwidget,
	uptimewidget,
}

for i = 1, table.getn(widgets) do
	widgets[i]:buttons(awful.util.table.join(awful.button({ }, 1, show_top_output)))
end

volbar.widget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () exec("gnome-volume-control") end),
   awful.button({ }, 4, function () exec("amixer -q set Master 2dB+", false) end),
   awful.button({ }, 5, function () exec("amixer -q set Master 2dB-", false) end)
)) -- Register assigned buttons
volwidget:buttons(volbar.widget:buttons())

mpdwidget:buttons(awful.util.table.join(
    awful.button({ }, 1, show_mpd_menu),
    awful.button({ }, 3, show_mpd_menu)
))


-- }}}
-- {{{ Set up
mywibox2 = {}
mywibox2 = awful.wibox({ position = "bottom", screen = 1 })
mywibox2.widgets = {
	{
		-- Left to Right
		dnicon, netwidget, upicon,
		separator, memicon, memwidget, membar,
		separator, swapwidget, swapbar,
		separator, cpuicon, cpuwidget, cpufreq, cpubar,
		separator, uptimewidget,
		separator, loadwidget,
		separator, fsicon, fs.r.widget, fs.h.widget, fs.s.widget,
		separator, baticon, batterywidget, batterybar,
		separator, tempicon, homeweather,
		separator,
		layout = awful.widget.layout.horizontal.leftright
	},
	-- Right to Left
	volbar.widget, volwidget, volicon, separator,
	mpdwidget, mpdicon, separator, 
	layout = awful.widget.layout.horizontal.rightleft
}
-- }}}
-- }}}
-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}
-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w",
		function ()
			awful.menu.menu_keys.down  = { "Down",  "j" }
			awful.menu.menu_keys.up    = { "Up",    "k" }
			awful.menu.menu_keys.left  = { "Left",  "h" }
			awful.menu.menu_keys.right = { "Right", "l" }
			mymainmenu:toggle({ keygrabber = true, coords = { x = 525, y = 330 } })
			--mymainmenu:show({ keygrabber = true, coords = { x = 900, y = 330 } })
		end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- MPD menu
    awful.key({ modkey, "Shift"   }, "m", show_mpd_menu),
    -- pianobar
    awful.key({ modkey, "Shift"   }, "p", show_pianobar_menu),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
	-- Prompt with dmenu (install dmenu)
    awful.key({ modkey },            "p",
		function ()
			awful.util.spawn_with_shell( "exe=`dmenu_path | dmenu -nf '#888888' -nb '#222222' -sf '#ffffff' -sb '#285577'` && exec $exe")
		end),
	-- Switch apps with dmenu
	awful.key({ modkey },			"a",	aweswt.switch),
	-- LUA prompt
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

	-- Task list
	awful.key({ "Mod1" }, "Escape",
		function ()
			awful.menu.menu_keys.down  = { "Down",  "j" }
			awful.menu.menu_keys.up    = { "Up",    "k" }
			awful.menu.menu_keys.left  = { "Left",  "h" }
			awful.menu.menu_keys.right = { "Right", "l" }

			local cmenu = awful.menu.clients(
				{ width = 245 },
				{ keygrabber = true, coords = { x = 525, y = 330 } }
			)
			cmenu:geometry({x=100, y=200})
		end),

	-- Revelation
	awful.key({ modkey }, "e", revelation.revelation)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey, "Shift"   }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
    awful.key({ modkey,           }, "v",     function (c) c.maximized_vertical = not c.maximized_vertical end),
	awful.key({ modkey, "Shift", "Control" }, "Down",   function () awful.client.moveresize(0, 0,   0,  20) end),
	awful.key({ modkey, "Shift", "Control" }, "u",      function () awful.client.moveresize(0, 0,   0, -20) end),
	awful.key({ modkey, "Shift", "Control" }, "Right",  function () awful.client.moveresize(0, 0,  20,   0) end),
	awful.key({ modkey, "Shift", "Control" }, "Left",   function () awful.client.moveresize(0, 0, -20,   0) end),
	awful.key({ modkey, "Shift"   }, "Down",  function () awful.client.moveresize(  0,  20,   0,   0) end),
	awful.key({ modkey, "Shift"   }, "Up",    function () awful.client.moveresize(  0, -20,   0,   0) end),
	awful.key({ modkey, "Shift"   }, "Left",  function () awful.client.moveresize(-20,   0,   0,   0) end),
	awful.key({ modkey, "Shift"   }, "Right", function () awful.client.moveresize( 20,   0,   0,   0) end),
	awful.key({ modkey,           }, "t",
		function (c)
			if c.titlebar then
				awful.titlebar.remove(c)
			else
				awful.titlebar.add(c, { modkey = modkey })
			end
		end
	),
	awful.key({ modkey,           }, "s", function (c) c.sticky = not c.sticky end),
    awful.key({ modkey, "Control"   }, "t",  capture_task),
	awful.key({ modkey,           }, "i",
		function (c)
			local geom = c:geometry()

			local t = ""
			if c.class    then t = t .. "<b>Class</b>: "    .. c.class    .. "\n" end
			if c.instance then t = t .. "<b>Instance</b>: " .. c.instance .. "\n" end
			if c.role     then t = t .. "<b>Role</b>: "     .. c.role     .. "\n" end
			if c.name     then t = t .. "<b>Name</b>: "     .. c.name     .. "\n" end
			if c.type     then t = t .. "<b>Type</b>: "     .. c.type     .. "\n" end
			if
				geom.width and
				geom.height and
				geom.x and geom.y
				then
				t = t .. "<b>Dimensions</b>: <b>x</b>:" .. geom.x .. "<b> y</b>:" .. geom.y .. "<b> w</b>:" .. geom.width .. "<b> h</b>:" .. geom.height
			end

			naughty.notify({
				text = t,
				timeout = 30
			})
		end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Mod1" }, "#" .. i + 9,
                  function ()
					  for s = 1, screen.count() do
						  awful.tag.viewonly(tags[s][i])
					  end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}
-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    {
		rule = { },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = true,
			keys = clientkeys,
			buttons = clientbuttons,
			size_hints_honor = false,
            maximized_horizontal = false,
            maximized_vertical   = false
		}
	},
	{
		rule = { class = "MPlayer" },
		properties = { floating = true }
	},
	{
		rule = { class = "Clock" },
		properties = { floating = true }
	},
	{
		rule = { class = "XClock" },
		properties = { floating = true }
	},
	{
		rule = { class = "pinentry" },
		properties = { floating = true }
	},

	{
		rule = { class = "Gimp" },
		properties = { floating = true },
		callback = awful.titlebar.add
	},
	{
		rule = { role = "gimp-toolbox" },
		properties = {
			floating = true,
			ontop = true
		},
		callback = function (c)
			c:geometry({x=0, y=19, width=224, height=523})
		end
	},
	{
		rule = { role = "gimp-dock" },
		properties = {
			floating = true,
			ontop = true
		},
		callback = function (c)
			c:geometry({x=0, y=542, width=224, height=506})
		end
	},

	{
		rule = { class = "Eog" },
		properties = { floating = true },
		callback = awful.titlebar.add
	},
	{
		rule = { class = "display" },
		properties = { floating = true },
		callback = awful.titlebar.add
	},
	{
		rule = { class = "FbPager" },
		properties = {
			floating = true,
			ontop = true
		},
		callback = function (c)
			c:geometry({x=1272, y=1026, width=406, height=22})
		end
	},
	{
		rule = { class = "Gvim" },
		--properties = { floating = true },
		--callback = awful.titlebar.add
	},
	{
		rule = { class = "Gtg" },
		properties = { floating = true }
	},
	{
		rule = { class = "Evince" },
		properties = { floating = true }
	},
	{
		rule = { class = "Ktimetracker" },
		properties = {
			floating = true
		},
		callback = function (c)
			c:geometry({x=1680, y=19, width=450, height=400})
		end
	},
	{
		rule = { class = "Gdesklets-daemon" },
		properties = {
			focus = false,
			floating = true,
			ontop = true
		},
		callback = function (c)
			c:geometry({x=2444, y=1003, width=136, height=136})
		end
	},
	{
		rule = { class = "Skype", role = "MainWindow" },
		properties = {
			floating = true,
			ontop = true,
			tag = tags[1][4]
		},
		callback = function (c)
			c:geometry({x=2336, y=18, width=244, height=448})
		end
	},
	{
		rule = { class = "Skype", role = "Chats" },
		properties = {
			floating = false,
			tag = tags[1][4]
		},
		callback = function (c)
			c:geometry({width=515, height=252})
		end
	},
	{
		rule = { class = "Pidgin", role = "buddy_list" },
		properties = {
			floating = true,
			ontop = true,
			tag = tags[1][5]
		},
		callback = function (c)
			c:geometry({x=2336, y=18, width=244, height=448})
		end
	},
	{
		rule = { class = "Pidgin", role = "conversation" },
		properties = {
			floating = false,
			tag = tags[1][5]
		},
		callback = function (c)
			c:geometry({width=515, height=252})
		end
	},
	{
		rule = { class = "Firefox", instance = "Navigator" },
		callback = function (c)
			--c:geometry({x=1680, y=170, width=1120, height=878})
			c:geometry({x=1680, y=20, width=897, height=923})
		end
	}
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}
-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they do not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus",   function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
-- {{{ Autostart
function run_once(prg)
	if not prg then
		do return nil end
	end
	awful.util.spawn_with_shell("pgrep -u $USER -x " .. prg .. " || (" .. prg .. ")")
end

-- Clipboard Manager
--os.execute("klipper &")
--os.execute("parcellite &")
run_once("parcellite")
-- Network Manager
os.execute("nm-applet &")
-- Power Manager
--os.execute("jupiter.exe &")
run_once("jupiter")
-- Set caps lock as control
os.execute("xmodmap ~/.Xmodmap &")
-- Gnome settings
os.execute("gnome-power-manager &")
--os.execute("xfce-power-manager &")
-- Gnome settings
os.execute("/usr/lib/gnome-settings-daemon/gnome-settings-daemon &")
-- First terminal
--os.execute("gnome-terminal &")
run_once("gnome-terminal")
-- }}}

-- vim:set foldmethod=marker noexpandtab sw=4 ts=4:
