-- ====================================================================
-- Pimp sourcecode generator
-- ====================================================================
--
-- (c) 2018-19, IT-Gears.hu
-- 
-- Author: Janos Bali
--
-- 1.2 : 
--  added generic object
--  align property for newText added
--  stored options for native/all objects
--
local lfs = require "lfs"
local file = require "pimp.putil"
local json = require "json"

local pageRef, resourceRef, varRef

local namespace = ""

local exportInfo = [[
-- 
-- generated by pimp v1.2
-- 
-- (c) 2018-19, IT-Gears.hu
-- 
-- Author: Janos Bali
--
--
]]

local sceneRequire = [[
local composer = require "composer"
local pimpCore = require "pimp.core"
local dict = require "pimp.dictionary"
local pimp = require "#NSPC#pimp.#MDLE#"
]]

local sceneTemplate = [[

local scene = composer.newScene()

local sceneObjects
local objectOptions

function scene:create(event)
  local sceneGroup = self.view
  sceneObjects = pimp.getSceneObjects(event,sceneGroup)
  objectOptions = pimp.getObjectOptions()
end

function scene:show(event)
  if event.phase=="will" then
    for o,t in pairs(sceneObjects) do
      if objectOptions[o].translate then 
        sceneObjects[o].text = dict.get(objectOptions[o].text)
      end
    end
    pimpCore.showNativeObjects(sceneObjects,objectOptions)
  end
end

function scene:hide(event)
  if event.phase=="did" then
    pimpCore.hideNativeObjects(sceneObjects,objectOptions)
  end
end

function scene:destroy( event)
  pimpCore.destroyNativeObjects(sceneObjects,objectOptions)
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
]]

local template = [[
local pfont= require "pimp.pfont"
local pimpCore = require "pimp.core"
local dict = require "pimp.dictionary"

local m={}
local objectOptions = {}
function m.getObjectOptions()
  return objectOptions
end
function m.getSceneObjects(event,sceneGroup)
  local opt, obj
  local sceneObjects = {}
  
]]

local template_end = [[

  return sceneObjects
end
return m
]]

-- utilities -----------------------------------------------------------
function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end

function math.round(x)
  if x%2 ~= 0.5 then
    return math.floor(x+0.5)
  end
  return x-0.5
end

local function getPageRef(t, notquoted)
  local ref = t.ref
  if pageRef and ref then
    for i,p in pairs(pageRef) do
      if p.id==ref then
        if notquoted then
          return string.gsub(p.name, " ", "")
        else
          return "\""..namespace..string.gsub(p.name, " ", "").."\""
        end
      end
    end
  end
  return "nil"
end

local function getTransform(t)
  local trans = {}
  local i = 1
  for match in string.gmatch(t.transform,"[%d%.%d+%d-e?%-?%d?]+") do
    if i<5 then
      table.insert(trans, math.round( math.acos(tonumber(match))/math.pi*180) )
    else
      table.insert(trans, math.round(tonumber(match)))
    end
    i = i + 1
  end
  return trans
end

local function getStyle(s)
  local style = {}
  local tt = s:split(";")
  for i=1,#tt do
    local r = tt[i]:split(":")
    if r and r[1] and r[2] then
      style[string.gsub(r[1]," ","")] = string.gsub(r[2]," ","")
    end
  end
  return style
end

local function getAlignment(s)
  local al = s:split(",")
  local hA = "left"
  if al[1] == "1" then hA = "center" elseif  al[1] == "2" then hA = "right" end
  local hV = "top"
  if al[2] == "1" then hV = "middle" elseif  al[2] == "2" then hV = "bottom" end
  return hA, hV
end

local function getPair(s)
  local p = s:split(",")
  return p[1],p[2]
end

local function getFontParams(fStyle)
  local fName = "native.systemFont"
  local fSize = 12
  local fAlign = "left"
  if fStyle["font-weight"] == "bold" then
    fName = "native.systemFontBold"
  end
  local ff = fStyle["font-family"]
  if ff then 
	  local fl = ff:match("([^,]+),([^,]+)")
	  local ff = fl or ff
	  if string.find(ff, '^"', 1) then
		ff = string.sub(ff, 2, -2)
	  end
	  if ff ~= "LiberationSans" then
      fName = "pfont.get('"..ff.."')"
	  end
	  fSize = string.gsub(fStyle["font-size"],"px","")
	  fAlign = fStyle["text-align"]
  end
  return fName, fSize, fAlign
