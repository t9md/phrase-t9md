" Phrase: input dialog
"======================================================================
let answer = inputdialog("???")
echo answer

" Phrase: Unite source example
"======================================================================
" Unite source lines {{{
" Ref: http://vim-users.jp/2011/01/hack197/
" Ref: http://d.hatena.ne.jp/thinca/20101105/1288896674
let s:unite_source = {}
let s:unite_source.name = 'lines'
function! s:unite_source.gather_candidates(args, context)
  let path = expand('%:p')
  let lines = getbufline('%', 1, '$')
  let format = '%' . strlen(len(lines)) . 'd: %s'
  return map(lines, '{
  \   "word": printf(format, v:key + 1, v:val),
  \   "source": "lines",
  \   "kind": "jump_list",
  \   "action__path": path,
  \   "action__line": v:key + 1,
  \ }')
endfunction

" Register_Unite_sources:
" ---------------------------------------
"   Method1: call define_sources directly
call unite#define_source(s:unite_source)
unlet s:unite_source

"   Method2: place above to &rtp/autoload/unite/sources/lines.vim
function! unite#sources#lines#define() "{{{
  return s:unite_source
endfunction "}}}
" }}}

" Phrase: black hole
"======================================================================
silent normal! gg"_dG

" Phrase: redir
"======================================================================
let result = ''
try
  redir => result
  for cmd in a:000
    silent execute cmd
  endfor
finally
  redir END
endtry

" Phrase: Basic
"======================================================================
" filter example
let lis = [ 1, 2, 3, 4, 5]
echo filter(copy(lis),"v:val % 2")
echo filter(lis,"v:val % 2 == 0")

set number  " set 1
set number! " Toggle
set number& " revert to defalt

" 作業用バッファ
" バッファが表示されなくなった時,隠す
setlocal  bufhidden=hide    buftype=nofile noswapfile nobuflisted
" バッファが表示されなくなった時, 内容を消す
setlocal  bufhidden=delete  buftype=nofile noswapfile nobuflisted
" バッファが表示されなくなった時, 内容を消す。変更も不可
setlocal  bufhidden=delete  buftype=nofile noswapfile nobuflisted nomodifiable

" Phrase: color echo
"======================================================================
echohl Function
echo "MSG"
echohl Normal

" Phrase: Good keymap
"===========================================================
"-----------------------------------------------------------------
" 1. not good
"-----------------------------------------------------------------
nnoremap          tt  <C-]>
nnoremap <silent> tn  :<C-u>tag<CR>
nnoremap <silent> tp  :<C-u>pop<CR>
nnoremap <silent> tl  :<C-u>tags<CR>

"-----------------------------------------------------------------
" 2. good
"-----------------------------------------------------------------

