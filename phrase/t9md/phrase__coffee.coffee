#  Phrase: basic lesson
# ======================================================================
p = console.log

print = console.log

p 'empty function ----------------------------------------'
->

p 'default opt----------------------------------------'
fill = (container, liquid = "coffee") ->
  "Filling the #{container} with #{liquid}..."
p fill "ABC"
p fill "ABC", "DEF"

p 'Object ----------------------------------------'
song = ["do", "re", "mi", "fa", "so"]

singers = {Jagger: "Rock", Elvis: "Roll"}

bitlist = [
  1, 0, 1
  0, 0, 1
  1, 1, 0
]

kids =
  brother:
    name: "Max"
    age:  11
  sister:
    name: "Ida"
    age:  9



p '----------------------------------------'
outer = 1
changeNumbers = ->
  inner = -1
  outer = 10
inner = changeNumbers()
p outer
p inner
p inner


p '----------------------------------------'
# mood = greatlyImproved if singing
# if happy and knowsIt
  # clapsHands()
  # chaChaCha()
# else
  # showIt()

# date = if friday then sue else jill
# options or= defaults
p '----------------------------------------'
gold = silver = rest = "unknown"

awardMedals = (first, second, others...) ->
  gold   = first
  silver = second
  rest   = others

contenders = [
  "Michael Phelps"
  "Liu Xiang"
  "Yao Ming"
  "Allyson Felix"
  "Shawn Johnson"
  "Roman Sebrle"
  "Guo Jingjing"
  "Tyson Gay"
  "Asafa Powell"
  "Usain Bolt"
]

awardMedals contenders...

p "Gold: " + gold
p "Silver: " + silver
p "The Field: " + rest
p '----------------------------------------'

iEat = (food) ->
  p "I eat #{food}"

iEat food for food in ["toast", "cheese", "wine"] when food == "toast"
p '----------------------------------------'
countdown = (num for num in [10..1] when num % 2 == 0 )
p countdown
p '----------------------------------------'
evens = (x for x in [0..10] by 2)
evens = (x for x in [10..0] by -2)
p '----------------------------------------'
yearsOld = max: 10, ida: 9, tim: 11

ages = for child, age of yearsOld
  child + " is " + age
p ages

p '----------------------------------------'
# Econ 101
if this.studyingEconomics
  buy()  while supply > demand
  sell() until supply > demand

# Nursery Rhyme
num = 6
lyrics = while num -= 1
  num + " little monkeys, jumping on the bed.
    One fell out and bumped his head."

p lyrics

p '----------------------------------------'
alert = p
class Animal
  constructor: (@name) ->
  move: (meters) ->
    alert @name + " moved " + meters + "m."

class Snake extends Animal
  move: ->
    alert "Slithering..."
    super 5

class Horse extends Animal
  move: ->
    alert "Galloping..."
    super 45

sam = new Snake "Sammy the Python"
tom = new Horse "Tommy the Palomino"

sam.move()
tom.move()
p '----------------------------------------'
String::dasherize = ->
  this.replace /_/g, "-"

p "ABC_def_a".dasherize()

p '----------------------------------------'

futurists =
  sculptor: "Umberto Boccioni"
  painter:  "Vladimir Burliuk"
  poet:
    name:   "F.T. Marinetti"
    address: [
      "Via Roma 42R"
      "Bellagio, Italy 22021"
    ]

{poet: {name, address: [street, city]}} = futurists

p street
p city
p '----------------------------------------'
tag = "<impossible>"
[open, contents..., close] = tag.split("")
p contents.join("")
# p tag.split("")
p '----------------------------------------'
cholesterol = 127

healthy = 200 > cholesterol > 60
p healthy
p '----------------------------------------'
html = '''
       <strong>
         cup of coffeescript
       </strong>
       '''
p html
###==================================================================
this is com
==================================================================###
fs = require 'fs'
fs.readFile "/etc/hosts"
# p lines



#  Phrase: [example] quick start
# ======================================================================
name = "Nao"
puts "My name is #{name}"

pos =
  x: 100
  x: 200
  dump: ->
    puts "x:#{@x}, y:#{@y}"

size = width: 100, height: 100

# myFnc(width:100, height:100)

arr = ["a", "b", "c", "d", "e"]
for val in arr
  puts val

arr = ["a", "b", "c", "d", "e"]
for val, i in arr
  puts "#{i}: #{val}"

# User `of` for Object
data = x: 100, y: 200, z: 300
for name, value of data
    console.log "#{name}: #{value}"

sep = ->
  puts '------------------------------'

sep()
if myName?
  puts "yes"
else
  puts "no"

sep()
html = '''
       <html>
       <head>
        <title>CoffeeScript</title>
       </head>
       <body>
        <table>
         <tr>
          <td></td>
         </tr>
        </table>
       </body>
       </html>
       '''
# puts html
p '----------------------------------------'
pos =
    x: 100
    y: 200
    dump: ->
        # 関数内部で@x(this.x)を使いたいのでfuncの定義は=>にしないといけない
        func = =>
            p "x:#{@x}, y:#{@y}"
        func()
pos.dump()

# http://tech.kayac.com/archive/coffeescript-tutorial.html#coffee_helloworld
p '----------------------------------------'
class Animal
   # newした時に呼ばれるコンストラクタ
   constructor: (name) ->
       @name = name
   say: (word) ->
       console.log "#{@name} said: #{word}"

class Dog extends Animal
   constructor: (name) ->
       # 親クラスのコンストラクタを呼ぶ
       super name
   say: (word) ->
       # 親クラスのメソッドを呼ぶ
       super "Bowwow, #{word}"

class Cat extends Animal
   constructor: (name) ->
       # 親クラスのコンストラクタを呼ぶ
       super name
   say: (word) ->
       # 親クラスのメソッドを呼ぶ
       super "Mew, #{word}"

dog = new Dog("Bob")
dog.say("Hello!")
cat = new Cat("Mike")
cat.say("Hey!")
p '----------------------------------------'
values = (num * 2 for num in [1..5])
puts values
p '----------------------------------------'

if 4 is 4
   puts true
else
   puts false


# Phrase: Method Aliasing
#===========================================================
puts = console.log
print = console.log
p = console.log

alias = (new_meth, old_meth) ->
  eval("#{new_meth} = #{old_meth}")

alias "alert", "puts"

