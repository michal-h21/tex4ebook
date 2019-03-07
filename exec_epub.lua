module("exec_epub",package.seeall)
local lfs = require("lfs")
local os = require("os")
local io = require("io")
--local ebookutils = require("ebookutils")
local ebookutils = require "mkutils"
-- font loading doesn't work, font database format changes  often
-- and it is different between TL and Miktex
-- local load_font = require("list-fonts")
local outputdir_name="OEBPS"
local metadir_name = "META-INF"
local mimetype_name="mimetype"
outputdir=""
outputfile=""
outputfilename=""
-- the directory where the epub file should be moved to
destdir=""
basedir = ""
tidy = false
local include_fonts = false
local metadir=""

-- from https://stackoverflow.com/a/43407750/2467963
local function deletedir(dir)
  local attr = lfs.attributes(dir)
  if attr then
    for file in lfs.dir(dir) do
        local file_path = dir..'/'..file
        if file ~= "." and file ~= ".." then
            if lfs.attributes(file_path, 'mode') == 'file' then
                os.remove(file_path)
                print('remove file',file_path)
            elseif lfs.attributes(file_path, 'mode') == 'directory' then
                print('dir', file_path)
                deletedir(file_path)
            end
        end
    end
    lfs.rmdir(dir)
  end
  print('remove dir',dir)
end

function prepare(params)
	local randname=tostring(math.random(12000))
	-- if not ebookutils.file_exists("tex4ht.env") then
	--  local env_file = kpse.find_file("epub2.env")
	--print("Local env file: "..env_file)
	--  ebookutils.copy(env_file,"tex4ht.env")
	-- end
	local makedir= function(path)
		local current = lfs.currentdir()
		local dir = ebookutils.prepare_path(path .. "/")
		if type(dir) == "table" then
			local parts,msg =  ebookutils.find_directories(dir)
			if parts then 
			 ebookutils.mkdirectories(parts)
		  end
		end
		lfs.chdir(current)
	end
	basedir = params.input.."-".. params.format
	outputdir= basedir.."/"..outputdir_name --"outdir-"..randname --os.tmpdir()
  deletedir(basedir)
	makedir(outputdir)
	-- lfs.mkdir(outputdir)
	--ebookutils.mkdirectories(ebookutils.prepare_path(outputdir.."/"))
	metadir = basedir .."/" .. metadir_name --"metadir-"..randname
	makedir(metadir)
  if params.outdir ~= "" then
    destdir = params.outdir .. "/"
    makedir(destdir)
  end
	--local dd = ebookutils.prepare_path(metadir.."/")
	--for _,d in pairs(dd) do print("metadir path: "..d) end
	-- lfs.mkdir(metadir)
	--local status, msg = ebookutils.mkdirectories(ebookutils.prepare_path(metadir.."/"))
	--if not status then print("make mmetadir error:" ..msg) end
	mimetype= basedir .. "/" ..mimetype_name --os.tmpname()
	print(outputdir)
	print(mimetype)
	tidy = params.tidy
	include_fonts = params.include_fonts
	params["t4ht_par"] = params["t4ht_par"] -- + "-d"..string.format(params["t4ht_dir_format"],outputdir)
  params.tex4ht_sty_par = params.tex4ht_sty_par .. ",uni-html4"
	return(params)
end

function run(out,params)
	--local currentdir=
	outputfilename=out
	outputfile = outputfilename..".epub"
	print("Output file: "..outputfile)
	--lfs.chdir(metadir)
	local m= io.open(metadir.."/container.xml","w")
	m:write([[
<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
<rootfiles>
<rootfile full-path="OEBPS/content.opf"
media-type="application/oebps-package+xml"/>
</rootfiles>
</container>
	]])
	m:close()
	--lfs.chdir("..")
	m=io.open(mimetype,"w")
	m:write("application/epub+zip")
	m:close()
	local htlatex_run = "${htlatex} ${input} \"${config}${tex4ht_sty_par}\" \"${tex4ht_par}\" \"${t4ht_par}\" \"${latex_par}\"" % params
	print("Make4ht run")
	print("-------------------")
	params.config_file.Make.params = params
  local mode = params.mode
	if params.config_file.Make:length() < 1 then
    if mode == "draft" then
      params.config_file.Make:htlatex()
    else
      params.config_file.Make:htlatex()
      params.config_file.Make:htlatex()
      params.config_file.Make:htlatex() 
    end
	end
	if #params.config_file.Make.image_patterns > 0 then
		params["t4ht_par"] = params["t4ht_par"] .." -p"
	end
	params.config_file.Make:tex4ht()
	params.config_file.Make:t4ht()
	params.config_file.Make:run()
	print("-------------------")
	--[[for k,v in pairs(params.config_file.Make) do
		print(k.. " : "..type(v))
	end--]]
  --print(os.execute(htlatex_run))