nnoremap          [tag]   <Nop>
nmap              t       [tag]
nnoremap          [tag]t  <C-]>
nnoremap <silent> [tag]n  :<C-u>tag<CR>
nnoremap <silent> [tag]p  :<C-u>pop<CR>
nnoremap <silent> [tag]l  :<C-u>tags<CR>
nnoremap [t    :echo "but you have to wait! til &timeout"<CR>

"-----------------------------------------------------------------
" 3. best
"-----------------------------------------------------------------

nnoremap     <SID>[tag]        <Nop>
nmap              t            <SID>[tag]
nnoremap          <SID>[tag]t  <C-]>
nnoremap <silent> <SID>[tag]n  :<C-u>tag<CR>
nnoremap <silent> <SID>[tag]p  :<C-u>pop<CR>
nnoremap <silent> <SID>[tag]l  :<C-u>tags<CR>
nnoremap [t    :echo "but you have to wait! til &timeout"<CR>

"-----------------------------------------------------------------

" Phrase: rb-appscript
"===========================================================
ruby << ENDRUBY
require 'rubygems'
require 'appscript'
ENDRUBY

fun! ITermWrite(cmd)
  ruby Appscript.app('iTerm').current_terminal.sessions.write(:text => VIM::evaluate('a:cmd'))
endfun

" Phrase: Python Interface
"===========================================================
fun! PyDelLines(start,end)
python << EOF
cb = vim.current.buffer
start = int(vim.eval('a:start'))
end = int(vim.eval('a:end'))
del cb[start:end]
EOF
endfun
nnoremap <buffer> <F6> :call PyTest()<CR>

" Phrase: expand()
"============================================================
echo expand("%")     | "file base name 'hoge.vim'
echo expand("%:p")   | "filename (full path) '/home/hoge/hoge.vim
echo expand("%:p:h") | "dirname
echo expand("%:p:t") | "basename
echo expand("%:p:e") | "extname
echo expand("%:p:r") | "delete extention '/home/hoge/hoge

" Phrase: OOP Style Array implementation
"============================================================
let s:m = {}
fun! s:m.shift()
	return remove(self.data, 0)
endfun

fun! s:m.unshift(val)
	return insert(self.data, a:val, 0)
endfun

fun! s:m.pop()
	return remove(self.data, -1)
endfun

fun! s:m.push(val)
	return add(self.data, a:val)
endfun

fun! s:m.concat(ary)
	return extend(self.data, a:ary)
endfun

let Array = {}
fun! Array.new(data)
	let obj = {}
	let obj.data = a:data
	call extend(obj, s:m, 'error')
	return obj
endfun

echo "-setup--"
let a = Array.new(range(5))
echo a.data
echo "-shift--"
echo a.shift()
echo a.data
echo "-shift--"
echo a.shift()
echo a.data
echo "-pop--"
echo a.pop()
echo a.data
echo "-unshift--"
call a.unshift(99)
echo a.data
echo "-push--"
call a.push(99)
echo a.data
echo "-push-2-"
call a.push([99])
echo a.data
echo "-concat--"
call a.concat([1,2,3,4])
echo a.data
finish

" Phrase: SaveExcursion
"============================================================
fun! g:SaveExcursion(fun)
let win_saved = winsaveview()
let org_win = winnr()
let org_buf = bufnr('%')

try
  let result = a:fun.call()
finally
  if (winnr() != org_win)| execute org_win . "wincmd w"  | endif
  if (bufnr('%') != org_buf)| edit #| endif
  call winrestview(win_saved)
endtry

return result
endfun

fun! PasteToTarget()

let fun = {}
fun! fun.call()
  call g:Pm.next_mark()
  normal P`[V`]
  redraw!
  sleep 500m
  normal <Esc>
endfun

call g:SaveExcursion(fun)
endfun

" Phrase: Object copy(), deepcopy()
"============================================================
echo "------------------"
echo "not copy()"
echo "------------------"
let list_0 = [1,2,3,4,5]
let list_1 = list_0
let list_1[0] = 99
echo list_0 
" => [99, 2, 3, 4, 5]
echo list_1
" => [99, 2, 3, 4, 5]

echo "------------------"
echo "copy()"
echo "------------------"
unlet! list_0
unlet! list_1
let list_0 = [[0],[1],2,3,4,5]
let list_1 = copy(list_0)
let list_1[0] = []
call insert(list_1[1], 99)
echo list_0
" => [[0], [99, 1], 2, 3, 4, 5]
echo list_1
" => [[], [99, 1], 2, 3, 4, 5]

echo "------------------"
echo "deepcopy()"
echo "------------------"
unlet! list_0
unlet! list_1
let list_0 = [[0],[1],2,3,4,5]
let list_1 = deepcopy(list_0)
let list_1[0] = []
call insert(list_1[1], 99)
echo list_0
" => [[0], [1], 2, 3, 4, 5]
echo list_1
" => [[], [99, 1], 2, 3, 4, 5]

" Phrase: Get visually selected text from function
"============================================================
" The best way I found was to paste the selection into a register:

function! lh#visual#selection()
  try
    let a_save = @a
    normal! gv"ay
    return @a
  finally
    let @a = a_save
  endtry
endfunction

" Phrase: Higher order function
"============================================================
function! E(msg)
  echo "".a:msg
endfunction
command! -nargs=* E :call E(<q-args>)

