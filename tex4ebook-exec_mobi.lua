module(...,package.seeall)
local eb = require("tex4ebook-exec_epub")
local ebookutils = require("mkutils")
local log = logging.new "exec_mobi"

function prepare(params)
	return eb.prepare(params)
end

function run(out,params)
	return eb.run(out, params)
end

function kindlegen(source, outputfile)
  -- try to run kindlegen first
  local command = "kindlegen " .. source .. " -o " .. outputfile
  local status, output = ebookutils.execute(command)
  log:debug("running kindlegen: " .. command, status)
  -- if we cannot find kindlegen, try ebook-convert
  if not output:match("Amazon") then
    log:debug("kindlegen failed, trying epub-convert")
    local ebookcmd = "ebook-convert " .. source .. " " .. outputfile
    status, output = ebookutils.execute(ebookcmd)
    if status > 0 then 
      log:error("Conversion to the output format failed")
      log:error("Do you have either kindlegen or ebook-convert installed?")
      return false
    end
  end
  return true
end

function writeContainer()
	local ret =  eb.writeContainer()
  -- convert the epub file to mobi
  local epubpath = eb.basedir .. "/" .. eb.outputfile
  -- find the mobi filename 
  local mobifile = eb.outputfile:gsub("epub$", "mobi")
  local mobidist = eb.destdir ..  eb.outputfile:gsub("epub$", "mobi")
  log:info("Convert Epub to mobi")
  local status = kindlegen(epubpath, mobifile)
  if status then
    -- copy the mobi file to the destination directory
    -- the destination directory will be created by the epub writer, so it is possible to use
    -- the cp function which doesn't try to create directory
    if mobifile ~= mobidist then
      ebookutils.cp(mobifile, mobidist)
    end
  end
	return ret
end

function clean()
	return eb.clean()
end

