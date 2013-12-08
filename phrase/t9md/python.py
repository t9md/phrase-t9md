#  Phrase: get directory of current file
# ======================================================================
import os
__dir__ = os.path.dirname(os.path.realpath(__file__))
print __dir__

#  Phrase: myfunc
# ======================================================================
def myfunc(myvar=None):
    if myvar is None:
        myvar = []
    myvar.append("x")
    return myvar
print myfunc(), myfunc()

#  Phrase: # mystr is now "This is wondrous"
# ======================================================================
if txt in mystr[-10:]:
    print "'%s' found in last 10 characters"%txt

# Or use the startswith() and endswith() string methods:
if mystr.startswith(txt):
    print "%s starts with %s."%(mystr, txt)
if mystr.endswith(txt):
    print "%s ends with %s."%(mystr, txt)


#  Phrase: string substring
# ======================================================================
mystr = "This is what you have"
#       +012345678901234567890  Indexing forwards  (left to right)
#        109876543210987654321- Indexing backwards (right to left)
#         note that 0 means 10 or 20, etc. above

first = mystr[0]                            # "T"
start = mystr[5:7]                          # "is"
rest = mystr[13:]                           # "you have"
last = mystr[-1]                            # "e"
end = mystr[-4:]                            # "have"
piece = mystr[-8:-5]                        # "you"
print first
print start
print rest
print last

#  Phrase: GoodCode
# ======================================================================
class TestDriver(driver.Scheduler):
    """Scheduler Driver for Tests"""
    def schedule(context, topic, *args, **kwargs):
        return 'fallback_host'

    def schedule_named_method(context, topic, num):
        return 'named_host'

#  Phrase: utctime
# ======================================================================
import datetime
print (datetime.datetime.utcnow())

# Phrase: uppper string
#======================================================================
def hello(name):
    """docstring for hello"""
    print name

def hello2(name):
    """docstring for hello"""
    print name.upper()

hello("t9md")
hello2("yamamoto")

# Phrase: POST
#======================================================================
def _post(self, params, headers={}):
    """POST to the web form (internal method)."""
    request = urllib2.Request(self.post_url,
                              urllib.urlencode(params),
                              headers)
    try:
        response = urllib2.urlopen(request)
    except IOError, exc:
        response = exc
    return response.code, response.msg

# Phrase: try import library
#======================================================================
try:
    import simplejson as json
except ImportError:
    import json

# Phrase: add lib path
#======================================================================
import sys
print sys.path
mylibpath= "/Users/taqumd/Dropbox/dev/Python/lib"
sys.path.insert(0, mylibpath)
print sys.path

# Phrase: Good Code
#===========================================================
import random
fruit = ['apple', 'pear', 'banana'] 
print random.sample(fruit, 2 )
# print random.sample(fruit)

# Phrase: add lib seach path
#===========================================================
mylibpath= "/Users/taqumd/Dropbox/dev/Python/lib"
sys.path.insert(0, mylibpath)

# Phrase: Lack Of Closure WorkAround
#===========================================================

# clean but not `closed' in independent binding environment.
# means, share scope with two(a and b) function, and could be
# accessed other via counter.count.

def counter():
    counter.count = 0
    def c():
        counter.count += 1
        return counter.count
    return c

a = counter()
b = counter()
print a()
print "===="
print b()

# >> 1
# >> ====
# >> 2

# Phrase: Genka Shoukyaku
#===========================================================
def teigaku(shutoku_kakaku, taiyou_nensu):
    shoukyaku_ritsu_table = { 4: 0.25, 5: 0.20 }
    shoukyaku_ritsu = shoukyaku_ritsu_table[taiyou_nensu]
    zanzon_kakaku = shutoku_kakaku * 0.10
    answer = (shutoku_kakaku - zanzon_kakaku ) * shoukyaku_ritsu
    return answer

pc1 = { "shutoku_kakaku": 500000, "taiyou_nensu": 5 }
zan = pc1['shutoku_kakaku'] - teigaku(**pc1)
zan = pc1['shutoku_kakaku']

# print 500000 * 0.05

gengaku  = teigaku(**pc1)
print "gengaku = ", gengaku

while True:
    zan = zan - gengaku
    if zan <  pc1['shutoku_kakaku'] * 0.05: break
    print zan

# Phrase: Logging
#===========================================================
import logging
import sys

LEVELS = {'debug': logging.DEBUG,
          'info': logging.INFO,
          'warning': logging.WARNING,
          'error': logging.ERROR,
          'critical': logging.CRITICAL}

if len(sys.argv) > 1:
    level_name = sys.argv[1]
    level = LEVELS.get(level_name, logging.NOTSET)
    logging.basicConfig(level=level)