let U = {}
function! U.createTypeCheckerFor(type)
  let checker = {'type': a:type }
  fun! checker.check(type) dict
    return (type(a:type) == type(self.type))
  endfun
  return checker
endfunction

let IsArray = U.createTypeCheckerFor([])
let IsDictionary = U.createTypeCheckerFor({})
let IsString = U.createTypeCheckerFor("")

unlet! target
for target in ["", [], {}]
  echo "## test for " . string(target)
  for type in ["String", "Array", "Dictionary"]
    let funcname = "Is".type
    echo " ".funcname." : " {funcname}.check(target)
  endfor
  " let a = "String"
  " echo Is{a}.check(target)
  " echo IsArray.check(target)
  " echo IsDictionary.check(target)
  E
  unlet! target
endfor

" Phrase: JavaScript Like OOP in VimScript
"============================================================
function! E(msg)
  echo "".a:msg
endfunction
command! -nargs=* E :call E(<q-args>)

E "===================================="
E " * JavaScript Like OOP in VimScript"
E "===================================="
E " Constructor"
E "===================================="

let Person = {}
function! Person.new(name)
  let obj = {}
  let obj.name = a:name
  function! obj.hello()
    echo "Hello I'm ".self.name."."
  endfunction

  function! obj.if_respond(meth)
    return has_key(self, a:meth)
  endfunction

  function! obj.has_method(meth)
    " type return 2 if Funcref"
    return (has_key(self, a:meth) && type(self[a:meth]) == 2)
  endfunction

  return obj
endfunction

E "===================================="
E " Instanciate"
E "===================================="
let taro   = Person.new("taro")
let hanako = Person.new("hanako")
call taro.hello()  |" => Hello I'm taro.
call hanako.hello()|" => Hello I'm hanako.
E "===================================="
E " Refrection method"
E "===================================="
echo taro.if_respond("name")     |" => 1
echo taro.if_respond("hello")    |" => 1
E
echo taro.has_method("name")     |" => 0
echo taro.has_method("hello")    |" => 1
E
echo taro.if_respond("non_exist")|" => 0
let  taro.height = 180
echo taro.if_respond("height")   |" => 1
echo hanako.if_respond("height") |" => 0
E
E "===================================="
E " Singleton method"
E "===================================="

function! taro.run()
  return "Hi my name is '".(self.name)."' Now I'm running"
endfunction

echo taro.has_method("run")  |" => 1
echo hanako.has_method("run")|" => 0
echo taro.run()              |"Im running
E
echo taro.run  |" => 923 " return Funcref '923' is method id
echo taro.run()|" => Hi my name is 'taro' Now I'm running
E
let tmp = {}
let tmp.meth = taro.run
echo type(tmp.meth)          |" => 2 (means Funcref)
echo call(tmp.meth,[],hanako)|" => Hi my name is 'hanako' Now I'm running

E "===================================="
E " Inheritance"
E "===================================="
let Child = {}
function! Child.new(name)
  let  obj = {}
  " echo g:Person.new("tario")
  " echo Person.new(a:name)
  let result = extend(obj, g:Person.new(a:name),'keep')
  return result
endfunction
unlet! jiro
let jiro = Child.new("jiro")
let sabro = Child.new("sabro")
call jiro.hello()
call sabro.hello()
E
function! jiro.hello()
  echo "Hello My name is ".self.name."."
endfunction
call jiro.hello()
call sabro.hello()
E
call taro.hello()
call hanako.hello()
" let jiro=Child.new("jiro")

" Phrase: Array multiple asignment
"============================================================
let member = [
			\ ["Yamada", "Tarou", 1999, 9, 1],
			\ ["Yamada", "Hanako", 1970, 3, 11]
			\ ]

for [sec_name, first_name; date ] in member
	let full_name = "'".sec_name." ".first_name."'"
	let born_date = join(date,"_")
	echo full_name." was born at ".born_date."."
endfor

" Phrase: Misc
"============================================================

