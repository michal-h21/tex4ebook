module(...,package.seeall)
local eb = require("exec_epub")
local dom = require("luaxml-domobject")

local ext = "xhtml"
local outputdir = nil
local input     = nil
function prepare(params)
	local basedir = params.input.."-".. params.format
  local outputdir_name="OEBPS"
	outputdir= basedir.."/"..outputdir_name
  input = params.input 
  params.ext = ext
  params.tex4ht_sty_par = params.tex4ht_sty_par .. ",html5"
  params.packages = params.packages .. string.format("\\Configure{ext}{%s}",ext)
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

local function add_media_overlays(content)
  local opfdom = dom.parse(content)
  local items = opfdom:query_selector("manifest item")
  local ref = {}
  local times = {}
  local package = opfdom:query_selector("metadata")[1]
  -- we must read all smil files and find references to html files
  -- it is necessary to add media-overlay attribute to the referenced items
  for _, item in ipairs(items) do
    local href = item:get_attribute("href")
    ref[href] = item
    -- we must read audio length from the smil file and add it as a <meta> property
    if href:match("smil$") then
      local f = io.open(outputdir .. "/" .. href, "r")
      local smil = f:read("*all")
      f:close()
      local smildom = dom.parse(smil)
      local audios = smildom:query_selector("audio")
      local last = audios[#audios]
      -- add audio duration to the metadata section
      if last then
        local duration = last:get_attribute("clipend")
        if duration then
          -- todo: calculate total audio length
          table.insert(times, duration)
          local audio_id = item:get_attribute("id")
          local meta = package:create_element("meta",{property="media:duration", refines="#"..audio_id})
          local dur_el = meta:create_text_node(duration)
          meta:add_child_node(dur_el)
          package:add_child_node(meta)
        end
      end

      -- add the media-overlay attribute
      local textref = smil:match('epub:textref="(.-)"')
      local id = item:get_attribute("id")
      local referenced = ref[textref]
      if referenced then
        referenced:set_attribute("media-overlay", id)
      end
    end
  end
  local serialized = opfdom:serialize()
  return serialized
end


local function cleanOPF()
  -- in epub3, there must be table of contents
	-- if there is no toc in the document, we must add generic one
	local opf =  "content.opf"
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
    local inputfile = input .. "." .. ext
    print("Main file name", inputfile)
		-- write toc file
    local toc_name = "generic_toc" .."."..ext
		local f = io.open(outputdir .. "/" .. toc_name, "w")
		f:write(makeTOC(inputfile))
		f:close()
		-- add toc file to the conten.opf
		content = content:gsub("<manifest>","<manifest>\n<item id='htmltoc'" ..
		  " properties=\"nav\" media-type=\"application/xhtml+xml\" href=\""..
			toc_name .."\" />\n")
    content = content:gsub("<spine([^>]*)>", "<spine%1>\n<itemref idref=\"htmltoc\" linear=\"no\"/>\n")
    -- remove empty guide element
  end
  content = content:gsub("<guide>%s*</guide>","")
  content = add_media_overlays(content)
  f = io.open(outputdir .. "/" ..opf,"w")
  f:write(content)
  f:close()
  --makeTOC(inputfile)
end



function writeContainer()			
	--local ret =  eb.writeContainer()
	eb.make_opf()
	cleanOPF()
	local ret = eb.pack_container()
	return ret
end

function clean()
	return eb.clean()
end