logging.debug('This is a debug message')
logging.info('This is an info message')
logging.warning('This is a warning message')
logging.error('This is an error message')
logging.critical('This is a critical error message')

# Phrase: List slice
#===========================================================
lis =  [ 1,2,3,4,5 ]
print lis

print "## zero_to_one ##"
zero_to_one = slice(0,1)
print lis[0:1]
print lis[zero_to_one]

print "## zero_to_last ##"
zero_to_last = slice(0,-1)
print lis[0:-1]
print lis[zero_to_last]

print "### two_to_end ###"
two_to_end = slice(2,None)
print lis[2:]
print lis[two_to_end]

print "### start_to_three ###"
start_to_three = slice(None, 3)
print lis[:3]
print lis[start_to_three]

'''
### Result ####
[1, 2, 3, 4, 5]
## zero_to_one ##
[1]
[1]
## zero_to_last ##
[1, 2, 3, 4]
[1, 2, 3, 4]
### two_to_end ###
[3, 4, 5]
[3, 4, 5]
### start_to_three ###
[1, 2, 3]
[1, 2, 3]
'''


# Phrase: Simple ScoketServer
#===========================================================
import SocketServer
class hwRequestHandler(SocketServer.StreamRequestHandler):
    def handle(self):
       self.wfile.write("Hello World!\n") 

server = SocketServer.TCPServer(("", 2525), hwRequestHandler)
server.serve_forever()

## Socket Programming
import socket
# TCP IP v6
streamV6Sock = socket.socket( socket.AF_INET6, socket.SOCK_STREAM )
# TCP IP v4
streamV4Sock = socket.socket( socket.AF_INET, socket.SOCK_STREAM )
# UDP
dgramSock = socket.socket( socket.AF_INET, socket.SOCK_DGRAM )
streamSock.close()
del streamSock

print type(streamSock)
print type(dgramSock)


# Socket constants
import socket
solist = [x for x in dir(socket) if x.startswith('SO_')]
solist.sort()
for x in solist:
    print x


# Phrase: with statements
#===========================================================
class Session(object):
    def __init__(self):
        self.dirty = []

    def add(self, data):
        self.dirty.append(data)

    def commit(self):
        """docstring for commit"""
        print "commited %s" % repr(self.dirty)

    def test(self):
        print "hello"
        
class SessionContext():
    def __init__(self, commit=False):
        self._commit  = commit

    def __enter__(self):
        self._session = Session()
        return self._session
    
    def __exit__(self, cls, value, tb):
        if self._commit:
            self._session.commit()

session = SessionContext
with session(commit=True) as s:
    s.add("abc")
    s.add("def")
    s.test()


# Phrase: Pymongo
#===========================================================
import pymongo
from pymongo import Connection

connection = Connection()
# same as bellow
# connection = Connection('localhost', 27017)

db = connection.test_database
collection = db.test_collection
import datetime

post = {
    "author": "Mike",
    "text": "My first blog post!",
    "tags": ["mongodb", "python", "pymongo"],
    "date": datetime.datetime.utcnow()
}
posts = db.posts
posts.insert(post)
db.collection_names()

new_posts = [{"author": "Mike",
  "text": "Another post!",
  "tags": ["bulk", "insert"],
  "date": datetime.datetime(2009, 11, 12, 11, 14)},
 {"author": "Eliot",
  "title": "MongoDB is fun",
  "text": "and pretty easy too!",
  "date": datetime.datetime(2009, 11, 10, 10, 45)}]

posts.insert(new_posts)
# posts.remove({})
for post in posts.find():
    print post

# Phrase: function argment
#===========================================================
def argtest1(arg1, arg2):
    """docstring for argtest"""
    print arg1, arg2

argtest1(1,2)           #=> 1 2
argtest1(2,1)           #=> 2 1
argtest1(arg2=2,arg1=1) #=> 1 2
argtest1(1, arg2=2)     #=> 1 2

def argtest2(arg1, arg2, *arg3, **arg4):
    """docstring for argtest"""
    print arg1, arg2, arg3, arg4

argtest2(1,2)              # => 1 2 () {}
argtest2(1, 2, 3, 4)       # => 1 2 (3, 4) {}
argtest2(1, 2, 3, 4, 5)    # => 1 2 (3, 4, 5) {}
argtest2(1, 2, 3, a=1,b=1) # => 1 2 (3,) {'a': 1, 'b': 1}
argtest2(1, 2, a=1,b=1)    # => 1 2 () {'a': 1, 'b': 1}

# Phrase: Datetime module
#===========================================================
import datetime
now = datetime.datetime.now()
print "%s-%s-%s" % (now.year, now.month, now.day)