echo range(8, 4, -2)
echo range(8, 12)
" vim の辞書はほぼJSON形式
let uk2nl = {'one': 'een', 'two': 'twee', 'three': 'drie'}
" 辞書の初期化
let dict = {}

" => [8, 6, 4]
"
" Phrase: HTTP status code handler(example of function dispatcher)
"============================================================
" Code
let status_table = {
      \ 200 :"OK",
      \ 302 : "FOUND",
      \ 304 : "NOT_MODIFIED",
      \ 404 : "NOT_FOUND",
      \ }

" Dispatcher
function! status_table.do(status_code) dict
  let func_name = tolower(self[a:status_code])
  call self[func_name]()
endfunction

" each implementation
function status_table.ok() dict
  echo "Conguratt!"
endfunction

function status_table.found() dict
  echo "Found!"
endfunction

function status_table.not_modified() dict
  echo "Not Modified!"
endfunction

function status_table.not_found() dict
  echo "Not Found!"
endfunction

call status_table.do("200")
call status_table.do("302")
call status_table.do("304")
call status_table.do("404")

" Phrase: Anonymous Function and Closure
"============================================================
" Anonymous Function
function! s:foo()
  let foo = {}
  fun foo.funcall() dict
    echo 'lambda'
  endf
  return foo
endfunction
call s:foo().funcall()
" => lambda

" Closure
function! s:foo(num)
  let foo = {'i': a:num}
  fun foo.funcall() dict
    let self.i += 1
    return self.i
  endf
  return foo
endfunction

let counter = s:foo(1)
echo counter.funcall()
echo counter.funcall()
echo counter.funcall()
" => 2
"    3
"    4

" Phrase: serialize and de-serialize with string and eval
"============================================================
" List
let  list_a = [ "a", "b" ]
echo list_a[0]
let  str_list_a = string(list_a)
let  list_b = eval(str_list_a)
echo list_b[0]

" Phrase: closure2: higher-order function
"============================================================
" vim can't pass anonymous function(=lambda) ?
" so I have to use temporary obj(=dictionary) to carry args,variable
" to be set inner function when called.
let Function = {}

function Function.print(arg) dict
    echo a:arg
endfunction

function Function.multi(arg)
    return a:arg * a:arg
endfunction

function Function.upCase(arg)
    return toupper(a:arg)
endfunction

function Function.downCase(arg)
    return tolower(a:arg)
endfunction

function Function.each(list, func) dict
    for i in range(0, len(a:list)-1)
        execute call(a:func, [a:list[i]], self)
    endfor
endfunction

let ary = [1,2,3,4,5]
" call Function.each(ary, Function.print)
" call Function.each(ary, Function.multi)

function! Function.map(list, func) dict
    let outer = { 'result': [], 'this': self, 'a_list': a:list, 'a_func': a:func }
    let self._outer = outer

    function! outer.f1(val) dict
        let result = call(self._outer.a_func, [a:val], self)
        call add(self._outer.result, result)
    endfunction

    call self.each(a:list, outer.f1)

    call remove(self, '_outer')
    let answer = outer.result
    return answer
endfunction

" echo Function
let  ary = [1,2,3,4,5]
let  strs = ["abc", "bde", "c", "d"]
echo Function.map(ary, Function.multi)
" => [1, 4, 9, 16, 25]
echo Function.map(strs, Function.upCase)
" => ['ABC', 'BDE', 'C', 'D']
echo Function.map(Function.map(strs, Function.upCase),Function.downCase)
" => ['abc', 'bde', 'c', 'd']  

" echo Function

" Phrase: closure2: reference outer self via dict
"============================================================
let Function = {}
let Function.data = [1,2,3,4,5]

function! Function.test() dict
    let obj = { 'v1': 'v1', 'v2': [1,2,3], 'this': self }

    function! obj.f1() dict
        return self.this
    endfunction

    return obj
endfunction

unlet! a
let  a = Function.test()
echo a
" => {'v2': [1, 2, 3], 'f1': function('1146'), 'this': {'data': [1, 2, 3, 4, 5], 'test': function('1145')}, 'v1': 'v1'}

