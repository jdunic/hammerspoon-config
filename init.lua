-- Basis of most of this taken from: https://github.com/miromannino/miro-windows-management

local mash = {"cmd", "ctrl"}
local mash2 = {"ctrl", "alt"}
local toggle = false
local VOLUME_INC = 10

local sizes = {1, 3, 2, 3/2}
local fullScreenSizes = {1, 4/3, 2}

-- don't use any animations because they suck
hs.window.animationDuration = 0

-- set the grid size to work with
local GRID = {w = 24, h = 24}
hs.grid.setGrid(GRID.w .. 'x' .. GRID.h)
hs.grid.MARGINX = 0
hs.grid.MARGINY = 0

-- don't really know what this is for
local pressed = {
  up = false,
  down = false,
  left = false,
  right = false
}


-- my own modification with a bunch of if statements to fix the fact that some 
-- apps are unable to be resized <= 1/3 of a 15 inch macbook pro screen...
function nextStep(dim, offs, cb)
  if hs.window.focusedWindow() then
    local axis = dim == 'w' and 'x' or 'y'
    local oppDim = dim == 'w' and 'h' or 'w'
    local oppAxis = dim == 'w' and 'y' or 'x'
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local screen = win:screen()

    cell = hs.grid.get(win, screen)

  if dim == 'w' then
    if cell.w == GRID.w / sizes[1] then
      nextSize = sizes[2]
    end

    if cell.w >= GRID.w / sizes[2] and cell.w <= GRID.w / sizes[3] then
      nextSize = sizes[3]
    end

    if cell.w == GRID.w / sizes[3] then
      nextSize = sizes[4]
    end

    if cell.w == GRID.w / sizes[4] then
      nextSize = sizes[1]
    end

    cb(cell, nextSize)
    if cell[oppAxis] ~= 0 and cell[oppAxis] + cell[oppDim] ~= GRID[oppDim] then
      cell[oppDim] = GRID[oppDim]
      cell[oppAxis] = 0
    end

    hs.grid.set(win, cell, screen)
  end

  if dim == 'h' then
    if cell.h == GRID.h / sizes[1] then
      nextSize = sizes[2]
    end

    if cell.h >= GRID.h / sizes[2] and cell.h <= GRID.h / sizes[3] then
      nextSize = sizes[3]
    end

    if cell.h == GRID.h / sizes[3] then
      nextSize = sizes[4]
    end

    if cell.h == GRID.h / sizes[4] then
      nextSize = sizes[1]
    end

    cb(cell, nextSize)
    if cell[oppAxis] ~= 0 and cell[oppAxis] + cell[oppDim] ~= GRID[oppDim] then
      cell[oppDim] = GRID[oppDim]
      cell[oppAxis] = 0
    end

    hs.grid.set(win, cell, screen)
  end

end
end