# Phrase: Pygments
#===========================================================
from pygments import highlight
from pygments.lexers import PythonLexer
from pygments.formatters import TerminalFormatter

code = 'print "Hello World"'
print highlight(code, PythonLexer(), TerminalFormatter())

# var = ['manni', 'perldoc', 'borland', 'colorful', 'default', 'murphy', 'trac',
# 'fruity', 'autumn', 'emacs', 'pastie', 'friendly', 'native']
# # SIZE = ' style="font-size: 14pt"'
# STYLE = var[4]
# print STYLE
# # TERM_STYLE = "font-size: 14pt; background: black; color: white"
# CSS = HtmlFormatter(style=STYLE).get_style_defs('.highlight')

# css_out = open("./highlight.css","w")
# css_out.write(CSS) 

# Phrase: twisted xmlrpc
#===========================================================
from twisted.web.xmlrpc import Proxy
from twisted.internet import reactor

class Snipplr(object):
    """docstring for Snipplr"""
    api_key = None
    proxy = Proxy('http://snipplr.com/xml-rpc.php')

    def __init__(self):
        super(Snipplr, self).__init__()
        
    def printValue(self,value):
        for sni in value: print sni
        # print len(value)
        reactor.stop()

    def printError(self,error):
        print 'error', error
        reactor.stop()

    def _call(self,api, *arg):
        """docstring for call"""
        self.proxy.callRemote(api, *arg).addCallbacks(self.printValue, self.printError)
        return reactor.run()

    def get(self, id):
        self._call('snippet.get', id)

    def list(self):
        self._call('snippet.list', self.api_key)

snipplr=Snipplr()
snipplr.api_key = open('/Users/taqumd/.snipplr/api_key').read().strip()
snipplr.get(43966)
# snipplr.list()
# snippet_id = 43966

# Phrase: module importing and __all__
#===========================================================
# __all__ is special touple, when you import this module
# with 'from thismod import *' declared in __all__ will exposed to
# importing scope.
__all__ = (
    'var', 
    '_var'
)
var = 1
# variable start with '_' is usually not exporsed by import *.
# unless it is explicitly declared in __all__ tuple
_var = 10

# Phrase: @staticmethod, @classmethod, @property
#===========================================================
class Dog2(object):
    def wag(self):
        return 'instance wag'

    def bark(self):
        return "instance bark"

    def growl(self):
        return "instance growl"

    @staticmethod
    def bark():
        return "staticmethod bark, arg: None"

    @classmethod
    def growl(cls):
        return "classmethod growl, arg: cls=" + cls.__name__                 

    @property
    def gao(self):
        return "Gaoo!!"

print Dog2.bark()
print Dog2.growl()
dog = Dog2()
# @classmethod and @staticmethod is not independent of instance method.
# so instance method have same name is hidden.

# Once you make goo() 'property' original way of calling via goo() is not effect.
# because goo return 'Goo!!' string so not callable.
# print dog.gao() 
print dog.gao

# Phrase: Appscript
#===========================================================
import appscript
# key = appscript.k
# iTerm = appscript.app('iTerm')
# iTerm.current_terminal.sessions.write(text='ls')
# iTerm.activate()
# appscript.app('System Events').keystroke('l', using=key.control_down)
# MacVim = appscript.app('MacVim')
# MacVim.activate()

class ITerm(object):
    """docstring for ITerm"""
    def __init__(self):
        super(ITerm, self).__init__()
        self.app = appscript.app('iTerm')

    def write(self, cmd):
        self.app.current_terminal.sessions.write(text=cmd)

    def special_key(self, key, using=None):
        """send non printable key
        
        using is list of special key like:
        ['control_down', 'command_down', 'option_down']
        """
        sp_keys = [ getattr(appscript.k, sp_key) for sp_key in using if hasattr(appscript.k, sp_key) ]
        appscript.app('System Events').keystroke(key , using=sp_keys)


    def activate(self):
        self.app.activate()
        
iTerm=ITerm()
# iTerm.activate()
iTerm.write('ls')
iTerm.activate()
iTerm.special_key('l', using=['control_down'])
MacVim = appscript.app('MacVim').activate()

# appscript.app('iTerm').current_terminal.sessions.write(text='ls')
# appscript.app('iTerm').activate()
# appscript.app('System Events').keystroke('l', using=key.control_down)
# MacVim = appscript.app('MacVim')

# Phrase: Iterator mechanism
#===========================================================
import random
fruit = ['apple', 'pear', 'banana'] 
print random.choice(fruit)

fruit = ['apple', 'pear', 'banana'] 
print random.sample(fruit, 2 )
# print random.sample(fruit)

# Phrase: Exception handling
import sys
import urllib
import os
print os.getcwd()
os.chdir('/etc')
print os.getcwd()

