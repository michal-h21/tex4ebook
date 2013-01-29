module(...,package.seeall)
local eb = require("exec_epub")

function prepare(params)
	return eb.prepare(params)
end

function run(out,params)
	return eb.run(out, params)
end

function writeContainer()
	local ret =  eb.writeContainer()
	return ret
end

function clean()
	return eb.clean()
end
