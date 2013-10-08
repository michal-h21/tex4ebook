-- Simple make system for tex4ht
--kpse.set_program_name("luatex")
module("make4ht",package.seeall)

Make = {}
--Make.params = {}
Make.build_seq = {}
Make.add = function(self,name,fn,par)
	local par = par or {}
	self.params = self.params or {}
	Make[name] = function(self,p,typ)
		local params = {}
		for k,v in pairs(self.params) do params[k] = v end
		for k,v in pairs(par) do params[k] = v; print("setting param "..k) end
		local typ = typ or "make"
		local p = p or {}
		local fn = fn
		for k,v in pairs(p) do
			params[k]=v
		end
		-- print( fn % params)
		local command = {
			name=name,
			type=typ,
			command = fn,
			params = params
		}
		table.insert(self.build_seq,command)
	end
end

Make.length = function(self)
	return #self.build_seq
end
Make.run = function(self) 
	local return_codes = {}
	for _,v in ipairs(self.build_seq) do
		--print("sekvence: "..v.name)
	  local params = self.params or {}
		for p,n in pairs(v.params) do params[p] = n end
		--for c,_ in pairs(params) do print("build param: "..c) end
		local command = v.command % params
		print("Make4ht: " .. command)
		local status = os.execute(command)
		table.insert(return_codes,{name=v.name,status=status})
	end
  return return_codes
end

--[[Make:add("hello", "hello ${world}", {world = "world"})
Make:add("ajaj", "ajaj")
Make:hello()
Make:hello{world="světe"}
Make:hello()
Make:run()
--]]
