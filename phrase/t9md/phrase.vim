" Phrase: python's if __name__ == “__main__”
"======================================================================
if expand("%:p") !=# expand("<sfile>:p")
  finish
endif

" Phrase: logger
"======================================================================
function! s:smalls.log(msg)
  cal vimproc#system('echo "' . a:msg . '" >> ~/vimlog.log')
endfunction

" Phrase: should and should not ensurerer
"======================================================================
function! Test(case, v)
  echo a:case
  try
    call s:should( empty(a:v), "should empty" )
    call s:should_not( empty(a:v), "empty not allowed" )
  catch
    echo v:exception
  endtry
endfunction

function! s:should(expr, err)
  if ! a:expr
    throw a:err
  endif
endfunction
function! s:should_not(expr, err)
  if a:expr
    throw a:err
  endif
endfunction
call Test("#case1: pass empty", '')
call Test("#case2: pass not empty", 'a')
" #case1: pass empty
" empty not allowed
" #case2: pass not empty
" should empty

" Phrase: ErrorCheck
"======================================================================
function! s:checker(check, ...)
　let expr = get(a:, 1, "ERROR")
　if a:check
　　throw expr
　endif
endfunction
call s:checker(Check1())
call s:checker(Check2(), "ERROR Check2")
function! Check1()
  return 1
endfunction
function! Check2()
  return 1
endfunction
command! -nargs=* Checker if <args> | throw "ERROR" | endif
Checker Check1()
Checker Check2()

function! s:throw(exp)
  throw a:exp
endfunction
let _ = Check1() && s:throw("ERROR")
let _ = Check2() && s:throw("ERROR")

" Phrase: default setting
"======================================================================
let g:textmanip_default_mode = "replace"
let s:default_settings = {
      \ "enable_mappings" : 0,
      \ "default_mode" : "insert",
      \ }

let s:prefix = "textmanip_"
function! s:set_default(dict) "{{{
  for [name, val] in items(a:dict)
    let var = s:prefix . name
    let g:{var} = get(g:, var, val)
    unlet name val
  endfor
endfunction "}}}
call s:set_default(s:default_settings)

" Phrase: v: variable
"======================================================================
for [k,v] in items(v:)
  echo join(["v:" . k, PP(v) ]," = ")
  unlet v
endfor

" Phrase: include
"======================================================================
let lis = ["ruby", "python", "perl"]
function! s:include(list, val)
  return index(a:list, a:val)
endfunction
echo s:include(lis, "ruby")
" => 0
echo s:include(lis, "python")
" => 1
echo s:include(lis, "perl")
" => 2
echo s:include(lis, "perlo")
" => -1

" Phrase: command args
"======================================================================
function! Test(...) "{{{
  echo "arg count:" . a:0
  echo "args:" . PP(a:000)
endfunction "}}}
command! -nargs=* Test1 :call Test(<args>)
command! -nargs=* Test2 :call Test(<q-args>)
command! -nargs=* Test3 :call Test(<f-args>)
" CommandList: {{{
let s:cmds = [
      \ 'Test1',
      \ 'Test1 var',
      \ 'Test1 "need quote"',
      \ 'Test2',
      \ 'Test2 a b c',
      \ 'Test3',
      \ 'Test3 a b c',
      \ ] "}}}
function! Run() "{{{
  let var = "VAR"
  for cmd in s:cmds
    echo "== :" . cmd
    execute cmd
    echo ""
  endfor
