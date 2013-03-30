module("exec_epub",package.seeall)
local lfs = require("lfs")
local os = require("os")
local io = require("io")
local ebookutils = require("ebookutils")
local outputdir_name="OEBPS"
local metadir_name = "META-INF"
local mimetype_name="mimetype"
outputdir=""
outputfile=""
outputfilename=""
local metadir=""


function prepare(params)
	local randname=tostring(math.random(12000))
	-- if not ebookutils.file_exists("tex4ht.env") then
	--  local env_file = kpse.find_file("epub2.env")
	--print("Local env file: "..env_file)
	--  ebookutils.copy(env_file,"tex4ht.env")
	-- end
	outputdir= outputdir_name --"outdir-"..randname --os.tmpdir()
	lfs.mkdir(outputdir)
	metadir = metadir_name --"metadir-"..randname
	lfs.mkdir(metadir)
	mimetype= mimetype_name --os.tmpname()
	print(outputdir)
	print(mimetype)
	params["t4ht_par"] = params["t4ht_par"] -- + "-d"..string.format(params["t4ht_dir_format"],outputdir)
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
	local htlatex_run = "${htlatex} ${input} \"${config}${tex4ht_sty_par}\" \"${tex4ht_par}\" \"${t4ht_par}\" \"\${latex_par}\"" % params
	print("Make4ht run")
	print("-------------------")
	params.config_file.Make.params = params
	if params.config_file.Make:length() < 1 then
		params.config_file.Make:htlatex()
		params.config_file.Make:htlatex()
		params.config_file.Make:htlatex()
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
	ncx = "application/x-dtbncx+xml"
}

local function make_opf()
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
			local lg_file = ebookutils.parse_lg(outputfilename..".lg")
			local used_files = lg_file["files"]
			--[[for f in lfs.dir("./OEBPS") do
			--table.insert(used_files,f)
			--used_files[f] = true
			end--]]
			local all_html = find_all_files(table.concat(used_files,"\n"))
			local outside_spine = {}
			-- This was duplicated code
			--[[for i, ext in pairs(all_html) do
				if not used_html[i] then
					print("Prvni insert: ".. i .."."..ext)
					local item, id = lg_item(i.."."..ext) 
					table.insert(opf_complete,item)
					table.insert(outside_spine,id)
				end
			end--]]
			local all_used_files = find_all_files(opf_complete[1],"([%a%d%-%_]+%.[%a%d]+)")
			local used_paths = {}
			for _,k in ipairs(lg_file["files"]) do
				local ext = k:match("%.([%a%d]*)$")
				local parts = k:split "/"
				local fn = parts[#parts]
				table.remove(parts,#parts)
				table.insert(parts,1,"OEBPS")
				--print("SSSSS "..fn.." ext .." .. ext)
				--if string.find("jpg gif png", ext) and not all_used_files[k] then
				local item,id = lg_item(k) 
				if item then
					local path = table.concat(parts)
					if not used_paths[path] then
						ebookutils.mkdirectories(parts)
						used_paths[path]=true
					end
					ebookutils.copy(k, outputdir .. "/"..k)
					if not all_used_files[fn] then
						table.insert(opf_complete,item)
						table.insert(outside_spine,id)
					end
				end
			end
			for _,f in ipairs(lg_file["images"]) do
				local p = lg_item(f)
				ebookutils.copy(f, outputdir .. "/"..f)
				table.insert(opf_complete,p)
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
			h_first:write(table.concat(opf_complete,"\n"))
			h_first:close()
			os.remove(opf_second_part)
			--ebookutils.copy(outputfilename ..".css",outputdir.."/")
			ebookutils.copy(opf_first_part,outputdir.."/"..opf_first_part)
			--print(table.concat(opf_complete,"\n"))
		else
			print("Missing opf file")
		end
	end
	function writeContainer()
		make_opf()
		print("Tidy ncx "..
		os.execute("tidy -xml -i -q -m " .. 
		outputdir .. "/" .. outputfilename .. ".ncx"))
		print("Tidy opf "..
		os.execute("tidy -xml -i -q -m " .. 
		outputdir .. "/" .. "content.opf"))
		print("Pack mimetype " .. os.execute("zip -q0X "..outputfile .." mimetype"))
		print("Pack metadir "   .. os.execute("zip -qXr9D " .. outputfile.." "..metadir))
		print("Pack outputdir " .. os.execute("zip -qXr9D " .. outputfile.." "..outputdir))
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
		os.remove(mimetype)
	end
