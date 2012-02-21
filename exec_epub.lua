module("exec_epub",package.seeall)
require("lfs")
require("os")
require("io")
require("ebookutils")
local outputdir_name="OEBPS"
local metadir_name = "META-INF"
local mimetype_name="mimetype"
local outputdir=""
local metadir=""
local mimetype=""

function prepare(params)
  outputdir=os.tmpdir()
  metadir = os.tmpdir()
  mimetype= "mimetype.tmp"--os.tmpname()
  print(outputdir)
  print(mimetype)
  params["t4ht_par"] = params["t4ht_par"] + "-d"..outputdir
  return(params)
end

function run(outputfile)
  --local currentdir=
  outputfile = outputfile..".epub"
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
  lfs.chdir("..")
  m=io.open(mimetype,"w")
  m:write("application/epub+zip")
  m:close()
end

function writeContainer(path)

end
local function deldir(path)
  lfs.chdir(path)
  for entry in lfs.dir(path) do
    print("Remove file: "..entry)
    if entry~="." and entry~=".." then 
      os.remove(path.."/"..entry)
      print("Remove file: "..entry)
    end
  end
  lfs.rmdir(path)
end

function clean()
  deldir(outputdir)
  deldir(metadir)
  os.remove(mimetype)
end