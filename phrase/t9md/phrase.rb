# Phrase: Array with size limit
#===========================================================
class ArrayWithSizeLimit < Array
  def initialize(max_size)
    super()
    @max_size = max_size
  end

  def push(val)
    self.concat([val])
    shift if size > @max_size
    self
  end
  alias_method :<<, :push
end

ary = []
ary << 1 # => [1]
ary << 2 # => [1, 2]
ary << 3 # => [1, 2, 3]
ary << 4 # => [1, 2, 3, 4]
ary << 5 # => [1, 2, 3, 4, 5]
ary << 6 # => [1, 2, 3, 4, 5, 6]
ary << 7 # => [1, 2, 3, 4, 5, 6, 7]

ary_with_max = ArrayWithSizeLimit.new(3)
ary_with_max << 1 # => [1]
ary_with_max << 2 # => [1, 2]
ary_with_max << 3 # => [1, 2, 3]
ary_with_max << 4 # => [2, 3, 4]
ary_with_max << 5 # => [3, 4, 5]
ary_with_max << 6 # => [4, 5, 6]
ary_with_max << 7 # => [5, 6, 7]

# Phrase: Arity
#===========================================================
class Cla2
  def meth1; end
  def meth2(arg1) end
  def meth3(arg1, arg2) end
  def meth4(arg1, *arg2) end
end

# Arity return numbe orf required argments, if method can accept 
# variable args, it return number of argments at least required with '-N' form
#
Cla2.instance_method(:meth1).arity # => 0
Cla2.instance_method(:meth2).arity # => 1
Cla2.instance_method(:meth3).arity # => 2
Cla2.instance_method(:meth4).arity # => -2

# Phrase: SysLogger from mojombo's God
#===========================================================
require 'syslog'

class SysLogger
  SYMBOL_EQUIVALENTS = {
    :fatal => Syslog::LOG_CRIT,
    :error => Syslog::LOG_ERR,
    :warn  => Syslog::LOG_WARNING,
    :info  => Syslog::LOG_INFO,
    :debug => Syslog::LOG_DEBUG
  }

  # Set the log level
  #   +level+ is the Symbol level to set as maximum. One of:
  #           [:fatal | :error | :warn | :info | :debug ]
  #
  # Returns Nothing
  def self.level=(level)
    Syslog.mask = Syslog::LOG_UPTO(SYMBOL_EQUIVALENTS[level])
  end

  # Log a message to syslog.
  #   +level+ is the Symbol level of the message. One of:
  #           [:fatal | :error | :warn | :info | :debug ]
  #   +text+ is the String text of the message
  #
  # Returns Nothing
  def self.log(level, text)
    Syslog.log(SYMBOL_EQUIVALENTS[level], text)
  end
end

# Syslog must be opend before Syslog.mask= is called in SysLogger.level
begin
  Syslog.open('t9md')
rescue RuntimeError
  Syslog.reopen('t9md')
end

Syslog.info("Syslog enabled.")
SysLogger.level = :warn
SysLogger.log(:debug, "this is debug message")
SysLogger.log(:info, "this is info message")
SysLogger.log(:warn, "this is warn message")
SysLogger.log(:fatal, "this is fatal message")

# Phrase: How to detect multiple consequtive failure
#===========================================================
class MultipleConsequtiveFailure < StandardError;  end

@failure_limit = 3
@major_duration = 5
@try_times = []
def detect_consequtive_failure(now)
  consequtive_failure = @try_times.select {|time| time >= now - @major_duration }
  if consequtive_failure.length >= @failure_limit
    raise MultipleConsequtiveFailure
  end
  "OK"
rescue MultipleConsequtiveFailure
  "MultipleConsequtiveFailure"
end

def case1
  sleep 3; @try_times << Time.now.to_i
  sleep 3; @try_times << Time.now.to_i
  sleep 3; @try_times << Time.now.to_i
  detect_consequtive_failure(Time.now.to_i)
end
def case2
  sleep 1; @try_times << Time.now.to_i
  sleep 1; @try_times << Time.now.to_i
  sleep 1; @try_times << Time.now.to_i
  detect_consequtive_failure(Time.now.to_i)
end
case1  # => "OK"
case2 # => "MultipleConsequtiveFailure"

# Phrase: Socket programming
#===========================================================
require "socket"

# 正引き
Socket.gethostbyname("www.yahoo.co.jp") # => ["www.ya.gl.yahoo.co.jp", ["www.yahoo.co.jp"], 2, "|S\353\314"]

hostent = Socket.gethostbyname("www.yahoo.co.jp")

# unpack は文字列を配列へ，pack は配列を文字列へ(C構造体にマッピングされる)
hostent[3].unpack("C4").join('.') # => "124.83.235.204"

# 逆引き
Socket.gethostbyaddr(hostent[3]) # => ["f9.top.vip.ogk.yahoo.co.jp", [], 2, "|S\353\314"]
# 正引き
Socket.getaddrinfo("www.kame.net", 80, Socket::AF_INET)



# Phrase: Daemonize
#===========================================================
raise 'Must run as root' if Process.euid != 0

raise 'First fork failed' if (pid = fork) == -1
exit unless pid.nil?

Process.setsid
raise 'Second fork failed' if (pid = fork) == -1
exit unless pid.nil?
puts "Daemon pid: #{Process.pid}" # Or save it somewhere, etc.

# Release working directory
Dir.chdir '/' 
# Reset umask
File.umask 0000

STDIN.reopen '/dev/null'
STDOUT.reopen '/dev/null', 'a'
STDERR.reopen STDOUT
f = File.open('/tmp/daemon.log', 'w')

3.times do |n|
  f.puts n
  f.flush
  sleep 10
end
f.puts "FINISH!!"

# Phrase: appscript iterm sample
#===========================================================

def create_sessions(max)
  iTerm = app('iTerm')
  1.upto(max) do |num|
    iTerm.current_terminal.launch_(:session => "Default Session")
    iTerm.current_terminal.current_session.name.set("tab_#{num}")
    # puts iTerm.current_terminal.current_session.name.get
  end
end

