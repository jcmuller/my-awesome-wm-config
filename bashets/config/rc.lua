-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
require("awful.tooltip")
require("awful.placement")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
-- Bashets
require("bashets")
-- My Awesome Widgets
require("myaw")
-- fd.org menu
require("freedesktop.menu")
-- Presets
require("presets")

local capi = { screen = screen,
               awesome = awesome,
               dbus = dbus,
               widget = widget,
               wibox = wibox,
               image = image,
               timer = timer }

-- {{{ Variable definitions
-- Global variables
bright_color="#000000"   -- Color to highlight widget elements
modkey = "Mod4"          -- Default modkey

-- Do some obvious things
presets.locale()                      -- Set correct locale
presets.set_theme("strict")           -- Set beautiful theme
presets.autorun({                     -- Autorun apps
	"xcompmgr",
	"xscreensaver -no-splash",
--	"xbindkeys",
	"wmname LG3D"
--	"xxkb"
--	"ivman"
})
local run = presets.runner

-- Commands table
local commands = {}
commands.terminal = "xterm"
commands.editor = "xterm -e vim"
commands.mail = "firefox http://gmail.com"
commands.lock = "xscreensaver-command --lock"
commands.fileman = "pcmanfm"
commands.calc = "xcalc"
commands.mute = "mute.sh"
commands.browser = "firefox"
commands.raisevol = "amixer set Master 5%+"
commands.lowervol = "amixer set Master 5%-"
commands.playpause = "mpc toggle"
commands.player = "xterm -e ncmpc"
commands.nexttrack = "mpc next"
commands.prevtrack = "mpc prev"
commands.playstop = "mpc stop"
commands.screenshot = "scrot -e 'mv $f ~/screenshots'"
commands.screenwin = "scrot -s -b -e 'mv $f ~/screenshots'"

-- Naughty position
naughty.config.presets.normal.position = "top_right"

-- MyAW widget options
myaw.calendar.options.position = "top_right"        -- Calendar position
myaw.coverart.options.position = "bottom_right"     -- Cover art position

-- Layout table
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
-- }}}


-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}


-- {{{ Menu
-- Create a laucher widget and a main menu
awesomemenu = {
   { "manual", commands.terminal .. " -e man awesome" },
   { "edit config", commands.editor .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

menuitems = {
	{ "awesome", awesomemenu, beautiful.awesome_icon },
	{ "matlab", "matlab -desktop"},
        { "open terminal", commands.terminal }
}

menuitems = awful.util.table.join(menuitems, freedesktop.menu.new()) -- Join with freedesktop menu

mymainmenu = awful.menu({ items = menuitems })
mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Bashets widgets
datew = widget({ type = "textbox", name = "datew", align="right" })
bashets.register(datew, "date.sh", '<span color="' .. bright_color ..'">  $1  </span>', 60, '|')

mpdw = widget({ type = "textbox", name = "mpdw"})
bashets.register(mpdw, "mpd.sh", '<span color="' .. bright_color .. '" face="Monospace">$1</span> $2 | $3', 1, '|')

memw = widget({type="textbox",name="memw"})
bashets.register(memw, "mem.sh", ' <span color="' .. bright_color .. '">M:</span> $1%', 3)

cpuw = widget({type="textbox",name="cpuw"})
bashets.register(cpuw, "cpu.sh", ' <span color="' .. bright_color .. '">C:</span> $1%', 2)

gapw = widget({type="textbox", name="gapw", align="right"})
gapw.text = " "

ww = widget({type="textbox", name="ww"})
bashets.register_async(ww, "forecast.sh", ' <span face="ConkyWeather" font="10" color="' .. bright_color .. '" weight="bold" rise="-1400">$1</span><span font="5"> </span><span rise="1400">$2</span>', 3600)

mw = widget({type="textbox", name="mw"})
bashets.register_async(mw, "checkmail.sh", ' <span face="MarVoSym" font="12" color="' .. bright_color .. '" weight="bold">B</span><span font="5"> </span><span>$1</span>', 3600)

xkbw = widget({type="textbox", name="xkbw", align="right"})
bashets.register_async(xkbw, "xkb.sh", ' <span color="' .. bright_color .. '">$1</span>  ')

datew:add_signal("mouse::enter", myaw.calendar.actions.show)
datew:add_signal("mouse::leave", myaw.calendar.actions.hide)
datew:buttons(awful.util.table.join(
    awful.button({ }, 4, myaw.calendar.actions.prev),
    awful.button({ }, 5, myaw.calendar.actions.next)
))

mpdw:add_signal("mouse::enter", myaw.coverart.actions.popup)
mpdw:add_signal("mouse::leave", myaw.coverart.actions.hide)
-- }}}

-- {{{ Wibox
-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
topbar = {}
bottombar = {}

mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
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
                                          end)
)

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
    -- Create the wiboxes
    topbar[s] = awful.wibox({ position = "top", screen = s })
    bottombar[s] = awful.wibox({ position = "bottom", screen = s})

    -- memw, cpuw, fsw, vlw,
    bottombar[s].widgets ={ 
	    { mypromptbox[s], mw, gapw, cpuw, memw, layout = awful.widget.layout.horizontal.leftright},
	    mylayoutbox[s], gapw, mpdw,
	    layout = awful.widget.layout.horizontal.rightleft
    }
    topbar[s].widgets = {datew, ww, xkbw, mysystray, gapw,
    		{mylauncher, mytaglist[s], mytasklist[s], layout = awful.widget.layout.horizontal.leftright},
		layout = awful.widget.layout.horizontal.rightleft
    }
end
-- }}}

