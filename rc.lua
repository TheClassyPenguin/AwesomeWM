--[[
                                     
     Whiteburn Awesome WM config 2.0 
     github.com/copycat-killer       
                                     
--]]

-- {{{ Required libraries
local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local drop      = require("scratchdrop")
local lain      = require("lain")
-- local picturesque = require("picturesque")
-- }}}

-- seed and "pop a few"
math.randomseed( os.time())
for i=1,1000 do tmp=math.random(0,1000) end


-- {{{ Error handling
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
-- }}}

-- {{{ Autostart applications
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -f -x " .. findme .. " > /dev/null || " .. cmd )
end

-- run_once("urxvtd")
run_once("/usr/bin/unclutter")
run_once("/usr/bin/compton --config /home/samaro/.config/compton.conf")
run_once("/usr/bin/nm-applet")
run_once("eval $(gpg-agent --daemon --enable-ssh-support --write-env-file ~/.gnupg/gpg-agent.env); export `cat ~/.gnupg/gpg-agent.env`")
run_once("/usr/bin/xcalib -d :0 /home/samaro/.local/share/icc/profile.icm ")
-- }}}

-- {{{ Variable definitions
-- localization
os.setlocale(os.getenv("LANG"))

-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/blackburn/theme.lua")

-- common
modkey     = "Mod4"
altkey     = "Mod1"
terminal   = "urxvt"
editor     = os.getenv("EDITOR") or "nano" or "vi"
editor_cmd = terminal .. " -e " .. editor

-- user defined
browser    = "chromium-browser"
gui_editor = "subl"
graphics   = "gimp"

local layouts = {
    awful.layout.suit.floating,
    lain.layout.uselesstile,
    awful.layout.suit.fair,
    lain.layout.uselesstile.left,
    lain.layout.uselesstile.top
}
-- }}}

-- {{{ Tags
tags = {
   names = { "ƀ", "Ƅ", "Ɗ", "ƈ", "ƙ" },
   layout = { layouts[2], layouts[3], layouts[2], layouts[1], layouts[5] }
}
for s = 1, screen.count() do
   tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Wallpaper
-- if beautiful.wallpaper then
--     for s = 1, screen.count() do
--         gears.wallpaper.maximized(beautiful.wallpaper, s, true)
--     end
-- end
-- }}}

---- {{{ Picturesque
--local pt = timer {timeout = 10 }
--pt:connect_signal("timeout", picturesque.change_image)
--pt:start()
--pt:emit_signal("timeout")
---- }}}
-- {{{ Menu
mymainmenu = awful.menu.new({ items = require("menugen").build_menu(),
                              theme = { height = 16, width = 130 }})
-- }}}

-- {{{ Function definitions

-- scan directory, and optionally filter outputs
function scandir(directory, filter)
    local i, t, popen = 0, {}, io.popen
    if not filter then
        filter = function(s) return true end
    end
    print(filter)
    for filename in popen('ls -a "'..directory..'"'):lines() do
        if filter(filename) then
            i = i + 1
            t[i] = filename
        end
    end
    return t
end

-- }}}

-- configuration - edit to your liking
wp_index = 1
wp_timeout  = 20
wp_path = "/home/samaro/pics/wall/"
wp_filter = function(s) return string.match(s,"%.png$") or string.match(s,"%.jpg$") end
wp_files = scandir(wp_path, wp_filter)
 
