-- Phrase: OOP example
--===========================================================
Vector = {}
function Vector:new(x, y, z)
  local object = {x=x, y=y, z=z}
  setmetatable(object, { __index = Vector })
  return object
end

function Vector:magnitude()
  return math.sqrt(self.x^2 + self.y^2 + self.z^2)
end

function Vector:display()
  return print(self.x, self.y, self.z)
end

vec = Vector:new(3,4,5)
print(vec:magnitude())
print(vec.x)
vec:display()

-- Phrase: Function Basic
--===========================================================
function each(t,f)
  for _i,v in pairs(t) do
    f(v)
  end
end
each({100,200,300}, print)
--> 100
--> 200
--> 300

function each_with_index(t,f)
  for idx,val in ipairs(t) do
    f(val,idx)
  end
end

each_with_index({100,200,300}, function(v,i)
  ret = string.format("%-3d  %3d", i, v)
  print(ret)
end)
--> 1    100
--> 2    200
--> 3    300

-- Phrase: Bench Mark Sample with os.clock()
--===========================================================
function bench_mark(callback)
  local st, en
  st = os.clock(); callback(); en = os.clock()
  print("time="..(en-st).."sec") --> time=2.8sec
end

function exec_test()
	n = 0
	for i = 1,10000 do
	  for j = 1,1000 do
		n = n + j -i
		n = n * 2
		n = n / j
	  end
	end
end

bench_mark(exec_test)

-- Phrase: Table Basic
--===========================================================
t = { 1, 2, 3}
-- table.concat(table, [sep,[start, end]])
table.concat(t)           --> 123
table.concat(t, ":")      --> 1:2:3
table.concat(t, "/", 1,2) --> 1/2