end

local function getListItems(s,specChar)
  local items = {}
  local tt = s:split("|")
  local hl = -1
  for i=1,#tt do
    if tt[i] then
      if specChar and string.find(tt[i], specChar) then
        local ti = string.gsub(tt[i],specChar,"")
        table.insert(items,ti)
        hl = i
      else
        table.insert(items,tt[i])
      end
    end
  end
  return items, hl
end

local function getColorString(s)
  if s then
    s = s:sub(2)
    local r = tonumber("0x"..s:sub(1,2))/255
    local g = tonumber("0x"..s:sub(3,4))/255
    local b = tonumber("0x"..s:sub(5,6))/255
    local a = tonumber("0x"..s:sub(7,8))/255
    return r..","..g..","..b..","..a
  else
    return "1,1,1,1"
  end
end

local function getImageString(s)
  local img = {}
  local opt = s:split(",")
  img[1] = string.gsub(opt[3],"ref://","")
  img[2] = opt[1]
  img[3] = opt[2]
  return img
end

local function getVarName(t)
  varRef = varRef or {}
  local vt = t[1].varType or "obj"
  local v = string.gsub(t[1].varName or ""," ","_")
  if string.len(v)==0 then v = vt end
  local n = varRef[v]
  if n==nil then
    varRef[v] = 1
    return v, vt
  else
    varRef[v] = n + 1
    return v .. varRef[v], vt
  end
end

local function beginObject(t)
  local varName, varType = getVarName(t)
  local script =   string.format( "\tobjectOptions[\"%s\"] = {\n", varName )
  script = script..string.format( "\tid = \"%s\",\n", varName)
  script = script..string.format( "\ttype = \"%s\",\n", varType)
  script = script..string.format( "\tisVisible = %s,\n", t[1].visible or "true" ) 
  if t[1].notranslate~=nil then
      script = script..string.format( "\ttranslate = %s,\n",  tostring(t[1].notranslate =="false") ) 
  end
  return script, varName
end

local function endObject(t, varName, cfunc )
  local script =   string.format( "\tsceneGroup = sceneGroup,\n" )
  if  getPageRef(t)~="nil" then
	script = script..string.format( "\treference = %s,\n\t}\n", getPageRef(t) )
  else
	script = script.."\t}\n"
  end
  script = script..string.format( "\tobj = pimpCore.%s (objectOptions[\"%s\"])\n", cfunc, varName)
  script = script..string.format( "\tobj.id = \"%s\"\n", varName ) 
  script = script..string.format( "\tobj.isVisible = %s\n", t[1].visible or "true" ) 
  script = script..string.format( "\tsceneObjects[\"%s\"] = obj\n", varName)
  return script
end

------------------------------------------------------------------------
local function doRect(t)
  local trf = getTransform(t)
  local style = getStyle(t[2].rect.style)
  local wh = t[1].box:split(",")
  
  local objStr, varName = beginObject(t)
  objStr = objStr..string.format( "\tx = %s,\n", trf[5] )
  objStr = objStr..string.format( "\ty = %s,\n", trf[6] ) 
  objStr = objStr..string.format( "\twidth = %s,\n", wh[1] )
  objStr = objStr..string.format( "\theight = %s,\n", wh[2] )
  objStr = objStr..string.format( "\tcornerRadius = %s,\n", t[2].rect.rx )
  objStr = objStr..string.format( "\tstrokeWidth = %s,\n", style["stroke-width"])
  objStr = objStr..string.format( "\tfillColor = {%s},\n", getColorString(t[1].fillColor))
  objStr = objStr..string.format( "\tstrokeColor = {%s},\n", getColorString(t[1].strokeColor))
  objStr = objStr..endObject(t, varName, "newRect")
  return objStr
end

