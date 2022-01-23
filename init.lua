local hotkey = require "hs.hotkey"
local mash = {"ctrl", "alt"}

-- https://github.com/dsanson/hs.tiling
local tiling = require "hs.tiling"
hotkey.bind(mash, "'", function() tiling.cycleLayout() end)
hotkey.bind(mash, "l", function() tiling.cycle(1) end)
hotkey.bind(mash, "j", function() tiling.cycle(-1) end)
hotkey.bind(mash, "k", function() tiling.promote() end)
hotkey.bind(mash, ";", function() tiling.goToLayout("fullscreen") end)

tiling.set('layouts', {
  'fullscreen', 'main-vertical', 'gp-vertical', 'columns'
})

-- https://aaronlasseigne.com/2016/02/16/switching-from-slate-to-hammerspoon/
-- TODO: maybe prefer http://www.hammerspoon.org/docs/hs.grid.html
local positions = {
  maximized = hs.layout.maximized,
  centered = {x=0, y=0, w=1, h=1},

  left34 = {x=0, y=0, w=0.34, h=1},
  left50 = hs.layout.left50,
  left66 = {x=0, y=0, w=0.66, h=1},

  right34 = {x=0.66, y=0, w=0.34, h=1},
  right50 = hs.layout.right50,
  right66 = {x=0.34, y=0, w=0.66, h=1},

  upper50 = {x=0, y=0, w=1, h=0.5},
  upper50Left50 = {x=0, y=0, w=0.5, h=0.5},
  upper50Right50 = {x=0.5, y=0, w=0.5, h=0.5},

  lower50 = {x=0, y=0.5, w=1, h=0.5},
  lower50Left50 = {x=0, y=0.5, w=0.5, h=0.5},
  lower50Right50 = {x=0.5, y=0.5, w=0.5, h=0.5}
}

local grid = {
  {key="q", units={positions.upper50Left50}},
  {key="w", units={positions.upper50}},
  {key="e", units={positions.upper50Right50}},

  {key="a", units={positions.left50, positions.left66, positions.left34}},
  {key="s", units={positions.centered, positions.maximized}},
  {key="d", units={positions.right50, positions.right66, positions.right34}},

  {key="z", units={positions.lower50Left50}},
  {key="x", units={positions.lower50}},
  {key="c", units={positions.lower50Right50}}
}

hs.fnutils.each(grid, function(entry)
  hotkey.bind(mash, entry.key, function()
    local units = entry.units
    local screen = hs.screen.mainScreen()
    local window = hs.window.focusedWindow()
    local windowGeo = window:frame()

    local index = 0
    hs.fnutils.find(units, function(unit)
      index = index + 1

      local geo = hs.geometry.new(unit):fromUnitRect(screen:frame()):floor()
      return windowGeo:equals(geo)
    end)
    if index == #units then index = 0 end

    window:moveToUnit(units[index + 1])
  end)
end)

hotkey.bind(mash, "/", function()
    local window = hs.window.focusedWindow()
    local otherScreen = hs.fnutils.find(hs.screen.allScreens(), function(s)
                                           return s ~= window:screen()
    end)
    if otherScreen ~= nil then
       window:moveToScreen(otherScreen)
    end
end)

-- hs.window.highlight.ui.overlay = true
-- hs.window.highlight.ui.overlayColor = {0,0,0,0.0000000001}
-- hs.window.highlight.ui.frameWidth = 3 -- seems to only work if overlayColor is non-transparent
-- hs.window.highlight.ui.frameColor = {1,0,0,1}
-- hs.window.highlight.start()


-- Trying out hs.window.tiling
hotkey.bind(mash, "p", function()
               local window = hs.window.focusedWindow()
               local allScreenWindows = {window, table.unpack(window:otherWindowsSameScreen())}
               hs.window.tiling.tileWindows(allScreenWindows, window:screen():fullFrame())
end)

-- Power operation.
caffeinateOnIcon = [[ASCII:
.....1a..........AC..........E
..............................
......4.......................
1..........aA..........CE.....
e.2......4.3...........h......
..............................
..............................
.......................h......
e.2......6.3..........t..q....
5..........c..........s.......
......6..................q....
......................s..t....
.....5c.......................
]]

    caffeinateOffIcon = [[ASCII:
.....1a.....x....AC.y.......zE
..............................
......4.......................
1..........aA..........CE.....
e.2......4.3...........h......
..............................
..............................
.......................h......
e.2......6.3..........t..q....
5..........c..........s.......
......6..................q....
......................s..t....
...x.5c....y.......z..........
]]

local caffeinateTrayIcon = hs.menubar.new()

local function caffeinateSetIcon(state)
    caffeinateTrayIcon:setIcon(state and caffeinateOnIcon or caffeinateOffIcon)

    if state then
        caffeinateTrayIcon:setTooltip("Sleep never sleep")
    else
        caffeinateTrayIcon:setTooltip("System will sleep when idle")
    end
end

local function toggleCaffeinate()
    local sleepStatus = hs.caffeinate.toggle("displayIdle")
    if sleepStatus then
        hs.notify.new({title="HammerSpoon", informativeText="System never sleep"}):send()
    else
        hs.notify.new({title="HammerSpoon", informativeText="System will sleep when idle"}):send()
    end

    caffeinateSetIcon(sleepStatus)
end

hotkey.bind(mash, "[", toggleCaffeinate)
caffeinateTrayIcon:setClickCallback(toggleCaffeinate)
caffeinateSetIcon(sleepStatus)
