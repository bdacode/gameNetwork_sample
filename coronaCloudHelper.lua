-- Copyright © 2013 Corona Labs Inc. All Rights Reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of the company nor the names of its contributors
--      may be used to endorse or promote products derived from this software
--      without specific prior written permission.
--    * Redistributions in any form whatsoever must retain the following
--      acknowledgment visually in the program (e.g. the credits of the program): 
--      'This product includes software developed by Corona Labs Inc. (http://www.coronalabs.com).'
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL CORONA LABS INC. BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- the object to be returned
local coronaCloudHelper = {}
local json = require("json")
local widget = require "widget_orig"

-- isOrientationLandscape
-- returns true if the current orientation is landscape
coronaCloudHelper.isOrientationLandscape = function()
	
	local toReturn = false
	
	local DW = display.contentWidth
	local DH = display.contentHeight
	
	if (DH < DW) then
		toReturn = true
	end
	
	return toReturn
	
end

-- isOrientationPortrait
-- returns true if the current orientation is portrait
coronaCloudHelper.isOrientationPortrait = function()

	local toReturn = false
	
	local DW = display.contentWidth
	local DH = display.contentHeight
	
	if (DH > DW) then
		toReturn = true
	end
	
	return toReturn

end

-- isIphone5
-- returns true if the current terminal is a Iphone 5
coronaCloudHelper.isIphone5 = function()
	if ( display.pixelWidth == 640 and display.pixelHeight == 1136 ) or ( display.pixelHeight == 640 and display.pixelWidth == 1136 ) then
            return true
        end
end

-- isPointInside
-- determine if a point is inside a boundary
coronaCloudHelper.isPointInside = function( obj, x, y )
	local inside = false
	local bounds = obj.contentBounds
    inside = bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
	return inside
end

-- encoding
coronaCloudHelper._b64enc = function(data)
    -- character table string
	local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
coronaCloudHelper._b64dec = function(data)
	-- character table string
	local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

coronaCloudHelper._saveCloudDataToFile = function( t )
	local path = system.pathForFile( "cData", system.DocumentsDirectory )
	local file = io.open( path, "w" )
	if file then
		local contents = json.encode( t )
		file:write( contents )
		io.close( file )
		return true
	else
 		return false
	end
end

coronaCloudHelper._loadCloudDataFromFile = function()
    local path = system.pathForFile( "cData", system.DocumentsDirectory )
    local contents = ""
    local responseTable = {}
    local file = io.open( path, "r" )
    if file then
         local contents = file:read( "*a" )
         responseTable = json.decode (contents );
         io.close( file )
         return responseTable 
    end
    return nil
end

coronaCloudHelper._fileExists = function( fileName, base )
  --assert(fileName, "fileName is missing")
  local base = base or system.TemporaryDirectory
  local filePath = system.pathForFile( fileName, base )
  local exists = false
 
  if (filePath) then -- file may exist. won't know until you open it
    local fileHandle = io.open( filePath, "r" )
    if (fileHandle) then -- nil if no file found
      exists = true
      io.close(fileHandle)
    end
  end
 
  return(exists)
end

return coronaCloudHelper
