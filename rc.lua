local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
vicious = require("vicious")
labelcolor = "#FF8C00"

if awesome.startup_errors then
  naughty.notify({ preset = naughty.config.presets.critical,
                   title = "Oops, there were errors during startup!", 
                   text = awesome.startup_errors })
end

do
  local in_error = false
  awesome.connect_signal("debug::error", function (err)
    if in_error then return end
    in_error = true
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, an error happened!",
                     text = err })
    in_error = false
  end)
end

beautiful.init("/usr/share/awesome/themes/dust/theme.lua")

terminal = "gnome-terminal"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"

local layouts = {
--  awful.layout.suit.magnifier,
  awful.layout.suit.max,
  awful.layout.suit.floating,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile,
  awful.layout.suit.tile.top,
  awful.layout.suit.tile.left
--  awful.layout.suit.fair,
--  awful.layout.suit.fair.horizontal,
--  awful.layout.suit.spiral,
--  awful.layout.suit.spiral.dwindle
--  awful.layout.suit.max.fullscreen,
}

tags = {names = {"1:main", "2:www", "3:dev", "4:mail", "5:msg", 6, 7, 8, 9}}

for s = 1, screen.count() do
  tags[s] = awful.tag(tags.names, s, layouts[1])
end

myawesomemenu = {
  { "manual", terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = {	
  { "awesome", myawesomemenu, "/usr/share/awesome/themes/dust/awesomemenu-dust.png"},
  { "terminal", terminal, "/usr/share/icons/Faenza/apps/16/xterm.png"},
  { "chromium", "chromium-browser", "/usr/share/icons/Faenza/apps/16/chromium.png"},
  { "firefox", "firefox", "/usr/share/icons/Faenza/apps/16/firefox.png"},
  { "opera", "opera", "/usr/share/icons/Faenza/apps/16/opera.png" },
  { "libreoffice", "libreoffice", "/usr/share/icons/Faenza/apps/16/libreoffice-main.png"},
  { "files" , "pcmanfm", "/usr/share/icons/Faenza/apps/16/file-manager.png"},
  { "pidgin", "pidgin", "/usr/share/icons/Faenza/apps/16/pidgin.png"},
  { "sublime-text", "subl", "/opt/sublime_text/Icon/16x16/sublime-text.png"},
  { "eclipse", "eclipse", "/opt/eclipse/icon.xpm"},
  { "eclipse 4.9", "eclipse-4.9", "/opt/eclipse-4.9/icon.xpm"},
  { "virtualbox", "virtualbox", "/usr/share/icons/Faenza/apps/scalable/virtualbox.svg"},
  { "spotify", "spotify", "/usr/share/icons/Faenza/apps/scalable/spotify-linux-48x48.svg"}
}})

mylauncher = awful.widget.launcher({ image = "/usr/share/awesome/themes/dust/awesomemenu-dust.png", menu = mymainmenu })
menubar.utils.terminal = terminal

-- custom widget, showing host name and IPs in tooltip
infowidget = wibox.widget.imagebox(os.getenv("HOME") .. "/.config/awesome/scripts/img/infowidget.png")
infowidget_tooltip =  awful.tooltip({ 
  objects = { infowidget },
  timer_function = function()
    return awful.util.pread(os.getenv("HOME") .. "/.config/awesome/scripts/infowidget_tooltip")
  end
})
infowidget_tooltip:set_timeout(60)

-- custom widget, showing kernel version
kernelwidget = wibox.widget.textbox()
kernelwidget:set_markup(' <span color="' .. labelcolor .. '">kernel:</span> ' .. awful.util.pread(os.getenv("HOME") .. "/.config/awesome/scripts/kernelwidget"))
kernelwidget_tooltip =  awful.tooltip({ 
  objects = { kernelwidget },
	timer_function = function()
     return awful.util.pread(os.getenv("HOME") .. "/.config/awesome/scripts/kernelwidget_tooltip")
  end
})
kernelwidget_tooltip:set_timeout(60)

-- custom widget, showing battery status
batterywidget = wibox.widget.textbox()
batterywidget:set_markup(' <span color="' .. labelcolor .. '">bat:</span> ' .. awful.util.pread(os.getenv("HOME") .. "/.config/awesome/scripts/batterywidget"))
batterywidget_tooltip =  awful.tooltip({
  objects = { batterywidget },
  timer_function = function()
     return awful.util.pread(os.getenv("HOME") .. "/.config/awesome/scripts/batterywidget_tooltip")
  end
})

-- custom widget, showing date
datewidget = wibox.widget.textbox()
datewidget_tooltip = awful.tooltip({
	objects = { datewidget },
	timer_function = function()
		return awful.util.pread(os.getenv("HOME") .. "/.config/awesome/scripts/datewidget_tooltip")
	end
})
datewidget_tooltip:set_timeout(60)