api_key_file = os.path.expanduser("~/.snipplr/api_key")
# print sys.__dict__.keys()
# print urllib.__dict__.keys()
# print os.__dict__.keys()

def head(arg): print "Iterator " +  "=" * 40

head("Generator Expression")
print sum(i*i for i in range(10)) 
print [ i*i for i in range(10) ]

head("Generator")
def reverse(data):
    for index in range(len(data)-1, -1, -1):
        yield data[index]

for ch in reversed('golf'): print ch,

print '-' * 10

def each_with_index(lis):
  i = 0
  while i < len(lis):
      yield i, lis[i]
      i+=1
  raise StopIteration

for idx, e in each_with_index(range(1,5)):
  print idx, e

print '-' * 10
for idx, e in enumerate(range(1,5)):
  print idx, e

head("Iterator")
"""
イテレータ: for の背後で何が起こっているか？
iter() がCollectionに対して呼ばれる。
iter() がCollectionに対して呼ばれると、__iter__ が呼ばれる。
__iter__ は next() メソッドを持つオブジェクトを返さなければならない。
コレクションの要素を一つずつ得る為に、iter() で得られたオブジェクトの
next() を呼んで、コレクションから要素を取り出す。
要素がなくなった事は、StopIteration 例外で判断するので、next()
は要素がなくなった時、StopIteration 例外を発生させるよう実装しなければならない。
"""

class Reverse(object):
  """docstring for Reverse"""
  def __init__(self, data):
    self.data = data
    self.index = len(data)
  def __iter__(self):
    print "Called!!"
    return self
  def next(self):
    if self.index == 0:
      raise StopIteration
    self.index = self.index - 1
    return self.data[self.index]


obj = Reverse('abcdefg')
itr = iter(obj) # => Called!!

print (itr is obj) # => True
print type(itr) # => <class '__main__.Reverse'>
print type(obj) # => <class '__main__.Reverse'>
for o in [obj, itr, obj, itr]: print o.next(),
# => g f e d
print

# print obj.next()
# print obj.next()
# print obj.next()

# li = [ char.upper() for char in Reverse('abcdefg') ]
# print li
    
head("Iterator")
s = 'abc'
it = iter(s)
print dir(it)

print it.next()
print it.next()
print it.next()

try:
  print it.next()
except StopIteration, e:
  print "No more data"
print "=" * 60

class MyClass(object):
  """docstring for MyClass"""
  def __init__(self):
    super(MyClass, self).__init__()

  i = 12345
  def f(self):
    return "hello world %s" % self.name

print MyClass.i
a = MyClass()
a.name="a"
print a.f()
a.name="A"
print a.f()
print MyClass.f(a)
print "=" * 60
b = MyClass()
b.name = "b"
print MyClass.f(b)
print MyClass.__doc__
print b.__doc__

print "=" * 60
xf = a.f
a.name="CHANGED!!"
a.f = "a"
a.__f = "j"
print a.__f
print a.f
print xf()

print "=" * 60
for element in [1, 2, 3] : print element,
print
for element in (1, 2, 3) : print element,
print
for key in {'one':1, 'two':2}: print key,
print
for char in "123": print char,
# for line in open("myfile.txt"): print line

# Phrase: Random
#===========================================================
import random
fruit = ['apple', 'pear', 'banana'] 
print random.choice(fruit)
print random.choice(fruit)
print random.choice(fruit)

fruit = ['apple', 'pear', 'banana'] 
print random.sample(fruit, 2 )

# Phrase: Exception handling
#===========================================================
class AnswerNotAnticipated(Exception): pass
class AnswerRejected(AnswerNotAnticipated): pass
class AnswerEmpty(AnswerNotAnticipated): pass

def meth_1(arg):
  if len(arg) == 0:
    raise AnswerEmpty("empty! why!?")

  if arg.lower() not in ["yes", "ok"]:
    raise AnswerEmpty("You rejected why!?.")

  print "Thank you! for your acception"

print "=" * 50
meth_1("OK")
meth_1("yes")

print "=" * 50
try:
  meth_1("")
except AnswerNotAnticipated, e:
  print "Error :", e

print "=" * 50
try:
  meth_1("no")
except AnswerNotAnticipated, e:
  print "Error :", e

print "=" * 50
try:
  meth_1("no")
except AnswerNotAnticipated, e:
  print "Error :", e

# Phrase: Argument check
#===========================================================
# Same
def check(opt):
  if   opt.type.upper() == "GET": print "GET"
  elif opt.type.upper() == "POST": print "POST"
  else: print  "ERROR"

check(Opt('get'))
check(Opt('post'))
check(Opt('delete'))
print "*" * 25

