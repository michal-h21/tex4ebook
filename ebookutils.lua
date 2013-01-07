module("ebookutils",package.seeall)
--template engine
function interp(s, tab)
  return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end
--print( interp("${name} is ${value}", {name = "foo", value = "bar"}) )

function addProperty(s,prop)
  if prop ~=nil then
    return s .." "..prop
  else
    return s
  end
end
getmetatable("").__mod = interp
getmetatable("").__add = addProperty 

--print( "${name} is ${value}" % {name = "foo", value = "bar"} )
-- Outputs "foo is bar"

function remove_extension(path)
	local found, len, remainder = string.find(path, "^(.*)%.[^%.]*$")
	if found then
		return remainder
	else
		return path
	end
end

-- 

function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- searching for converted images
function parse_lg(filename)
  local outputfiles,status={},nil
  if not file_exists(filename) then
    print("Cannot read log file: "..filename)
  else
    for line in io.lines(filename) do
      line:gsub("==> ([%a%d%p.]*)",function(k) table.insert(outputfiles,k) end)
    end
    status=true
  end
  return outputfiles,status
end