endfunction "}}}
call Run()
" Result: "{{{
" == :Test1
" arg count:0
" args:[]
"
" == :Test1 var
" arg count:1
" args:['VAR']
"
" == :Test1 "need quote"
" arg count:1
" args:['need quote']
"
" == :Test2
" arg count:1
" args:['']
"
" == :Test2 a b c
" arg count:1
" args:['a b c']
"
" == :Test3
" arg count:0
" args:[]
"
" == :Test3 a b c
" arg count:3
" args:['a', 'b', 'c']
" }}}
" Phrase: Manage Win Variable
"======================================================================
function! s:set_winvar()
 for n in map(range(winnr('$')), 'v:val+1')
   call setwinvar(n, "quickhl_winno", n)
 endfor
endfunction

function! s:get_winvar()
 for n in map(range(winnr('$')), 'v:val+1')
   let here = n == winnr() ? " <==" : ''
   echo n . ":". getwinvar(n, "quickhl_winno", -1) . here
 endfor
endfunction

function! s:find_win(num)
 for n in map(range(winnr('$')), 'v:val+1')
   if getwinvar(n, "quickhl_winno", -1)  == a:num
     return n
   endif
 endfor
 return -1
endfunction

" command! -nargs=1 FindWin  :echo <SID>find_win(<args>)
" nnoremap <F8> :call <SID>get_winvar()<CR>
" nnoremap <F9> :call DEBUG()<CR>
" function! DEBUG()
 " if exists("w:quickhl_winno")
   " PP w:quickhl_winno
 " endif
 " echo [ "winnr('#') = " . winnr('#'),  "winnr() = " . winnr()]
" endfunction

" Phrase: Check called mode
"======================================================================
function! CheckMode()
  let mode = mode(1) == "\<C-v>" ? "C-v" : mode(1)
  return ":call Mode('" . mode . "')\r"
endfunction

function! Mode(mode)
  echo "mode: " . a:mode
endfunction

nnoremap <expr> <Plug>(check-mode) CheckMode()
xnoremap <expr> <Plug>(check-mode) CheckMode()
" vnoremap <Plug>(

nmap <F9> <Plug>(check-mode)
xmap <F9> <Plug>(check-mode)

" Phrase: regexp
"======================================================================
" help ordinary-atom
" HOF, EOF
/\v%^
/\v%$

" Phrase: call() replace self arbitalily
"======================================================================
let s:t = {}
let s:t.name = "Taku"
let s:t.age = 37

function! s:t.hello()
  return "Hello " . self.name
endfunction
function! s:t.bye()
  return "Bye " . self.name
endfunction
function! s:t.judge()
  return ( self.age > 30 ? "old" : "young" )
endfunction
function! s:t.report()
  return self.name . " is " . self.age . " years old. so He is " . self.judge() . "."
endfunction
function! s:t.eat(meal)
  return self.name . " is eating " . a:meal . " now."
endfunction

let s:y = {"name": "Yurie", "age": 39 }
let s:y = extend( s:y, s:t, "keep" )

echo extend({"name": "Taiki", "age": 9 }, s:t, "keep" ).report()
echo s:t.report()
echo s:t.eat("yakiniku")
echo s:y.report()
let s:akira = {"name": "Akira", "age": 3 }
echo call(s:t.hello, [], s:akira )
" call s:t.eath function with replacing 'self' to s:akira
echo call(s:t.eat, ["Mikan"], s:akira )
let s:t = {}
let s:t.name = "Taku"
let s:t.age = 37

function! s:t.hello()
  return "Hello " . self.name
endfunction
function! s:t.bye()
  return "Bye " . self.name
endfunction
function! s:t.judge()
  return ( self.age > 30 ? "old" : "young" )
endfunction
function! s:t.report()
  return self.name . " is " . self.age . " years old. so He is " . self.judge() . "."
endfunction
function! s:t.eat(meal)
  return self.name . " is eating " . a:meal . " now."
endfunction

let s:y = {"name": "Yurie", "age": 39 }
let s:y = extend( s:y, s:t, "keep" )

echo extend({"name": "Taiki", "age": 9 }, s:t, "keep" ).report()
echo s:t.report()
echo s:t.eat("yakiniku")
echo s:y.report()
let s:akira = {"name": "Akira", "age": 3 }
echo call(s:t.hello, [], s:akira )
" call s:t.eath function with replacing 'self' to s:akira
echo call(s:t.eat, ["Mikan"], s:akira )

" Phrase: closure
"======================================================================
function! s:func_creator()
  let o = {}
  function! o.call(dir)
    let orig_cwd = getcwd()
    exe "cd " . a:dir
    let result = self.callback()
    exe "cd " . orig_cwd
    return result
  endfunction

  return o
endfunction

function! s:exe_with_dir(dir, cmd)
  let o = s:func_creator()
  let o.cmd = a:cmd

  function! o.callback()
    return vimproc#system(self.cmd)
  endfunction
  return o.call(a:dir)
endfunction

function! s:func_with_dir(dir, func)
  let o = s:func_creator()
  let o.func = a:func

  function! o.callback()
    return self.func()
  endfunction
  return o.call(a:dir)
endfunction

function! s:hello()
  return getcwd()
endfunction

echo s:exe_with_dir("~/.vim/bundle", "find . -type d -depth 2")
echo s:func_with_dir("~/.vim/bundle", function("s:hello"))

" Phrase: neat condition clause
"======================================================================
function! Dev1(mode)
  if      a:mode == '1' | let range_str = 'one'   |
  elseif  a:mode == '2' | let range_str = "two"   |
  elseif  a:mode == '3' | let range_str = 'three' |
  else                  | let range_str = 'other' |
  endif
  echo range_str
endfunction

function! s:hoge() abort
  let v = 14
  let case =
        \ v ==# 11 ? 1 :
        \ v ==# 12 ? 2 :
        \ v ==# 13 ? 3 :
        \ v ==# 14 ? 4 :
        \ NOT_EXIST_LOCAL_VARIABLE
  echo case
endfunction


function! Dev2(mode)
  echo
        \ a:mode  == '1' ? 'one'   :
        \ a:mode  == '2' ? 'two'   :
        \ a:mode  == '3' ? 'three' :
        \                'other'
endfunction

echo "--------"
call Dev1(1) | call Dev1(2) | call Dev1(3) | call Dev1(4)
echo "--------"
call Dev2(1) | call Dev2(2) | call Dev2(3) | call Dev2(4)
echo "--------"

" Phrase: default setter
"======================================================================
let g:default_settings = {
      \ "g:http_port": 80,
      \ "g:http_version": 1.0,
      \ "g:http_timeout": 3,
      \ }

function! s:set_default(dict)
  for [var,val] in items(a:dict)
    if !exists(var)
      let {var} = val
    endif
  endfor
endfunction

call s:set_default(g:default_settings)

" Phrase: chef.vim test code
"======================================================================
function! s:attrs()
  let attr1 = 'node["haproxy"]["enable_admin"]'
  let attr2 = "node['haproxy']['enable_admin']"
  let attr3 = "node[:haproxy][:enable_admin]"
  let attr4 = 'node[:"a haproxy"][:"b enable_admin"]'
  return [ attr1, attr2, attr3, attr4 ]
endfunction

function! s:quote(attr, quote_str)
  let tmp = substitute(a:attr, '[:"'']','','g')
  let tmp = substitute(tmp, "[", "[" . a:quote_str ,'g')
  return substitute(tmp, "]", a:quote_str . "]",'g')
endfunction

function! s:single_quote(attr)
  return s:quote(a:attr, "'")
endfunction

function! s:double_quote(attr)
  return s:quote(a:attr, '"')
endfunction
function! s:symbolize(attr)
  if matchstr(a:attr, '[:') != ''
    return a:attr
  endif
  let tmp = substitute(a:attr, '[:"'']','','g')
  return substitute(tmp, "[", '[:','g')
endfunction

function! s:main()
  for attr in s:attrs()
    echo "= " . attr
    let symbolized = s:symbolize(attr)
    echo symbolized
    let single_quote = s:single_quote(attr)
    echo single_quote
    let double_quote = s:double_quote(attr)
    echo double_quote
    echo ""
  endfor
endfunction

call s:main()
finish


function! s:finder.attr_patterns() "{{{1
    let attr = matchlist(self.env.attr, '[.*\]')[0]
    let idx = len(attr)

    let s:attr_transfunc = [
          \ function("s:single_quote"),
          \ function("s:double_quote"),
          \ function("s:symbolize"),
          \ ]

    let candidate = []
    while 1
        let idx = strridx(attr, ']', idx-1)
        if idx == -1| break | endif
        let org = attr[ : idx ]
        call add(candidate, org)
        for F in s:attr_transfunc
          call add(candidate, call(F,[org]))
          unlet F
        endfor
    endwhile
    return map(candidate, "escape(v:val, '[]')")
endfunction

" Phrase: case like expression
"======================================================================
let cmd = "ls"
let proc =
      \ cmd == 'ls'   ? "proc_ls" :
      \ cmd == 'find' ? "proc_find" :
      \ cmd == 'tar'  ? "proc_tar" :
      \ "default"
echo proc

" Phrase: call function with {} pattern
"======================================================================
function! This()
  return "This"
endfunction
function! That()
  return "That"
endfunction

let is = "is"
let th = "Th"
PP {th}{is}()
" => {th}{is}() = 'This'
"
let is = substitute(is, 'is', 'at','')

PP {th}{is}()
" => {th}{is}() = 'That'

" Phrase: registers()
"============================================================
" There are nine types of registers:			*registers* *E354*
" 1. The unnamed register ""
" 2. 10 numbered registers "0 to "9
" 3. The small delete register "-
" 4. 26 named registers "a to "z or "A to "Z
" 5. four read-only registers ":, "., "% and "#
" 6. the expression register "=
" 7. The selection and drop registers "*, "+ and "~
" 8. The black hole register "_
" 9. Last search pattern register "/

" set search pattern to ruby
let @/ = 'ruby'
" clear last search pattern
let @/ = ''

" Phrase: array with number
"======================================================================
for [num, line] in map(readfile("/home/maeda_taku/.bashrc"),'[v:key+1, v:val]')
  echo num ":" line
endfor

" Phrase: get selected text from tyru's open-browser
"======================================================================
" Get selected text in visual mode.
function! s:get_selected_text() "{{{
    let save_z = getreg('z', 1)
    let save_z_type = getregtype('z')

    try
        normal! gv"zy
        return @z
    finally
        call setreg('z', save_z, save_z_type)
    endtry
endfunction "}}}

" Phrase: sort by length
"======================================================================
function! s:sort_by_length(list)
  function! l:f(v1, v2)
    return a:v1 == a:v2 ? 0 : len(a:v1) > len(a:v2) ? 1 : -1
  endfunction
  return sort(copy(a:list), function("l:f"))
endfunction

function! s:reverse_sort_by_length(list)
  return reverse(s:sort_by_length(a:list))
endfunction
let numbers = ["11", "22222", "3", "444444444444444", "55555555", "666666"]
echo PP(s:sort_by_length(numbers))
" => ['3', '11', '22222', '666666', '55555555', '444444444444444']
"
echo PP(s:reverse_sort_by_length(numbers))
" => ['444444444444444', '55555555', '666666', '22222', '11', '3']

" Phrase: Tips
" ======================================================================
" ]c, [c 次/前の差異

" Phrase: get SID
" ======================================================================
function! s:SID()
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction

"  Phrase: Convert alist to dictionary
" ======================================================================
let Dict = {}
function! Dict.new(ary)
    " if (len(a:ary) % 2) != 0 | return -1 | endif
    let d = {}
    for [key, val] in a:ary
        let d[key] = val
    endfor
    return d
endfunction

let ary = [["a", "1"], ["b", "2"], ["c", "3"],["d", "4"]]
echo Dict.new(ary)

"  Phrase: list all tag
" ======================================================================
function! TagdbCreate()
    let db = {}
    let taglist = taglist('.')
    for tag in taglist
        let key = tag['kind']
        if empty(key) | continue | endif
        if !has_key(db, key)
            let db[key] = []
        endif
        call add(db[key], tag)
    endfor
    return db
endfunction
unlet! s:tagdb

function! TagQuery(type)
    if !exists('s:tagdb')
        let s:tagdb = TagdbCreate()
    endif
    return sort(map(copy(s:tagdb[a:type]), 'v:val["name"]'))
endfunction

for type in ['a', 'c', 'f', 'v', 'F', 'm']
    echo "==============================="
    echo " TYPE: " . type
    echo "==============================="
    echo join(TagQuery(type),"\n")
endfor

"  Phrase: function factory
" ======================================================================
function! s:finder_factory(ary)
    for finder_name in a:ary
        let exp = []
        call add(exp,'function! chef#controller#find' . finder_name . '(...)')
        call add(exp, '    let s:Controller.finders = [ s:finder_for("' . finder_name . '") ] ')
        call add(exp, '    call call(s:Controller.main, a:000, s:Controller)')
        call add(exp, 'endfunction')
        " echo join(exp, "\n")
        exe join(exp, "\n")
    endfor
endfunction
call s:finder_factory(["Attribute", "Source", "Recipe", "Definition", "Related" ])

"  Phrase: sub and gsub from rails.vim
" ======================================================================
function! s:sub(str,pat,rep)
  return substitute(a:str,'\v\C'.a:pat, a:rep,'')
endfunction
function! s:gsub(str,pat,rep)
  return substitute(a:str,'\v\C'.a:pat, a:rep,'g')
endfunction
let word = "people"
echo s:sub(word,'eople$','ersons')
echo s:gsub(word,'p','g')

"  Phrase: [metaprog] Type checker
" ======================================================================
let s:type = {}
let s:type_list = {
            \ "number": type(0),
			\ "string": type(""),
			\ "function": type(function("tr")),
			\ "list": type([]),
			\ "dictionary": type({}),
			\ "float": type(0.0)
            \ }

function! s:add_method(obj, methods)
    let o = a:obj
    for [f, typenum] in items(a:methods)
        let exp = 'function o.is_'. f . "(arg)\n"
                    \ . "   return type(a:arg) == " . typenum
                    \ . "\nendfunction"
        execute exp
    endfor
endfunction
call s:add_method(s:type, s:type_list)
echo  s:type.is_list([])
echo  s:type.is_list("")
echo  s:type.is_number(99)
echo  s:type.is_float(9.9)

"  Phrase: Count multibyte word
" ======================================================================
function! s:strlen(str)
    return strlen(substitute(a:str, ".", "x", "g"))
endfunction
let str =  "あいうえお"
echo "original strlen is " . strlen(str)
echo "multibyte support ver " . s:strlen(str)

"  Phrase: Dynamically generate function
" ======================================================================
let s:fname = {}
function! s:fname.new(fname)
    let self._fname = a:fname
    return self
endfunction
function! s:fname.org()
    return self._fname
endfunction

let s:pat = {
            \ 'expand_path': ":p",
            \ 'dirname': ":h",
            \ 'basename': ":t",
            \ 'extname': ":e",
            \}

for [f, p ] in items(s:pat)
    " echo f
    let exp = 'function s:fname.' . f . "()\n" . "return fnamemodify(self.org(),'" .  p.  "')" . "\nendfunction"
    execute exp
endfor
unlet! fn
let fn = s:fname.new("~/local/dev/hoge.rb")
echo fn.org()
echo fn.expand_path()
echo fn.dirname()
echo fn.basename()
echo fn.extname()

finish

"  Phrase: Fname object
" ======================================================================
let s:fname = {}
function! s:fname.new(fname)
    let self._fname = a:fname
    return self
endfunction
function! s:fname.org()
    return self._fname
endfunction
function! s:fname.expand_path()
    return fnamemodify(self.org(), ":p")
endfunction
function! s:fname.dirname()
    return fnamemodify(self.org(),":p:h")
endfunction
function! s:fname.basename(...)
    " let ext = a:0 ? a:1 : ""
    return fnamemodify(self.org(),":p:t")
endfunction
function! s:fname.extname()
    return fnamemodify(self.org(),":p:e")
endfunction

let Fname = s:fname

let f = Fname.new("~/local/dev/hoge.rb")
echo f.org()
echo f.expand_path()
echo f.dirname()
echo f.basename()
echo f.extname()

"  Phrase: expose options
" ======================================================================
function! s:SetOptDefault(opt,val)
  if !exists("g:".a:opt)
    let g:{a:opt} = a:val
  endif
endfunction

let g:Sample_statusline = 99
call s:SetOptDefault("Sample_statusline",1)
call s:SetOptDefault("Sample_syntax",2)
call s:SetOptDefault("Sample_mappings",3)

" let default_opt = {
            " \ "Sample_statusline": 1,
            " \ "Sample_syntax": 2,
            " \ "Sample_mappings": 3
            " \ }
let default_opt = {}
let default_opt.Sample_statusline = 1
let default_opt.Sample_syntax     = 2
let default_opt.Sample_mappings   = 3

for [key, val] in items(default_opt)
    call s:SetOptDefault(key, val)
endfor

echo g:Sample_statusline
echo g:Sample_syntax
echo g:Sample_mappings

"  Phrase: String#scan
" ======================================================================
function! s:scan(str, pattern)
    let ret = []
    let pattern = a:pattern
    let nth = 1
    while 1
        let m = matchlist(a:str, pattern, 0, nth)
        if empty(m)
            break
        endif
        call add(ret, m[1])
        let nth += 1
    endwhile
    return ret
endfunction

"  Phrase: use exeption as class like Ruby
" ======================================================================
fun! Thrower()
    let o = {"_chef": 1, 'message': "hello", "id": "RelatedFinder"}
    throw string(o)
    " throw "MMM"
endf

try
    call Thrower()
catch
    try
        let original_exception = v:exception
        let exception = eval(v:exception)
        if ! has_key(exception, '_chef')
            throw original_exception
        endif
    catch /E121/
        throw original_exception
    endtry

    echo exception.message
endtry

"  Phrase: dictionary extend
" ======================================================================
let a = {'a': 1, 'A': 2 }
let b = {'a': 2, 'b': 1, 'B': 2 }
call extend(a, b, 'keep')
echo a
" => {'a': 1, 'b': 1, 'A': 2, 'B': 2}

"  Phrase: Middleware Framework
" ======================================================================
" new -> condition -> pre -> call -> after
"
function! s:Finder.new(name)
    let instance = deepcopy(self)
    let instance.name = a:name
    return instance
endfunction

function! s:Finder.condition()
    return
endfunction

function! s:Finder.pre()
    return
endfunction

function! s:Finder.call()
    return self.name
endfunction

function! s:Finder.after()
    return
endfunction

let flist = []
call add(flist, s:Finder.new("abc"))
call add(flist, s:Finder.new("def"))
for f in flist
    echo f.call()
endfor

"  Phrase: try catch
" ======================================================================
function! Try1()
  let var = "try1"
  throw var
endfunction

function! Try2()
  let var = "try2"
  throw var
endfunction

function! Main()
  try
    call Try1()
    call Try2()
  catch /try1/
    echo "catch try1"
  catch /try2/
    echo "catch try1"
  finally
    echo "Finish"
  endtry
endfunction

call Main()

"  Phrase: Unique
" ======================================================================
function! Unique(list) " -- remove duplicate values from {list} (in-place) {{{
	let index = 0
	while index < len(a:list)
		let value = a:list[index]
		let match = index(a:list, value, index+1)
		if match >= 0
			call remove(a:list, match)
		else
			let index += 1
		endif
		unlet value
	endwhile
	return a:list
endfunction "}}}

"  Phrase: timer object
" ======================================================================
" timer object: {{{
let s:o = {}
let s:o._data = {}
function! s:o.start()
  call self.reset()
  let self._data.start = reltime()
  " unlet! self._data.end
endfunction
function! s:o.end()
  let self._data.end = reltime()
endfunction
function! s:o.reset()
  let self._data.start = []
  let self._data.end   = []
endfunction
function! s:o.duration()
  return split(reltimestr(reltime(self._data.start, self._data.end)))[0]
endfunction
let time = s:o
unlet s:o
"}}}
" Usage: {{{
call time.start()
sleep 10
call time.end()
echo time.duration()
"}}}

"  Phrase: let with default values
" ======================================================================
function! s:let_default(varname, default)
  if !exists(a:varname)
    let {a:varname} = a:default
  endif
endfunction
command! -nargs=+ LetDeafult :call <SID>let_default(<f-args>)
" unlet g:CommandTMaxHeight
LetWithDeafult g:CommandTMaxHeight 40
echo g:CommandTMaxHeight

"  Phrase: More curry
" ======================================================================
" Utility function"{{{
fun! Echo(e)
  echo a:e
endfun
fun! Header(num)
  echo "\n" . a:num . "\n"
endfun
command! -nargs=* H :call Header(<f-args>)"}}}

function! Curry(...) "{{{
  let args = deepcopy(a:000)
  let o = {}
  let o._fun = remove(args, 0)
  let o._args = args

  function! o.bind(obj)
    let self._obj = a:obj
    return self
  endfunction

  function! o.call(...)
    return call(self._fun, self._args + a:000, get(self, '_obj', {}))
  endfunction
  return o
endfunction "}}}

function! s:each(lis, fun)
  for e in a:lis
    call a:fun(e)
  endfor
endfunction

let lis = range(5)
unlet! val
H 0.0)----
call s:each(lis, function('Echo'))
H 0.1)----
call call(function('s:each'), [lis, function('Echo')])
H 1)----
call call(function('s:each'), [lis, function('Echo')])
H 2)----
call Curry(function('s:each')).call(lis, function('Echo'))
H 3)----
call Curry(function('s:each'), lis).call(function('Echo'))
H 4)----
call Curry(function('s:each'), lis, function('Echo')).call()
echo '---------------------------------------'
" Result: {{{
" 0.0)----

