--*********************************************************************************************
--
-- ====================================================================
-- Simple Dictionary
-- ====================================================================
--
-- File: dictionary.lua
--
-- Version 1.0
--
--
--*********************************************************************************************

require "pimp.putil"

local m = {}

local dictionary = table.load( "dictionary.json" ) or {}

function m.get(key,lng)
  lng = lng or string.lower(_APP_LANG) or "hu"
  key = key or "???"
  if dictionary[key] then
    return dictionary[key][lng] or key
  else
    -- print("WARNING! DICTIONARY KEY MISSING:", key )
    return key
  end
end

function m.getDictionary()
  return dictionary
end

return m