# Same
def check2(opt):
  if opt.type.upper() in ( 'GET', 'POST' ): print "OK"
  else: print "ERROR"

print "*" * 25
check2(Opt('get'))
check2(Opt('post'))
check2(Opt('delete'))

# Phrase: Sort
#===========================================================
student_tuples = [
        ('john', 'A', 15),
        ('jane', 'B', 12),
        ('dave', 'B', 10),
        ]
# sort by higher score
print sorted(student_tuples, key=lambda student: student[2], reverse=True)

# Phrase: basic
#===========================================================
# show all builtins va
for key, val in (vars(__builtins__)).items():
    print "%-10s => %s\n%10s" % (key, val, getattr(__builtins__, key).__doc__)

# dir() は名前を表示する。
# var() はdict をかえす。
# 名前空間は辞書で実装されている。
# globals() はグローバル名前空間を返す。
# locals() はローカル名前空間を返す。

ipython
help()
modules
 # => モジュール一覧
keywords
 # => キーワードをリスト

# オブジェクトIDを得る
id()

app_root = os.path.dirname(os.path.abspath(__file__))
app_root = os.path.basename(os.path.abspath(__file__))

if os.path.isfile(db_path): os.remove(db_path)
sys.stderr.write('Warning, log file not found starting a new one\n') 
import re 
re.findall(r'\bf[a-z]*', 'which foot or hand fell fastest') 

lis = [ n * n for n in range(5) ]
print lis
# => [0, 1, 4, 9, 16]

for i,v in enumerate(lis): print "[%s] %s" % (i, v)
# => 
# [0] 0
# [1] 1
# [2] 4
# [3] 9
# [4] 16

# Phrase: File IO
#===========================================================
fin = None                      # init fin (so cleanup will not throw)
fout = None                     # init fout for same reason
try:                            # file IO is "dangerous"
  fin = open("input.txt","r")   # open input.txt, mode as in c fopen
  fout = open("output.txt","w") # open output.txt, mode as in c fopen
  # first = fin.readline()        # read line with "\n" at end, "" (False) on EOF
  for line in fin:              # implements iterator interface (readline loop)
    fout.write(line)            # writes a string to a file
except IOError, e:              # catch IOErrors, e is the instance
  print "Error in file IO: ", e # print exception info if thrown
if fin: fin.close()             # cleanup, close fin only if open (not None)
if fout: fout.close()           # cleanup, close fout only if open (not None)

# read binary records from a file
from struct import *            # needed for struct.unpack function
fin = None                      # init fin (so cleanup will not throw)
try:                            # file IO is "dangerous"
  fin = open("input.bin","rb")  # open input.bin in binary read mode
  s = f.read(8)                 # read 8 bytes (or less) into a string
  while (len(s) == 8):          # continue as long as we have full records
    x,y,z = unpack(">HH<L", s)  # parse 2 big-end ushorts, 1 little-end ulong
    print "Read record: " \     # print a long line
      "%04x %04x %08x"%(x,y,z)  # formatting similar to c printf
    s = f.read(8)               # read another record
except IOError:                 # catch IOErrors, no instance
  pass                          # just continue on problem
if fin: fin.close()             # cleanup, close fin only if open (not None)

# print a line without automatic new-line at end
print "without a new line",

# read entire file to memory at once
data = fin.read()

# format strings sprintf-style (% is a basic property of any str)
s = "%s has %d eyes" % (name,2)

# serialize and deserialize complex objects into files
import pickle                   # needed for serialization logic
ages = {"ron":18,"ted":21}      # create a complex data structure
pickle.dump(ages,fout)          # serialize the map into a writable file
ages = pickle.load(fin)         # deserialize the map from a readable file

# navigating the file system and listing files (dir modules for more info)
import os                       # needed for basic OS interaction
print os.getcwd()               # get current directory
os.chdir('..')                  # change current directory
import glob                     # needed for file globbing with wildcards
lst = glob.glob('*.txt')        # get a list of files according to wildcard
import shutil                   # needed for file management tasks
shutil.copyfile('a.py','a.bak') # copy a file from source to destination

# Phrase: Regexp recipe
#===========================================================
# matching (actually searching since match checks beginning only)
c = 'Someone, call 911.'          # the string we want to match upon
mo = re.search(r'call',c)         # mo is a match obj instance (or None)
s = mo.group(0)                   # s is 'call' - entire matched string
t = mo.span(0)                    # t is (9,13) - tuple of (start,end) pos
mo = re.search(r'Some(...)',c)    # mo is a match obj instance (or None)
s = mo.group(1)                   # s is 'one' - mo.group(0) is 'Someone'
t = mo.groups()                   # t is ('one') - tuple of mo.group from 1 up
t = mo.span(1)                    # t is (4,7) - mo.span(0) is (0,7)
# global matching (get all found, like /g in perl)
i = re.finditer(r'.o.',c)         # i is an iterator of all mo found
for mo in i: print mo.group(0)    # will print 'Som' 'eon'
l = re.findall(r'.o.',c)          # l is ['Som','eon'] - without mo, just strs
l = re.findall(r'o(.)(.)',c)      # l is [('m','e'),('n','e')] - groups are ok

