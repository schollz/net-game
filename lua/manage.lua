
local util = require 'lua/util'
local logger = require 'lua/logger'
local gensema = require 'lua/gensema'
local filenamer = require 'lua/filenamer'
local query = require 'lua/query'
local pquery = require 'lua/pquery'
local task = require 'lua/task'

local dispatch = {
   quit = function (_)
      filenamer.cleanup()
      os.exit(0)
   end,
   ter = function (_)
      checkin()
   end,
   need = function (x)
      y = tokenize(x)
      request(y[1], y[2])
   end,
   goget = function (x)
      wname, expr = string.match(x, "(%S+)%s+(.+)")
      request_custom({expr}, wname)
   end
}

local ext_dispatch = {
   goget = function (x)
      wname = table.remove(x, 1)
      request_custom(x, wname)
   end
}

local req_objs = {
   actors    = function () return pquery.PQuery.new():people(3):celebs(3) end,
   map       = function () return pquery.PQuery.new():places(3) end,
   wildlife  = function () return pquery.PQuery.new():animals(2) end,
   foliage   = function () return pquery.PQuery.new():foods(2) end,
   equipment = function () return pquery.PQuery.new():weapons(2) end
}

local allqueries = {}

local socket = require 'socket'
local conn = nil

function tokenize(data)
   local tokens = {}
   for elem in data:gmatch '%S+' do
      table.insert(tokens, elem)
   end
   return tokens
end

function name_and_args(data)
   name = data:match "%S+"
   args = data:match "%s.+" or ""
   args = string.sub(args, 2)
   return name, args
end

function dispatch_on(name, args)
   local func = dispatch[name]
   if type(func) == 'function' then
      func(args)
   else
      logger.echo(1, "Warning: Unknown message '" .. name .. "' received!\n")
   end
end

function dispatch_ext(args, conn)
   local count = tonumber(args)
   if count and count >= 1 then
      local header = assert( conn:receive("*line") ) -- TODO Handle timeout and other errors
      local func = ext_dispatch[header]
      if type(func) == 'function' then
         local arr = {}
         -- The header is included in the count, so skip line number one
         for i = 2, count do
            local line = assert( conn:receive("*line") )
            table.insert(arr, line) -- TODO Handle timeout and other errors
         end
         func(arr)
      else
         logger.echo(1, "Warning: Unknown extended message '" .. name .. "' received!\n")
      end
   else
      logger.echo(1, "Warning: Invalid argument '" .. args .. "' to 'ext'!\n")
   end
end

function setup_and_run()

   logger.set_debug_level(tonumber(arg[2]))
   logger.echo(1, "Debug level set to " .. logger.get_debug_level())

   if tonumber(arg[3]) > 0 then
      pquery.use_reinforcement()
   end

   local server = socket.tcp()
   server:bind('localhost', arg[1])
   server:listen()
   conn = assert( server:accept() )

   if arg[4] ~= 'no' then
      conn:settimeout(tonumber(arg[4]))
   end

   local data, err
   while true do
      data, err = conn:receive '*l'
      if data then
         local name, args = name_and_args(data)
         if name == "ext" then
            dispatch_ext(args, conn)
         else
            dispatch_on(name, args)
         end
      elseif err == 'timeout' then
         -- Timed out; do a routine check and then move on
         dispatch_on('ter', '')
      else
         error(err)
      end
   end

end

function checkin()
   -- Check in with the semaphore for the generator
   gensema.check_unlock()
   -- Inform each query that a 'ter' check has occurred
   for _, v in ipairs(allqueries) do
      v:ter()
   end
   -- Send finished query data
   local done = {}
   for i, v in ipairs(allqueries) do
      if v._finished then
         conn:send('(completed "' .. v._worldname .. '")') -- TODO Escape if worldname has "quotes"
         table.insert(done, i)
      end
   end
   -- Remove finished elements from the query list
   for _, j in ipairs(done) do
      table.remove(allqueries, j)
   end
end

function request(type_, wname)
   local curr = req_objs[type_]
   if type(curr) == 'function' then
      local result = curr()
      result._worldname = wname
      result:req()
      table.insert(allqueries, result)
   else
      io.stderr:write("WARNING: Unknown request type '" .. type_ .. "'!\n")
   end
end

function request_custom(exprs, wname)
   result = pquery.PQuery.new()
   result._worldname = wname
   for i, v in ipairs(exprs) do
      result:custom(v)
   end
   result:req()
   table.insert(allqueries, result)
end

-- TODO Unify the logger APIs a bit so they're not so drastically different

local status, err = pcall(setup_and_run)
if not status then
   logger.echo(1, "Error during execution: " .. tostring(err))
end
filenamer.cleanup()
