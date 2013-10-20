kpse.set_program_name("luatex")
local  function exists(fn)
	local f = io.open(fn,"r")
	if f~=nil then io.close(f) return true else return false end
end
local function load_fontbase(pathtable)
	-- path should point to possible location of luaotfload font database
	-- pathtable should be array of strings
	-- each path should not end with lua

	local path = pathtable
	if type(pathtable) =="string" then path = {pathtable} end
	if #path == 0 then return nil end
	local currentpath = table.remove(path,1)
	if exists(currentpath ..".lua") then return require(currentpath) 
	else return load_fontbase(path) end
end

--local fontbase  = require(kpse.expand_var("$TEXMFSYSVAR")  .. "/luatex-cache/generic/names/luaotfload-names.lua")
local sysvar = kpse.expand_var("$TEXMFSYSVAR")
local var =  kpse.expand_var("$TEXMFVAR")
local namespath = "/luatex-cache/generic/names/"
local oldnames = "otfl-names"
local newnames = "luaotfload-names"
local compose_path = function(path, name) return path .. namespath .. name end
local fontbase_path = {
	compose_path(sysvar, newnames), 
	compose_path(var, newnames),
	compose_path(sysvar, oldnames),
	compose_path(var,oldnames)
}

local fontbase = load_fontbase(fontbase_path) or {}
fontbase.mappings = fontbase.mappings or {}
-- assert(fontbase, "Cannot load font names")


-- [[
-- This is code for querying the database
--
local search = arg[1] or ""
search = unicode.utf8.lower(search)
--]]
local fonts = {}
for _,record in pairs(fontbase.mappings) do
	local familyname = record.familyname
	local styles = fonts[familyname] or {}  
	local sanitized = record.sanitized or record.names
	local subfamily = sanitized.subfamily --record.sanitized.subfamily or record.names.subfamily
	styles[subfamily] = record -- We add subfamily as key to prevent duplicates
	fonts[familyname] = styles
end

local FontLoader = {}

FontLoader.__index = FontLoader

FontLoader.load_family = function(familyname)
	local self = setmetatable({},FontLoader)
	local family = fonts[familyname]
	--[[ for _, record in pairs(fontbase.mappings) do
		if record.familyname == familyname then 
			local style = record.sanitized.subfamily
			family[style] = record
		end
	end
	--]]
	self.family = family
	return self
end
FontLoader.get_path =function(self,style)
	local rec = self.family[style]
	local filename = rec.filename
	if type(filename) == "table" then
		filename = filename[1]
	end
	return kpse.find_file(filename,'opentype fonts') or kpse.find_file(filename,'truetype fonts')
end


FontLoader.list = function(self)
	for style,rec in pairs(self.family) do
		print(style, self:get_path(style))
	end
end


local FontNames = {}
FontNames.__index = FontNames

FontNames.new = function()
	self = setmetatable({},FontNames)
	self.names = {}
	return self
end

FontNames.add_family = function(self,properties) 
	local properties = properties or {}
	return function(names)
		local names = names or {}
		for _,n in pairs(names) do
			self.names[n] = properties
		end
	end
end

FontNames.list = function(self)
	for name,prop in pairs(self.names) do
		local p = {}
		for k,v in pairs(prop) do
			table.insert(p,k..'='..v)
		end
		print(name, table.concat(p))
	end
end

--[[
local fontnames = {}
for fontname,_ in pairs(fonts) do
	local lowername = unicode.utf8.lower(fontname)
	if lowername:find(search) then 
		table.insert(fontnames, fontname)
	end
end

table.sort(fontnames)
--for fontname, styles in pairs (fonts) do
for _, name in pairs(fontnames) do
	local fontname = name
	local styles = fonts[fontname]
	local t = {} 
	for n,_ in pairs(styles) do table.insert(t,n) end
	print(fontname, table.concat(t,', '))
end
--]]

local testfont = FontLoader.load_family("math")
--testfont:list()

local n= FontNames.new()
n:add_family {type = "serif", name = "LMMono10"} {"cmr"}
n:add_family {type = "serif", name = "TeXGyreTermes"} {"ts1-qtmr", "ec-qtmr","ec-qtmri"}
--n:list()

return {FontLoader = FontLoader, FontNames =  n}