# substituting
g = "hello world"                 # the string we want to replace in
g = re.sub(r'hello','world',g)    # g is now 'goodbye world'

# splitting
l = re.split(r'\W+',c)          # l is ['Someone','call','911','']
l = re.split(r'(\W+)',c)        # l is ['Someone',', ','call',' ','911','.','']

# pattern syntax (to make things short g0 is retval.group(0), g1 is group(1))
re.search(r'c.11',c)       # . is anything but \n, g0 is 'call'
re.search(r'c.11',c,re.S)  # S is singe-line, . will include \n, g0 is 'call'
re.search(r'911\.',c)      # \ escapes metachars {}[]()^$.|*+?\, g0 is '911.'
re.search(r'o..',c)        # matches earliest, g0 is 'ome'
re.search(r'g?one',c)      # ? is 0 or 1 times, g0 is 'one'
re.search(r'cal+',c)       # + is 1 or more times, g0 is 'call', * for 0 or more
re.search(r'cal{2}',c)     # {2} is exactly 2 times, g0 is 'call'
re.search(r'cal{0,3}',c)   # {0,3} is 0 to 3 times, g0 is 'call', {2,} for >= 2
re.search(r'S.*o',c)       # matches are greedy, g0 is 'Someo'
re.search(r'S.*?o',c)      # ? makes match non-greedy, g0 is 'So'
re.search(r'^.o',c)        # ^ must match beginning of line, g0 is 'So'
re.search(r'....$',c)      # $ must match end of line, g0 is '911.'
re.search(r'9[012-9a-z]',c)# one of the letters in [...], g0 is '91'
re.search(r'.o[^m]',c)     # none of the letters in [^...], g0 is 'eon'
re.search(r'\d*',c)        # \d is digit, g0 is '911'
re.search(r'S\w*',c)       # \w is word [a-zA-Z0-9_], g0 is 'Someone'
re.search(r'..e\b',c)      # \b is word boundry, g0 is 'one', \B for non-boundry
re.search(r' \D...',c)     # \D is non-digit, g0 is ' call', \W for non-word
re.search(r'\s.*\s',c)     # \s is whitespace char [\t\n ], g0 is ' call '
re.search(r'\x39\x31+',c)  # \x is hex byte, g0 is '911'
re.search(r'Some(.*),',c)  # (...) extracts, g1 is 'one', g0 is 'Someone,'
re.search(r'e(one|two)',c) # | means or, g0 is 'eone', g1 is 'one'
re.search(r'e(?:one|tw)',c)# (?:...) does not extract, g0 is 'eone', g1 is None
re.search(r'(.)..\1',c)    # \1 is memory of first brackets, g0 is 'omeo'
re.search(r'some',c,re.I)  # I is case-insensitive, g0 is 'Some'
re.search(r'^Some',c,re.M) # M is multi-line, ^ will match start of each line

# Phrase: Class with special method
#===========================================================
class MyVector(object):
  """A simple vector class."""
  num_created = 0               # static member, initialized to 0
  def __init__(self,x=0,y=0):   # 
    self.__x = x                # create members by placing variables on self
    self.__y = y                # __ variable prefix indicated private variable
    MyVector.num_created += 1   # update the static variable
  def get_size(self):           # all methods must accept the self argument
    return self.__x+self.__y
  @staticmethod                 # static methods added only in new versions
  def get_num_created():        #  with decorator @staticmethod (no self needed)
    return MyVector.num_created
  def __repr__(self):         # called by repr() func for string representation
    return "MyVector("+repr(self.__x)+","+repr(self.__y)+")"
  def __str__(self):          # called by print() when obj is printed
    return "vector with coords ("+repr(self.__x)+","+repr(self.__y)+")"
  def __cmp__(self,other):    # obj comparison (<>==), retval similar to strcmp
    return (self.get_size() - other.get_size())
  def __nonzero__(self):      # bool() truth value testing
    if (self.get_size()>0): return True
    else: return False
  def __add__(self,other):    # implement + operator for object
    return MyVector(self.__x+other.__x,self.__y+other.__y)

print MyVector.num_created      # access static variables
v = MyVector()                  # create a vector with default values
w = MyVector(0.23,0.98)         # create a vector with given values
# usage
print repr(v)
print w
if w > v: print "w is bigger"
if not v: print "v is False"
print v+w