local function doCircle(t)
  local trf = getTransform(t)
  local style = getStyle(t[2].properties.style)
  
  local objStr, varName = beginObject(t)
  objStr = objStr..string.format( "\tx = %s,\n", trf[5] )
  objStr = objStr..string.format( "\ty = %s,\n", trf[6] ) 
  objStr = objStr..string.format( "\tradius = %s,\n", t[2].properties.rx )
  objStr = objStr..string.format( "\tstrokeWidth = %s,\n", style["stroke-width"])
  objStr = objStr..string.format( "\tfillColor = {%s},\n", getColorString(t[1].fillColor))
  objStr = objStr..string.format( "\tstrokeColor = {%s},\n", getColorString(t[1].strokeColor))
  objStr = objStr..endObject(t, varName, "newCircle")
  return objStr
end

local function doText(t)
  local trf = getTransform(t)
  local style = getStyle(t[3].properties.style)
  local fn,fs = getFontParams(style)
  
  local w, h = getPair(t[1].box or t[1].width)
  local aH, aV = getAlignment(t[1].textAlign)
  
  local objStr, varName = beginObject(t)
  
  objStr = objStr..string.format( "\ttext = [[%s]],\n", t[1].label )
  objStr = objStr..string.format( "\tx = %s,\n", trf[5] )
  objStr = objStr..string.format( "\ty = %s,\n", trf[6])
  objStr = objStr..string.format( "\tfont = %s,\n", fn )
  objStr = objStr..string.format( "\tfontSize = %s,\n", fs )
  objStr = objStr..string.format( "\tfillColor = {%s},\n", getColorString(t[1].textColor) )
  objStr = objStr..string.format( "\twidth = %d,\n", w)
  objStr = objStr..string.format( "\theight = %d,\n", h)
  objStr = objStr..string.format( "\talign= \"%s\",\n", aH )
  objStr = objStr..string.format( "\tvalign= \"%s\",\n", aV )
  objStr = objStr..endObject(t, varName, "newText") 
  return objStr
end

local function doMaterialIcon(t)
  local trf = getTransform(t)
  local style = getStyle(t[2].properties.style)
  
  local fn,fs = getFontParams(style)
  
  local objStr, varName = beginObject(t)
  objStr = objStr..string.format( "\ttext = mIcon.get(\"%s\"),\n", t[1].label )
  objStr = objStr..string.format( "\tx = %s - %s/4,\n", trf[5], fs )
  objStr = objStr..string.format( "\ty = %s - %s/8,\n", trf[6], fs )
  objStr = objStr..string.format( "\twidth = %s,\n", fs )
  objStr = objStr..string.format( "\theight = %s,\n", fs )
  objStr = objStr..string.format( "\tfont = %s,\n", fn)
  objStr = objStr..string.format( "\tfontSize = %s,\n", fs )
  objStr = objStr..string.format( "\tfillColor = {%s},\n", getColorString(t[1].textColor) )
  objStr = objStr..endObject(t, varName, "newMaterialIcon") 
  return objStr
end


local function doButton(t)
  local trf = getTransform(t)
  local style = getStyle(t[2].rect.style)
  local strokeStyle = t[1].strokeStyle:split("|")
  local fontStyle = getStyle(t[5].properties.style)
  local w = t[1].box:split(",")
  
  local fn,fs = getFontParams(fontStyle)
  
  local objStr, varName = beginObject(t)
  objStr = objStr..string.format("\tlabel = [[%s]],\n", t[1].label)
  objStr = objStr..string.format("\tshape = \"%s\",\n", "roundedRect")
  objStr = objStr..string.format("\tcornerRadius = %s,\n", string.gsub(t[2].rect.rx,"px",""))
  objStr = objStr..string.format("\tstrokeWidth = %s,\n", strokeStyle[1])
  objStr = objStr..string.format("\tx = %s,\n", trf[5])
  objStr = objStr..string.format("\ty = %s,\n", trf[6])
  objStr = objStr..string.format("\twidth = %s,\n", w[1])
  objStr = objStr..string.format("\theight = %s,\n", w[2])
  objStr = objStr..string.format("\tfont = %s,\n", fn )
  objStr = objStr..string.format("\tfontSize = %s,\n", fs )
  objStr = objStr..string.format("\tlabelColor  = { default={%s}, over={%s} },\n",
    getColorString(t[1].textColor), getColorString(t[1].textOverColor) )
  objStr = objStr..string.format("\tfillColor = { default={%s}, over={%s} },\n",
    getColorString(t[1].fillColor), getColorString(t[1].fillOverColor) )
  objStr = objStr..string.format("\tstrokeColor  = { default={%s}, over={%s} },\n",
    getColorString(t[1].strokeColor), getColorString(t[1].strokeOverColor) )
  objStr = objStr..endObject(t, varName, "newButton")
  return objStr