-- custom widget, showing CPU usage graph (requires vicious)
cpuwidget = awful.widget.graph()
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_border_color('#222222')
cpuwidget:set_color({ 
  type = "linear", 
  from = { 0, 0 }, 
  to = { 0,25 }, 
  stops = { 
    {0, "#FF5656"}, 
    {0.5, "#88A175"}, 
    {1, "#AECF96" }
  }
})
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")
cpuwidget_label = wibox.widget.textbox()
cpuwidget_label:set_markup(' <span color="' .. labelcolor .. '">cpu:</span> ')
cpuwidget_tooltip = awful.tooltip({ 
  objects = { cpuwidget, cpuwidget_label },
  timer_function = function()
     return awful.util.pread(os.getenv("HOME") .. "/.config/awesome/scripts/cpuwidget_tooltip")
  end
})
cpuwidget_tooltip:set_timeout(60)

-- custom widget, showing memory usage graph (requires vicious)
memwidget = awful.widget.progressbar()
memwidget:set_width(8)
memwidget:set_height(10)
memwidget:set_vertical(true)
memwidget:set_background_color("#494B4F")
memwidget:set_border_color('#222222')
memwidget:set_color({ 
  type = "linear", 
  from = { 0, 0 }, 
  to = { 0,20 }, 
  stops = {
    {0, "#FF5656"},
    {0.5, "#88A175"},
    {1, "#AECF96"}
  }
})
vicious.register(memwidget, vicious.widgets.mem, "$1", 13)
memwidget_label = wibox.widget.textbox()
memwidget_label:set_markup(' <span color="' .. labelcolor .. '">mem:</span> ')
memwidget_tooltip = awful.tooltip({
	objects = { memwidget, memwidget_label },
	timer_function = function()
		return awful.util.pread(os.getenv("HOME") .. "/.config/awesome/scripts/memwidget_tooltip")
	end
})
memwidget_tooltip:set_timeout(60)

-- custom widget, adding some space between widgets in the menubar
spacer = wibox.widget.textbox()
spacer:set_markup(' ')

-- widget timer, updating the value of the date widget
datetimer = timer({ timeout = 1 })
datetimer:connect_signal(
  "timeout",
  function ()
    datewidget:set_markup(' <span color="' .. labelcolor .. '">date:</span> ' .. awful.util.pread(os.getenv("HOME") .. "/.config/awesome/scripts/datewidget"))
  end
)
datetimer:start()

-- widget timer, updating the value of the battery widget
batterytimer = timer({ timeout = 600 })
batterytimer:connect_signal(
  "timeout",
  function ()
    batterywidget:set_markup(' <span color="' .. labelcolor .. '">bat:</span> ' .. awful.util.pread(os.getenv("HOME") .. "/.config/awesome/scripts/batterywidget") .. '%')
  end
)
batterytimer:start()

mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
    if c == client.focus then
      c.minimized = true
    else
      c.minimized = false
      if not c:isvisible() then
        awful.tag.viewonly(c:tags()[1])
      end
      client.focus = c
      c:raise()
    end
  end),
  awful.button({ }, 3, function ()
    if instance then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({
          theme = { width = 250 }
      })
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
  mypromptbox[s] = awful.widget.prompt()
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
  awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
  awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
  awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
  awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
  mywibox[s] = awful.wibox({ position = "top", screen = s })
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(mytaglist[s])
  left_layout:add(mypromptbox[s])

  local right_layout = wibox.layout.fixed.horizontal()
  right_layout:add(memwidget_label) --end
  right_layout:add(memwidget) --end
  right_layout:add(cpuwidget_label) --end
  right_layout:add(cpuwidget) --end
  right_layout:add(batterywidget)
  right_layout:add(kernelwidget) --end
  right_layout:add(datewidget)
  right_layout:add(infowidget) --end
  right_layout:add(spacer)
  if s == 1 then right_layout:add(wibox.widget.systray()) end
  right_layout:add(mylauncher)
  right_layout:add(mylayoutbox[s])

  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(mytasklist[s])
  layout:set_right(right_layout)

  mywibox[s]:set_widget(layout)
end

root.buttons(awful.util.table.join(
  awful.button({ }, 3, function () mymainmenu:toggle() end),
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)
))