end

local mimetypes = {
	css = "text/css",
	png = "image/png", 
	jpg = "image/jpeg",
	gif = "image/gif",
	svg = "image/svg+xml",
	html= "application/xhtml+xml",
	xhtml= "application/xhtml+xml",
	ncx = "application/x-dtbncx+xml",
	otf = "application/opentype",
	ttf = "application/truetype",
	woff = "application/font-woff",
  js = "text/javascript",
  mp3 = "audio/mpeg",
  smil = "application/smil+xml"
}

function remove_empty_guide(content)
  return content:gsub("<guide>%s*</guide>","")
end

function make_opf()
	-- Join files content.opf and content-part2.opf
	-- make item record for every converted image
	local lg_item = function(item)
		-- Find mimetype and make item tag for each converted file in the lg file
		local fname,ext = item:match("([%a%d%_%-]*)%p([%a%d]*)$")
		local mimetype = mimetypes[ext] or ""
		if mimetype == "" then print("Mimetype for "..ext.." is not registered"); return nil end
		local dir_part = item:split("/")
		table.remove(dir_part,#dir_part)
		local id=table.concat(dir_part,"-")..fname.."_"..ext
    -- remove invalid characters from id start
    id = id:gsub("^[%.%-]*","")
		return "<item id='"..id .. "' href='"..item.."' media-type='"..mimetype.."' />",id
	end
	local find_all_files= function(s,r)
		local r = r or "([%a%d%_%-]*)%.([x]?html)"
		local files = {}
		for i, ext in s:gmatch(r) do
			--local i, ext = s:match(r)-- do
			ext = ext or "true"
			files[i] = ext 
		end 
		return files
	end
	local tidyconf = nil
	if tidy then 
		tidyconf = kpse.find_file("tidyconf.conf")
	end
	--local opf_first_part = outputdir .. "/content.opf" 
	local opf_first_part =   "content.opf" 
	local opf_second_part =  "content-part2.opf"
	--local opf_second_part = outputdir .. "/content-part2.opf"
	if 
		ebookutils.file_exists(opf_first_part) and ebookutils.file_exists(opf_second_part) 
		then
			local h_first  = io.open(opf_first_part,"r")
			local h_second = io.open(opf_second_part,"r")
			local opf_complete = {}
			table.insert(opf_complete,h_first:read("*all"))
			local used_html = find_all_files(opf_complete[1])
			-- local lg_file = ebookutils.parse_lg(outputfilename..".lg")
      -- The lg_file has been already loaded by make4ht, it doesn't make sense to load it again
      -- Furthermore, it is now possible to add new files from Lua build files
      local lg_file = Make.lgfile  or ebookutils.parse_lg(outputfilename..".lg")
			local used_files = {}
      for _,filename in ipairs(lg_file["files"]) do
        -- we need to test the filenames in order to prevent duplicates
        -- filenames are tested without paths, so there may be issues if 
        -- the same filename is used in different directories. Is that a problem?
        used_files[filename] = true
      end
			local outside_spine = {}
			local all_used_files = find_all_files(opf_complete[1],"([%a%d%-%_]+%.[%a%d]+)")
			local used_paths = {}
      local used_ids   = {}
			for _,k in ipairs(lg_file["files"]) do
				local ext = k:match("%.([%a%d]*)$")
				local parts = k:split "/"
				local fn = parts[#parts]
				local allow_in_spine =  {html="",xhtml = "", xml = ""}
				table.remove(parts,#parts)
				--table.insert(parts,1,"OEBPS")
				table.insert(parts,1,outputdir)
				-- print("SSSSS "..fn.." ext .." .. ext)
				--if string.find("jpg gif png", ext) and not all_used_files[k] then
				local item,id = lg_item(k) 
				if item then
         local path = table.concat(parts)
					if not used_paths[path] then
						ebookutils.mkdirectories(parts)
						used_paths[path]=true
					end
					if allow_in_spine[ext] and tidy then 
						if tidyconf then
							print("Tidy: "..k)
							local run ="tidy -c  -w 200 -q -utf8 -m -config " .. tidyconf .." " .. k
							os.execute(run) 
						else
							print "Tidy: Cannot load tidyconf.conf"
						end
					end
          if not used_ids[id] then    
            ebookutils.copy(k, outputdir .. "/"..k)
            if not all_used_files[fn] then
              table.insert(opf_complete,item)
              if allow_in_spine[ext] then 
                table.insert(outside_spine,id)
              end
            end
					end
          used_ids[id] = true
				end
			end
			for _,f in ipairs(lg_file["images"]) do
				local f = f.output
        local p, id = lg_item(f)
        -- process the images only if they weren't registered in lg_file["files"]
        -- they would be processed twice otherwise
        if not used_files[f] and not used_ids[id] then
          ebookutils.copy(f, outputdir .. "/"..f)
          table.insert(opf_complete,p)
        end
        used_ids[id] = true
			end
			local end_opf = h_second:read("*all")
			local spine_items = {}
			for _,i in ipairs(outside_spine) do
				table.insert(spine_items,
				'<itemref idref="${idref}" linear="no" />' % {idref=i})
			end
			table.insert(opf_complete,end_opf % {spine = table.concat(spine_items,"\n")})
			h_first:close()
			h_second:close()
			h_first = io.open(opf_first_part,"w")
      local opf_completed = table.concat(opf_complete,"\n")
      -- poor man's tidy: remove trailing whitespace befora xml tags
      opf_completed = opf_completed:gsub("[ ]*<","<")
      opf_completed = remove_empty_guide(opf_completed)
			h_first:write(opf_completed)
			h_first:close()
			os.remove(opf_second_part)
			--ebookutils.copy(outputfilename ..".css",outputdir.."/")
			ebookutils.copy(opf_first_part,outputdir.."/"..opf_first_part)
			--for c,v in pairs(lg_file["fonts"]) do
			--	print(c, table.concat(v,", "))
			--end
			--print(table.concat(opf_complete,"\n"))
		else
			print("Missing opf file")
		end
	end
  local function find_zip()
    if io.popen("zip -v","r"):close() then
      return "zip"
    elseif io.popen("miktex-zip -v","r"):close() then
      return "miktex-zip"
    end
    print "It appears you don't have zip command installed. I can't pack the ebook"
    return "zip"
  end

	function pack_container()
    local ncxfilename = outputdir .. "/" .. outputfilename .. ".ncx"
		if os.execute("tidy -v") > 0 then
			print("Warning:\n  tidy command seems missing, you should install it" ..
			" in order\n  to make valid epub file") 
      print("Using regexp based cleaning")
      local lines = {}
      for line in io.lines(ncxfilename) do
        local content = line:gsub("[ ]*<","<")
        if content:len() > 0 then
          table.insert(lines, content)
        end
      end
      table.insert(lines,"")
      local ncxfile = io.open(ncxfilename,"w")
      ncxfile:write(table.concat(lines,"\n"))
      ncxfile:close()
		else
		  print("Tidy ncx "..
		  os.execute("tidy -xml -i -q -utf8 -m " ..  ncxfilename))
			print("Tidy opf "..
			os.execute("tidy -xml -i -q -utf8 -m " .. 
			outputdir .. "/" .. "content.opf"))
		end
		print(mimetype)
    local zip = find_zip()
    -- we need to remove the epub file if it exists already, because it may contain files which aren't used anymore
    if ebookutils.file_exists(outputfile) then os.remove(outputfile) end
		print("Pack mimetype " .. os.execute("cd "..basedir.." && "..zip.." -q0X "..outputfile .." ".. mimetype_name))
		print("Pack metadir "   .. os.execute("cd "..basedir.." && "..zip.." -qXr9D " .. outputfile.." "..metadir_name))
		print("Pack outputdir " .. os.execute("cd "..basedir.." && "..zip.." -qXr9D " .. outputfile.." "..outputdir_name))
		print("Copy generated epub ")
		ebookutils.cp(basedir .."/"..outputfile, destdir .. outputfile)
end


	function writeContainer()
		make_opf()
		pack_container()
	end
	local function deldir(path)
		for entry in lfs.dir(path) do
			if entry~="." and entry~=".." then  
				os.remove(path.."/"..entry)
			end
		end
		os.remove(path)
		--]]
	end

	function clean()
		--deldir(outputdir)
		--deldir(metadir)
		--os.remove(mimetype)
end
