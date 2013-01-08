kpse.set_program_name("luatex")
require("lapp")
require("ebookutils")

-- Setting
local latex_cmd="htlatex"
local copy_cmd="copy"
local move_cmd="move"
local env_param="%%" 
local htlatex_call=""
-- These correspond to htlatex parameters
local tex4ht_sty_par=""
local tex4ht_par=""
local t4ht_par=""
local latex_par=""
local output_formats={epub=true,mobi=true}
local executor=nil
local arg_message = [[
tex4ebook - ebook generation support for LaTeX
Usage:
tex4ebook [switches] inputfile 
  -c,--config (default xhtml) Custom config file
  -f,--format (default epub) Output format
  -l,--lua  Runs htlualatex instead of htlatex
  -s,--shell_escape  Enable shell escape in htlatex run
  -r,--resolution (default 167)
  -u,--utf8 
]]
local args=lapp(arg_message)

if args[1] == nil then
  print(arg_message) 
  return
else
  input_file=args[1]
end

if args.lua then
  print("Mame lua")
  latex_cmd="htlualatex"
end

if args.utf8 then
  tex4ht_sty_par=tex4ht_sty_par .. ", charset=utf-8"
  tex4ht_par=tex4ht_par .. " -cunihtf -utf8"
end

if args.shell_escape then 
  latex_par = latex_par .. " -shell-escape"
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


-- Env file copying 

if not ebookutils.file_exists("tex4ht.env") then
   local env_file = kpse.find_file("epub2.env")
   ebookutils.copy(env_file,"tex4ht.env",function(s) return s % {move = move_cmd,copy = copy_cmd} end)
end

--print ("nazdar ${world}" % {world="svete"})
--print(args.config)

tex4ht_sty_par = tex4ht_sty_par..","+args.format
tex4ht_sty_par = tex4ht_sty_par +args[2]
tex4ht_par = tex4ht_par +args[3]
t4ht_par = t4ht_par + args[4]
latex_par = latex_par + args[5]
local params = {
  htlatex=latex_cmd
  ,input=input_file 
  ,latex_par=latex_par
  ,config=args.config
  ,tex4ht_sty_par=tex4ht_sty_par
  ,tex4ht_par=tex4ht_par
  ,t4ht_par=t4ht_par
  ,t4ht_dir_format=t4ht_dir_format
}  

if output_formats[args.format] then
  executor=require("exec_"..args.format)
  params=executor.prepare(params)
else
  print("Unknown output format: "..args.format)
  return
end

print("${htlatex} ${input} \"${config}${tex4ht_sty_par}\" \"${tex4ht_par}\" \"${t4ht_par}\" \"\${latex_par}\"" % params)
executor.run(ebookutils.remove_extension(input_file),params)
executor.writeContainer()
executor.clean()
--print(args[1])
