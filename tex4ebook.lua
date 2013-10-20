kpse.set_program_name("luatex")
require("lapp")
-- require("ebookutils")
local ebookutils = require "mkutils"

-- Setting
local latex_cmd="latex"
local copy_cmd="copy"
local move_cmd="move"
local env_param="%%" 
local htlatex_call=""
-- These correspond to htlatex parameters
local tex4ht_sty_par=""
local tex4ht_par=""
local t4ht_par=""
local latex_par=""
local output_formats={epub=true,mobi=true,epub3=true}
local executor=nil
local tidy = false
local include_fonts = false
local arg_message = [[
tex4ebook - ebook generation support for LaTeX
Usage:
tex4ebook [switches] inputfile 
-c,--config (default xhtml) Custom config file
-f,--format (default epub) Output format. Supported values: epub, epub3, mobi
-i,--include-fonts  Include fonts in ebook 
-l,--lua  Runs htlualatex instead of htlatex
-m,--mathml Mathml support
-r,--resolution (default 167)
-s,--shell-escape  Enable shell escape in htlatex run
-t,--tidy Run html tidy on html output. May result in wrong spacing!
]]

-- This option is no longer available, all files must be unicode
-- -u,--utf8 
local args=lapp(arg_message)

if args[1] == nil then
  print(arg_message) 
  return
else
  input_file=args[1]
end

if args.lua then
  print("Mame lua")
  latex_cmd="dvilualatex"
end

--if args.utf8 then
tex4ht_sty_par=tex4ht_sty_par .. ", charset=utf-8"
tex4ht_par=tex4ht_par .. " -cunihtf -utf8"
--end

if args["shell-escape"] then 
  latex_par = latex_par .. " -shell-escape"
end

if args["include-fonts"] then 
  include_fonts = true
end

local mathml = ","
if args["mathml"] then
  -- mathml = ",mathml,"
  tex4ht_sty_par = tex4ht_sty_par .. ",mathml"
end

if os.type=="unix" then
  env_param="$"
  copy_cmd="cp"
  move_cmd="mv"
  t4ht_dir_format="%s/"
else 
  env_param="%%"
  copy_cmd="copy"
  move_cmd="move"
  t4ht_dir_format="%s"
end

if args.tidy then 
  tidy = true
else
  tidy = false
end
-- Env file copying 

--[[if not ebookutils.file_exists("tex4ht.env") then
local env_file = kpse.find_file("epub2.env")
ebookutils.copy_filter(env_file,"tex4ht.env",function(s) return s % {
move = move_cmd,
copy = copy_cmd,
resolution = args.resolution
} end)
end--]]

--print ("nazdar ${world}" % {world="svete"})
--print(args.config)

local input = ebookutils.remove_extension(input_file)
local config=ebookutils.remove_extension(args.config)
local tex4ht_sty_par = config ..tex4ht_sty_par..","+args.format
--local sty_args =  args[2] and ", " .. args[2]  or ""
local sty_args = ""
if args[2] then 
  sty_args = "," .. args[2]
end
local tex4ht_sty_par = tex4ht_sty_par + sty_args --args[2]
local tex4ht_par = tex4ht_par +args[3]
local t4ht_par = t4ht_par + args[4]
local latex_par = latex_par + args[5]
local params = {
  htlatex=latex_cmd
  ,input=input 
  ,format=args.format
  ,latex_par=latex_par
  ,tex4ht_sty_par=tex4ht_sty_par
  ,tex4ht_par=tex4ht_par
  ,t4ht_par=t4ht_par
  ,t4ht_dir_format=t4ht_dir_format
  ,tidy = tidy
  ,include_fonts = include_fonts
  ,resolution=args.resolution
  ,mathml=mathml
  ,packages="\\RequirePackage{tex4ebook}"
}  

if output_formats[args.format] then
  executor=require("exec_"..args.format)
  params=executor.prepare(params)
else
  print("Unknown output format: "..args.format)
  return
end

local config_file = ebookutils.load_config(nil, input.. ".mk4")

params["config_file"] = config_file
--config_file.Make:run()
print("${htlatex} ${input} \"${config}${tex4ht_sty_par}\" \"${tex4ht_par}\" \"${t4ht_par}\" \"${latex_par}\"" % params)
executor.run(input,params)
executor.writeContainer()
executor.clean()
--print(args[1])
