
--- @module luarocks.which_cmd
-- Driver for the `luarocks which` command.
local which_cmd = {}

local loader = require("luarocks.loader")
local cfg = require("luarocks.core.cfg")
local util = require("luarocks.util")
local fs = require("luarocks.fs")

which_cmd.help_summary = "Tell which file corresponds to a given module name."
which_cmd.help_arguments = "<modname>"
which_cmd.help = [[
Given a module name like "foo.bar", output which file would be loaded to resolve
that module by luarocks.loader, like "/usr/local/lua/]]..cfg.lua_version..[[/foo/bar.lua".
]]

--- Driver function for "lua" command.
-- @return boolean This function terminates the interpreter.
function which_cmd.command(_, modname)
   if modname == nil then
      return nil, "Missing module name. " .. util.see_help("which")
   end
   local pathname, rock_name, rock_version = loader.which(modname)

   if pathname then
      util.printout(pathname)
      util.printout("(provided by " .. tostring(rock_name) .. " " .. tostring(rock_version) .. ")")
      return true
   end

   local modpath = modname:gsub("%.", "/")
   for _, v in ipairs({"path", "cpath"}) do
      for p in package[v]:gmatch("([^;]+)") do
         local pathname = p:gsub("%?", modpath)
         if fs.exists(pathname) then
            util.printout(pathname)
            util.printout("(found directly via package." .. v .. " -- not installed as a rock?)")
            return true
         end
      end
   end

   return nil, "Module '" .. modname .. "' not found."
end

return which_cmd