echo a.f1()
" => {'data': [1, 2, 3, 4, 5], 'test': function('1145')}

" Phrase: closure
"============================================================
" Counter
function! s:counter(num)
    let counter= {'_val': a:num}

    function counter.inc() dict
        let self._val += 1
        return self._val
    endfunction

    function counter.dec() dict
        let self._val -= 1
        return self._val
    endfunction

    function counter.getValue() dict
        return self._val
    endfunction

    return counter
endfunction
let counter = s:counter(5)
echo counter.inc()      | " => 6
echo counter.dec()      | " => 5
echo counter.inc()      | " => 6
echo counter.inc()      | " => 7
echo counter.getValue() | " => 7


" Function factory
unlet! a
unlet! A
function! s:foo(num)
    let foo = {'initial': a:num}
    function foo.funcall(arg) dict
        return self.initial + a:arg
    endfunction
    return foo
endfunction
let plus2 = s:foo(2)
let plus3 = s:foo(3)
echo plus2.funcall(5) | " => 7
echo plus2.funcall(1) | " => 3
echo plus3.funcall(5) | " => 8 
echo plus3.funcall(1) | " => 4

" Phrase: underscore.js like
"============================================================
let ary = [1,2,3,4,5]
let _ = { }

function _.each(list, func) dict
    echo "start"
    for i in range(0, len(a:list)-1)
        execute call(a:func, [a:list[i]], self)
    endfor
    echo "end"
endfunction

function _.print(arg) dict
    echo a:arg
endfunction

function _.multi(arg)
    echo a:arg * a:arg
endfunction

call _.each(ary, _.print)
echo
call _.each(ary, _.multi)


" Phrase: higher order function in vimscript
"============================================================
function! FunA(a)
    echo "A: " . a:a
endfunction

function! FunB(func, list)
    echo "start"
    " call function via 'Funcref' passing argment as 'list'
    " like Javascipts 'apply' a:func.apply(this, a:list)
    execute call(a:func, a:list)
    echo "finish"
endfunction

" call function via 'Funcref'
" you can get 'Funcref' by passing function name to function() function
" and call imediately with arg '1'
call function("FunA")(1)

" asign 'Funcref' to variable
let Fn = function("FunA")
call FunB(function("FunA"), [1])

call FunB(obj.init, [1])

" Phrase: vim opration
"============================================================
## Fold
zf  : 作成
za  : 開く/閉じる
zd  : 削除
zD  : すべての折り畳みを削除
zR  : すべての折り畳みを開く
zM  : すべての折り畳みを閉じる

## Key-word
" TODO: todo
" XXX: memo
" ANY: memo
" FIXME: should fix

" コマンドラインへの挿入
### Insert object under the cursor: |c_CTRL-R_CTRL-F|
CTRL-R CTRL-F filename
CTRL-R CTRL-P path as in |gf|
CTRL-R CTRL-W word
CTRL-R CTRL-A WORD
example)

"/etc/sysconfig-network-scripts abc
" stdio.h  <= CTRL-R_CTRL-P expanded /usr/include/stdio.h when path=/usr/include

g> => show last page of previous command output
C-W z => :pclose
~ => tild Swap character Case

"## Normal mode
t/T => search char forward then stop BEFORE match
f/F => search char forward then stop at match
;/, => repeat t or f

" ## insert mode
C-t => indent"

" Phrase: try catch
"============================================================
try
    throw "oops"
catch /^oo/
    echo "caught"
endtry

" Phrase: strftime , getftime to show file mtime
"============================================================
echo strftime("%Y%m%d_%H%M",getftime("/etc/hosts"))

" Phrase: usage of <sfile>
"============================================================
" sfile is replaced with it's filename while sourced
let g:FNAME = expand('<sfile>')
function! Name()
    " in function <sfile> is treated as function name
    " in this case this function return `function Name'.
    return expand('<sfile>')
endfunction
echo g:FNAME
echo Name()