# Phrase: Code investigate
#===========================================================
def sum_3(a,b=False,*c,**d):
    pass

def func_code_diag(f):
    for attr in dir(f.func_code):
        print attr.ljust(50,'-')
        print eval("%s.func_code.%s" % (f.__name__, attr))
        print

def obj_diag(o):
    for attr in dir(o):
        print attr.ljust(50,'-')
        print eval("%s.%s" % (o.__name__, attr))
        print

# print sum_3.__name__
# obj_diag(sum_3)
# print sum_3.func_name
# print sum_3.func_doc
# func_code_diag(sum_3)
# print sum_3.func_code.co_varnames
# print sum_3.func_code.co_filename
# print sum_3.func_code.co_nlocals
# print sum_3.func_code.co_stacksize
# print sum_3.func_code.co_flags
# print sum_3.func_code.co_codestring
# print sum_3.func_code.co_constants
# print sum_3.func_code.co_names
print sum_3.func_code.co_varnames
print sum_3.func_code.co_argcount
print sum_3.func_code.co_filename
print sum_3.func_code.co_name
# print sum_3.func_code.co_firstlineno


# Phrase: Decorator and higher order function
#===========================================================
############################################
## Setup
############################################
# function which return newley created function
def gen_seq_transformer(f):
    """
    Take trans function as argment
    and return newley created function which
    take sequence as argment.
    and call function to each element in sequence
    """
    def transformer(l):
        new_seq = [ f(line) for line in l]
        return new_seq
    return transformer

# Target Data
org = ["abc", "def", "efg", "hij", "klm"]
############################################
print "== Primitive higher order function" + "=" * 10
# 1. apply uppper() to all element in sequence
upper_list = gen_seq_transformer(lambda x: x.upper())
print upper_list(org)

# 2. apply lower() to all element in sequence
lower_list = gen_seq_transformer(lambda x: x.lower())
print lower_list(ret)
# => ['abc', 'def', 'efg', 'hij', 'klm']

# 3. apply list() to all element in sequence
print gen_seq_transformer(list)(org)

# 4. apply len() to all element in sequence
print gen_seq_transformer(len)(org)

""" Result:
== Primitive higher order function==========
['ABC', 'DEF', 'EFG', 'HIJ', 'KLM']
['abc', 'def', 'efg', 'hij', 'klm']
[['a', 'b', 'c'], ['d', 'e', 'f'], ['e', 'f', 'g'], ['h', 'i', 'j'], ['k', 'l', 'm']]
[3, 3, 3, 3, 3]
"""
############################################
# Decorator Version
############################################
print "== Decorator Version " + "=" * 10
org = ["abc", "def", "efg", "hij", "klm"]

# 1. apply uppper() to all element in sequence
@gen_seq_transformer
def transform_upper(l): return l.upper()
print transform_upper(org)

# 2. apply lower() to all element in sequence
@gen_seq_transformer
def transform_lower(l): return l.lower()
print transform_lower(org)

# 3. apply list() to all element in sequence
@gen_seq_transformer
def transform_list(l): return list(l)
print transform_list(org)

# 4. apply len() to all element in sequence
@gen_seq_transformer
def transform_len(l): return len(l)
print transform_len(org)

""" Result:
== Decorator Version ==========
['ABC', 'DEF', 'EFG', 'HIJ', 'KLM']
['abc', 'def', 'efg', 'hij', 'klm']
[['a', 'b', 'c'], ['d', 'e', 'f'], ['e', 'f', 'g'], ['h', 'i', 'j'], ['k', 'l', 'm']]
[3, 3, 3, 3, 3]
"""
# Phrase: Remove duplicates from Lists
#===========================================================
# http://kogs-www.informatik.uni-hamburg.de/~meine/python_tricks
def distinct_1(l):
  return dict.fromkeys(l).keys()

def distinct_2(l):
  return list(set(l))

a=[ "a",1,"a",10,1,55 ]
b=("a",1,"a",10,1,55)

print (distinct_1(a) == distinct_1(b) == distinct_2(a) == distinct_2(b))
# => True

print distinct_1(a) # => ['a', 1, 10, 55]
print distinct_1(b) # => ['a', 1, 10, 55]

print distinct_2(a) # => ['a', 1, 10, 55]
print distinct_2(b) # => ['a', 1, 10, 55]

# Phrase: lambda example
#===========================================================
def make_incrementor(n):
  return lambda x: x + n

f = make_incrementor(42)
print f    # => <function <lambda> at 0x662f0>
print f(0) # => 42
print f(1) # => 43