-- setup the timer
wp_timer = timer { timeout = wp_timeout }
wp_timer:connect_signal("timeout", function()
 
  -- set wallpaper to current index for all screens
  for s = 1, screen.count() do
    wp_index = math.random( 1, #wp_files)
    gears.wallpaper.maximized(wp_path .. wp_files[wp_index], s, true)
  end
 
  wp_timer:again()
end)
 
-- initial start when rc.lua is first run
wp_timer:start()
wp_timer:emit_signal("timeout") 
  


-- {{{ Menu
-- require("freedesktop/freedesktop")
-- }}}

-- {{{ Wibox
markup = lain.util.markup
gray   = "#9E9C9A"

-- Textclock
mytextclock = awful.widget.textclock(" %H:%M ")

-- Calendar
lain.widgets.calendar:attach(mytextclock)

--[[ Mail IMAP check
-- commented because it needs to be set before use
-- mailwidget = lain.widgets.imap({
--     timeout  = 180,
--     server   = "server",
--     mail     = "mail",
--     password = "keyring get mail",
--     settings = function()
--         mail  = ""
--         count = ""
-- 
--         if mailcount > 0 then
--             mail = "Arch "
--             count = mailcount .. " "
--         end
-- 
--         widget:set_markup(markup(gray, mail) .. count)
--     end
-- })
--]]

-- MPD
-- mpdwidget = lain.widgets.mpd({
--     settings = function()
--         artist = mpd_now.artist .. " "
--         title  = mpd_now.title  .. "  "
-- 
--         if mpd_now.state == "pause" then
--             artist = "mpd "
--             title  = "paused  "
--         elseif mpd_now.state == "stop" then
--             artist = ""
--             title  = ""
--         end
-- 
--         widget:set_markup(markup(gray, artist) .. title)
--     end
-- })

-- -- /home fs
-- fshome = lain.widgets.fs({
--    partition = "/home",
--     settings  = function()
--         fs_header = ""
--         fs_p      = ""
-- 
--         if fs_now.used >= 90 then
--             fs_header = " Hdd "
--             fs_p      = fs_now.used
--         end
-- 
--         widget:set_markup(markup(gray, fs_header) .. fs_p)
--     end
-- })

-- Battery
batwidget = lain.widgets.bat({
    settings = function()
    bat_p = tonumber(bat_now.perc)
        if bat_p<33 then
        bat_header = ' <span font="Icons 10">ű</span>'
        elseif bat_p<66 then
        bat_header = ' <span font="Icons 10">Ų</span>'
        elseif bat_p>=66 then
        bat_header = ' <span font="Icons 10">ų</span>'
    end

        if bat_now.status == "Not present" then
            bat_header= ""
            bat_p      = ""
        end

    if bat_now.status == "Charging" then
        bat_header = ' <span font="Icons 10">ł</span>'
    end

    if bat_p == 100 then
        widget:set_markup(markup(gray, bat_header))
    else
        widget:set_markup(markup(gray, bat_header) .. bat_p)
    end
    end
})

-- ALSA volume
volumewidget = lain.widgets.alsa({
    settings = function()
        level = tonumber(volume_now.level)
        if level<33 then
            header = ' <span font="Icons 10">Ƣ</span>'
        elseif level<66 then
            header = ' <span font="Icons 10">ơ</span>'
        elseif level>=66 then
            header = ' <span font="Icons 10">Ơ</span>'
        end

        if volume_now.status == "nil" then
            widget:set_markup("")
        elseif volume_now.status == "off" then
            header = ' <span font="Icons 10">ū</span>'
            widget:set_markup(markup(gray, header))
        else
            widget:set_markup(markup(gray, header) .. level .. " ")
        end
    end
})

-- Weather
-- old id = 12695789
-- Valencia, Spain: 20080314
-- Openweathermap ID: 2509954
yawn = lain.widgets.yawn(2509954,
{
    settings = function()
        widget:set_markup(" " .. units .. " ")
    end
})

-- Keyboard map indicator and changer
kbdcfg = {}
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = { { "us", "" }, { "es", "" } }
kbdcfg.current = 2  -- us is our default layout
kbdcfg.widget = wibox.widget.textbox()
kbdcfg.widget:set_text(" " .. kbdcfg.layout[kbdcfg.current][1] .. " ")
kbdcfg.switch = function ()
  kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
  local t = kbdcfg.layout[kbdcfg.current]
  kbdcfg.widget:set_text(" " .. t[1] .. " ")
  os.execute( kbdcfg.cmd .. " " .. t[1] .. " " .. t[2] )
end

 -- Mouse bindings
kbdcfg.widget:buttons(
 awful.util.table.join(awful.button({ }, 1, function () kbdcfg.switch() end))
)


-- Separators
first = wibox.widget.textbox('<span font="Termsyn 7"> </span>')
arrl_pre = wibox.widget.imagebox()
arrl_pre:set_image(beautiful.arrl_lr_pre)
arrl_post = wibox.widget.imagebox()
arrl_post:set_image(beautiful.arrl_lr_post)

-- Create a wibox for each screen and add it
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
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
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

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18 })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(first)
    left_layout:add(mytaglist[s])
    left_layout:add(arrl_pre)
    left_layout:add(mylayoutbox[s])
    left_layout:add(arrl_post)
    left_layout:add(mypromptbox[s])
    left_layout:add(first)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(first)
    -- right_layout:add(mpdwidget)
    -- right_layout:add(mailwidget)
    right_layout:add(yawn.icon)
    right_layout:add(yawn.widget)
    -- right_layout:add(fshome)
    right_layout:add(batwidget)
    right_layout:add(volumewidget)
    right_layout:add(kbdcfg.widget)
    right_layout:add(mytextclock)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)

    -- Set proper background, instead of beautiful.bg_normal
    mywibox[s]:set_bg(beautiful.topbar_path .. screen[mouse.screen].workarea.width .. ".png")
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
--    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Take a screenshot
    -- https://github.com/copycat-killer/dots/blob/master/bin/screenshot
    awful.key({ altkey }, "p", function() os.execute("screenshot") end),

    -- Tag browsing
    awful.key({ modkey }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey }, "Escape", awful.tag.history.restore),

    -- Non-empty tag browsing
    awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end),
    awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end),

    -- Default client focus
    awful.key({ altkey }, "k",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ altkey }, "j",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- By direction client focus
    awful.key({ modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    -- Show Menu
    awful.key({ modkey }, "w",
        function ()
            mymainmenu:show({ keygrabber = true })
        end),

    -- Show/Hide Wibox
    awful.key({ modkey }, "h", function ()
        mywibox[mouse.screen].visible = not mywibox[mouse.screen].visible
    end),

    -- On the fly useless gaps change
    awful.key({ altkey, "Control" }, "+", function () lain.util.useless_gaps_resize(1) end),
    awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end),

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
    awful.key({ altkey, "Shift"   }, "l",      function () awful.tag.incmwfact( 0.05)     end),
    awful.key({ altkey, "Shift"   }, "h",      function () awful.tag.incmwfact(-0.05)     end),
    awful.key({ modkey, "Shift"   }, "l",      function () awful.tag.incnmaster(-1)       end),
    awful.key({ modkey, "Shift"   }, "h",      function () awful.tag.incnmaster( 1)       end),
    awful.key({ modkey, "Control" }, "l",      function () awful.tag.incncol(-1)          end),
    awful.key({ modkey, "Control" }, "h",      function () awful.tag.incncol( 1)          end),
    awful.key({ modkey,           }, "space",  function () awful.layout.inc(layouts,  1)  end),
    awful.key({ modkey, "Shift"   }, "space",  function () awful.layout.inc(layouts, -1)  end),
    awful.key({ modkey, "Control" }, "n",      awful.client.restore),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r",      awesome.restart),
    awful.key({ modkey, "Shift"   }, "q",      awesome.quit),

    -- Dropdown terminal
    awful.key({ modkey,           }, "z",      function () drop(terminal) end),

    -- Widgets popups
    awful.key({ altkey,           }, "c",      function () lain.widgets.calendar:show(7) end),
    awful.key({ altkey,           }, "h",      function () fshome.show(7) end),
    awful.key({ altkey,           }, "w",      function () myweather.show(7) end),

    -- ALSA volume control
    awful.key({ }, "XF86AudioRaiseVolume",
        function ()
            awful.util.spawn("amixer -c 1 sset Master 1%+")
            volumewidget.update()
        end),
    awful.key({ }, "XF86AudioLowerVolume",
        function ()
            awful.util.spawn("amixer -c 1 sset Master 1%-")
            volumewidget.update()
        end),
    awful.key({ }, "XF86AudioMute",
        function ()
            awful.util.spawn("amixer -c 1 sset Master toggle")
	    awful.util.spawn("amixer -c 1 sset Headphone unmute");
	    awful.util.spawn("amixer -c 1 sset Speaker unmute");
            volumewidget.update()
        end),

    -- MPD control
--    awful.key({ altkey, "Control" }, "Up",
--        function ()
--            awful.util.spawn_with_shell("mpc toggle || ncmpc toggle || pms toggle")
--            mpdwidget.update()
--        end),
--    awful.key({ altkey, "Control" }, "Down",
--        function ()
--            awful.util.spawn_with_shell("mpc stop || ncmpc stop || pms stop")
--            mpdwidget.update()
--        end),
--    awful.key({ altkey, "Control" }, "Left",b
--        function ()
--            awful.util.spawn_with_shell("mpc prev || ncmpc prev || pms prev")
--            mpdwidget.update()
--        end),
--    awful.key({ altkey, "Control" }, "Right",
--        function ()
--            awful.util.spawn_with_shell("mpc next || ncmpc next || pms next")
--            mpdwidget.update()
--        end),
    
    -- Brightness keys
    awful.key({ modkey }, "F3", function()
      awful.util.spawn("xbacklight -inc 15") end),
    awful.key({ modkey }, "F2", function()
      awful.util.spawn("xbacklight -dec 15") end),

    -- Copy to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

    -- User programs
    awful.key({ modkey }, "q", function () awful.util.spawn(browser) end),
--    awful.key({ modkey }, "i", function () awful.util.spawn(browser2) end),
    awful.key({ modkey }, "s", function () awful.util.spawn(gui_editor) end),
    awful.key({ modkey }, "g", function () awful.util.spawn(graphics) end),

    -- Prompt
    awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
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
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false } },
    { rule = { class = "URxvt" },
          properties = { opacity = 0.99 } },

    { rule = { class = "MPlayer" },
          properties = { floating = true } },

    { rule = { class = "Dwb" },
          properties = { tag = tags[1][1] } },

    { rule = { class = "Iron" },
          properties = { tag = tags[1][1] } },

    { rule = { instance = "plugin-container" },
          properties = { tag = tags[1][1] } },

    { rule = { class = "Gimp" },
          properties = { tag = tags[1][4] } },

    { rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { maximized_horizontal = true,
                         maximized_vertical = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup and not c.size_hints.user_position
       and not c.size_hints.program_position then
        awful.placement.no_overlap(c)
        awful.placement.no_offscreen(c)
    end
end)

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if (c.maximized_horizontal == true and c.maximized_vertical == true) or c.border_width ~= 0 then
            c.border_width = 0
            c.border_color = beautiful.border_normal
        else
            c.border_width = beautiful.border_width
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do screen[s]:connect_signal("arrange", function ()
        local clients = awful.client.visible(s)
        local layout  = awful.layout.getname(awful.layout.get(s))

        if #clients > 0 then -- Fine grained borders and floaters control
            for _, c in pairs(clients) do -- Floaters always have borders
                if awful.client.floating.get(c) or layout == "floating" then
                    c.border_width = beautiful.border_width

                -- No borders with only one visible client
                elseif #clients == 1 or layout == "max" then
                    clients[1].border_width = 0
                    awful.client.moveresize(0, 0, 2, 2, clients[1])
                else
                    c.border_width = beautiful.border_width
                end
            end
        end
      end)
end
-- }}}
