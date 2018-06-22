module(...,package.seeall)
local eb = require("exec_epub")
local ebookutils = require("mkutils")

function prepare(params)
	return eb.prepare(params)
end

function run(out,params)
	return eb.run(out, params)
end

function writeContainer()
	local ret =  eb.writeContainer()
  -- convert the epub file to mobi
  local epubpath = eb.basedir .. "/" .. eb.outputfile
	print("Pack mobi "..os.execute("kindlegen " .. epubpath))
  -- find the mobi filename 
  local mobifile = epubpath:gsub("epub$", "mobi")
  local mobidist = eb.destdir ..  eb.outputfile:gsub("epub$", "mobi")
  -- copy the mobi file to the destination directory
  -- the destination directory will be created by the epub writer, so it is possible to use
  -- the cp function which doesn't try to create directory
  ebookutils.cp(mobifile, mobidist)

	return ret
end

function clean()
	return eb.clean()
end