# Phrase: List comprehension
#===========================================================
# this
cmd_list = [ select_all_buffer, buffer_length, clear_buffer ]
return [ "%-20s %-10s" % (cmd.__name__, cmd.__doc__) for cmd in cmd_list]

# and this is 'same meaning'
result = []
for cmd in cmd_list:
  result.append("%-20s %-10s" % (cmd.__name__, cmd.__doc__))
  return result

freshfruit = [" bannana ", " loganberry ", " passion fruit   "]
print [weapon.strip() for weapon in freshfruit]
# => ['bannana', 'loganberry', 'passion fruit']

vec = [ 2, 4, 6 ]
[ 3*x for x in vec ]
# => [6, 12, 18]

[ 3*x for x in vec if x  > 3]
# => [12, 18]

[[x,x**2] for x in vec]
# => [[2, 4], [4, 16], [6, 36]]

[(x, x**2) for x in vec]
# => [(2, 4), (4, 16), (6, 36)]

range(1,6) # => [1, 2, 3, 4, 5]
[str(round(355/113.0, i)) for i in range(1,6)]
# => ['3.1', '3.14', '3.142', '3.1416', '3.14159']

# Phrase: String format
#===========================================================
a = 100
b = -200

print "Hello! %d" % a
# タプル
print "Hello! %d %d" % (a, b)
# マップオブジェクト
print "Hello! %(hoge)d %(piyo)d" % {'hoge':a, 'piyo':b}
# 幅の指定
print "Hello! %10d %10d" % (a, b)
# 精度の指定
print "Hello! %10.2f %10.2f" % (a, b)
# 0 で数値の左を埋める
print "Hello! %010d %010d" % (a, b)
# 左寄せ
print "Hello! %-10d %-10d" % (a, b)
# 符号をつける
print "Hello! %+10d %+10d" % (a, b)

# Phrase: Idiom
#===========================================================
# http://bayes.colorado.edu/PythonIdioms.html

# This idiom is called DSU for 'decorate-sort-undecorate.' In the 'decorate'
# step, make a list of tuples containing (transformed_value, second_key, ... ,
# original value). In the 'sort' step, use the built-in sort on the tuples. In
# the 'undecorate' step, retrieve the original list in the sorted order by
# extracting the last item from each tuple. For example:
#
aux_list = [(i.Count, i.Name, ... i) for i in items]
aux_list.sort()    #sorts by Count, then Name, ... , then by item itself
sorted_list = [i[-1] for i in items] #extracts last item
		

# Ruby's each_with_index
data = ["a", "b", "c", "d", "e", "f"]
for data, index in zip(data, xrange(len(list))):
  print [index, data]


# Catch errors rather than avoiding them to avoid cluttering your code with
# special cases. This idiom is called EAFP ('easier to ask forgiveness than
# permission'), as opposed to LBYL ('look before you leap'). This often makes
# the code more readable. For example:

#Worse:
#check whether int conversion will raise an error
if not isinstance(s, str) or not s.isdigit:
  return None
elif len(s) > 10:    #too many digits for int conversion
  return None
else:
  return int(str)

#Better:
try:
  return int(str)
except (TypeError, ValueError, OverflowError): #int conversion failed
  return None


while 1:
    curr_line = reader.next()
    if not curr_line:
        break
    curr_line.process()

# sort
list = [1, 9, 3, 8, 200, 10, 40, 189]
for i in reversed(sorted(list)):
  print i


# fp = open("/etc/hosts")

#############################
# BAD: deprecated
#############################
# for line in fp.readlines():
  # print line.rstrip()

#############################
# Better
#############################
# for line in fp:
#   print line.rstrip()

#############################
# Why:
#############################
def print_lines(lines):
  for line in lines:
    print line.rstrip()

# both works!
print_lines(["This", "is", "the", "List", "of", "String"])
print_lines(open("/etc/hosts"))

# Phrase: String interporation
#===========================================================
from os import system
food = 'spam'
system('echo %(food)s' % locals())

# read result
ret = os.popen("ls -l ").read()
print ret

# get result as list and count the length => number of file in dir.
ret = os.popen("ls").read().split("\n")
len(ret) # get num of file

# Phrase: Basic
#===========================================================
for needle in [1,2,3,4,5]:
  print needle

list = [1,2,3,4,5]
list.pop() # => 5
list.pop(0) # => 1

# Phrase: vim
#===========================================================
vim.current.line
vim.current.buffer
vim.current.window
vim.current.range

# delete range of 1-5
del cb().range(1,5)[:]

# Phrase: Version Check
#===========================================================
import sys
if sys.version_info < (2, 4):
    raise "must use python 2.5 or greater"
else:
    # syntax error in 2.4, ok in 2.5
    x = 1 if True else 2
    print x

