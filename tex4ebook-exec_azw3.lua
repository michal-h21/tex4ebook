module(...,package.seeall)
local eb = require("tex4ebook-exec_epub")
local mobi = require("tex4ebook-exec_mobi")
local ebookutils = require("mkutils")
local log = logging.new "exec_azw"

function prepare(params)
	return eb.prepare(params)
end

function run(out,params)
	return eb.run(out, params)
end

function writeContainer()
	local ret =  eb.writeContainer()
  -- convert the epub file to azw
  local epubpath = eb.basedir .. "/" .. eb.outputfile

  -- find the azw filename 
  local azwfile = eb.outputfile:gsub("epub$", "azw3")
  local azwdist = eb.destdir ..  azwfile
  -- local command = "kindlegen " .. epubpath .. " -o " .. azwfile
	-- log:info("Pack azw ".. command)
  -- local status, output = ebookutils.execute(command)
  local status = mobi.kindlegen(epubpath, azwfile)
  if status then
    -- copy the azw file to the destination directory
    -- the destination directory will be created by the epub writer, so it is possible to use
    -- the cp function which doesn't try to create directory
    if azwfile ~= azwdist then
      ebookutils.cp(azwfile, azwdist)
    end
  end

	return ret
end

function clean()
	return eb.clean()
end
