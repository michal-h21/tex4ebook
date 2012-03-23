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
local metadir=""
local mimetype=""

function prepare(params)
  local randname=tostring(math.random(12000))
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

function run(outputfilename,params)
  --local currentdir=
  outputfile = outputfilename..".epub"
  print("Output file: "..outputfile)
  lfs.chdir(metadir)
  local m= io.open("container.xml","w")
  m:write([[
<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
   <rootfiles>
      <rootfile full-path="content.opf"
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

function writeContainer()
  print(os.execute("zip -q0X "..outputfile .." mimetype"))
  print(os.execute("zip -qXr9D " .. outputfile.." "..metadir))
  print(os.execute("zip -qXr9D " .. outputfile.." "..outputdir))
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