end

local function doSpinner(t)
  local trf = getTransform(t)
  local wh = t[1].box:split(",")
  
  local objStr, varName = beginObject(t)
  objStr = objStr..string.format("\tx = %s,\n", trf[5])
  objStr = objStr..string.format("\ty = %s,\n", trf[6])
  objStr = objStr..string.format("\twidth = %s,\n", wh[1])
  objStr = objStr..string.format("\theight = %s,\n", wh[2])
  objStr = objStr..endObject(t, varName, "newSpinner")
  return objStr
end

local function doImage(t)
  local trf = getTransform(t)
  local img = getImageString(t[1].imageData) 
  table.insert(resourceRef,img[1])
  
  local wh = t[1].box:split(",")
  local objStr, varName = beginObject(t)
  objStr = objStr..string.format("\timage = \"%s\",\n", img[1])
  -- objStr = objStr..string.format("\twidth = %s,\n",img[2])
  -- objStr = objStr..string.format("\theight = %s,\n",img[3])
  objStr = objStr..string.format("\twidth = %s,\n", wh[1])
  objStr = objStr..string.format("\theight = %s,\n", wh[2])
  objStr = objStr..string.format("\tx = %s,\n",trf[5] )
  objStr = objStr..string.format("\ty = %s,\n",trf[6] )
  objStr = objStr..endObject(t, varName, "newImageRect")
  return objStr
end


local function doSwitch(t)
  local trf = getTransform(t)
  local wh = t[1].box:split(",")
  local switchStyle = t[1].varType or "onOff"
  
  local objStr, varName = beginObject(t)
  objStr = objStr..string.format("\tstyle  = \"%s\",\n", switchStyle)
  objStr = objStr..string.format("\tinitialSwitchState  = %s,\n",t[1].on)
  objStr = objStr..string.format("\tx = %s,\n",trf[5])
  objStr = objStr..string.format("\ty = %s,\n",trf[6])
  objStr = objStr..string.format("\twidth = %s,\n", wh[1])
  objStr = objStr..string.format("\theight = %s,\n", wh[2])
  objStr = objStr..endObject(t, varName, "newSwitch")
  return objStr
end

local function doSlider(t)
  local trf = getTransform(t)
  local wh = t[1].box:split(",")
  local prog = t[1].prog:split(",")
  
  local orientation = t[1].orientation or "horizontal"
  local value = 100* tonumber(prog[1]) / tonumber(wh[1])
  if orientation == "vertical" then
    value = 100 * (1- tonumber(prog[2]) / tonumber(wh[2]))
  end
  
  local objStr, varName = beginObject(t)
  objStr = objStr..string.format("\tx = %s,\n",trf[5])
  objStr = objStr..string.format("\ty = %s,\n",trf[6])
  objStr = objStr..string.format("\torientation = \"%s\",\n",orientation)
  objStr = objStr..string.format("\tvalue = %d,\n", value )
  objStr = objStr..string.format("\twidth = %s,\n", wh[1])
  objStr = objStr..string.format("\theight = %s,\n", wh[2])
  objStr = objStr..endObject(t, varName, "newSlider")
  return objStr
end

local function doProgress(t)
  local trf = getTransform(t)
  local wh = t[1].box:split(",")
  local prog = t[1].prog:split(",")
  
  local value = tonumber(prog[1]) / tonumber(wh[1])
  
  local objStr, varName = beginObject(t)
  objStr = objStr..string.format("\tx = %s,\n",trf[5])
  objStr = objStr..string.format("\ty = %s,\n",trf[6])
  objStr = objStr..string.format("\tprogress = %f,\n", value )
  objStr = objStr..string.format("\tanimated  = %s,\n",t[1].animated)
  objStr = objStr..string.format("\twidth = %s,\n", wh[1])
  objStr = objStr..string.format("\theight = %s,\n", wh[2])
  objStr = objStr..endObject(t, varName, "newProgressView")
  
  return objStr
