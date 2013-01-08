module("exec_epub",package.seeall)
require("lfs")
require("os")
require("io")
require("ebookutils")
local outputdir_name="OEBPS"
local metadir_name = "META-INF"
local mimetype_name="mimetype"
local outputdir=""
local outputfile=""
local outputfilename=""
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
  params["t4ht_par"] = params["t4ht_par"] + "-d"..string.format(params["t4ht_dir_format"],outputdir)
  return(params)
end

function run(out,params)
  --local currentdir=
  outputfilename=out
  outputfile = outputfilename..".epub"
  print("Output file: "..outputfile)
  lfs.chdir(metadir)
  local m= io.open("container.xml","w")
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
  lfs.chdir("..")
  m=io.open(mimetype,"w")
  m:write("application/epub+zip")
  m:close()
  local htlatex_run = "${htlatex} ${input} \"${config}${tex4ht_sty_par}\" \"${tex4ht_par}\" \"${t4ht_par}\" \"\${latex_par}\"" % params
  print(os.execute(htlatex_run))
end

local mimetypes = {
  png = "image/png", 
  jpg = "image/jpeg",
  gif = "image/gif",
  svg = "image/svg+xml",
  html= "application/xhtml+xml"
}

local function make_opf()
  -- Join files content.opf and content-part2.opf
  -- make item record for every converted image
  local lg_item = function(item)
  -- Find mimetype and make item tag for each converted file in the lg file
    local fname,ext = item:match("([%a%d%_%-]*)%p([%a%d]*)")
    local mimetype = mimetypes[ext] or ""
    if mimetype == "" then print("Mimetype for "..ext.."is not registered") end
    return ("<item id='"..fname.."_"..ext.."' href='"..item.."' media-type='"..mimetype.."' />")
  end
  local find_all_html = function(s)
    local files = {}
    for i in s:gmatch("([%a%d%-%-]*)%.html") do
      files[i] =  true
    end
    return files
  end
  local opf_first_part = outputdir .. "/content.opf" 
  local opf_second_part = outputdir .. "/content-part2.opf"
  if 
    ebookutils.file_exists(opf_first_part) and ebookutils.file_exists(opf_second_part) 
  then
    local h_first  = io.open(opf_first_part,"r")
    local h_second = io.open(opf_second_part,"r")
    local opf_complete = {}
    table.insert(opf_complete,h_first:read("*all"))
    local used_html = find_all_html(opf_complete[1])
    local used_files = {}
    for f in lfs.dir("./OEBPS") do
       table.insert(used_files,f)
       --used_files[f] = true
    end
    local all_html = find_all_html(table.concat(used_files,"\n"))
    for i,_ in pairs(all_html) do
      if used_html[i] ~= true then
        table.insert(opf_complete,lg_item(i..".html"))
      end
    end
    for _,f in ipairs(ebookutils.parse_lg(outputfilename..".lg")) do
      table.insert(opf_complete,lg_item(f))
    end
    table.insert(opf_complete,h_second:read("*all"))
    h_first:close()
    h_second:close()
    h_first = io.open(opf_first_part,"w")
    h_first:write(table.concat(opf_complete,"\n"))
    h_first:close()
    os.remove(opf_second_part)
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
