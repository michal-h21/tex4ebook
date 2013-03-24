-- Simple make system for tex4ht
kpse.set_program_name("luatex")
local ebookutils = require("ebookutils")

Make = {}
Make.build_seq = {}
Make.type = "make"
Make.add = function(self,name,fn,params)
	local params = params or {}
	Make[name] = function(self,p,typ)
		local typ = typ or "make"
		local p = p or {}
		local fn = fn
		for k,v in pairs(p) do
			params[k]=v
		end
		print( fn % params)
		local command = {
			name=name,
			type=typ,
			command = fn,
			params = params
		}
		table.insert(self.build_seq,command)
	end
end


Make.run = function(self) 
	for _,v in ipairs(self.build_seq) do
		print("sekvence: "..v.name.." ".. v.type)
	end
end

Make:add("hello", "hello ${world}", {world = "world"})
Make:add("ajaj", "ajaj")
Make:hello()
Make:hello{world="světe"}
Make:hello()
Make:run()