-- not sure if this is just redundant now....
function nextFullScreenStep()
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local screen = win:screen()

    cell = hs.grid.get(win, screen)

    local nextSize = fullScreenSizes[1]
    for i=1,#fullScreenSizes do
      if cell.w == GRID.w / fullScreenSizes[i] and 
         cell.h == GRID.h / fullScreenSizes[i] and
         cell.x == (GRID.w - GRID.w / fullScreenSizes[i]) / 2 and
         cell.y == (GRID.h - GRID.h / fullScreenSizes[i]) / 2 then
        nextSize = fullScreenSizes[(i % #fullScreenSizes) + 1]
        break
      end
    end

    cell.w = GRID.w / nextSize
    cell.h = GRID.h / nextSize
    cell.x = (GRID.w - GRID.w / nextSize) / 2
    cell.y = (GRID.h - GRID.h / nextSize) / 2

    hs.grid.set(win, cell, screen)
  end
end

-- legacy habit from my old slate days, wanting to go direct to full screen
function fullDimension(dim)
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    local id = win:id()
    local screen = win:screen()
    cell = hs.grid.get(win, screen)

    if (dim == 'x') then
      cell = '0,0 ' .. GRID.w .. 'x' .. GRID.h
    else  
      cell[dim] = GRID[dim]
      cell[dim == 'w' and 'x' or 'y'] = 0
    end

    hs.grid.set(win, cell, screen)
  end
end

hs.hotkey.new(mash, "/", function()
    local win = hs.window.focusedWindow()
    local frame = win:frame()
    local screen = win:screen()
    local sframe = screen:frame()

    if toggle == true then
        toggle = false
        frame.x = 0
        frame.w = sframe.w * .85
    else
        toggle = true
        frame.x = sframe.w * .85
        frame.w = sframe.w * .15
    end

    frame.y = 0
    frame.h = sframe.h

    win:setFrame(frame)
end):enable()

hs.hotkey.bind(mash, "right", function ()
  pressed.right = true
  if pressed.left then 
    fullDimension('w')
  else
    nextStep('w', true, function (cell, nextSize)
      cell.x = GRID.w - GRID.w / nextSize
      cell.w = GRID.w / nextSize
    end)
  end
end, function () 
  pressed.right = false
end)

hs.hotkey.bind(mash, "left", function ()
  pressed.left = true
  if pressed.right then 
    fullDimension('w')
  else
    nextStep('w', false, function (cell, nextSize)
      cell.x = 0
      cell.w = GRID.w / nextSize
    end)
  end
end, function () 
  pressed.left = false
end)

hs.hotkey.bind(mash, "down", function ()
  pressed.down = true
  if pressed.up then 
    fullDimension('h')
  else
    nextStep('h', true, function (cell, nextSize)
      cell.y = GRID.h - GRID.h / nextSize
      cell.h = GRID.h / nextSize
    end)
  end
end, function () 
  pressed.down = false
end)

hs.hotkey.bind(mash, "up", function ()
  pressed.up = true
  if pressed.down then 
      fullDimension('h')
  else
    nextStep('h', false, function (cell, nextSize)
      cell.y = 0
      cell.h = GRID.h / nextSize
    end)
  end
end, function () 
  pressed.up = false
end)


hs.hotkey.new({"ctrl"}, "right", function()
    local win = hs.window.focusedWindow()
    win:focusWindowEast()

end):enable()
hs.hotkey.new({"ctrl"}, "up", function()
    local win = hs.window.focusedWindow()
    win:focusWindowNorth()
end):enable()

hs.hotkey.new({"ctrl"}, "left", function()
    local win = hs.window.focusedWindow()
    win:focusWindowWest()
end):enable()

hs.hotkey.new({"ctrl"}, "down", function()
    local win = hs.window.focusedWindow()
    win:focusWindowSouth()
end):enable()

hs.hotkey.new({"ctrl"}, "\\", function()
    local win = hs.window.focusedWindow()
    local frame = win:frame()
    win:maximize()
end):enable()

hs.hotkey.bind(mash, "R", function()
    hs.reload()
    hs.alert.show("HS RELOADED")
end)


-- Send Window Next Monitor --> see: https://gist.github.com/josephholsten/1e17c7418d9d8ec0e783
hs.hotkey.bind({"ctrl"}, "]", function()
  local win = hs.window.focusedWindow()
  --local nextScreen = win:screen():next()
  local nextScreen = win:moveOneScreenEast()
  win:moveToScreen(nextScreen)
end)

hs.hotkey.bind({"ctrl"}, "[", function()
  local win = hs.window.focusedWindow()
  --local nextScreen = win:screen():next()
  local nextScreen = win:moveOneScreenWest()
  win:moveToScreen(nextScreen)
end)

-- Allow me to switch between windows rather than just apps 
-- (e.g., I don't want to bounce between sublime/preview/ and ALL open excel files)
-- https://github.com/Hammerspoon/hammerspoon/issues/2037
switcher = hs.window.switcher.new() -- default windowfilter: only visible windows, all Spaces
switcher_space = hs.window.switcher.new(hs.window.filter.new():setCurrentSpace(true):setDefaultFilter{}) -- include minimized/hidden windows, current Space only
switcher_browsers = hs.window.switcher.new{'Safari','Google Chrome'} -- specialized switcher for your dozens of browser windows :)

-- bind to hotkeys; WARNING: at least one modifier key is required!
hs.hotkey.bind(mash,'tab','Next window yo',function()switcher:next()end)
hs.hotkey.bind('ctrl-cmd-shift','tab','Prev window',function()switcher:previous()end)