-- {{{ Free-form desktop wiboxes aka "widgets"
calendtext = widget({type="textbox", name="calendtext"})
calendtext.text = "<span font=\"14\">" .. os.date("%B") .. "</span>\n<span font=\"12\">" .. os.date("%A") .. "</span>\n<span font=\"25\">" .. os.date("%d") .. "</span>"
calendbox = wibox({width=100, height=100, bg="#ffffff00"})
calendbox.widgets = {calendtext, layout = awful.widget.layout.horizontal.leftright}
calendbox:geometry({x=1280 - calendtext:extents().width - 30, y=30})
calendbox.screen = mouse.screen

pstext = widget({type="textbox", name="pstext"})
pstext.text = "<span face=\"Monospace\">" .. awful.util.pread("ps axk -%cpu,-%mem o pid,comm,%cpu,%mem | head -n 6") .. "</span>"
psbox = wibox({width=pstext:extents().width, height=pstext:extents().height, bg="#ffffff00"})
psbox.widgets = {pstext, layout = awful.widget.layout.horizontal.leftright}
psbox:geometry({x=1280 - pstext:extents().width - 30, y=1024 - 50 - pstext:extents().height})
psbox.screen = mouse.screen
bashets.register(pstext, "ps.sh", "<span face=\"Monospace\">$1</span>", 2, '|')
-- }}}

-- {{{ Start updates for bashets
bashets.start()
-- }}}

-- {{{ Mouse bindings
-- Mouse bindings for root window
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- Mouse bindings for client window
clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
-- }}}   //Mouse bindings

-- {{{ Key bindings
-- Key bindings for root window
globalkeys = awful.util.table.join(
    -- User defined commands
    awful.key({}, "XF86AudioMute", run(commands.mute)),
    awful.key({}, "XF86AudioRaiseVolume", run(commands.raisevol)),
    awful.key({}, "XF86AudioLowerVolume", run(commands.lowervol)),
    awful.key({}, "XF86AudioPlay", run(commands.playpause)),
    awful.key({}, "XF86AudioMedia", run(commands.player)),
    awful.key({}, "XF86AudioStop", run(commands.playstop)),
    awful.key({}, "XF86AudioNext", run(commands.nexttrack)),
    awful.key({}, "XF86AudioPrev", run(commands.prevtrack)),
    awful.key({}, "XF86MyComputer", run(commands.fileman)),
    awful.key({}, "XF86Mail", run(commands.mail)),
    awful.key({}, "XF86HomePage", run(commands.browser)),
    awful.key({}, "XF86Calculator", run(commands.calc)),
    awful.key({"Mod1"}, "Print", run(commands.screenwin)),
    awful.key({}, "Print", run(commands.screenshot)),
    awful.key({}, "XF86Sleep", run(commands.lock)),
    awful.key({"Control", "Mod1"}, "l", run(commands.lock)),
    awful.key({ modkey,           }, "Return", run(commands.terminal)),
    
    -- Tag switching
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    -- Client switching
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

    -- Menu key
    awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

    -- Client manipulation within layout
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

    -- Awesome commands
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- Client area manipulation
    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),

    -- Layout switching
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end)

    -- Lua prompt
    --awful.key({ modkey }, "x",
    --          function ()
    --              awful.prompt.run({ prompt = "Run Lua code: " },
    --              mypromptbox[mouse.screen].widget,
    --              awful.util.eval, nil,
    --              awful.util.getdir("cache") .. "/history_eval")
    --          end)
)

-- Default 9-tag keybindings
-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, i,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, i,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, i,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, i,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end)
	)
end

-- Set root window keys
root.keys(globalkeys)

-- Key bindings for client window
clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)
-- }}}   //Key bindings

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Gajim" },
      properties = { floating = true } },
    { rule = { class = "Empathy" },
      properties = { floating = true } },
    { rule = { class = "Cairo-clock" },
      properties = { floating = true } },
    { rule = { class = "XClock" },
      properties = { floating = true } },
    { rule = { class = "XTerm"},
      properties = { opacity = 0.6} },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}   //Rules

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

    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- awful.client.setslave(c)
    c.size_hints_honor = false
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}   // Signals