" Phrase: Regexp example
"============================================================
let a = 'getscripts.vba.gz'
let b = 'getscripts.vba'
echo substitute(a,'\(\w\+\)\.vba\(\.gz\)\?','\1','')
echo substitute(b,'\(\w\+\)\.vba\(\.gz\)\?','\1','')
echo matchlist(a,'\(\w\+\)\.vba\(\.gz\)\?')[1]
echo matchlist(b,'\(\w\+\)\.vba\(\.gz\)\?')[1]

" Phrase: Keyword argments with dictionary
"============================================================
let g:opt_default = {
            \ 'port'  : 80,
            \ 'bind'  : "localhost",
            \ 'https' : 'none',
            \ }

function! s:setup_option(opt)
    let result = {}
    for key in keys(g:opt_default)
        let result[key] = get(a:opt, key, g:opt_default[key])
    endfor
    return result
endfunction

echo s:setup_option({})
  " => {'https': 'none', 'port': 80, 'bind': 'localhost'}
echo s:setup_option({'port': 8080})
  " => {'https': 'none', 'port': 8080, 'bind': 'localhost'}
echo s:setup_option({'port': 8080, 'https': "true", 'bind': "any"})
  " => {'https': 'true', 'port': 8080, 'bind': 'any'}

" another way
echo extend(deepcopy(g:default_opt), {'port':8080}, 'force')
 " => {'https': 'none', 'port': 8080 }
echo extend(deepcopy(g:default_opt), {'port':8080}, 'keep')
 " => {'https': 'none', 'port': 80 }
echo extend(g:default_opt, {'port':8080}, 'force')
 " => {'https': 'none', 'port': 8080 }
echo g:default_opt
 " => {'https': 'none', 'port': 8080 }

function! PrintDict(dict)
    for [k, v] in items(a:dict) | echo k . ': ' . v | endfor
endfunction

let opt = s:setup_option({})
call PrintDict(opt)
echo "---"
let opt = s:setup_option({'port': 8080})
call PrintDict(opt)
echo "---"
let opt = s:setup_option({
            \ 'port': 443,
            \ 'bind': '192.168.1.254',
            \ 'https': 'true',})
call PrintDict(opt)
echo "---"

" Phrase: shell command and status system()
"============================================================
!mv foo bar
if v:shell_error
  echo 'could not rename "foo" to "bar"! :' . v:shell_error
endif

" Phrase: inputlist() Sample
"============================================================
let color = inputlist(['Select color:',
            \ '1. red',
            \ '2. green',
            \ '3. blue',
            \ ])
echo "\nanswer is " color

" Phrase: cmap, getcmdline(), setcmdpos() sample
"============================================================
cnoremap <F7> <C-\>eAppendSome()<CR>
func! AppendSome()
    let cmd = getcmdline() . " Some()"
    " place the cursor on the )
    call setcmdpos(strlen(cmd))
    return cmd
endfunc
" Phrase: FlattenAry
"============================================================
let ary = [ [0], 1, [2,[[3]]], [4] ] 
let Array = {}
function! Array.flatten(ary)
    let result = []
    for i in range(0, len(a:ary)-1)
        unlet! l " avoid var type mismatch erro
        let l = get(a:ary,i)
        if (type(l) == type([]))
             let result += self.flatten(l)
        else
            call add(result, l)
        endif
    endfor
    return result
endfunction

echo Array.flatten(ary)
   " => [ 0, 1, 2, 3, 4 ]
 
" Phrase: OOP Style experiment
"============================================================
let Array = {}

function! Array.new(ary)
   return  {
            \ 'data'   : a:ary,
            \ 'print'  : self.print,
            \ 'length' : self.length,
            \ 'map'    : self.map,
            \ 'each_with_index' : self.each_with_index,
            \ }
endfunction

function! Array.print() dict 
    return self.data
endfunction

function! Array.length() dict
    return len(self.data)
endfunction

function! Array.map(callback) dict
    let r = []
    for i in range(0, self.length()-1) 
        call add(r, a:callback(get(self.data, i)))
    endfor
    return r
endfunction