globalkeys = awful.util.table.join(
  awful.key({ modkey,	"Shift"	}, "w",	function() awful.util.spawn("xscreensaver-command -a", false) end),
  awful.key({ modkey,           }, "Right", function ()
    awful.client.focus.byidx( 1)
    if client.focus then client.focus:raise() end
  end),
  awful.key({ modkey,           }, "Left", function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
  end),
  awful.key({ modkey, "Shift"   }, "Right", function () awful.client.swap.byidx(  1)    end),
  awful.key({ modkey, "Shift"   }, "Left", function () awful.client.swap.byidx( -1)    end),
  awful.key({ modkey, "Control" }, "Right", function () awful.screen.focus_relative( 1) end),
  awful.key({ modkey, "Control" }, "Left", function () awful.screen.focus_relative(-1) end),
  awful.key({ modkey,           }, "Down",     function () awful.tag.incmwfact( 0.05)    end),
  awful.key({ modkey,           }, "Up",     function () awful.tag.incmwfact(-0.05)    end),
  awful.key({ modkey, "Shift"   }, "Up",     function () awful.tag.incnmaster( 1)      end),
  awful.key({ modkey, "Shift"   }, "Down",     function () awful.tag.incnmaster(-1)      end),
  awful.key({ modkey, "Control" }, "Up",     function () awful.tag.incncol( 1)         end),
  awful.key({ modkey, "Control" }, "Down",     function () awful.tag.incncol(-1)         end),
  awful.key({ modkey,           }, "j",   awful.tag.viewprev       ),
  awful.key({ modkey,           }, "k",  awful.tag.viewnext       ),    
  awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
  awful.key({ modkey, "Mod1" }, "Down", function () awful.client.moveresize( 0, 20, 0, 0) end),
  awful.key({ modkey, "Mod1" }, "Up", function () awful.client.moveresize( 0, -20, 0, 0) end),
  awful.key({ modkey, "Mod1" }, "Left", function () awful.client.moveresize(-20, 0, 0, 0) end),
  awful.key({ modkey, "Mod1" }, "Right", function () awful.client.moveresize( 20, 0, 0, 0) end),
  awful.key({ modkey, "Mod1", "Shift" }, "Down", function () awful.client.moveresize( 0, 0, 0, 20) end),
  awful.key({ modkey, "Mod1", "Shift" }, "Up", function () awful.client.moveresize( 0, 0, 0, -20) end),
  awful.key({ modkey, "Mod1", "Shift" }, "Left", function () awful.client.moveresize( 0, 0, -20, 0) end),
  awful.key({ modkey, "Mod1", "Shift" }, "Right", function () awful.client.moveresize( 0, 0, 20, 0) end),
  awful.key({ modkey,           }, "w", function () mymainmenu:show() end),
  awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
  awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
  awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
  awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
  awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
  awful.key({ modkey,           }, "Tab",   awful.tag.viewnext       ),
  awful.key({ modkey, "Shift"   }, "Tab",   awful.tag.viewprev       ),
  awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
  awful.key({ modkey, "Control" }, "r", awesome.restart),
  awful.key({ modkey,           }, "l",			function () awful.client.incwfact( 0.05)    end),
  awful.key({ modkey,           }, "h",     function () awful.client.incwfact(-0.05)    end),
  awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
  awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
  awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
  awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
  awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
  awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
  awful.key({ modkey, "Control" }, "n", awful.client.restore),
  awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
  awful.key({ modkey }, "x", function ()
    awful.prompt.run({ prompt = "Run Lua code: " }, mypromptbox[mouse.screen].widget, awful.util.eval, nil, awful.util.getdir("cache") .. "/history_eval")
  end),
  awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
  awful.key({ modkey,           }, "f",		function (c) c.fullscreen = not c.fullscreen  	end),
  awful.key({ modkey,           }, "q",		function (c) c:kill()							end),
  awful.key({ modkey, "Shift"   }, "c",		function (c) c:kill()                  		    end),
  awful.key({ modkey, "Control" }, "space",	awful.client.floating.toggle                     ),
  awful.key({ modkey, "Control" }, "Return",	function (c) c:swap(awful.client.getmaster()) end),
  awful.key({ modkey,           }, "o",		awful.client.movetoscreen                        ),
  awful.key({ modkey,           }, "t",		function (c) c.ontop = not c.ontop            end),
  awful.key({ modkey,           }, "n", function (c)
    c.minimized = true
  end),
  awful.key({ modkey,           }, "m", function (c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical   = not c.maximized_vertical
  end)
)

for i = 1, 9 do
  globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "#" .. i + 9, function ()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then awful.tag.viewonly(tag) end
    end),
    awful.key({ modkey, "Control" }, "#" .. i + 9, function ()
      local screen = mouse.screen
      local tag = awful.tag.gettags(screen)[i]
      if tag then
        awful.tag.viewtoggle(tag)
      end
    end),
    awful.key({ modkey, "Shift" }, "#" .. i + 9, function ()
      if client.focus then
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if tag then awful.client.movetotag(tag) end
      end
    end),
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function ()
      if client.focus then
        local tag = awful.tag.gettags(client.focus.screen)[i]
        if tag then awful.client.toggletag(tag) end
      end
    end)
  )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

root.keys(globalkeys)

awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
										 size_hints_honor = false },
      callback = function(c)
        awful.placement.centered(c,nil)
      end },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
		{rule = {class = "Gnome-terminal"}, 
			properties = { floating = false } },
		{rule = {class = "Pcmanfm"}, 
			properties = { floating = true } },
}

client.connect_signal("manage", function (c, startup)
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)