module(...,package.seeall)
local eb = require("exec_epub")

local outputdir = nil
local input     = nil
function prepare(params)
	local basedir = params.input.."-".. params.format
  local outputdir_name="OEBPS"
	outputdir= basedir.."/"..outputdir_name
  input = params.input 
	return eb.prepare(params)
end

function run(out,params)
	return eb.run(out, params)
end


local function makeTOC(document)
  local template = [[
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" 
 xmlns:epub="http://www.idpf.org/2007/ops"
>
<head><title>TOC</title></head>
<body>
<nav id="pub-toc" epub:type="toc">
 <h1>Table of contents</h1>
 <ol class="toc" hidden="hidden">
  <li>
   <a href="${document}">Document</a>
  </li>
 </ol>
</nav>
</body>
</html>
]] % {document=document}
  return template
end

local function findTOC()
  -- in epub3, there must be table of contents
	-- if there is no toc in the document, we must add generic one
  local inputfile = input .. ".html"
	local opf =  "content.opf"
	local toc_name = "generic_toc.html"
	local f = io.open(opf,"r")
	if not f then 
    print("Cannot open "..opf .. " for toc searching")
		return nil
  end
  local content = f:read("*all")
	f:close()
	if content:find "properties[%s]*=[%s]*\"[^\"]*nav" then
    print "TOC nav found"
  else
    print "no TOC, using generic one"
		-- write toc file
		local f = io.open(outputdir .. "/" .. toc_name, "w")
		f:write(makeTOC(inputfile))
		f:close()
		-- add toc file to the conten.opf
		content = content:gsub("<manifest>","<manifest>\n<item id='htmltoc'" ..
		  " properties=\"nav\" media-type=\"application/xhtml+xml\" href=\""..
			toc_name .."\" />\n")
    content = content:gsub("<spine([^>]*)>", "<spine%1>\n<itemref idref=\"htmltoc\" linear=\"no\"/>\n")
		f = io.open(outputdir .. "/" ..opf,"w")
		f:write(content)
		f:close()
  end
  --makeTOC(inputfile)
end



function writeContainer()			
	--local ret =  eb.writeContainer()
	eb.make_opf()
	findTOC()
	local ret = eb.pack_container()
	return ret
end

function clean()
	return eb.clean()
end