def create_terminal
  iTerm = app('iTerm')
  # iTerm.make(:new => :terminal)
  # max = iTerm.terminals.count
  iTerm.current_terminal.make(:at => iTerm.terminals.last.sessions.end, :new => :session)
  shell = ENV['SHELL']
  iTerm.current_terminal.current_session.exec(:command => shell)
end

def create_terminals(max)
  iTerm = app('iTerm')
  1.upto(max) do |num|
    iTerm.current_terminal.launch_(:session => "Default Session")
    iTerm.current_terminal.current_session.name.set("tab_#{num}")
    # puts iTerm.current_terminal.current_session.name.get
  end
end

def bulk_execute_other_than_current_active_term(cmd)
  iTerm = app('iTerm')
  myself = iTerm.current_terminal.current_session.tty.get
  1.upto(iTerm.terminals.count) do |num|
    iTerm.terminals[num].select
    next if iTerm.terminals[num].current_session.tty.get == myself 
    iTerm.current_terminal.current_session.write(:text => cmd)
    sleep 0.03
  end
end

# Phrase: Factory and Singleton
#===========================================================
class Creator
  # with limit of number of instance

  @@instance = []
  class << self
    attr_accessor :instance_max
  end

  attr_reader :name

  # インスタンスは Creator.create
  # クラスメソッド経由で作成し、@@instance_max
  # を超えると、それ以上作成しない。
  def self.create(name)
    if @@instance.size + 1 > @instance_max
      return "No more space!!"
    end
    obj = self.new(name)
    @@instance << obj
    obj
  end

  def self.member
    @@instance
  end

  # p メソッドの引数に渡されると、inspect メソッドが呼ばれる。
  def inspect
    "<#{self.class}:%#x #{@name}>" % [ self.object_id ]
  end

  def self.list_member
    lis = []
    @@instance.each_with_index do |m, idx|
      lis << "%02d %s" % [idx, m.name]
    end
    lis
  end

  def initialize(name)
    @name = name
  end

  def hello
    "hello #{name}"
  end
end

Creator.instance_max = 3
Creator.instance_max  # => 3
Creator.create("toko") # => <Creator:0x12124 toko>
Creator.create("moko") # => <Creator:0x11ff8 moko>
Creator.create("moyo") # => <Creator:0x11ecc moyo>
Creator.create("roro") # => "No more space!!"

Creator.member # => [<Creator:0x12124 toko>, <Creator:0x11ff8 moko>, <Creator:0x11ecc moyo>]
Creator.list_member
# => ["00 toko", "01 moko", "02 moyo"]