function! Array.each_with_index(callback) dict
    for i in range(0, self.length()-1)
        call a:callback(get(self.data, i), i)
    endfor
endfunction

function! Plus5(arg)
    return a:arg + 5
endfunction

"function! s:callback()
    "function! Print2(arg, i)
        "echo  a:arg * a:i
    "endfunction
    "return function("Print2")
"endfunction

function! s:upcase(arg)
    return toupper(a:arg)
endfunction

let e = Array.new([1, 2, 3, 4, 5, 6])
echo "original = "| echon  e.print()
echo "length   = "| echon  e.length() 
echo "Plush5   = "| echon  e.map(function("Plus5"))
echo "---"
let e = Array.new(["a", "b", "c", "d" ])
echo "original = "| echon  e.print()
echo "length   = "| echon  e.length() 
echo "upcase   = "| echon  e.map(function("s:upcase"))
echo "original = "| echon  e.print()

" Phrase: Save Cursor Position and Do Something then Restore Cursor Position
"============================================================
"
" number of window
winnr('$')
" current win number
winnr()
" alternate window (target of <C-w>p)
winnr('#')

let save_cursor = getpos(".")
MoveTheCursorAround
call setpos('.', save_cursor)

" Phrase: カーソルのある位置から3文字を取得する例
"============================================================
strpart(getline("."), col(".") - 1, 3)

" Phrase: 3項目演算子の見やすい使い方
"============================================================
let ext = "rb"
let fname = exists("ext") && !empty(ext)
            \ ? "scratch." . ext
            \ : "scratch"

" Phrase: Combinded Condition Expression
"============================================================
  return (!&shellslash && (has('win32') || has('win64')) ? '\' : '/')

" Phrase: Dictionaries 辞書の使い方  { dict-modification }
"============================================================
let person = {
            \ 'age'     : 14,
            \ 'height'  : 170,
            \ 'sex'     : 'man',
            \ 'country' : 'Japan',
            \ }
let person['country'] = "England"
echo person.sex
echo person
for key    in keys(person)       | echo key . "\t: " . person[key] | endfor
for key    in sort(keys(person)) | echo key . "\t: " . person[key] | endfor
for v      in values(person)     | echo "value: " . v              | endfor
for [k, v] in items(person)      | echo k . ': ' . v               | endfor

" Phrase: How to set default value to option variable(from rails.vim)
"============================================================
function s:defineOption(name, default)
  if !exists(a:name)
    let {a:name} = a:default
  endif
endfunction
call s:defineOption('g:fuf_help_switchOrder', 130)
call s:defineOption('g:fuf_help_cache_dir'  , '~/.vim-fuf-cache/help')

unlet! g:opt1
unlet! g:opt2
let opt  = {}
let optlist = { 'g:opt1': 'op1_default', 'g:opt2': 'op2_default' }
let g:opt1 = 'op111'
"let g:opt2 = 'op222'

for [k, v] in items(optlist)
   call s:defineOption(k, v)
endfor
echo g:opt1
echo g:opt2

" Phrase: <SID> <Plug> <SNR>
"============================================================
" <SID> is translated to <SNR>123_ (123 is Script NumbeR)
"  this enable you to call script local function from map
" <Plug> is special key code which is never be input from user keyboard
"  this sholud be provided for user to change keymap for script.
command! -nargs=0 CDtoCurrentFile :call <SID>CDtoCurrentFile()
" => CDtoCurrentFile 0         :call <SNR>25_CDtoCurrentFile() 
nnoremap <Plug>(Util_CDtoCurrentFileCmd)  :<C-u>CDtoCurrentFile<CR>
nnoremap <Plug>(Util_CDtoCurrentFileCall) :<C-u>call <SID>CDtoCurrentFile()<CR>
" user can define keymap like this(nnoremap not work because re-map is
" required to work as intended)
"nmap <F4> <Plug>(Util_CDtoCurrentFile)

function! s:CDtoCurrentFile()
    let dir = expand('%:h')
    if isdirectory(dir)
        exec 'lcd ' . dir
        redraw!
    endif
endfunction

