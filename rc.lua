-- Library {{{
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- vicious
vicious = require("vicious")
-- }}}

-- 路径
config_path = os.getenv("HOME") .. "/.config/awesome"
icons_path = config_path .. "/icons/"

-- Custom  {{{
function file_exists(path)
    local f, err = io.open(path, "r")
    if err == nil then
        io.close(f)
        return true
    else
        return false
    end
end

-- 如果存在 $HOME/.config/awesome/rc_local.lua 则载入
awesome_local = {}
do
    local fpath = config_path .. "/rc_local.lua"
    if file_exists(fpath) then
        loadfile(fpath)
    end
end
-- }}}

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ 
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors 
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
        title = "Oops, an error happened!",
        text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
theme.border_width  = 1
theme.wallpaper = config_path.."/backgrounds/Forever_by_Shady_S.jpg"
theme.font = "文泉驿微米黑 12"
theme.menu_width  = 200
theme.menu_height = 24
awesome.font = "文泉驿微米黑 12"

-- This is used later as the default terminal and editor to run.
--terminal = "x-terminal-emulator"
terminal = "xfce4-terminal"
editor = os.getenv("EDITOR") or "editor"
gui_editor = "gvim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    --awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
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
myawesomemenu = {
    { "&Manual", terminal .. " -e man awesome" },
    { "&Config", gui_editor .. " " .. awesome.conffile },
    { "&Restart", awesome.restart },
    { "&Quit", awesome.quit }
}

-- 系统菜单
mysystemmenu = {
    { "锁屏(&L)", "xscreensaver-command -lock", icons_path.."system-suspend.png" },
    { "挂起(&S)", "dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager.Suspend boolean:true", icons_path.."system-suspend.png" },
    { "休眠(&H)", "dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager.Hibernate boolean:true", icons_path.."system-suspend-hibernate.png" },
    { "重启(&R)", "dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager.Reboot boolean:true", icons_path.."system-reboot.png"  },
    { "关机(&O)", "dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager.PowerOff boolean:true", icons_path.."system-shutdown.png" }
}

mymainmenu = awful.menu({ 
    items = { 
        { "&Awesome", myawesomemenu, beautiful.awesome_icon },
        { "&Terminal", terminal, icons_path.."terminal.png" },
        { "&Vim", "gvim", icons_path.."vim.svg" },
        { "&Chrome", "google-chrome", icons_path.."google-chrome.png" },
        { "&Google Keep", "/opt/google/chrome/google-chrome --profile-directory=Default --app-id=hmjkmjkepdijhoojdojkdfohbdgmmhki", icons_path.."Google_Keep.png" },
        { "&Firefox", "firefox", icons_path.."firefox.png" },
        { "Virtual&Box", "virtualbox", icons_path.."virtualbox.png" },
        { "&QQ", "/opt/cxoffice/bin/wine --bottle 'xp' --check --wait-children --start 'C:/users/Public/Start Menu/Programs/腾讯软件/TM2013/腾讯TM.lnk'", icons_path.."TM.png" },
        { "&Explorer", "thunar", icons_path.."Thunar.png" },
        { "&System", mysystemmenu, icons_path.."system.png" },
    }
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu, width = 240 })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
menubar.cache_entries = true
menubar.app_folders = { "/usr/share/applications", "/usr/local/share/applications", os.getenv("HOME").."/.local/share/applications", os.getenv("HOME").."/Desktop" }
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock("%H:%M:%S", 1)
mytextclock:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("gvim " .. " -c ':Calendar -view=year'") end)
))