# Phrase: Best test
#===========================================================
number = ('0'..'9').to_a.join # => "0123456789"
lower  = ('a'..'z').to_a.join # => "abcdefghijklmnopqrstuvwxyz"
upper  = lower.upcase # => "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Phrase: This method
#===========================================================
module Kernel
  private
  def this_method
   caller[0][/`([^']*)'/, 1]
  end

  def calling_method
   caller[1][/`([^']*)'/, 1]
  end
end


# Phrase: Class#inherited hook
#===========================================================
class Parent
  @@plugins = []
  class << self
    def inherited(subclass)
      @@plugins << subclass
    end
  
    def plugins; @@plugins end
  end

  def hello
    "hello"
  end
end

class FirstChild < Parent; end
class NextChild < Parent; end

Parent.plugins # => [FirstChild, NextChild]

# Phrase: Tempfile
#===========================================================
require 'tempfile'

tmpfile = Tempfile.new('macvim')
tmpfile.write "HOGE"
tmpfile.flush
tmpfile.path # => "/var/folders/rk/rkEsbXEnFQeByW+4q-d9KU+++TM/-Tmp-/macvim20101025-89086-1wt2bbh-0"
File.read(tmpfile.path) # => "HOGE"
tmpfile.delete # => #<File:/var/folders/rk/rkEsbXEnFQeByW+4q-d9KU+++TM/-Tmp-/macvim20101025-89086-1wt2bbh-0>
tmpfile.path # => nil

# Phrase: Normalize ansi colored text
#===========================================================
class String
  def ansi_colored?
    self =~ /^\e\[[\[\e0-9;m]+m/
  end

  def to_s
    tmp = self.sub(/^\e\[[\[\e0-9;m]+m/, "")
    tmp.sub(/(\e\[[\[\e0-9;m]+m)$/, "")
  end

  def inner_str
    tmp = self.sub(/^\e\[[\[\e0-9;m]+m/, "")
    tmp.sub(/(\e\[[\[\e0-9;m]+m)$/, "")
  end
end

# Phrase: Colored example
#===========================================================
# http://d.hatena.ne.jp/ha-tan/20070907/1189172928

module Kernel
  def curry(sym, *fix)
    f = sym.respond_to?(:call) ? sym : method(sym)
    lambda do |*arg|
      f.call(*(fix + arg))
    end
  end
end

def add(a, b)
  a + b
end

curry(:add, 2)[3]                  # => 5
curry(method(:add), 2)[3]          # => 5
curry(lambda {|a, b| a * b}, 2)[3] # => 6

shift = 1
(0...10).map(&curry(:add, shift))
 # => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]


# Phrase: Colored example
#===========================================================
require "rubygems"
require "colored"

colors = %w( black red green yellow blue magenta cyan white).map(&:to_sym)
special = %w( bold underline reversed ).map(&:to_sym)
sample_string = "This is a Sample String (how it look like?)"
colors.each do |color|
  puts ("%-7s %-7s" % [color, ""]).send(color)
  special.each do |sp|
   puts ("%-7s %-7s" % [color, sp]).send(color).send(sp)
  end
end

require "rubygems"
require "colored"
puts "this is red".red
puts "this is red with a blue background (read: ugly)".red_on_blue
puts "this is red with an underline".red.underline
puts "this is really bold and really blue".bold.blue
puts Colored.colorize "This is red" # but this part is mostly untested

# Phrase: Mixlib sample
#===========================================================
require "rubygems"
require "mixlib/config"
require "stringio"

class ApacheConfig
  extend Mixlib::Config
end
ApacheConfig.from_file("./apache.conf")  # => 
ApacheConfig.first_value                 # => 
ApacheConfig.other_value                 # => 
ApacheConfig.group                       # => 
ApacheConfig.http_port                   # => 
ApacheConfig.username                    # => 

# Phrase: String Conversion
#===========================================================
def snake_case(str)
  str = str.dup
  str.gsub!(/[A-Z]/) {|s| "_" + s}
  str.downcase!
  str.sub!(/^\_/, "")
  str
end

snake_case "ConvertToClassName" # => "convert_to_class_name"

# Phrase: KeyMap keyboard
#===========================================================
class KeyMap
  class << self
    attr_reader :keymap

    def add_keymap(key, func)
      (@keymap ||= {})[key] = func
      @keymap
    end

    def read_keymap(io)
      delete_backward_word = lambda { "DELETE_BACKWARD_WORD" }
      delete_forward_word  = lambda { "DELETE_FORWARD_WORD" }
      forward_char         = lambda { "FORWARD_CHAR" }
      backward_char        = lambda { "BACKWARD_CHAR" }

      instance_eval io.read
    end
  end
end

class KeyImput
  def initialize(keymap)
    @keymap = keymap
  end

  def do(key)
    @keymap[key.intern].call
  end
end

require "stringio"
KEY_MAP_CONFIG =<<EOS
  add_keymap :"M-w", delete_backward_word
  add_keymap :"M-d", delete_forward_word
  add_keymap :"M-f", delete_forward_word
  add_keymap :"C-f", forward_char
  add_keymap :"C-b", backward_char
EOS

keymap = KeyMap.read_keymap StringIO.new( KEY_MAP_CONFIG )

keyboard = KeyImput.new keymap
keyboard.do "M-w" # => "DELETE_BACKWARD_WORD"
keyboard.do "M-d" # => "DELETE_FORWARD_WORD"
keyboard.do "C-f" # => "FORWARD_CHAR"
keyboard.do "C-b" # => "BACKWARD_CHAR"

# Phrase: Several style
#===========================================================
# Imperable style
def read_code1(source_file)
  code = ""
  lines = 0
  width = 0
  File.open(source_file) do |code_file|
    code_file.readlines.each do |line|
      code += "    #{line}"
      lines += 1
      width = line.length if line.length > width
    end
  end
  [code,lines,width]
end

# Functional?
def read_code2( source_file )
  lines     = File.open(source_file).readlines
  code      = lines.map { |line| "    #{line}" }.join(nil)
  max_width = lines.map { |line| line.length }.max
  [code, lines.size ,max_width]
end

# More Functional with Recursive Style
def read_code3( source_file )
  func = lambda { |code, count, max_width, lines|
    if lines.empty?
      return [code, count, max_width]
    else
      line = lines.shift
      func.call(
        code + "    #{line}",
        count + 1,
        (max_width < line.size) ? line.size : max_width,
        lines
      )
    end
  }
  func.call("", 0, 0, File.open(source_file).readlines)
end

SOURCE =  "./LICENSE"
one    =  read_code1 SOURCE
two    =  read_code2 SOURCE
three  =  read_code3 SOURCE
one    == two   # => true
one    == three # => true

# Phrase: Extend self
#===========================================================
module ModA
  extend self

  def meth1
    "meth1"
  end
  def meth2
    "meth2"
  end
end

class Hoge
  include ModA
end

ModA.meth1 # => "meth1"
ModA.meth2 # => "meeth2"
Hoge.new.meth1 # => "meth1"
Hoge.new.meth2 # => "meeth2"
# Phrase: Kernel.fork
#===========================================================
child_pid = Kernel.fork do
  "Child" # => "Child"
  Process.pid # => 24273
end
parent_pid = Process.pid
child_pid # => 24273
parent_pid # => 24272

# Phrase: [metaprog] Javascript like function
#===========================================================
module Kernel
  def metaclass
    (class << self ; self ; end)
  end

  def fun(meth_name = nil, &blk)
    metaclass.instance_eval {
      meth( meth_name, &blk )
    }
  end

  def meth(meth_name = nil, &blk)
    function_body = lambda {|*args| blk.call(*args) }
    meth_name ?  define_method( meth_name, function_body) : function_body
  end
end

fun :hoge do
  "hoge"
end
hoge # => "hoge"

val = fun do |a, b|
  a + b
end.call(1,2)
val # => 3

class Counter
  count = 0
  def initialize(init = 0)
    # self.count=(init)
  end

  meth(:count=) { |x| count = x ; puts "set to #{count}" }
  meth(:count ) { count }
  meth(:inc   ) { count += 1 }
  meth(:dec   ) { count -= 1 }
  meth(:reset ) { count = 0 }
end

Counter.instance_methods(false)  # => ["count", "reset", "count=", "dec", "inc"]
counter = Counter.new
# counter.hello # => 
counter.inc # => 1
counter.dec # => 0
counter.inc # => 1
counter.inc # => 2
counter.reset # => 0
counter.inc # => 1

# Phrase: [metaprog] Flat scope and metaclass
#===========================================================
# Counter 1
def create_counter
  i = 0
  obj = Object.new
  (class << obj; self ; end ).class_eval {
    define_method(:inc, lambda { i += 1 } )
    define_method(:dec, lambda { i -= 1 } )
  }
  obj
end

counter = create_counter # => #<Object:0x21a84>
counter.inc # => 1
counter.inc # => 2
counter.inc # => 3
counter.dec # => 2
counter.dec # => 1
counter.dec # => 0
counter.dec # => -1
counter.dec # => -2

# Counter 2

class Counter
  count = 0
  def initialize(init = 0)
    self.count = init
  end

  define_method(:count= , lambda { |x| count = x } )
  define_method(:count  , lambda { count } )
  define_method(:inc    , lambda { count += 1 } )
  define_method(:dec    , lambda { count -= 1 } )
  define_method(:reset  , lambda { self.count = 0 } )
end

# counter = Counter.new
counter = Counter.new(10)
counter.inc # => 11
counter.dec # => 10
counter.reset # => 0
counter.inc # => 1

# Phrase: [metaprog] tail recursion could be translated into goto like flow.
#===========================================================
folder = lambda { |default_value, binary_function, list|
  fold_with_acc = lambda { |acc, list|
    indent = ' ' * $id
    $id += 4
    print indent, [ acc, list ].inspect, "\n"
    if list.empty?
      print indent, "empty", "\n"
      throw :gott, acc
    else
      print indent, "call: fold_with_acc.call(binary_function.call(#{acc.inspect}, #{list.first.inspect}), #{list[1..-1].inspect})", "\n"
      v = fold_with_acc.call(binary_function.call(acc, list.first), list[1..-1])
      print indent,  "return #{v}", "\n"
      v
    end
  }
  ret = catch(:gott) {
    fold_with_acc.call(default_value, list)
  }
  ret
}

folder.call(0, lambda{|a,b| a + b }, [1,2,3,4,5]) # => 15
# >> [0, [1, 2, 3, 4, 5]]
# >> call: fold_with_acc.call(binary_function.call(0, 1), [2, 3, 4, 5])
# >>     [1, [2, 3, 4, 5]]
# >>     call: fold_with_acc.call(binary_function.call(1, 2), [3, 4, 5])
# >>         [3, [3, 4, 5]]
# >>         call: fold_with_acc.call(binary_function.call(3, 3), [4, 5])
# >>             [6, [4, 5]]
# >>             call: fold_with_acc.call(binary_function.call(6, 4), [5])
# >>                 [10, [5]]
# >>                 call: fold_with_acc.call(binary_function.call(10, 5), [])
# >>                     [15, []]
# >>                     empty

# Phrase: [metaprog] Proc and lambda and proc
#===========================================================
f_Proc = Proc.new {|v| v } # !> multiple values for a block parameter (2 for 1)
f_Proc.call(1) # => 1
f_Proc.call(1,2) rescue nil # => [1, 2]

f_proc = proc {|v| v } # !> multiple values for a block parameter (2 for 1)
f_proc.call(1) # => 1
f_proc.call(1,2) rescue nil # => [1, 2]

f_lambda = lambda {|v| v } # !> multiple values for a block parameter (2 for 1)
f_lambda.call(1) # => 1
f_lambda.call(1,2) rescue nil # => [1, 2]

# When 'return' in Proc, it return from enclosed method.
def return_with_Proc
  f = Proc.new { return "return inside block" }
  f.call
  v = f.call
  return "#{v}: return from method_end" 
end
return_with_Proc # => "return inside block"

# When 'return' in lambda , it return value to caller as like normal methods.
def return_with_lambda
  f = lambda { return "return inside block" }
  f.call
  v = f.call
  return "#{v}: return from method_end" 
end
return_with_lambda # => "return inside block: return from method_end"

# Phrase: [metaprog] metadef for easiliy define class methods
#===========================================================
class Class
  def metaclass
    (class << self; self ; end)
  end
end

class A
  def self.metadef(meth_name, &meth_body)
    (class << self; self; end).send :define_method, meth_name, &meth_body
  end

  def self.metadef2(&blk)
    metaclass.class_eval(&blk) 
  end

  x = 0

  def self.meth1(x)
    "meth1: #{x}"
  end
  meth1 1 # => "meth1: 1"
  x # => 0

  metadef("meth2") { |x|
    # block parameter |x| is used to access method argment , it also referencing
    # already defined outer x. so, when you call meth2(arg), x is set to arg,
    # this mean, outer x also is set to arg.
    # x is not method local!!!!
    "meth2: #{x}"
  }
  x # => 0
  meth2 2 # => "meth2: 2"
  x # => 2

  metadef2 {
    def meth3(x)
      "meth3: #{x}"
    end
    private :meth3
  }
  meth3 3 # => "meth3: 3"
  x # => 2
end

A.singleton_methods(false) # => ["metadef", "metadef2", "meth2", "meth1"]
A.meth1(1) # => "meth1: 1"
A.meth2(1) # => "meth2: 1"
A.meth3(1) # -:50: private method `meth3' called for A:Class (NoMethodError)

# Phrase: JSON
#===========================================================
require "rubygems"
require "json"
default_config = {
  :port => 80,
  :listen => "127.0.0.1",
  :hostname => "localhost",
  :docroot => "/var/www/html",
}

user_config = {
  :port => 8080,
  :listen => "127.0.0.1",
  :hostname => "localhost",
  :docroot => "/var/www/usr",
}

default_config.update(user_config)
json_str = default_config.to_json
h = JSON.parse(json_str)
h['port'] # => 8080

# Phrase: Mini TIPS
#===========================================================
File.join('abc', 'def') # => "abc/def"
dirname, basename = File.split("a/b/c") # => ["a/b", "c"]
"a/b/c/d".split('/',2) # => ["a", "b/c/d"]

# break can return value
value = (1..10).each do |i|
  break i if  i > 3 
end
value # => 4

# p
require "pp"
module Kernel
  alias_method :old_inspct, :inspect
  alias_method :inspect, :pretty_inspect
end
str = {:port =>80, :listen => "127.0.0.1" }.inspect

# Phrase: YAML::Store , PStore
#===========================================================
require 'yaml/store'
DB_PATH="./db/db.yml"
@db_y = YAML::Store.new(DB_PATH)
key = "2WT9NBX"
@db_y.transaction do |db|
  if db.root?(key)
    db[key] = "update value"
  else
    db[key] = "new key"
  end
  db.roots # Hash#keys coordinate
end

require 'pstore'
@db_p = PStore.new(DB_PATH)
@db_p.transaction do |db|
  puts db["2WT9NBX"]
end

# Phrase: Signal innterupt
#===========================================================
Signal.trap(:INT) { puts "Interrupted"; exit 1 }

# or 
Signal.trap(:INT) do 
  puts "Interrupted"
  exit 1
end

# Phrase: Configuration file parse(support nested config)
#===========================================================
def read_conf(conf)
  File.open(conf).readlines.map  do |line|
    line.chomp!
    if line =~ /@include (.*)/
      line = read_conf($1)
    end
    line
  end.flatten
end

def parse_conf(array)
  h = {}
  array.each do |e|
    key, val = e.split('=')
    h[key] = val
  end
  h
end

conf1 =<< EOS
secure = true
server = 1.2.3.4
@include conf2
port = 80
name = example.com
END

conf2 =<< EOS
nestedvar1 = nested2
@include conf3
nestedvar2 = nested2
EOS

conf3 =<< EOS
nestedvar3 = nested3
nestedvar4 = nested4
EOS

conf = read_conf("conf1")
 # => ["secure = true",
 #     "server = 1.2.3.4",
 #     "nestedvar1 = nested2",
 #     "nestedvar3 = nested3",
 #     "nestedvar4 = nested4",
 #     "nestedvar2 = nested2",
 #     "port = 80",
 #     "name = example.com"]

parse_conf conf
 # => {"server "=>" 1.2.3.4",
 #     "secure "=>" true",
 #     "nestedvar4 "=>" nested4",
 #     "nestedvar3 "=>" nested3",
 #     "nestedvar2 "=>" nested2",
 #     "port "=>" 80",
 #     "nestedvar1 "=>" nested2",
 #     "name "=>" example.com"}

# Phrase: Pathname handling
#===========================================================
require "pathname"
Pathname.getwd # => #<Pathname:/Users/maeda_taku/Dropbox/config/.vim/util/scratch>
Pathname.pwd # => #<Pathname:/Users/maeda_taku/Dropbox/config/.vim/util/scratch>
__DIR__ = File.dirname(__FILE__)
Pathname.new(__DIR__).realpath # => #<Pathname:/Users/maeda_taku/Dropbox/config/.vim/util/scratch>

# Phrase: Simple DSL
#===========================================================
class Book
  attr_reader :title, :author, :isbn, :owners
  def initialize(opt)
    opt.each {|k,v| instance_variable_set("@#{k}", v) }
  end
end

class Library
  def initialize(name, &blk)
    @books = []
    instance_eval(&blk)
  end

  def new_book(opt)
   @books << Book.new(opt)
  end

  def lend(book)
    @books.each do |book|
    end
  end

  def books
    @books
  end

  def method_missing(meth, *args, &blk)
    key = if (meth.to_s =~ /^find_by_(.*)/) then
            $1.to_sym
          end

    @books.find_all do |book|
      (book.send key) == args.first
    end
  end
end

library = Library.new("Suginami") do
  new_book :title  => 'War and Peace',
           :author => 'Tolstoy',
           :isbn   => '0375760644',
           :owners => ['Amanda']

  new_book :title  => 'Lord of the Rings',
           :author => 'Tolkien',
           :owners => ['Steve', 'Amanda', 'Marty']
end

library.find_by_title 'War and Peace'
 # => [#<Book:0x2470c
 #      @author="Tolstoy",
 #      @isbn="0375760644",
 #      @owners=["Amanda"],
 #      @title="War and Peace">]

library.find_by_author 'Tolkien'
 # => [#<Book:0x2457c
 #      @author="Tolkien",
 #      @owners=["Steve", "Amanda", "Marty"],
 #      @title="Lord of the Rings">]

# Phrase: misc
#===========================================================
# read file as Array it's element deleted \n .
File.open(f).readlines.map(&:chomp)
# Phrase: logger usage
#===========================================================
require "logger"
LOG_DIR  = "."
LOG_FILE = "#{LOG_DIR}/#{File.basename(__FILE__, ".rb")}.log"
logio = open(LOG_FILE, "a+")
logio.sync = true
# logio = STDOUT
logger = Logger.new(logio)

logger.info { "START: this is sample" }
10.times do 
  sleep 1
  logger.error { "this is sample erro" }
end
logger.info { "END: this is sample" }

# ERROR: エラー
# FATAL: プログラムをクラッシュさせるような制御不可能なエラー
# WARN: 警告
# INFO: 一般的な情報
# DEBUG: 低レベルの情報

require 'logger'
LOG_FILE = "/tmp/macvim.log"

logio = open(LOG_FILE ,"a+")
logio.sync = true
$logger = Logger.new(logio)
class Object
  def debug(&blk) $logger.debug(&blk) end
  def info(&blk)  $logger.info(&blk) end
  def warn(&blk)  $logger.warn(&blk) end
  def error(&blk) $logger.error(&blk) end
  def fatal(&blk) $logger.fatal(&blk) end
end

$logger.level=Logger::WARN
debug { "debug" }
info  { "AAAA"  }
warn  { "AAAA"  }
fatal { "AAAA"  }

# Phrase: Delayed initalization
#===========================================================
# (@a ||= []) =equal=> @a = @a || []
(@a ||= []) << "a"
(@a ||= []) << "b"
@a # => ["a", "b"]

# (h[:a] ||= []) =equal=> h[:a] = h[:a] || []
h = {}
(h[:a] ||= []) << "a"
(h[:a] ||= []) << "b"
h[:a] # => ["a", "b"]

# Phrase: Simplified block with Symbol.to_proc
#===========================================================
a = [ "cat\n", "dog\n", "lion\n" ]
a # => ["cat\n", "dog\n", "lion\n"]
a.map(&:chomp) # => ["cat", "dog", "lion"]

# Phrase: [metaprog] method_missing for OpenStruct
#===========================================================
class MyOpenStruct
  def initialize
    @attributes = {}
  end

  def method_missing(name, *args)
    attribute = name.to_s
    if attribute =~ /=$/
      # chop ensure removing trailing '='
      @attributes[attribute.chop] = args[0]
    else
      @attributes[attribute] # => "vanilla"
    end
  end
end

icecream = MyOpenStruct.new
MyOpenStruct.instance_methods(false) # => ["method_missing"]
icecream.flavor = 'vanilla'
icecream # => #<MyOpenStruct:0x24f40 @attributes={"flavor"=>"vanilla"}>
icecream.flavor  # => "vanilla"
# Phrase: setup option with Hash#merge
#===========================================================
opt = {
  :port => 80,
  :listen => "127.0.0.1",
  :hostname => "localhost",
  :docroot => "/var/www/html",
}

user_opt = {
  :port => 8080,
  :docroot => "/home/html"
}

opt.merge! user_opt # => {:port=>8080, :listen=>"127.0.0.1", :hostname=>"localhost", :docroot=>"/home/html"}
opt # => {:port=>8080, :listen=>"127.0.0.1", :hostname=>"localhost", :docroot=>"/home/html"}

# Phrase: add custom libdir to LOAD_PATH
#===========================================================
LIBDIR = File.dirname(File.expand_path(__FILE__)) + "/lib"
$LOAD_PATH.unshift LIBDIR

# Phrase: [metaprog] ObjectSpace usage traverse all Object
#===========================================================

Module.ancestors # => [Module, Object, PP::ObjectMixin, Kernel]
Object.ancestors # => [Object, PP::ObjectMixin, Kernel]
Object.class # => Class
Module.class # => Class
modules = ObjectSpace.each_object(Module)
classes = ObjectSpace.each_object(Class)
pure_modules = modules.to_a  - classes.to_a
modules.map {|e| "#{e}" }.grep(/Object/) # => ["ObjectSpace", "Object",....]
# print ancestors for the modules not including Kernel module
modules.select do |e|
  not (e === Kernel)
end.each do |e|
  puts "#{e}\t:#{e.ancestors}"
end

# Phrase: [metaprog] Number of Module Include way
#============================================================
module FlowerGlowable; end
class Cattle; end

class Yappo < Cattle; end
Yappo.ancestors # => [Yappo, Cattle, Object, Kernel]

## standard
class Yappo
 include FlowerGlowable
end

## Advanced1
s =  "FlowerGlowable"
Yappo.class_eval "include #{s}"

## Advanced2
s =  "FlowerGlowable"
cls = ObjectSpace.const_get(s) 
Yappo.class_eval {
  include ObjectSpace.const_get(s)
}
Yappo.ancestors # => [Yappo, FlowerGlowable, Cattle, Object, Kernel]

# Phrase: eval and binding
#============================================================
def get_binding(str)
  return binding
end
str = "hello"
eval "str + ' Fred'"  # => "hello Fred"
eval "str + ' Fred'", get_binding("bye")  # => "bye Fred"

# Phrase: method aliasing
#============================================================
class LoginService
  alias_method :original_login, :login
  def login(user, pass)
    log_event "#{user} logging in"
    original_login(user, pass)
  end
end

# Phrase: [metaprog] Lazy load 
#============================================================
class Object
  def self.lazy_loaded_attr(*attrs)
    attrs.each do |attr|
      define_method(attr) do
        eval "@#{attr} ||= load_#{attr}"
      end
    end
  end
end

class Person
  lazy_loaded_attr :friends, :children, :parents
end

Person.instance_methods(false) # => ["parents", "children", "friends"]
p = Person.new 
def p.load_parents
  ["mama","papa"]
end
p.instance_variables # => []
p.parents # => ["mama", "papa"]
p.instance_variables # => ["@parents"]


# Phrase: [metaprog] my_attr_reader
#============================================================
class Object
  def Object.my_attr_reader(*attrs)
    attrs.each do |attr|
      define_method(attr) do
        instance_variable_get("@#{attr}")
      end
    end
  end
end

class Some
end
Some.instance_methods(false) # => []
class Some
  my_attr_reader :abc, :def
end
Some.instance_methods(false) # => ["def", "abc"]

# Phrase: [metaprog] varidate password field
#============================================================
class SomeBase
  def validate
    result = []
    methods.grep /^validate_/ do |m| 
      result << [m, self.send( m )]
    end
    result
  end
end

class Obj1 < SomeBase
  def initialize(attributes)
    attributes.each do |k,v|
      instance_variable_set "@#{k}", v
    end
  end

  def validate_pass
    instance_variables.grep(/^@.*password/).all? do |iv|
      (instance_variable_get iv).length > 5
    end
  end

  def validate_age
    @age > 18
  end
end

t9md = Obj1.new :name => "t9md", :my_password => "ab", :age => 19
t9md.validate # => [["validate_age", true], ["validate_pass", false]]
yuri= Obj1.new :name => "yuri", :my_password => "abcdefgh", :age => 18
yuri.validate # => [["validate_age", false], ["validate_pass", true]]
ryu= Obj1.new :name => "ryu",:my_password => "abcdefgh",
              :secret_password => "adei", :age => 45
ryu.validate # => [["validate_age", true], ["validate_pass", false]]



# Phrase: [metaprog] instance_variable_get
#============================================================
@event = 'Away Day'
instance_variable_get '@event' # => "Away Day"
instance_variable_set '@region','UK' # => "UK"
@region # => "UK"
instance_variables # => ["@event", "@region"]
'abc'.method(:capitalize) # => #<Method: String#capitalize>


class Person
  def initialize(name, age, sex)
    @name = name
    @aget = age
    @sex = sex
  end
end
Person.new('Faroog', 23, :male) # => #<Person:0x23334 @sex=:male, @aget=23, @name="Faroog">

class Person2
  def initialize(attributes)
    attributes.each do |attr, val|
      instance_variable_set("@#{attr}", val)
    end
  end
end

Person2.new :name => 'Faroog',
            :age  => 23, 
 
# Phrase: [metaprog] singleton method
#============================================================
class Person
  def self.enhance_me(description)
    @desc = description
    metacls.class_eval do
      def introduce_yourself
        "I am a #{self.inspect} #{@desc}"
      end
    end
  end
end

class Programmer < Person
  enhance_me "I write programs"
end

class Mathematician < Person
  enhance_me "I write proofs"
end

Person.singleton_methods() # => ["enhance_me", "metacls"]
Programmer.singleton_methods(false) # => ["introduce_yourself"]
Mathematician.introduce_yourself # => "I am a Mathematician I write proofs"

# Phrase: [metaprog] call method by key and usage of send
#============================================================
class Foo
  def foo() "foo" end
  def bar() "bar" end
  def baz() "baz" end
end

methods = { 1 => :foo,
            2 => :bar,
            3 => :baz}

Foo.new.send(methods[1]) # => "foo"
Foo.new.send(methods[2]) # => "bar"
Foo.new.send(methods[3]) # => "baz"

# Phrase: Metaprogramming
#============================================================
Class.is_a? Object # => true
Class.kind_of? Object # => true

# == `meta class of class` ==
class SomeClass
  def self.whats_this?
    class << self
      self
    end
  end
end
SomeClass.class # => Class
SomeClass.whats_this? # => #<Class:SomeClass>

#== class_eval ==
class Foo
  def bar
    puts "ehhlo worldh"
  end
end
Foo.new.bar # => nil
#>> ehhlo worldh

Foo = Class.new # !> already initialized constant Foo
Foo.class_eval do
  def bar
    puts "ehhlo worldh"
  end
end
Foo.new.bar # => nil
#>> ehhlo worldh 

#== convention over configration ==
class TestSuite
  def run
    self.methods.grep(/^test/).each { |m| send m }
  end
  
  def test_one_thing
    puts "I'm testing one thing"
  end

  def test_another_thing
    puts "I'm testing another thing"
  end

  def test_something
    puts "I'm testing something thing"
  end
end

TestSuite.new.run
    # >> I'm testing one thing
    # >> I'm testing another thing
    # >> I'm testing something thing

#== include hook ==

module Hook1
  def self.included(in_what)
   puts "#{self}: #{in_what.inspect} include Me!!"
  end
end

class Test1; include Hook1; end
class Test2; include Hook1; end
    # >> Hook1: Test1 include Me!!
    # >> Hook1: Test2 include Me!!

#== inherited Hook! ===
class Hook2
  def self.inherited(by_what)
    by_what.inspect # => "Test2"
  end
end
class Test2 < Hook2 ; end

#== Module#method_added
class Parent
  def self.method_added(method_name)
    method_name # => :hello, :world
  end
end

class Test2 < Parent
  def hello; end;
  def world; end;
end

#== MetaClass ==
class Object
  self # => Object

  def self.metacls
    class << self
      self
    end
  end

  def self.return_self;
    self
  end
end

Object.methods(false) # => ["return_self", "metacls"]
Object.return_self    # => Object
Object.class          # => Class
Object.class.class    # => Class
Object.metacls        # => #<Class:Object>
Array.metacls         # => #<Class:Array>
Object.ancestors      # => [Object, Kernel]
Kernel.ancestors      # => [Kernel]
Module.ancestors      # => [Module, Object, Kernel]
Class.ancestors       # => [Class, Module, Object, Kernel]

class Things
  metacls.instance_eval "attr_reader :things"
  # class << self
    # self.instance_eval("attr_reader :things")
  # end
  def self.thing(name, kind)
    thing = Kernel.const_get(kind.to_s.capitalize)
    @things ||= []
    @things << thing.new
  end
  thing :s, :string
  thing :o, :object
  thing :h, :hash
end
Things.methods(false) # => ["thing", "things"]
Things.things  # => ["", #<Object:0x218e0>, {}]
Things.thing :s, :string # => ["", #<Object:0x218e0>, {}, ""]
Things.things  # => ["", #<Object:0x218e0>, {}, ""]

# Phrase: [metaprog] instance_eval and module_eval
#============================================================
class Sample

  metacls.instance_eval "attr_reader :self_at_sample"
  @self_at_sample = self

#------------------------
# instance_eval 
#------------------------
# ブロックが与えられた場合にはそのブロックをオブジェクトのコンテキス
# トで評価してその結果を返します。ブロックの引数 obj には 
# self が渡されます。
# オブジェクトのコンテキストで評価するとは self をそのオブジェ
# クトにして実行するということです。また、文字列／ブロック中でメソッ
# ドを定義すれば self の特異メソッドが定義されます。

  self.instance_eval {
    def hello1
      "hello1: #{self}"
    end 
  }

  instance_eval {
    def hello2
      "hello2: #{self}"
    end
  }

#------------------------
# module_eval
#------------------------
# ブロックが与えられた場合にはそのブロックをモジュールのコンテキスト
# で評価してその結果を返します。ブロックの引数 mod には
# self が渡されます。
# モジュールのコンテキストで評価するとは、実行中そのモジュールが
# self になるということです。つまり、そのモジュールの定義文の
# 中にあるかのように実行されます。
  self.module_eval {
    def mod_hello1
      "mod_hello1: #{self}"
    end
  }
  module_eval {
    def mod_hello2
      "mod_hello2: #{self}"
    end
  }
end

Sample.hello1 # => "hello1: Sample"
Sample.hello2 # => "hello2: Sample"
Sample.singleton_methods(false) # => ["hello2", "self_at_sample", "hello1"]
Sample.new.mod_hello1 # => "mod_hello1: #<Sample:0x1bb84>"
Sample.new.mod_hello2 # => "mod_hello2: #<Sample:0x1b9e0>"
Sample.instance_methods(false) # => ["mod_hello2", "mod_hello1"]
Sample.self_at_sample # => Sample
Sample.metacls # => #<Class:Sample>

# Phrase: [metaprog] instance_variable_get/set
#============================================================
class Foo
  def initialize
    @foo = 1
  end
end
obj = Foo.new
obj.instance_variable_get("@foo") # => 1
obj.instance_variable_set("@foo", 2)  # => 2
obj.instance_variable_get("@foo") # => 2

# Phrase: [metaprog] define methods
#============================================================
class Base
  def self.my_attr(a)
    define_method(a) { instance_variable_get("@#{a.to_s}")}
    define_method("#{a}=") { |val| instance_variable_set("@#{a.to_s}", val )}
  end
end

class Child < Base
  my_attr :x
  def initialize
    @x = 5
  end
end
Child.instance_methods(false) # => ["x", "x="]
c = Child.new
c.x    # => 5
c.x=10 # => 10
c.x    # => 10
c.x=10 # => 10

# Phrase: instance eval class eval metaclass Advanced
#============================================================
## more advanced
class AClass; end

# this define instance meth
AClass.class_eval do
  def instance_meth1; "I'm ins meth1"; end
end
AClass.new.instance_meth1 # => "I'm ins meth1"

# this also define instance meth because class_eval is alias of module_eval
AClass.module_eval do
  def instance_meth2; "I'm ins meth2"; end
end
AClass.new.instance_meth2 # => "I'm ins meth2"

# this define class method of AClass
# instance eval evaluate block with setting `self` to receiver.
# so simple `def` , you can see as self.def, then self is AClass, so Aclass.cls_meth1 is defined
AClass.instance_eval do
  def cls_meth1; "I'm cls meth1"; end
end
AClass.singleton_methods # => ["cls_meth1", "metacls"]
AClass.cls_meth1 # => "I'm cls meth1"

# This is another way of defining class meth
class AClass
  class << self
    def cls_meth2; "I'm cls meth2"; end
  end
end
AClass.singleton_methods # => ["cls_meth1", "metacls", "cls_meth2"]
AClass.singleton_methods(false) # => ["cls_meth1", "cls_meth2"]

AClass.metacls.class_eval do
    def cls_meth4; "I'm cls meth4"; end
end

AClass.singleton_methods(false) # => ["cls_meth1", "cls_meth4", "cls_meth2"]
AClass.cls_meth4 # => "I'm cls meth4"

AClass.metacls.instance_eval do
  def meth_meth; "I'm c!!!ls meth4"; end
end
AClass.metacls.meth_meth # => "I'm c!!!ls meth4"
# AClass.new.meth_meth

AClass.singleton_methods # => ["cls_meth1", "cls_meth4", "metacls", "cls_meth2"]
AClass.singleton_methods(false) # => ["cls_meth1", "cls_meth4", "cls_meth2"]
AClass.ancestors # => [AClass, Object, Kernel]
AClass.cls_meth2 # => "I'm cls meth2"
AClass.cls_meth3 # => 
AClass.cls_meth4 # => 

# Phrase: handle platform dependent setting with 'rbconfig.rb'
#============================================================
require 'rbconfig'
RUBY_VERSION  # => "1.8.7"
include Config
Config.const_get("TOPDIR") # => "/opt/local"
TOPDIR # => "/opt/local"
r = CONFIG.keys.map {|e| "#{e} => #{CONFIG[e]}" }
puts r # => nil

# Phrase: etc module which handle unix /etc/passwd entries as struct
#============================================================
require 'etc'
Etc.getlogin
pwent = Etc.getpwnam(Etc.getlogin)
result = []
# process only method defined in 'Struct::Passwd'
pwent.class.instance_methods(false).each do |meth|
    next if meth =~ /=\z/
        result << "%-10s %-s" % [  meth, pwent.send(meth) ]
end
puts result

# Phrase: Special variable
#============================================================
$" => $LOADED_FEATURES # include finename loaded by require
$: => $LOAD_PATH

# Phrase: write PID to file
#============================================================
pid_file = "#{$0}.pid"
File.unlink pid_file if pid_file
File.open(pid_file, 'w') {|f| f.write Process.pid } if pid_file

# Phrase: Hash
#============================================================
# invert
h = { "n" => 100, "m" => 100, "y" => 300, "d" => 200, "a" => 0 }
h.invert   #=> {200=>"d", 300=>"y", 0=>"a", 100=>"n"}

# Phrase: StringIO sample
#============================================================
def methA(a,b=nil,c=nil)
   [ a, b, c]
end

a = [1,2,3 ]
methA(1,2,3) # => [1, 2, 3]
methA(a)     # => [[1, 2, 3], nil, nil]
methA(*a)    # => [1, 2, 3]

b = [1,2,3,4,5]

def methB(a,b=nil,*c)
   [ a, b, c]
end
methB(b)  # => [[1, 2, 3, 4, 5], nil, []]
methB(*b) # => [1, 2, [3, 4, 5]]
methB(*a) # => [1, 2, [3]]


# Phrase: StringIO sample
#============================================================
# usefull for pasuado IO during test phase.
require 'stringio'
io = StringIO.new
io.puts "ABC"
io.puts "DEF"
io.print "GHI\n\n"
io.print "JKL"
io.string # => "ABC\nDEF\nGHI\n\nJKL"

# Phrase: regexp captures
#============================================================
result = "55 tests, 77 assertions, 3 failures\n"
md = result.match(/\A(\d+) tests, (\d+) assertions, (\d+) failures\Z/)
Regexp.last_match               # => #<MatchData "55 tests, 77 assertions, 3 failures" 1:"55" 2:"77" 3:"3">
md[0]
md[1]
md[2]
md[3]
tests, assertions, failures = md.captures # => ["55", "77", "3"]
md.to_a # => ["55 tests, 77 assertions, 3 failures", "55", "77", "3"]

re = /(.) Status:(?:Success|Failure)/
"o Status:Success".match re # => #<MatchData "o Status:Success" 1:"o">
"F Status:Failure".match re # => #<MatchData "F Status:Failure" 1:"F">

# Phrase: regexp multiline
#============================================================

require 'date'
def parse_crt(str) # !> method redefined; discarding old parse_crt
  regexp = %r<
    ^Serial\sNumber:\s(\d+)\s.+$ # $1: Serial Number
    .*
    ^Issuer:\s.*\sCN=(.*?)$      # $2: Issuer's CN
    .*
    ^Validity$\n
    ^Not\sBefore:\s(.*)$\n       # $3: Valid from
    ^Not\sAfter\s:\s(.*)$\n      # $4: Expire after
    ^Subject:\s.*\sCN=(.*?)$     # $5: Our CN
    .*
  >mx

  str.scan(regexp)
  h = {}
  h["sn"]         = $1
  h["issuer"]     = $2
  h["valid_from"] = DateTime.parse($3).strftime("%Y%m%d")
  h["valid_to"]   = DateTime.parse($4).strftime("%Y%m%d")
  h["subject"]    = $5
  return h

end
crt_str=<<'EOS'
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 84925 (0x14bbd)
        Signature Algorithm: sha1WithRSAEncryption
        Issuer: C=JP, O=Test Company, Ltd., CN=Test CA
        Validity
            Not Before: Jul  1 02:36:09 2010 GMT
            Not After : Jul 31 14:59:00 2011 GMT
        Subject: C=JP, ST=Tokyo, L=Shibuya-ku, O=TEST, OU=TEST, CN=www.example.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
            RSA Public Key: (1024 bit)
                Modulus (1024 bit):
                    00:c0:89:7b:cf:dd:f9:40:14:ff:e4:1f:4f:ec:5b:
EOS
str=crt_str.map{|e| e.strip }.join("\n")
parse_crt(str) # => {"valid_to"=>"20110731", "subject"=>"www.example.com", "issuer"=>"Test CA", "sn"=>"84925", "valid_from"=>"20100701"}
