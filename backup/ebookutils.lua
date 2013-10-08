module("ebookutils",package.seeall)

--local make4ht = require("make4ht")
local make4ht = require("make4ht-eb")
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
    local fonts = {}
    local used_fonts = {}
    for line in io.lines(filename) do
      line:gsub("==> ([%a%d%p%.%-%_]*)",function(k) table.insert(outputimages,k)end)
      line:gsub("File: (.*)",  function(k) 
	 if not usedfiles[k] then
	   table.insert(outputfiles,k)
	   usedfiles[k] = true
         end
      end)
      line:gsub("htfcss: ([^%s]+)(.*)",function(k,r)
	      local fields = {}
	      r:gsub("[%s]*([^%:]+):[%s]*([^;]+);",function(c,v) 
		      fields[c] = v
	      end)
	      fonts[k] = fields
      end)
   
      line:gsub('Font("([^"]+)","([%d]+)","([%d]+)","([%d]+)"',function(n,s1,s2,s3) 
	      table.insert(used_fonts,{n,s1,s2,s3})
      end)
    end
    status=true
  end
  return {files = outputfiles, images = outputimages, htfonts = fonts,fonts = used_fonts},status
end

function copy_filter(src,dest, filter)
  local src_f=io.open(src,"rb")
  local dst_f=io.open(dest,"w")
  local contents = src_f:read("*all")
  local filter = filter or function(s) return s end
  src_f:close()
  dst_f:write(filter(contents))
  dst_f:close()
end

local cp_func = os.type == "unix" and "cp" or "copy"
function copy(src,dest)
	local command = string.format("%s %s %s", cp_func, src, dest)
	if cp_func == "copy" then command = command:gsub("/",'\\') end
	print("Copy: "..command)
	os.execute(command)
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
  local untrusted_function = nil
  if not loadstring then
	  untrusted_function, message = load(untrusted_code, nil, "t",env)
  else
	  untrusted_function, message = loadstring(untrusted_code)
  end
  if not untrusted_function then return nil, message end
  if not setfenv then setfenv = function(a,b) return true end end
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
env.Make:add("test","no takže ${tex4ht_sty_par} ${htlatex} ${input} ${config}")
env.Make:add("htlatex", "${htlatex} ${latex_par} --jobname=${input} '\\makeatletter\\def\\HCode{\\futurelet\\HCode\\HChar}\\def\\HChar{\\ifx\"\\HCode\\def\\HCode\"##1\"{\\Link##1}\\expandafter\\HCode\\else\\expandafter\\Link\\fi}\\def\\Link#1.a.b.c.{\\g@addto@macro\\@documentclasshook{\\RequirePackage[#1${mathml}html]{tex4ht}\\RequirePackage{tex4ebook}}\\let\\HCode\\documentstyle\\def\\documentstyle{\\let\\documentstyle\\HCode\\expandafter\\def\\csname tex4ht\\endcsname{#1,html}\\def\\HCode####1{\\documentstyle[tex4ht,}\\@ifnextchar[{\\HCode}{\\documentstyle[tex4ht]}}}\\makeatother\\HCode '${config}${tex4ht_sty_par}'.a.b.c.\\input  ${input}'")
env.Make:add("tex4ht","tex4ht ${input} ${tex4ht_par}")
env.Make:add("t4ht","t4ht ${input} ${t4ht_par}")

function load_config(settings, config_name)
  local settings = settings or main_settings
  env.settings = settings
  local config_name = config_name or "config.lua"
  local f = io.open(config_name,"r")
  if not f then return env, "Cannot open config file" end
  local code = f:read("*all")
  assert(run(code,env))
  return env
end