-- insert
table.insert(t, 2, "@")
table.concat(t, ":") --> 1:@:2:3
table.maxn(t)        --> 4
print(#t)            --> 4

-- remove
table.concat(t, ":") --> 1:@:2:3
table.remove(t)      --> 3
table.concat(t, ":") --> 1:@:2
table.remove(t)      --> 2
table.concat(t, ":") --> 1:@

-- table.sort
tab = {
  {name = 'yuri'    ,age=35},
  {name = 'taku'    ,age=34},
  {name = 'mitsue'  ,age=60},
  {name = 'ryouichi',age=62},
}
table.sort(tab, function(a,b)
  return (a.age < b.age)
end)

for k,v in ipairs(tab) do
  print(v.name..":"..v.age)
end

-->
  -- taku:34
  -- yuri:35
  -- mitsue:60
  -- ryouichi:62

-- Phrase: String Basic
-- ===========================================================
-- byte
s = "abc"
s:byte(1,3)     --> 97 98 99
s:byte(1)       --> 97

-- char
string.char(97) --> a

-- dump
function hoge() print("call hoge()") end
n = string.dump(hoge)
type(n)           --> string
f = loadstring(n)
f()               --> call hoge()

-- rep, reverse, upper, lower
s = "abcdefg"
string.rep("ab", 5) --> ababababab
string.reverse(s)   --> gfedcba
string.upper(s)     --> ABCDEFG
s:upper()           --> ABCDEFG
s:upper():lower()   --> abcdefg

-- Phrase: String Interporation
-- ===========================================================
function e(str)
  return string.gsub(str, "$(%w+)", function (n) return _G[n] end)
end
name = "Haiji"
like = "Sushi"
print(e"My name is $name, I like $like.")
--> My name is Haiji, I like Sushi.	2

-- Phrase: Function generator(Factory)
--===========================================================
function type_checker_of(type_str)
  return function(v)
    return type(v) == type_str
  end
end

is_function = type_checker_of "function"
is_string   = type_checker_of "string"
is_table    = type_checker_of "table"

f = function() end
s = ""
t = {}

function check(callback)
  local ret = {}
  table.insert(ret, callback(f))
  table.insert(ret, callback(s))
  table.insert(ret, callback(t))
  return ret
end

for k, v in ipairs(check(is_function)) do print(k,v) end
--> 1	true
--> 2	false
--> 3	false
for k, v in ipairs(check(is_string)) do print(k,v) end
--> 1	false
--> 2	true
--> 3	false
for k, v in ipairs(check(is_table)) do print(k,v) end
--> 1	false
--> 2	false
--> 3	true

-- Phrase: Practical Coroutine(Implement PIPE with producer - consumer model)
-- ===========================================================
function receive(prod)
  local status, value = coroutine.resume(prod)
  return value
end

function send(x) coroutine.yield(x) end

function producer()
  return coroutine.create(function()
    while true do
      local x = io.read()
      if not x then break end
      send(x)
    end
  end)
end

function filter(prod)
  return coroutine.create(function ()
    local line = 1
    while true do
      local x = receive(prod)
      if not x then break end
      x = string.format("%5d %s", line, x)
      send(x)
      line = line + 1
    end
  end)
end

function consumer(prod)
  while true do
    local x = receive(prod)
    if not x then break end
    io.write(x, "\n")
  end
end

consumer(filter(producer()))

-- Usage example
-- cat /etc/hosts | lua pipe_sample.lua

-- Phrase: Coroutine
-- ===========================================================
co = coroutine.create(function()
  print("hi")
end)

print(co)                    --> thread: 0x9b922d0
print(coroutine.status(co))  --> suspended
coroutine.resume(co)         --> hi
print(coroutine.status(co))  --> dead

-- pass argments to co-routine
co = coroutine.create(function (a,b,c)
  print("co", a,b,c)
end)
coroutine.resume(co, 1,2,3) --> co 1 2 3

-- Exchange date between co-routine and yield
co = coroutine.create(function(a,b)
  coroutine.yield(a+b, a-b)
end)
print(coroutine.resume(co, 20, 10)) --> true 30 10

-- coroutine.yield() return vlues passed to resume 
co = coroutine.create (function ()
  print("co", coroutine.yield())
end)
coroutine.resume(co)
coroutine.resume(co, 4, 5)   

-- Phrase: Error handling
-- ===========================================================
local status, err = pcall(function () a = 'a'+1 end)
print(err)
--> stdin:1: attempt to perform arithmetic on a string value

local status, err = pcall(function () error("my error") end)
print(err)
--> stdin:1: my error

-- Phrase: complex iterator
-- ===========================================================
function allwords()
  local line = io.read()
  local pos = 1
  return function()
    while line do
      local s, e = string.find(line, "%w+", pos)
      if s then
        pos = e + 1
        return string.sub(line, s, e)
      else
        line = io.read()
        pos = 1
      end
    end
    return nil
  end
end

for word in allwords() do
  print(word)
end
-- Usage example
-- cat /etc/hosts | lua allwords.lua

-- Phrase: Simple Iterator function
-- ===========================================================
function list_iter(t)
  local i = 0
  local size = table.getn(t)
  return function()
    i = i + 1
    if i <= size then return t[i] end
  end
end

t = {10, 20, 30}
iter = list_iter(t)
while true do
  local element = iter()
  if element == nil then break end
  print(element)
end
-- Phrase: Simple State Machine: tail call optimization
-- ===========================================================
-- movement from one room to another room is acomplished with
-- state machine.
-- Each State is represented by function.
-- moving with calling each function is placed in last expression
-- in enclosing function.
-- This could be condidered as goto because retered value is simply
-- discarded by calling function.
-- With this situation(=discading returned value make no difference
-- to final result) , compiler use no stack when tail call.
-- This optimization enable lmitless recursive call.
function room1()
  print "[room1]:"
  local move = io.read()
  if move == "south" then return room3()
  elseif move == "east" then return room2()
  else print("invalid move")
    return room1()
  end
end

function room2()
  print "[room2]:"
  local move = io.read()
  if move == "south" then return room4()
  elseif move == "west" then return room1()
  else print("invalid move")
    return room2()
  end
end

function room3()
  print "[room3]:"
  local move = io.read()
  if move == "north" then return room1()
  elseif move == "east" then return room4()
  else print("invalid move")
    return room3()
  end
end

function room4()
  print "[room4]:"
  print("conguratulations!")
end
room1()


-- Phrase: Talbe Array Size manupilation
--===========================================================
print(table.getn{10,2,4})          --> 3
print(table.getn{10,2,nil})        --> 2
print(table.getn{10,2,nil; n=3})   --> 3
print(table.getn{n=1000})          --> 1000

a = {}
print(table.getn(a))               --> 0
table.setn(a, 10000)
print(table.getn(a))               --> 10000

a = {n=10}
print(table.getn(a))               --> 10
table.setn(a, 10000)
print(table.getn(a))               --> 10000



-- Phrase: Basic
--===========================================================
-- Read file
for line in io.open("/etc/hosts"):lines() do
  print(line)
end

-- Execute Command via Shell: equivalent to system()
if os.execute() > 0 then
  code = os.execute("ping -c 1 -w 1.0 googe.com")
  print("code:".. code)
else
  print("sorry, could not execute")
end

-- emulate named argment
function rename_file(arg)
  return os.rename(arg.old, arg.new)
end
rename_file {old="oldfile", new="newfile"}

--configurat
function config(options)
  return {
    port = options.port or 80, 
    listen = options.listen or "127.0.0.1",
  }
end

conf = config{listen = '192.168.1.1'}
conf = config{port = 8080, listen = '192.168.1.1'}
print(conf["port"])


-- equivalent conditional operator in other launguage(such as C)
-- (x > y) ? x : y
x = 100
y = 10
max = (x > y) and x or y

-- unpack example
function fwrite (fmt, ...)
  return io.write(string.format(fmt, unpack(arg)))
end

-- quote with '%q' format string
function Quote(str)
  return string.format("%q", str)
end

-- Phrase: Mini module example
--===========================================================
-- Usage: require("Util"); print(Util.Quote("Taku's bag."))

-- avoid to overwrite fields when multiple modules add fields to Util table
Util = Util or {}

function Util.Quote(str)
  return string.format("%q", str)
end
return Util

-- Phrase: luarocks
--===========================================================
require "luarocks.loader"
_ = require 'underscore'
_.each({1,2,3}, print)