end

local function doTabBar(t)
  local trf = getTransform(t)
  local wh = t[1].box:split(",")
  local fontStyle = string.split(t[1].textFont,"|")
  local style = {["font-size"] = fontStyle[4], ["font-weight"] = fontStyle[2] } 
  local fn,fs = getFontParams(style)
  
  local buttons, hl = getListItems(t[1].contentText, "*")
  local butTable = "\tlocal tabButtons = {\n"
  for i,b in pairs(buttons) do
    butTable = butTable..string.format("\t{\n\tselected = %s,\n", tostring(i==hl) )
    butTable = butTable..string.format("\tid = \"%s\",\n", string.gsub(b," ","") )
    if t[1].varType == "TabBar" then
      butTable = butTable..string.format("\tlabel = \"%s\",\n", b )
      butTable = butTable..string.format("\tfont = %s,\n", fn )
      butTable = butTable..string.format("\tlabelYOffset = -%d,\n" , fs/2 ) 
    else
      butTable = butTable..string.format("\tlabel = mIcon.get(\"%s\"),\n", b )
      butTable = butTable..string.format("\tfont = %s,\n", fn )
    end
    butTable = butTable..string.format("\tsize = %d,\n", fs )
    butTable = butTable..string.format("\tlabelColor  = { default={%s}, over={%s} },\n",
    getColorString(t[1].textColor), getColorString(t[1].textOverColor) )
    butTable = butTable.."\t},\n"
  end
  butTable = butTable.."\t}\n"
  
  local objStr, varName = beginObject(t)
  objStr = objStr..string.format("\tleft = %s,\n",trf[5])
  objStr = objStr..string.format("\ttop = %s,\n",trf[6])
  objStr = objStr..string.format("\twidth = %s,\n", wh[1])
  objStr = objStr..string.format("\theight = %s,\n", wh[2])
  objStr = objStr.."\tbuttons = tabButtons, \n"
  objStr = objStr..endObject(t, varName, "newTabBar")
  
  return butTable..objStr
end

local function doGeneric(t)
  local trf = getTransform(t)
  -- local style = getStyle(t[2].rect.style)
  local strokeStyle = t[1].strokeStyle:split("|")
  
  local fontStyle
  -- todo fix 
  if t[5] == nil then
    fontStyle = getStyle(t[4].properties.style)
  else
    fontStyle = getStyle(t[5].properties.style)
  end

  local w = t[1].box:split(",")
  local fn,fs,ta = getFontParams(fontStyle)
  
  local varType = t[1].varType
  
  local hasText = (t[1].hasText=="true")
  local hasRect = (t[1].hasRect=="true")
  local hasOverColors = (t[1].hasOverColors=="true")
  local hasUdfOpt = (t[1].udfOpt=="true")
  
  local objStr, varName = beginObject(t)
  objStr = objStr..string.format("\tgenericType = \"%s\",\n", varType )
  objStr = objStr..string.format("\thasText = %s,\n", tostring(hasText) )
  objStr = objStr..string.format("\thasRect = %s,\n", tostring(hasRect) )
  objStr = objStr..string.format("\thasOverColors = %s,\n", tostring(hasOverColors) )
  
  objStr = objStr..string.format("\tx = %s,\n", trf[5])
  objStr = objStr..string.format("\ty = %s,\n", trf[6])
  objStr = objStr..string.format("\twidth = %s,\n", w[1])
  objStr = objStr..string.format("\theight = %s,\n", w[2])
  
  if hasRect then
    objStr = objStr..string.format("\tstrokeWidth = %s,\n", strokeStyle[1])
  end
  if hasText then
    objStr = objStr..string.format("\ttext = [[%s]],\n", t[1].label)
    objStr = objStr..string.format("\tfont = %s,\n", fn )
    objStr = objStr..string.format("\tfontSize = %s,\n", fs )
    objStr = objStr..string.format("\talign= \"%s\",\n", ta or "center" )
  end
  
  if hasRect then
    objStr = objStr..string.format("\tfillColor = { %s},\n", getColorString(t[1].fillColor) )
    objStr = objStr..string.format("\tstrokeColor = { %s},\n", getColorString(t[1].strokeColor) )
  end
  if hasText then
    objStr = objStr..string.format("\ttextColor = { %s},\n", getColorString(t[1].textColor) )
  end

  if hasUdfOpt then
    -- TODO parse for test
    objStr = objStr..string.format("\t%s\n", t[1].udfOptions)
  end
  objStr = objStr..endObject(t, varName, "newGenericObject")
  
  return objStr
end

------------------------------------------------------------------------

local objects = {
	["corona:Rect"] =  doRect,
	["corona:Circle"] = doCircle,
	["corona:Text"] =  doText,
	["corona:Button"] = doButton,
	["corona:Spinner"] = doSpinner,
	["corona:MaterialIcon"] = doMaterialIcon,
	["corona:Image"] = doImage,
	["corona:Checkbox"] = doSwitch,
	["corona:RadioButton"] = doSwitch,
	["corona:Switch"] = doSwitch,
	["corona:SliderH"] = doSlider,
	["corona:SliderV"] = doSlider,
	["corona:ProgressBar"] = doProgress,
	["corona:MaterialTab"] = doTabBar,
	["corona:Tabbar"] = doTabBar,

	["corona:Generic"] = doGeneric,
}

local backgroundColor = "#FFFFFFFF"

function setBackground(bkColor)
  backgroundColor = bkColor
end

function makePages(pages, projectName, outDir, tmpDir, prefix)
  
  lfs.mkdir(outDir)
  pageRef = pages
  resourceRef = {}
  local generatedSource = {}
  
  if prefix then
    namespace = prefix.."."
  end
  
  -- generate source
  for idx=1, #pages do
    local sSrc = {}
    varRef = {}
    for k,v in pairs(pages[idx].content) do
      v.projectName = projectName
      if objects[v.def] and type(objects[v.def])=="function" then
        -- table.print_r(v)
        table.insert(sSrc, objects[v.def](v))
      else
        print("N/A", v.def, v[1].varType)
      end
    end
    generatedSource[idx]=sSrc
  end
  
  lfs.mkdir(outDir.."/pimp")
  -- save
  for idx=1, #pages do
    -- export pimpcore files
      
      local pageRequire = sceneRequire
      -- save pages (parents)
      if pages[idx].parentPageId==nil then
        
        -- export page childs
        for cidx=1, #pages do
          if pages[cidx].parentPageId and pages[cidx].parentPageId==pages[idx].id then
            local childFn= string.gsub(pages[idx].name.."_"..pages[cidx].name, " ", "")
			local fileName = outDir.."/pimp/"..childFn..".lua"
            -- print("PIMP CHILD:",childFn)
            local file, errorString = io.open( fileName, "w" )
            file:write( exportInfo .. template:gsub("#NSPC#",namespace) .. table.concat(generatedSource[cidx],"\n") .. template_end )
            io.close( file )
          end
        end
        
        local incFn= string.gsub(pages[idx].name, " ", "")
        local fileName = outDir.."/pimp/"..incFn..".lua"
        -- print("PIMP INCLD:",fileName)
      
        local file, errorString = io.open( fileName, "w" )
		assert(file,"Output path not exists! "..tostring(fileName))
        -- print("Saving",fileName)
        file:write( exportInfo .. template:gsub("#NSPC#",namespace) .. table.concat(generatedSource[idx],"\n") .. template_end )
        io.close( file )
        
        -- export scene template if not exists
        fileName = string.gsub(outDir.."/"..pages[idx].name..".lua", " ", "")
        if not lfs.attributes(fileName) then
          file, errorString = io.open( fileName, "w" )
		  pageRequire =  pageRequire:gsub("#NSPC#",namespace):gsub("#MDLE#",incFn)
          file:write( exportInfo..pageRequire..sceneTemplate )
          io.close( file )
          -- print("PIMP SCENE:",fileName)
        end
      end

    
  end
  if #resourceRef>0 then
    lfs.mkdir(outDir.."/refimages")
    for k,v in pairs(resourceRef) do
      copyfile(tmpDir.."/refs/"..v, outDir.."/refimages/"..v)
    end
  end
  
end