-- CPU监控
cpuwidget = awful.widget.graph()
cpuwidget:set_width(30)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color({ 
    type = "linear",
    from = { 0, 0 },
    to = { 10,0 },
    stops = { {0, "#FF5656"}, {0.5, "#88A175"}, {1, "#AECF96" }}
})
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")
cpuwidget:buttons(awful.util.table.join(
    awful.button({ }, 1, 
        function () awful.util.spawn(terminal .. " -e htop") end
    )
))

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
    mywibox[s] = awful.wibox({ position = "top", height = "24", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)
    --right_layout:add(memwidget)
    right_layout:add(cpuwidget)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
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
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- 切换屏保
    awful.key({                   }, "XF86ScreenSaver", 
        function ()         
            local xsc = io.popen("pgrep -x xscreensaver | wc -l"):read()
            if xsc == "0" then
                awful.util.spawn("xscreensaver -nosplash")
                naughty.notify({ text = "开启屏保", })
            else
                awful.util.spawn("killall xscreensaver")
                naughty.notify({ text = "关闭屏保", })
            end
        end),

    -- 文件管理器
    awful.key({ modkey,           }, "e", function () awful.util.spawn("thunar") end),

    -- Gvim
    awful.key({ modkey,           }, "v", function () awful.util.spawn("gvim") end),

    --urxvt
    awful.key({ "Mod1", "Control" }, "t", function () awful.util.spawn_with_shell("urxvt") end), 

    -- 截图
    awful.key({                   }, "Print", function () awful.util.spawn_with_shell("import -window root $HOME/Pictures/screenshots/`date +%Y%m%d_%H%M%S`.png") end), 
    awful.key({ "Mod1"             }, "Print", function () awful.util.spawn_with_shell("import -frame $HOME/Pictures/screenshots/`date +%Y%m%d_%H%M%S`.png") end), 
    awful.key({ "Control"         }, "Print", function () awful.util.spawn_with_shell("import $HOME/Pictures/screenshots/`date +%Y%m%d_%H%M%S`.png") end), 

    -- 刷新网页
    awful.key({ modkey            }, "F5", function () awful.util.spawn_with_shell("old_window=`xdotool getactivewindow`;xdotool search --onlyvisible --limit 1 --class Chrome windowfocus key 'ctrl+r';xdotool windowactivate $old_window") end), 
    

    -- 音量控制
    awful.key({                   }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer set Master 5%+") end),
    awful.key({                   }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer set Master 5%-") end),
    awful.key({                   }, "XF86AudioMute", function () awful.util.spawn("amixer set Master toggle") end),

    -- 音乐控制
    awful.key({                   }, "XF86AudioPlay", function () awful.util.spawn("mpc toggle") end),
    awful.key({                   }, "XF86AudioStop", function () awful.util.spawn("mpc stop") end),
    awful.key({                   }, "XF86AudioPrev", function () awful.util.spawn("mpc prev") end),
    awful.key({                   }, "XF86AudioNext", function () awful.util.spawn("mpc next") end),

    -- 关闭触摸板
    awful.key({                   }, "XF86TouchpadToggle", function () awful.util.spawn_with_shell("synclient TouchpadOff=`synclient -l | grep -ce 'TouchpadOff.*0'`") end),

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

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end),
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
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { 
        rule = { },
        properties = { 
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            size_hints_honor = false,
        } 
    },
    {
        rule_any = {
            class = {
                "Flashplayer",
                "Display",
                "Gimp",
                "mplayer2",
                "Smplayer",
                "Wine",
                "Firefox",
                "Stardict",
                "Crossover",
                "Inkscape",
            },
        },
        properties = {
            floating = true,
            border_width = 0
        }
    },
    -- Chrome App Launcher
    { 
        rule = { instance = "chrome_app_list" },
        properties = { floating = true },
    },
    --Google chrome
    {
        rule = { class = "Google-chrome" },
        properties = { floating = true },
    },
    -- Google Keep
    { 
        rule = { instance = "crx_hmjkmjkepdijhoojdojkdfohbdgmmhki" },
        properties = { floating = true },
    },
    -- VirtualBox
    { 
        rule = { class = "VirtualBox" },
        except = { name = "Oracle VM VirtualBox Manager" },
        properties = { floating = true },
    },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
if type(awesome_local.rules) == 'table' then
    for _, v in ipairs(awesome_local.rules) do
        table.insert(awful.rules.rules, v)
    end
end
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

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
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

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Autorun

-- 改进后开机自启动脚本
-- 当元素为table时，name和cmd至少要有一个不为空
-- 命令可以和程序名称不一样

function run_once(name, cmd)
    awful.util.spawn_with_shell("pgrep -u $USER -x " .. name .. " || (" .. cmd .. ")")
end

do
    local prgs = {
        { name = "dropbox", cmd = "dropbox start" },
        { name = "xscreensaver", cmd = "xscreensaver -nosplash" },
        "mpd",
        "nm-applet",
        "fcitx",
        "offlineimap",
        "parcellite",
        "volumeicon",
        "compton",
    }
    if type(awesome_local.prgs) == 'table' then
        for _, v in ipairs(awesome_local.prgs) do
            table.insert(prgs, v)
        end
    end
    for _, i in ipairs(prgs) do
        if type(i) == 'string' then
            run_once(i, i)
        else
            if i.cmd == nil then
                i.cmd = i.name
            elseif i.name == nil then
                i.name = i.cmd
            end
            if i.always == nil then
                run_once(i.name, i.cmd)
            else
                awful.util.spawn_with_shell(i.cmd)
            end
        end
    end
end

-- 如果存在 $HOME/.config/awesome/autostart.sh 则运行
do
    local fpath = config_path.."/autostart.sh"
    if file_exists(fpath) then
        awful.util.spawn_with_shell(fpath)
    end
end
-- }}}

-- vim: ts=4 sw=4 fdm=marker
