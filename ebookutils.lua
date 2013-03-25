module("ebookutils",package.seeall)

local make4ht = require("make4ht")
--template engine
function interp(s, tab)
	local tab = tab or {}
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

function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

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
  print("Parse LG")
  local outputimages,outputfiles,status={},{},nil
  if not file_exists(filename) then
    print("Cannot read log file: "..filename)
  else
    local usedfiles={}
    for line in io.lines(filename) do
      line:gsub("==> ([%a%d%p%.%-%_]*)",function(k) table.insert(outputimages,k)end)
      line:gsub("File: (.*)",  function(k) 
	 if not usedfiles[k] then
	   table.insert(outputfiles,k)
	   usedfiles[k] = true
         end
      end)
    end
    status=true
  end
  return {files = outputfiles, images = outputimages},status
end

--function copy(src,dest, filter)
--  local src_f,dst_f=io.open(src,"r"),io.open(dest,"w")
--  local contents = src_f:read("*all")
--  local filter = filter or function(s) return s end
--  dst_f:write(filter(contents))
--  src_f:close()
--  dst_f:close()
--end

local cp_func = os.type == "unix" and "cp" or "copy"
function copy(src,dest)
	os.execute(string.format("%s %s %s", cp_func, src, dest))
end

mkdirectories = function(dirs)
  local currdir = lfs.currentdir()
  --print("Path: "..path) 
  --local dirs = path:split("/")
  --table.remove(dirs,#dirs) 
  for _,dir in ipairs(dirs) do
    local status = lfs.chdir(dir)
    if not status then  
      local status, msg = lfs.mkdir(dir)
      if not status then 
        print("Path making error: "..msg)
        break
      else
        lfs.chdir(dir)
      end
    end
    print(dir)
  end
  --lfs.copy(currdir.."/".."make.lua",currdir.."/"..path.."/make.lua")
  lfs.chdir(currdir)
  --os.execute("cp make.lua "..path)
end


-- Config loading
local function run(untrusted_code, env)
  if untrusted_code:byte(1) == 27 then return nil, "binary bytecode prohibited" end
  local untrusted_function, message = loadstring(untrusted_code)
  if not untrusted_function then return nil, message end
  setfenv(untrusted_function, env)
  return pcall(untrusted_function)
end

local main_settings = {}
main_settings.fonts = {}
local env = {}
env.Font = function(s)
  local font_name = s["name"]
  if not font_name then return nil, "Cannot find font name" end
  env.settings.fonts[font_name] = s
end

env.Make = make4ht.Make
env.Make.params = env.settings
function load_config(settings, config_name)
  local settings = settings or main_settings
  env.settings = settings
  local config_name = config_name or "config.lua"
  local f = io.open(config_name,"r")
  if not f then return nil, "Cannot open config file" end
  local code = f:read("*all")
  assert(run(code,env))
  return env
end