" 0
" 1
" 2
" 3
" 4

" 0.1)----

" 0
" 1
" 2
" 3
" 4

" 1)----

" 0
" 1
" 2
" 3
" 4

" 2)----

" 0
" 1
" 2
" 3
" 4

" 3)----

" 0
" 1
" 2
" 3
" 4

" 4)----

" 0
" 1
" 2
" 3
" 4
"}}}
" String object"{{{
let s = {}
function! s.new(str)
  let o = deepcopy(self)
  let o._data = a:str
  return o
endfunction
function! s.upcase()
  return toupper(self._data)
endfunction
function! s.tolower()
  return tolower(self._data)
endfunction
let String = s
"}}}
" Result: {{{
echo String.new('abc').upcase()                            |" => "ABC"
echo call(String.upcase, [], String.new("abcdefg"))        |" => "ABCDEFG"
let upcase = Curry(String.upcase)
let lower_string = String.new('lower string')
call upcase.bind(lower_string)
echo upcase.call()                                         |" => "LOWER STRING"
echo Curry(String.upcase).bind(String.new("lower")).call() |" => "LOWER"
echo Curry(String.tolower).bind(String.new("UPPER")).call()|" => "upper"
"}}}
"  Phrase: Curry 2
" ======================================================================
fun! Echo(e)
  echo a:e
endfun

unlet! consumer1
let  consumer1 = Curry(function('remove'), range(5))
echo consumer1._args
echo consumer1.call(1)
echo consumer1.call(1)
echo consumer1.call(1)
echo consumer1.call(1)
echo '---------------------------------------'
echo 'get index 0 value fixed'
echo '---------------------------------------'
let  consumer2 = Curry(function('remove'), range(5), 0)
echo consumer2.call()
echo consumer2.call()
echo consumer2.call()
echo consumer2.call()
echo consumer2.call()

echo '---------------------------------------'
echo 'get value from end of list'
echo '---------------------------------------'
let  consumer3 = Curry(function('remove'), range(5), -1)
echo consumer3._args
echo consumer3.call()
echo consumer3.call()
echo consumer3.call()
echo consumer3.call()
echo consumer3.call()
echo '---------------------------------------'
echo 'map ordinally invocation'
echo '---------------------------------------'
let lis = range(5)
call map(lis, 'v:val + 10')
echo lis

echo '---------------------------------------'
echo 'curry map invocation'
echo '---------------------------------------'
let lis = range(5)
let Map = Curry(function('map'), lis)
unlet! result
let result = Map.call('v:val + 10')
echo result

echo '---------------------------------------'
function! Each(lis, fun)
  for e in a:lis
    call a:fun(e)
  endfor
endfunction
let lis = range(5)
call Each(lis, function('Echo'))
echo '---------------------------------------'
let s:Each = Curry(function('Each'), lis)
call s:Each.call(function('Echo'))


" Phrase: Aliasing function
"============================================================
" Basic: {{{
let  lis = range(5)
echo lis           |" => [0, 1, 2, 3, 4]
echo remove(lis,0) |" => 0
echo remove(lis,0) |" => 1
echo add(lis, 99)  |" => [2, 3, 4, 99]
echo add(lis, 99)  |" => [2, 3, 4, 99, 99]
"}}}

echo '---------------------------------------'
" Aliasing:  {{{
" aliasing add to s:push {{{
function! s:push(lis, val)
  return call(function('add'), [a:lis, a:val ])
endfunction

function! s:pop(lis, val)
  return call(function('remove'), [a:lis, a:val ])
endfunction

function! s:pop2(lis, ...)
  return call(function('remove'), insert(deepcopy(a:000), a:lis))
endfunction

function! s:push2(...)
  return call(function('add'), a:000)
endfunction
" }}}
" Result: {{{
let  lis = range(5)
echo lis              |" => [0, 1, 2, 3, 4]
echo s:pop(lis,0)     |" => 0
echo s:pop2(lis,0)    |" => 1
echo s:push(lis, 99)  |" => [2, 3, 4, 99]
echo s:push2(lis, 99) |" => [2, 3, 4, 99, 99]
"}}}
"}}}
echo '---------------------------------------'
" Generarize: {{{

function! s:alias(org, new)
  unlet! {a:new}
  let {a:new} = function(a:org)
endfunction
command! -nargs=+ Alias :call s:alias(<f-args>)

call s:alias('add', 's:push3')
Alias add s:push4
Alias remove s:pop5

" Result: {{{
let  lis = range(5)
let  lis = range(5)
echo lis             |" => [0, 1, 2, 3, 4]
echo remove(lis,0)   |" => 0
echo s:pop5(lis,0)   |" => 1
echo s:push3(lis, 99)|" => [2, 3, 4, 99]
echo s:push4(lis, 99)|" => [2, 3, 4, 99, 99]
"}}}
"}}}

"  Phrase: Currying
" ======================================================================
function! Curry(...)"{{{
  let args = deepcopy(a:000)
  let o = {}
  let o._fun = remove(args, 0)
  let o._args = args

  function! o.bind(obj)
    let self._obj = a:obj
    return self
  endfunction

  function! o.call(...)
    return call(self._fun, self._args + a:000, get(self, '_obj', {}))
  endfunction
  return o
endfunction"}}}

unlet! Fref
let num = 1
let str = "str"
let Fref = function('type')
let lis = []
let dic = {}
let flt = 1.1

function! s:typecheck(obj1, obj2)
  echo "comparing: " . string(a:obj1) . " and " . string( a:obj2 )
  return (type(a:obj1) == type(a:obj2))
endfunction

" ordinary invocation
echo s:typecheck({}, {'a':"a"})
echo '---------------------------------------'

" fix first argment, and get object with 'call' member
let Is_num  = s:curry(function('s:typecheck'), num)
let Is_str  = s:curry(function('s:typecheck'), str)
let Is_Fref = s:curry(function('s:typecheck'), Fref)
let Is_lis  = s:curry(function('s:typecheck'), lis)
let Is_dic  = s:curry(function('s:typecheck'), dic)
let Is_flt  = s:curry(function('s:typecheck'), flt)

echo Is_num.call(num)
echo Is_str.call(str)
echo Is_Fref.call(Fref)
echo Is_lis.call(lis)
echo Is_dic.call(dic)
echo Is_flt.call(flt)

"  Phrase: ujihisa's explanation
" ======================================================================
" But if you also want to preserve the definition of arguments? There are
" still solution of each cases.  Named arguments (or no arguments)
function! F1(x)
  return F2(a:x)
endfunction
call F1("a")|" => a

" Unnamed arguments
function! F1(...)
  return call('F2', a:000)
endfunction
call F1("a", "b", "c")|" => a b c

" Then you can make mixed version, using call().
function! F1(x, ...)
  return call('F2', insert(deepcopy(a:000), a:x))
endfunction
call F1("a", "b", "c")|" => a b c

"  Phrase: Call functions
" ======================================================================
" call function {{{
" call
" Signature:
"  call({func}, {arglist} [, {dict}])
" Args:
"  func: if 'Funcref' or 'name of function'
"  arglist: is 'list' of argment like ["arg1", "arg2" ]
"  dict: is 'dictionary' is used as self in function with 'dict'
"        attribute.
" Example:

function! F1(var)
  echo "F1" a:var
endfunction
echo "1)-- ordinary invocation"
call F1("abc")

echo "1)-- first arg is 'Funcref"
echo call(function('F1'),["abc"])

echo "3)--- or 'function name'"
call call('F1',["abc"])
"}}}

" dict type function {{{
" Function with 'dict' attribute can refer 'self'
" call'
function! F2(var) dict
  echo "F2" a:var self.data
endfunction
echo "4)--- 3'rd arg, dict is used as self in 'function'"
call call(function('F2'),["aa"], {'data': "abc" })
"}}}

" OOP style method and Js like bind function {{{
let o = {}
function! o.m1(var)
  echo "meth:f1" a:var self.data
endfunction
function! o.m2(var)
  echo "meth:m2" a:var self.data
endfunction
echo "5)--- OOP style method , Js like bind functon"
call call(o.m1, ["var"], {'data': "abc" })
call call(o.m2, ["var"], {'data': "abc" })
let o.data = "nnn"
call call(o.m1, ["var"], o)
"}}}

"  Phrase: Mode Line modeline
" ======================================================================
" Vim:
" vim: set sw=4 sts=4 et fdm=marker fdc=3 fdl=5:
" Help:
" vim:tw=78:ts=8:ft=help:norl:

"  Phrase: .local.vimrc
" ======================================================================
setlocal noswapfile

augroup UnderlineTag
  autocmd!
  autocmd BufEnter *.py UnderlineTagOn
augroup END
lcd <sfile>:h
set isk+=:,-

" Phrase: split window with direction specified
"======================================================================
nmap <Space>sj <SID>(split-to-j)
nmap <Space>sk <SID>(split-to-k)
nmap <Space>sh <SID>(split-to-h)
nmap <Space>sl <SID>(split-to-l)
nnoremap <SID>(split-to-j) :<C-u>call <SID>split_with('split', 0, 1)<CR>
nnoremap <SID>(split-to-k) :<C-u>call <SID>split_with('split', 0, 0)<CR>
nnoremap <SID>(split-to-h) :<C-u>call <SID>split_with('vsplit', 0, 0)<CR>
nnoremap <SID>(split-to-l) :<C-u>call <SID>split_with('vsplit', 1, 0)<CR>

function! s:split_with(excmd, splitright, splitbelow) "{{{
  let save_splitright = &splitright
  let save_splitbelow = &splitbelow
  let &l:splitright = a:splitright
  let &l:splitbelow = a:splitbelow
  try
    execute a:excmd
  finally
    let &l:splitright = save_splitright
    let &l:splitbelow = save_splitbelow
  endtry
endfunction "}}}

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

" Phrase: fnamemodify()
"============================================================
let fname = expand('%')
echo "fullpath:         " . fnamemodify(fname,":p")
echo "dirname:          " . fnamemodify(fname,":p:h")
echo "without ext:      " . fnamemodify(fname,":p:r")
echo "ext only:         " . fnamemodify(fname,":p:e")
echo "basename:         " . fnamemodify(fname,":p:t")
echo "basename w/o ext: " . fnamemodify(fname,":p:t:r")
" :h extension-removal
echo expand('%<')

" RESULT:
" fullpath:         /home/t9md/.vim/tryit/tryit.vim
" dirname:          /home/t9md/.vim/tryit
" without ext:      /home/t9md/.vim/tryit/tryit
" ext only:         vim
" basename:         tryit.vim
" basename w/o ext: tryit

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

function! s:SID()
    echo matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfunction
command! SID :call s:SID()

nnoremap <F2> :call s:SID()<CR>
" => NG: スクリプト以外でSIDが使われました。
"
nnoremap <F2> :call <SID>SID()<CR>
" => OK: <SID>_SID() は <SNR>123_SID() に変換される。<SNR>は

" ScriptNumbeRの事。
" Phrase: Someones good tips
"============================================================
" new items marked *N* , corrected items marked *C*
" searching
/joe/e                      : cursor set to End of match
3/joe/e+1                   : find 3rd joe cursor set to End of match plus 1 *C*
/joe/s-2                    : cursor set to Start of match minus 2
/joe/+3                     : find joe move cursor 3 lines down
/^joe.*fred.*bill/          : find joe AND fred AND Bill (Joe at start of line)
/^[A-J]/                    : search for lines beginning with one or more A-J
/begin\_.*end               : search over possible multiple lines
/fred\_s*joe/               : any whitespace including newline *C*
/fred\|joe                  : Search for FRED OR JOE
/.*fred\&.*joe              : Search for FRED AND JOE in any ORDER!
/\<fred\>/                  : search for fred but not alfred or frederick *C*
/\<\d\d\d\d\>               : Search for exactly 4 digit numbers
/\D\d\d\d\d\D               : Search for exactly 4 digit numbers
/\<\d\{4}\>                 : same thing
/\([^0-9]\|^\)%.*%          : Search for absence of a digit or beginning of line
" finding empty lines
/^\n\{3}                    : find 3 empty lines
/^str.*\nstr                : find 2 successive lines starting with str
/\(^str.*\n\)\{2}           : find 2 successive lines starting with str
" using rexexp memory in a search
/\(fred\).*\(joe\).*\2.*\1
" Repeating the Regexp (rather than what the Regexp finds)
/^\([^,]*,\)\{8}
" visual searching
:vmap // y/<C-R>"<CR>       : search for visually highlighted text
:vmap <silent> //    y/<C-R>=escape(@", '\\/.*$^~[]')<CR><CR> : with spec chars
" \zs and \ze regex delimiters :h /\zs
/<\zs[^>]*\ze>              : search for tag contents, ignoring chevrons
" zero-width :h /\@=
/<\@<=[^>]*>\@=             : search for tag contents, ignoring chevrons
/<\@<=\_[^>]*>\@=           : search for tags across possible multiple lines
" searching over multiple lines \_ means including newline
/<!--\_p\{-}-->                   : search for multiple line comments
/fred\_s*joe/                     : any whitespace including newline *C*
/bugs\(\_.\)*bunny                : bugs followed by bunny anywhere in file
:h \_                             : help
" search for declaration of subroutine/function under cursor
:nmap gx yiw/^\(sub\<bar>function\)\s\+<C-R>"<CR>
" multiple file search
:bufdo /searchstr/                : use :rewind to recommence search
" multiple file search better but cheating
:bufdo %s/searchstr/&/gic   : say n and then a to stop
" How to search for a URL without backslashing
?http://www.vim.org/        : (first) search BACKWARDS!!! clever huh!
" Specify what you are NOT searching for (vowels)
/\c\v([^aeiou]&\a){4}       : search for 4 consecutive consonants
/\%>20l\%<30lgoat           : Search for goat between lines 20 and 30 *N*
/^.\{-}home.\{-}\zshome/e   : match only the 2nd occurence in a line of "home" *N*
:%s/home.\{-}\zshome/alone  : Substitute only the occurrence of home in any line *N*
" find str but not on lines containing tongue
^\(.*tongue.*\)\@!.*nose.*$
\v^((tongue)@!.)*nose((tongue)@!.)*$
.*nose.*\&^\%(\%(tongue\)\@!.\)*$
:v/tongue/s/nose/&/gic
"----------------------------------------
"substitution
:%s/fred/joe/igc            : general substitute command
:%s//joe/igc                : Substitute what you last searched for *N*
:%s/~/sue/igc               : Substitute your last replacement string *N*
:%s/\r//g                   : Delete DOS returns ^M
" Is your Text File jumbled onto one line? use following
:%s/\r/\r/g                 : Turn DOS returns ^M into real returns
:%s=  *$==                  : delete end of line blanks
:%s= \+$==                  : Same thing
:%s#\s*\r\?$##              : Clean both trailing spaces AND DOS returns
:%s#\s*\r*$##               : same thing
" deleting empty lines
:%s/^\n\{3}//               : delete blocks of 3 empty lines
:%s/^\n\+/\r/               : compressing empty lines
:%s#<[^>]\+>##g             : delete html tags, leave text (non-greedy)
:%s#<\_.\{-1,}>##g          : delete html tags possibly multi-line (non-greedy)
:%s#.*\(\d\+hours\).*#\1#   : Delete all but memorised string (\1) *N*
" VIM Power Substitute
:'a,'bg/fred/s/dick/joe/igc : VERY USEFUL
" duplicating columns
:%s= [^ ]\+$=&&=            : duplicate end column
:%s= \f\+$=&&=              : same thing
:%s= \S\+$=&&               : usually the same
" memory
%s#.*\(tbl_\w\+\).*#\1#     : produce a list of all strings tbl_*   *N*
:s/\(.*\):\(.*\)/\2 : \1/   : reverse fields separated by :
:%s/^\(.*\)\n\1$/\1/        : delete duplicate lines
" non-greedy matching \{-}
:%s/^.\{-}pdf/new.pdf/      : delete to 1st pdf only
" use of optional atom \?
:%s#\<[zy]\?tbl_[a-z_]\+\>#\L&#gc : lowercase with optional leading characters
" over possibly many lines
:%s/<!--\_.\{-}-->//        : delete possibly multi-line comments
:help /\{-}                 : help non-greedy
" substitute using a register
:s/fred/<c-r>a/g            : sub "fred" with contents of register "a"
:s/fred/<c-r>asome_text<c-r>s/g
:s/fred/\=@a/g              : better alternative as register not displayed
" multiple commands on one line
:%s/\f\+\.gif\>/\r&\r/g | v/\.gif$/d | %s/gif/jpg/
:%s/a/but/gie|:update|:next : then use @: to repeat
" ORing
:%s/goat\|cow/sheep/gc      : ORing (must break pipe)
:%s/\v(.*\n){5}/&\r         : insert a blank line every 5 lines *N*
" Calling a VIM function
:s/__date__/\=strftime("%c")/ : insert datestring
" Working with Columns sub any str1 in col3
:%s:\(\(\w\+\s\+\)\{2}\)str1:\1str2:
" Swapping first & last column (4 columns)
:%s:\(\w\+\)\(.*\s\+\)\(\w\+\)$:\3\2\1:
" format a mysql query
:%s#\<from\>\|\<where\>\|\<left join\>\|\<\inner join\>#\r&#g
" filter all form elements into paste register
:redir @*|sil exec 'g#<\(input\|select\|textarea\|/\=form\)\>#p'|redir END
:nmap ,z :redir @*<Bar>sil exec 'g@<\(input\<Bar>select\<Bar>textarea\<Bar>/\=form\)\>@p'<Bar>redir END<CR>
" substitute string in column 30 *N*
:%s/^\(.\{30\}\)xx/\1yy/
" decrement numbers by 3
:%s/\d\+/\=(submatch(0)-3)/
" increment numbers by 6 on certain lines only
:g/loc\|function/s/\d/\=submatch(0)+6/
" better
:%s#txtdev\zs\d#\=submatch(0)+1#g
:h /\zs
" increment only numbers gg\d\d  by 6 (another way)
:%s/\(gg\)\@<=\d\+/\=submatch(0)+6/
:h zero-width
" rename a string with an incrementing number
:let i=10 | 'a,'bg/Abc/s/yy/\=i/ |let i=i+1 # convert yy to 10,11,12 etc
" as above but more precise
:let i=10 | 'a,'bg/Abc/s/xx\zsyy\ze/\=i/ |let i=i+1 # convert xxyy to xx11,xx12,xx13
" find replacement text, put in memory, then use \zs to simplify substitute
:%s/"\([^.]\+\).*\zsxx/\1/
" Pull word under cursor into LHS of a substitute
:nmap <leader>z :%s#\<<c-r>=expand("<cword>")<cr>\>#
" Pull Visually Highlighted text into LHS of a substitute
:vmap <leader>z :<C-U>%s/\<<c-r>*\>/
" substitute singular or plural
:'a,'bs/bucket\(s\)*/bowl\1/gic   *N*
----------------------------------------
" all following performing similar task, substitute within substitution
" Multiple single character substitution in a portion of line only
:%s,\(all/.*\)\@<=/,_,g     : replace all / with _ AFTER "all/"
" Same thing
:s#all/\zs.*#\=substitute(submatch(0), '/', '_', 'g')#
" Substitute by splitting line, then re-joining
:s#all/#&^M#|s#/#_#g|-j!
" Substitute inside substitute
:%s/.*/\='cp '.submatch(0).' all/'.substitute(submatch(0),'/','_','g')/
----------------------------------------
" global command display
:g/gladiolli/#              : display with line numbers (YOU WANT THIS!)
:g/fred.*joe.*dick/         : display all lines fred,joe & dick
:g/\<fred\>/                : display all lines fred but not freddy
:g/^\s*$/d                  : delete all blank lines
:g!/^dd/d                   : delete lines not containing string
:v/^dd/d                    : delete lines not containing string
:g/joe/,/fred/d             : not line based (very powerfull)
:g/fred/,/joe/j             : Join Lines *N*
:g/-------/.-10,.d          : Delete string & 10 previous lines
:g/{/ ,/}/- s/\n\+/\r/g     : Delete empty lines but only between {...}
:v/\S/d                     : Delete empty lines (and blank lines ie whitespace)
:v/./,/./-j                 : compress empty lines
:g/^$/,/./-j                : compress empty lines
:g/<input\|<form/p          : ORing
:g/^/put_                   : double space file (pu = put)
:g/^/m0                     : Reverse file (m = move)
:g/^/m$                     : No effect! *N*
:'a,'bg/^/m'b               : Reverse a section a to b
:g/^/t.                     : duplicate every line
:g/fred/t$                  : copy(transfer) lines matching fred to EOF
:g/stage/t'a                : copy (transfer) lines matching stage to marker a (cannot use .) *C*
:g/^Chapter/t.|s/./-/g      : Automatically underline selecting headings *N*
:g/\(^I[^^I]*\)\{80}/d      : delete all lines containing at least 80 tabs
" perform a substitute on every other line
:g/^/ if line('.')%2|s/^/zz /
" match all lines containing "somestr" between markers a & b
" copy after line containing "otherstr"
:'a,'bg/somestr/co/otherstr/ : co(py) or mo(ve)
" as above but also do a substitution
:'a,'bg/str1/s/str1/&&&/|mo/str2/
:%norm jdd                  : delete every other line
" incrementing numbers (type <c-a> as 5 characters)
:.,$g/^\d/exe "norm! \<c-a>": increment numbers
:'a,'bg/\d\+/norm! ^A       : increment numbers
" storing glob results (note must use APPEND) you need to empty reg a first with qaq.
"save results to a register/paste buffer
:g/fred/y A                 : append all lines fred to register a
:g/fred/y A | :let @*=@a    : put into paste buffer
:let @a=''|g/Barratt/y A |:let @*=@a
" filter lines to a file (file must already exist)
:'a,'bg/^Error/ . w >> errors.txt
" duplicate every line in a file wrap a print '' around each duplicate
:g/./yank|put|-1s/'/"/g|s/.*/Print '&'/
" replace string with contents of a file, -d deletes the "mark"
:g/^MARK$/r tmp.txt | -d
" display prettily
:g/<pattern>/z#.5           : display with context
:g/<pattern>/z#.5|echo "=========="  : display beautifully
" Combining g// with normal mode commands
:g/|/norm 2f|r*                      : replace 2nd | with a star
"send output of previous global command to a new window
:nmap <F3>  :redir @a<CR>:g//<CR>:redir END<CR>:new<CR>:put! a<CR><CR>
"----------------------------------------
" Global combined with substitute (power editing)
:'a,'bg/fred/s/joe/susan/gic :  can use memory to extend matching
:/fred/,/joe/s/fred/joe/gic :  non-line based (ultra)
:/biz/,/any/g/article/s/wheel/bucket/gic:  non-line based *N*
----------------------------------------
" Find fred before beginning search for joe
:/fred/;/joe/-2,/sid/+3s/sally/alley/gIC
"----------------------------------------
" create a new file for each line of file eg 1.txt,2.txt,3,txt etc
:g/^/exe ".w ".line(".").".txt"
"----------------------------------------
" chain an external command
:.g/^/ exe ".!sed 's/N/X/'" | s/I/Q/    *N*
"----------------------------------------
" Operate until string found *N*
d/fred/                                :delete until fred
y/fred/                                :yank until fred
c/fred/e                               :change until fred end
"----------------------------------------
" Summary of editing repeats *N*
.      last edit (magic dot)
:&     last substitute
:%&    last substitute every line
:%&gic last substitute every line confirm
g%     normal mode repeat last substitute
g&     last substitute on all lines
@@     last recording
@:     last command-mode command
:!!    last :! command
:~     last substitute
:help repeating
----------------------------------------
" Summary of repeated searches
;      last f, t, F or T
,      last f, t, F or T in opposite direction
n      last / or ? search
N      last / or ? search in opposite direction
----------------------------------------
" Absolutely essential
----------------------------------------
* # g* g#           : find word under cursor (<cword>) (forwards/backwards)
%                   : match brackets {}[]()
.                   : repeat last modification
@:                  : repeat last : command (then @@)
matchit.vim         : % now matches tags <tr><td><script> <?php etc
<C-N><C-P>          : word completion in insert mode
<C-X><C-L>          : Line complete SUPER USEFUL
/<C-R><C-W>         : Pull <cword> onto search/command line
/<C-R><C-A>         : Pull <CWORD> onto search/command line
:set ignorecase     : you nearly always want this
:set smartcase      : overrides ignorecase if uppercase used in search string (cool)
:syntax on          : colour syntax in Perl,HTML,PHP etc
:set syntax=perl    : force syntax (usually taken from file extension)
:h regexp<C-D>      : type control-D and get a list all help topics containing
                      regexp (plus use TAB to Step thru list)
----------------------------------------
" MAKE IT EASY TO UPDATE/RELOAD _vimrc
:nmap ,s :source $VIM/_vimrc
:nmap ,v :e $VIM/_vimrc
:e $MYVIMRC         : edits your _vimrc whereever it might be  *N*
" How to have a variant in your .vimrc for different PCs *N*
if $COMPUTERNAME == "NEWPC"
ab mypc vista
else
ab mypc dell25
endif
----------------------------------------
" splitting windows
:vsplit other.php       # vertically split current file with other.php *N*
----------------------------------------
"VISUAL MODE (easy to add other HTML Tags)
:vmap sb "zdi<b><C-R>z</b><ESC>  : wrap <b></b> around VISUALLY selected Text
:vmap st "zdi<?= <C-R>z ?><ESC>  : wrap <?=   ?> around VISUALLY selected Text
----------------------------------------
"vim 7 tabs
vim -p fred.php joe.php             : open files in tabs
:tabe fred.php                      : open fred.php in a new tab
:tab ball                           : tab open files
" vim 7 forcing use of tabs from .vimrc
:nnoremap gf <C-W>gf
:cab      e  tabe
:tab sball                           : retab all files in buffer (repair) *N*
----------------------------------------
" Exploring
:e .                            : file explorer
:Exp(lore)                      : file explorer note capital Ex
:Sex(plore)                     : file explorer in split window
:browse e                       : windows style browser
:ls                             : list of buffers
:cd ..                          : move to parent directory
:args                           : list of files
:args *.php                     : open list of files (you need this!)
:lcd %:p:h                      : change to directory of current file
:autocmd BufEnter * lcd %:p:h   : change to directory of current file automatically (put in _vimrc)
----------------------------------------
" Changing Case
guu                             : lowercase line
gUU                             : uppercase line
Vu                              : lowercase line
VU                              : uppercase line
g~~                             : flip case line
vEU                             : Upper Case Word
vE~                             : Flip Case Word
ggguG                           : lowercase entire file
" Titlise Visually Selected Text (map for .vimrc)
vmap ,c :s/\<\(.\)\(\k*\)\>/\u\1\L\2/g<CR>
" titlise a line
nmap ,t :s/.*/\L&/<bar>:s/\<./\u&/g<cr>  *N*
" Uppercase first letter of sentences
:%s/[.!?]\_s\+\a/\U&\E/g
----------------------------------------
gf                              : open file name under cursor (SUPER)
:nnoremap gF :view <cfile><cr>  : open file under cursor, create if necessary
ga                              : display hex,ascii value of char under cursor
ggVGg?                          : rot13 whole file
ggg?G                           : rot13 whole file (quicker for large file)
:8 | normal VGg?                : rot13 from line 8
:normal 10GVGg?                 : rot13 from line 8
<C-A>,<C-X>                     : increment,decrement number under cursor
                                  win32 users must remap CNTRL-A
<C-R>=5*5                       : insert 25 into text (mini-calculator)
----------------------------------------
" Make all other tips superfluous
:h 42            : also http://www.google.com/search?q=42
:h holy-grail
:h!
----------------------------------------
" disguise text (watch out) *N*
ggVGg?                          : rot13 whole file (toggles)
:set rl!                        : reverse lines right to left (toggles)
:g/^/m0                         : reverse lines top to bottom (toggles)
----------------------------------------
" Markers & moving about
'.               : jump to last modification line (SUPER)
`.               : jump to exact spot in last modification line
g;               : cycle thru recent changes (oldest first)
g,               : reverse direction
:changes
:h changelist    : help for above
<C-O>            : retrace your movements in file (starting from most recent)
<C-I>            : retrace your movements in file (reverse direction)
:ju(mps)         : list of your movements
:help jump-motions
:history         : list of all your commands
:his c           : commandline history
:his s           : search history
q/               : Search history Window (puts you in full edit mode) (exit CTRL-C)
q:               : commandline history Window (puts you in full edit mode) (exit CTRL-C)
:<C-F>           : history Window (exit CTRL-C)
----------------------------------------
" Abbreviations & Maps
" Following 4 maps enable text transfer between VIM sessions
:map   <f7>   :'a,'bw! c:/aaa/x       : save text to file x
:map   <f8>   :r c:/aaa/x             : retrieve text
:map   <f11>  :.w! c:/aaa/xr<CR>      : store current line
:map   <f12>  :r c:/aaa/xr<CR>        : retrieve current line
:ab php          : list of abbreviations beginning php
:map ,           : list of maps beginning ,
" allow use of F10 for mapping (win32)
set wak=no       : :h winaltkeys
" For use in Maps
<CR>             : carriage Return for maps
<ESC>            : Escape
<LEADER>         : normally \
<BAR>            : | pipe
<BACKSPACE>      : backspace
<SILENT>         : No hanging shell window
#display RGB colour under the cursor eg #445588
:nmap <leader>c :hi Normal guibg=#<c-r>=expand("<cword>")<cr><cr>
map <f2> /price only\\|versus/ :in a map need to backslash the \
# type table,,, to get <table></table>       ### Cool ###
imap ,,, <esc>bdwa<<esc>pa><cr></<esc>pa><esc>kA
----------------------------------------
" Simple PHP debugging display all variables yanked into register a
iab phpdb exit("<hr>Debug <C-R>a  ");
----------------------------------------
" Using a register as a map (preload registers in .vimrc)
:let @m=":'a,'bs/"
:let @s=":%!sort -u"
----------------------------------------
" Useful tricks
"ayy@a           : execute "Vim command" in a text file
yy@"             : same thing using unnamed register
u@.              : execute command JUST typed in
"ddw             : store what you delete in register d *N*
"ccaw            : store what you change in register c *N*
----------------------------------------
" Get output from other commands (requires external programs)
:r!ls -R         : reads in output of ls
:put=glob('**')  : same as above                 *N*
:r !grep "^ebay" file.txt  : grepping in content   *N*
:20,25 !rot13    : rot13 lines 20 to 25   *N*
!!date           : same thing (but replaces/filters current line)
" Sorting with external sort
:%!sort -u       : use an external program to filter content
:'a,'b!sort -u   : use an external program to filter content
!1} sort -u      : sorts paragraph (note normal mode!!)
:g/^$/;,/^$/-1!sort : Sort each block (note the crucial ;)
" Sorting with internal sort
:sort /.*\%2v/   : sort all lines on second column *N*
" number lines
:new | r!nl #                  *N*
----------------------------------------
" Multiple Files Management (Essential)
:bn              : goto next buffer
:bp              : goto previous buffer
:wn              : save file and move to next (super)
:wp              : save file and move to previous
:bd              : remove file from buffer list (super)
:bun             : Buffer unload (remove window but not from list)
:badd file.c     : file from buffer list
:b3              : go to buffer 3 *C*
:b main          : go to buffer with main in name eg main.c (ultra)
:sav php.html    : Save current file as php.html and "move" to php.html
:sav! %<.bak     : Save Current file to alternative extension (old way)
:sav! %:r.cfm    : Save Current file to alternative extension
:sav %:s/fred/joe/           : do a substitute on file name
:sav %:s/fred/joe/:r.bak2    : do a substitute on file name & ext.
:!mv % %:r.bak   : rename current file (DOS use Rename or DEL)
:help filename-modifiers
:e!              : return to unmodified file
:w c:/aaa/%      : save file elsewhere
:e #             : edit alternative file (also cntrl-^)
:rew             : return to beginning of edited files list (:args)
:brew            : buffer rewind
:sp fred.txt     : open fred.txt into a split
:sball,:sb       : Split all buffers (super)
:scrollbind      : in each split window
:map   <F5> :ls<CR>:e # : Pressing F5 lists all buffer, just type number
:set hidden      : Allows to change buffer w/o saving current buffer
----------------------------------------
" Quick jumping between splits
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_
----------------------------------------
" Recording (BEST TIP of ALL)
qq  # record to q
your complex series of commands
q   # end recording
@q to execute
@@ to Repeat
5@@ to Repeat 5 times
qQ@qq                             : Make an existing recording q recursive *N*
" editing a register/recording
"qp                               :display contents of register q (normal mode)
<ctrl-R>q                         :display contents of register q (insert mode)
" you can now see recording contents, edit as required
"qdd                              :put changed contacts back into q
@q                                :execute recording/register q
" Operating a Recording on a Visual BLOCK
1) define recording/register
qq:s/ to/ from/g^Mq
2) Define Visual BLOCK
V}
3) hit : and the following appears
:'<,'>
4)Complete as follows
:'<,'>norm @q
----------------------------------------
"combining a recording with a map (to end up in command mode)
:nnoremap ] @q:update<bar>bd
----------------------------------------
" Visual is the newest and usually the most intuitive editing mode
" Visual basics
v                               : enter visual mode
V                               : visual mode whole line
<C-V>                           : enter VISUAL BLOCK mode
gv                              : reselect last visual area (ultra)
o                               : navigate visual area
"*y or "+y                      : yank visual area into paste buffer  *C*
V%                              : visualise what you match
V}J                             : Join Visual block (great)
V}gJ                            : Join Visual block w/o adding spaces
`[v`]                           : Highlight last insert
:%s/\%Vold/new/g                : Do a substitute on last visual area *N*
----------------------------------------
" Delete first 2 characters of 10 successive lines
0<c-v>10j2ld  (use Control Q on win32) *C*
----------------------------------------
" how to copy a set of columns using VISUAL BLOCK
" visual block (AKA columnwise selection) (NOT BY ordinary v command)
<C-V> then select "column(s)" with motion commands (win32 <C-Q>)
then c,d,y,r etc
----------------------------------------
" how to overwrite a visual-block of text with another such block *C*
" move with hjkl etc
Pick the first block: ctrl-v move y
Pick the second block: ctrl-v move P <esc>
----------------------------------------
" text objects :h text-objects                                     *C*
daW                                   : delete contiguous non whitespace
di<   yi<  ci<                        : Delete/Yank/Change HTML tag contents
da<   ya<  ca<                        : Delete/Yank/Change whole HTML tag
dat   dit                             : Delete HTML tag pair
diB   daB                             : Empty a function {}
das                                   : delete a sentence
----------------------------------------
" _vimrc essentials
:set incsearch : jumps to search word as you type (annoying but excellent)
:set wildignore=*.o,*.obj,*.bak,*.exe : tab complete now ignores these
:set shiftwidth=3                     : for shift/tabbing
:set vb t_vb=".                       : set silent (no beep)
:set browsedir=buffer                 : Maki GUI File Open use current directory
----------------------------------------
" launching Win IE
:nmap ,f :update<CR>:silent !start c:\progra~1\intern~1\iexplore.exe file://%:p<CR>
:nmap ,i :update<CR>: !start c:\progra~1\intern~1\iexplore.exe <cWORD><CR>
----------------------------------------
" FTPing from VIM
cmap ,r  :Nread ftp://209.51.134.122/public_html/index.html
cmap ,w  :Nwrite ftp://209.51.134.122/public_html/index.html
gvim ftp://www.somedomain.com/index.html # uses netrw.vim
----------------------------------------
" appending to registers (use CAPITAL)
" yank 5 lines into "a" then add a further 5
"a5yy
10j
"A5yy
----------------------------------------
[I     : show lines matching word under cursor <cword> (super)
----------------------------------------
" Conventional Shifting/Indenting
:'a,'b>>
" visual shifting (builtin-repeat)
:vnoremap < <gv
:vnoremap > >gv
" Block shifting (magic)
>i{
>a{
" also
>% and <%
----------------------------------------
" Redirection & Paste register *
:redir @*                    : redirect commands to paste buffer
:redir END                   : end redirect
:redir >> out.txt            : redirect to a file
" Working with Paste buffer
"*yy                         : yank curent line to paste
"*p                          : insert from paste buffer
" yank to paste buffer (ex mode)
:'a,'by*                     : Yank range into paste
:%y*                         : Yank whole buffer into paste
:.y*                         : Yank Current line to paster
" filter non-printable characters from the paste buffer
" useful when pasting from some gui application
:nmap <leader>p :let @* = substitute(@*,'[^[:print:]]','','g')<cr>"*p
----------------------------------------
" Re-Formatting text
gq}                          : Format a paragraph
gqap                         : Format a paragraph
ggVGgq                       : Reformat entire file
Vgq                          : current line
" break lines at 70 chars, if possible after a ;
:s/.\{,69\};\s*\|.\{,69\}\s\+/&\r/g
----------------------------------------
" Operate command over multiple files
:argdo %s/foo/bar/e          : operate on all files in :args
:bufdo %s/foo/bar/e
:windo %s/foo/bar/e
:argdo exe '%!sort'|w!       : include an external command
:bufdo exe "normal @q" | w   : perform a recording on open files
:silent bufdo !zip proj.zip %:p   : zip all current files
----------------------------------------
" Command line tricks
gvim -h                    : help
ls | gvim -                : edit a stream!!
cat xx | gvim - -c "v/^\d\d\|^[3-9]/d " : filter a stream
gvim -o file1 file2        : open into a split
" execute one command after opening file
gvim.exe -c "/main" joe.c  : Open joe.c & jump to "main"
" execute multiple command on a single file
vim -c "%s/ABC/DEF/ge | update" file1.c
" execute multiple command on a group of files
vim -c "argdo %s/ABC/DEF/ge | update" *.c
" remove blocks of text from a series of files
vim -c "argdo /begin/+1,/end/-1g/^/d | update" *.c
" Automate editing of a file (Ex commands in convert.vim)
vim -s "convert.vim" file.c
#load VIM without .vimrc and plugins (clean VIM)
gvim -u NONE -U NONE -N
" Access paste buffer contents (put in a script/batch file)
gvim -c 'normal ggdG"*p' c:/aaa/xp
" print paste contents to default printer
gvim -c 's/^/\=@*/|hardcopy!|q!'
" gvim's use of external grep (win32 or *nix)
:!grep somestring *.php     : creates a list of all matching files *C*
" use :cn(ext) :cp(rev) to navigate list
:h grep
" Using vimgrep with copen                              *N*
:vimgrep /keywords/ *.php
:copen
----------------------------------------
" GVIM Difference Function (Brilliant)
gvim -d file1 file2        : vimdiff (compare differences)
dp                         : "put" difference under cursor to other file
do                         : "get" difference under cursor from other file
" complex diff parts of same file *N*
:1,2yank a | 7,8yank b
:tabedit | put a | vnew | put b
:windo diffthis
----------------------------------------
" Vim traps
In regular expressions you must backslash + (match 1 or more)
In regular expressions you must backslash | (or)
In regular expressions you must backslash ( (group)
In regular expressions you must backslash { (count)
/fred\+/                   : matches fred/freddy but not free
/\(fred\)\{2,3}/           : note what you have to break
----------------------------------------
" \v or very magic (usually) reduces backslashing
/codes\(\n\|\s\)*where  : normal regexp
/\vcodes(\n|\s)*where   : very magic
----------------------------------------
" pulling objects onto command/search line (SUPER)
<C-R><C-W> : pull word under the cursor into a command line or search
<C-R><C-A> : pull WORD under the cursor into a command line or search
<C-R>-                  : pull small register (also insert mode)
<C-R>[0-9a-z]           : pull named registers (also insert mode)
<C-R>%                  : pull file name (also #) (also insert mode)
<C-R>=somevar           : pull contents of a variable (eg :let sray="ray[0-9]")
----------------------------------------
" List your Registers
:reg             : display contents of all registers
:reg a           : display content of register a
:reg 12a         : display content of registers 1,2 & a *N*
"5p              : retrieve 5th "ring"
"1p....          : retrieve numeric registers one by one
:let @y='yy@"'   : pre-loading registers (put in .vimrc)
qqq              : empty register "q"
qaq              : empty register "a"
:reg .-/%:*"     : the seven special registers *N*
:reg 0           : what you last yanked, not affected by a delete *N*
"_dd             : Delete to blackhole register "_ , don't affect any register *N*
----------------------------------------
" manipulating registers
:let @a=@_              : clear register a
:let @a=""              : clear register a
:let @a=@"              : Save unnamed register *N*
:let @*=@a              : copy register a to paste buffer
:let @*=@:              : copy last command to paste buffer
:let @*=@/              : copy last search to paste buffer
:let @*=@%              : copy current filename to paste buffer
----------------------------------------
" help for help (USE TAB)
:h quickref             : VIM Quick Reference Sheet (ultra)
:h tips                 : Vim's own Tips Help
:h visual<C-D><tab>     : obtain  list of all visual help topics
                        : Then use tab to step thru them
:h ctrl<C-D>            : list help of all control keys
:helpg uganda           : grep HELP Files use :cn, :cp to find next
:helpgrep edit.*director: grep help using regexp
:h :r                   : help for :ex command
:h CTRL-R               : normal mode
:h /\r                  : what's \r in a regexp (matches a <CR>)
:h \\zs                 : double up backslash to find \zs in help
:h i_CTRL-R             : help for say <C-R> in insert mode
:h c_CTRL-R             : help for say <C-R> in command mode
:h v_CTRL-V             : visual mode
:h tutor                : VIM Tutor
<C-[>, <C-T>            : Move back & Forth in HELP History
gvim -h                 : VIM Command Line Help
:cabbrev h tab h        : open help in a tab *N*
----------------------------------------
" where was an option set
:scriptnames            : list all plugins, _vimrcs loaded (super)
:verbose set history?   : reveals value of history and where set
:function               : list functions
:func SearchCompl       : List particular function
----------------------------------------
" making your own VIM help
:helptags /vim/vim64/doc  : rebuild all *.txt help files in /doc
:help add-local-help
----------------------------------------
" running file thru an external program (eg php)
map   <f9>   :w<CR>:!c:/php/php.exe %<CR>
map   <f2>   :w<CR>:!perl -c %<CR>
----------------------------------------
" capturing output of current script in a separate buffer
:new | r!perl #                   : opens new buffer,read other buffer
:new! x.out | r!perl #            : same with named file
:new+read!ls
----------------------------------------
" create a new buffer, paste a register "q" into it, then sort new buffer
:new +put q|%!sort
----------------------------------------
" Inserting DOS Carriage Returns
:%s/$/\<C-V><C-M>&/g          :  that's what you type
:%s/$/\<C-Q><C-M>&/g          :  for Win32
:%s/$/\^M&/g                  :  what you'll see where ^M is ONE character
----------------------------------------
" automatically delete trailing Dos-returns,whitespace
autocmd BufRead * silent! %s/[\r \t]\+$//
autocmd BufEnter *.php :%s/[ \t\r]\+$//e
----------------------------------------
" perform an action on a particular file or file type
autocmd VimEnter c:/intranet/note011.txt normal! ggVGg?
autocmd FileType *.pl exec('set fileformats=unix')
----------------------------------------
" Retrieving last command line command for copy & pasting into text
i<c-r>:
" Retrieving last Search Command for copy & pasting into text
i<c-r>/
----------------------------------------
" more completions
<C-X><C-F>                        :insert name of a file in current directory
----------------------------------------
" Substituting a Visual area
" select visual area as usual (:h visual) then type :s/Emacs/Vim/ etc
:'<,'>s/Emacs/Vim/g               : REMEMBER you dont type the '<.'>
gv                                : Re-select the previous visual area (ULTRA)
----------------------------------------
" inserting line number into file
:g/^/exec "s/^/".strpart(line(".")."    ", 0, 4)
:%s/^/\=strpart(line(".")."     ", 0, 5)
:%s/^/\=line('.'). ' '
----------------------------------------
#numbering lines VIM way
:set number                       : show line numbers
:map <F12> :set number!<CR>       : Show linenumbers flip-flop
:%s/^/\=strpart(line('.')."        ",0,&ts)
#numbering lines (need Perl on PC) starting from arbitrary number
:'a,'b!perl -pne 'BEGIN{$a=223} substr($_,2,0)=$a++'
#Produce a list of numbers
#Type in number on line say 223 in an empty file
qqmnYP`n^Aq                       : in recording q repeat with @q
" increment existing numbers to end of file (type <c-a> as 5 characters)
:.,$g/^\d/exe "normal! \<c-a>"
" advanced incrementing
http://vim.sourceforge.net/tip_view.php?tip_id=150
----------------------------------------
" advanced incrementing (really useful)
" put following in _vimrc
let g:I=0
function! INC(increment)
let g:I =g:I + a:increment
return g:I
endfunction
" eg create list starting from 223 incrementing by 5 between markers a,b
:let I=223
:'a,'bs/^/\=INC(5)/
" create a map for INC
cab viminc :let I=223 \| 'a,'bs/$/\=INC(5)/
----------------------------------------
" generate a list of numbers  23-64
o23<ESC>qqYp<C-A>q40@q
----------------------------------------
" editing/moving within current insert (Really useful)
<C-U>                             : delete all entered
<C-W>                             : delete last word
<HOME><END>                       : beginning/end of line
<C-LEFTARROW><C-RIGHTARROW>       : jump one word backwards/forwards
<C-X><C-E>,<C-X><C-Y>             : scroll while staying put in insert
----------------------------------------
#encryption (use with care: DON'T FORGET your KEY)
:X                                : you will be prompted for a key
:h :X
----------------------------------------
" modeline (make a file readonly etc) must be in first/last 5 lines
// vim:noai:ts=2:sw=4:readonly:
" vim:ft=html:                    : says use HTML Syntax highlighting
:h modeline
----------------------------------------
" Creating your own GUI Toolbar entry
amenu  Modeline.Insert\ a\ VIM\ modeline <Esc><Esc>ggOvim:ff=unix ts=4 ss=4<CR>vim60:fdm=marker<esc>gg
----------------------------------------
" A function to save word under cursor to a file
function! SaveWord()
   normal yiw
   exe ':!echo '.@0.' >> word.txt'
endfunction
map ,p :call SaveWord()
----------------------------------------
" function to delete duplicate lines
function! Del()
 if getline(".") == getline(line(".") - 1)
   norm dd
 endif
endfunction

:g/^/ call Del()
----------------------------------------
" Digraphs (non alpha-numerics)
:digraphs                         : display table
:h dig                            : help
i<C-K>e'                          : enters é
i<C-V>233                         : enters é (Unix)
i<C-Q>233                         : enters é (Win32)
ga                                : View hex value of any character
#Deleting non-ascii characters (some invisible)
:%s/[\x00-\x1f\x80-\xff]/ /g      : type this as you see it
:%s/[<C-V>128-<C-V>255]//gi       : where you have to type the Control-V
:%s/[€-ÿ]//gi                     : Should see a black square & a dotted y
:%s/[<C-V>128-<C-V>255<C-V>01-<C-V>31]//gi : All pesky non-asciis
:exec "norm /[\x00-\x1f\x80-\xff]/"        : same thing
#Pull a non-ascii character onto search bar
yl/<C-R>"                         :
/[^a-zA-Z0-9_[:space:][:punct:]]  : search for all non-ascii
----------------------------------------
" All file completions grouped (for example main_c.c)
:e main_<tab>                     : tab completes
gf                                : open file under cursor  (normal)
main_<C-X><C-F>                   : include NAME of file in text (insert mode)
----------------------------------------
" Complex Vim
" swap two words
:%s/\<\(on\|off\)\>/\=strpart("offon", 3 * ("off" == submatch(0)), 3)/g
" swap two words
:vnoremap <C-X> <Esc>`.``gvP``P
" Swap word with next word
nmap <silent> gw    "_yiw:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<cr><c-o><c-l> *N*
----------------------------------------
" Convert Text File to HTML
:runtime! syntax/2html.vim        : convert txt to html
:h 2html
----------------------------------------
" VIM has internal grep
:grep some_keyword *.c            : get list of all c-files containing keyword
:cn                               : go to next occurrence
----------------------------------------
" Force Syntax coloring for a file that has no extension .pl
:set syntax=perl
" Remove syntax coloring (useful for all sorts of reasons)
:set syntax off
" change coloring scheme (any file in ~vim/vim??/colors)
:colorscheme blue
" Force HTML Syntax highlighting by using a modeline
# vim:ft=html:
" Force syntax automatically (for a file with non-standard extension)
au BufRead,BufNewFile */Content.IE?/* setfiletype html
----------------------------------------
:set noma (non modifiable)        : Prevents modifications
:set ro (Read Only)               : Protect a file from unintentional writes
----------------------------------------
" Sessions (Open a set of files)
gvim file1.c file2.c lib/lib.h lib/lib2.h : load files for "session"
:mksession                        : Make a Session file (default Session.vim)
:q
gvim -S Session.vim               : Reload all files
----------------------------------------
#tags (jumping to subroutines/functions)
taglist.vim                       : popular plugin
:Tlist                            : display Tags (list of functions)
<C-]>                             : jump to function under cursor
----------------------------------------
" columnise a csv file for display only as may crop wide columns
:let width = 20
:let fill=' ' | while strlen(fill) < width | let fill=fill.fill | endwhile
:%s/\([^;]*\);\=/\=strpart(submatch(1).fill, 0, width)/ge
:%s/\s\+$//ge
" Highlight a particular csv column (put in .vimrc)
function! CSVH(x)
    execute 'match Keyword /^\([^,]*,\)\{'.a:x.'}\zs[^,]*/'
    execute 'normal ^'.a:x.'f,'
endfunction
command! -nargs=1 Csv :call CSVH(<args>)
" call with
:Csv 5                             : highlight fifth column
----------------------------------------
zf1G      : fold everything before this line *N*
" folding : hide sections to allow easier comparisons
zf}                               : fold paragraph using motion
v}zf                              : fold paragraph using visual
zf'a                              : fold to mark
zo                                : open fold
zc                                : re-close fold
:help folding
zfG      : fold everything after this line *N*
----------------------------------------
" displaying "non-asciis"
:set list
:h listchars
----------------------------------------
" How to paste "normal commands" w/o entering insert mode
:norm qqy$jq
----------------------------------------
" manipulating file names
:h filename-modifiers             : help
:w %                              : write to current file name
:w %:r.cfm                        : change file extention to .cfm
:!echo %:p                        : full path & file name
:!echo %:p:h                      : full path only
:!echo %:t                        : filename only
:reg %                            : display filename
<C-R>%                            : insert filename (insert mode)
"%p                               : insert filename (normal mode)
/<C-R>%                           : Search for file name in text
----------------------------------------
" delete without destroying default buffer contents
"_d                               : what you've ALWAYS wanted
"_dw                              : eg delete word (use blackhole)
----------------------------------------
" pull full path name into paste buffer for attachment to email etc
nnoremap <F2> :let @*=expand("%:p")<cr> :unix
nnoremap <F2> :let @*=substitute(expand("%:p"), "/", "\\", "g")<cr> :win32
----------------------------------------
" Simple Shell script to rename files w/o leaving vim
$ vim
:r! ls *.c
:%s/\(.*\).c/mv & \1.bla
:w !sh
:q!
----------------------------------------
" count words/lines in a text file
g<C-G>                                 # counts words
:echo line("'b")-line("'a")            # count lines between markers a and b *N*
:'a,'bs/^//n                           # count lines between markers a and b
:'a,'bs/somestring//gn                 # count occurences of a string
----------------------------------------
" example of setting your own highlighting
:syn match DoubleSpace "  "
:hi def DoubleSpace guibg=#e0e0e0
----------------------------------------
" reproduce previous line word by word
imap ]  @@@<ESC>hhkyWjl?@@@<CR>P/@@@<CR>3s
nmap ] i@@@<ESC>hhkyWjl?@@@<CR>P/@@@<CR>3s
" Programming keys depending on file type
:autocmd bufenter *.tex map <F1> :!latex %<CR>
:autocmd bufenter *.tex map <F2> :!xdvi -hush %<.dvi&<CR>
----------------------------------------
" reading Ms-Word documents, requires antiword
:autocmd BufReadPre *.doc set ro
:autocmd BufReadPre *.doc set hlsearch!
:autocmd BufReadPost *.doc %!antiword "%"
----------------------------------------
" a folding method
vim: filetype=help foldmethod=marker foldmarker=<<<,>>>
A really big section closed with a tag <<<
--- remember folds can be nested ---
Closing tag >>>
----------------------------------------
" Return to last edit position (You want this!) *N*
autocmd BufReadPost *
     \ if line("'\"") > 0 && line("'\"") <= line("$") |
     \   exe "normal! g`\"" |
     \ endif
----------------------------------------
" store text that is to be changed or deleted in register a
"act<                                 :  Change Till < *N*
----------------------------------------
# using gVIM with Cygwin on a Windows PC
if has('win32')
source $VIMRUNTIME/mswin.vim
behave mswin
set shell=c:\\cygwin\\bin\\bash.exe shellcmdflag=-c shellxquote=\"
endif
----------------------------------------
" Just Another Vim Hacker JAVH
vim -c ":%s%s*%Cyrnfr)fcbafbe[Oenz(Zbbyranne%|:%s)[[()])-)Ig|norm Vg?"
----------------------------------------
__END__
----------------------------------------
"Read Vimtips into a new vim buffer (needs w3m.sourceforge.net)
:tabe | :r ! w3m -dump http://zzapper.co.uk/vimtips.html    *N*
----------------------------------------
updated version at http://www.zzapper.co.uk/vimtips.html
----------------------------------------
Please email any errors, tips etc to
david@rayninfo.co.uk
" Information Sources
----------------------------------------
www.vim.org
Vim Wiki *** VERY GOOD *** *N*
Vim Use VIM newsgroup *N*
comp.editors
groups.yahoo.com/group/vim "VIM" specific newsgroup
VIM Webring
Vim Book
Searchable VIM Doc
VimTips PDF Version (PRINTABLE!)
----------------------------------------
" : commands to neutralise < for HTML display and publish
" use yy@" to execute following commands
:w!|sav! vimtips.html|:/^__BEGIN__/,/^__END__/s#<#\<#g|:w!|:!vimtipsftp
----------------------------------------

# History & Attributions

" vim: set sw=2 sts=2 et fdm=marker fdc=3 fdl=5:
