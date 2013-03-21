-- Simple make system for tex4ht
kpse.set_program_name("luatex")
require("ebookutils")
Make = {}
Make.add = function(self,name,fn,params)
	local params = params or {}
	Make[name] = function(self,p)
		local p = p or {}
		local fn = fn
		for k,v in pairs(p) do
			params[k]=v
		end
		print( fn % params)
	end
end

Make:add("hello", "hello ${world}", {world = "world"})
local make = Make
Make:hello()
Make:hello{world="světe"}

