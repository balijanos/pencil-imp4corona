-- ====================================================================
-- Pimp parser
-- ====================================================================
--
-- (c) 2018-19, IT-Gears.hu
-- 
-- Author: Janos Bali
--
-- version v1.2
--
local zip = require "plugin.zip"
local lfs = require "lfs"
local xml = require "pimp.xml"

require "pimp.pgen"
require "pimp.putil"

local zipFile
local tmpDir = system.pathForFile("", system.TemporaryDirectory)
local srcDir = system.pathForFile("", system.ResourceDirectory)
local files, dirs

local pimpDoneCallback
local pimpExportDir
local prefix

local function getProperty(p, propName, propValue)
  local props = {}
  propName = propName or "name"
  propValue = propValue or "value"
  for k,v in pairs(p) do
    props[v.properties[propName]] = v[propValue]
  end
  return props
end

local function getProps(p)
  local props = {}
  propName = propName or "name"
  propValue = propValue or "value"
  for i=1, #p do
    if p[i] and p[i].properties and p[i].properties.name and p[i].value then
      -- print(i, p[i].properties.name,"=",p[i].value)
      props[p[i].properties.name] = p[i].value
    else
      props[p[i].name] = p[i].properties
    end
  end
  return props
end

local function getFiles(t)
	local f = {}
  local d = {}
  for k,v in pairs(t) do
    if string.sub(v,-1) == "/" then
      table.insert(d,v)
    else
      table.insert(f,v)
    end
	end
  return f, d
end
local function processZip(event)
  
  local startPage
  local projectName = zipFile:match("^.+/(.+)$"):match("(.+)%..+")
  
  local oDir = lfs.currentdir()
  -- move files
  lfs.chdir(tmpDir)
  for k,v in pairs(dirs) do
    lfs.mkdir(v)
  end
  for k,v in pairs(files) do
    copyfile(srcDir.."/"..v, tmpDir.."/"..v)
    os.remove(srcDir.."/"..v)
  end
  lfs.chdir(oDir)
  for k,v in pairs(dirs) do
    lfs.rmdir(v)
  end
  
  xmlP = xml.newParser()
  local t = xmlP:loadFile("content.xml", system.TemporaryDirectory)

  if "Pages" == t.child[2].name then
    local pages = {}
    for n,v in pairs(t.child[2].child) do
      local p = xmlP:loadFile(v.properties.href, system.TemporaryDirectory)
      
      local page = getProperty(p.child[1].child, "name", "value")
      
      if startPage==nil and string.lower(page.name) ~= "icon" then
        startPage = page.name:gsub(" ","")
      end
      
      local ctag = p.child[2].child
      local props = {}
      for i=1, #ctag do
        props[i]={}
        props[i].id = ctag[i].properties.id
        props[i].type = ctag[i].properties.type
        props[i].def = ctag[i].properties.def
        props[i].ref = ctag[i].properties.RelatedPage
        props[i].transform = ctag[i].properties.transform
        local metag = ctag[i].child
        for j=1, #metag do
          local p = getProps(metag[j].child)
          props[i][j] = p
          props[i][j]["properties"] = metag[j].properties
          props[i][j]["name"] = metag[j].name
          if metag[j].child and #metag[j].child>0 then
            props[i][j]["childs"] = {}
            for k=1,#metag[j].child do
              if metag[j].child[k] then
                props[i][j]["childs"][k] = getProps(metag[j].child[k].child)
              end
            end
          end
        end
      end
      page["content"] = props
      pages[n] = page
    end
    makePages(pages,projectName,pimpExportDir,tmpDir,prefix)
    
    if type(pimpDoneCallback)=="function" then
      pimpDoneCallback(projectName, startPage)
    end
  end
end

local function unzipListener( event )
  files, dirs = getFiles(event.response)
end
local unzipOptions = {
    zipFile = zipFile,
    zipBaseDir = system.ResourceDirectory,
    dstBaseDir = system.ResourceDirectory,
    listener = function(e) files,dirs=getFiles(e.response) processZip(e) end
}

local M = {}

function M.import(fileName, outDir, appPrefix, pdc)
  pimpExportDir = outDir or "export"
  prefix = appPrefix
  pimpDoneCallback = pdc or function() end
  zipFile = fileName
  unzipOptions.zipFile = zipFile
  zip.uncompress( unzipOptions )
end

return M