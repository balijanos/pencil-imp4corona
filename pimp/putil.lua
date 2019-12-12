-- ====================================================================
-- Pimp global utilities
-- ====================================================================
--

-- Copy a file to another.
--
-- @tparam string src  Source filename.
-- @tparam string dst  Destination filename.
-- @tparam number? blocksize  Size of read blocks. Default is 1M.

local json = require "json"

function copyfile(src, dst, blocksize)
	blocksize = blocksize or 1024*1024
	local sf, df, err
	local function bail(...)
		if sf then sf:close() end
		if df then df:close() end
		return ...
	end
	sf, err = io.open(src, "rb")
	if not sf then return bail(nil, err) end
	df, err = io.open(dst, "wb")
	if not df then return bail(nil, err) end
	while true do
		local ok, data
		data = sf:read(blocksize)
		if not data then break end
		ok, err = df:write(data)
		if not ok then return bail(nil, err) end
	end
	return bail(true)
end

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

function os.fileExists(fileName, filePath)
  local path = system.pathForFile( fileName, filePath or appDataPath )
	if path == nil then
		return false
	else
		local file = io.open(path, "r")
		if file then
			io.close(file)
      return true
		end
		return false
	end
end

function table.load( filename, location )
 
    local loc = location
    if not location then
        loc = appDataPath
    end
 
    -- Path for the file to read
    local path = system.pathForFile( filename, loc )
 
    -- Open the file handle
    local file, errorString = io.open( path, "r" )
 
    if not file then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
    else
        -- Read data from file
        local contents = file:read( "*a" )
        -- Decode JSON data into Lua table
        local t = json.decode( contents )
        -- Close the file handle
        io.close( file )
        -- Return table
        return t
    end
end

function table.print_r ( t ) 
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end