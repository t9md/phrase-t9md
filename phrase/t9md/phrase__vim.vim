" Phrase: performance for vs map / for と map の速度比較
"=============================================================================
function! s:val(arg) "{{{1
  " noop
endfunction
"}}}

let start = reltime()
let list = range(500000)
" for n in list | call s:val(n) | endfor
" for n in list | call s:val(n) | endfor
" call map(list, 's:val(v:val)')
" call map(list, 's:val(v:val)')
echo reltimestr(reltime(start))

" Phrase: backword compatible api change
"=============================================================================
" care backward compatibility "{{{
let arg_1st = get(a:000, 0, {})
let arg_2nd = get(a:000, 1, '')

if type(arg_1st) is s:TYPE_DICTIONARY
  let config = arg_1st
else
  " old api call
  let config = { 'auto_choose': arg_1st }
  if !empty(arg_2nd)
    let config.label = arg_2nd
  endif
  echoerr 'Choosewin: you use old api, help "choosein#start()" for new api-call'
endif "}}}

" Phrase: Command meta programming / 黒魔術 by manga-osyo
"=============================================================================
let s:apply = []
let s:count = 0
command! ENDfunction
      \	let s:count += 1
      \| execute "function! s:func" . s:count . "() \n endfunction"
      \| call add(s:apply, function("s:func" . s:count))
      \| execute "function! s:func" . s:count . "()"

ENDfunction
  echo "homu"
endfunction

function! s:apply_colorscheme(name)
  echo "colorschem " . a:name
endfunction

ENDfunction
  call s:apply_colorscheme("mami")
endfunction
" なんかいっぱい処理
call map(s:apply, "v:val()")

" Phrase: String interpolation / 文字列の差し込み
"=============================================================================
function! s:intrpl(string, vars) "{{{1
  let mark = '\v\{(.{-})\}'
  return substitute(a:string, mark,'\=a:vars[submatch(1)]', 'g')
endfunction

echo s:intrpl('\v%{w0}l\_.*%{w$}l', { 'w0': line('w0'), 'w$': line('w$') })
" =>  \v%1l\_.*%20l

function! s:intrpl(string, vars) "{{{1
  let mark = '\v\{(.{-})\}'
  let r = []
  for expr in s:scan(a:string, mark)
    call add(r, substitute(expr, '\v([a-z][a-z$0]*)', '\=a:vars[submatch(1)]', 'g'))
  endfor
  call map(r, 'eval(v:val)')
  return substitute(a:string, mark,'\=remove(r, 0)', 'g')
endfunction

function! s:scan(str, pattern) "{{{1
  let ret = []
  let nth = 1
  while 1
    let m = matchlist(a:str, a:pattern, 0, nth)
    if empty(m)
      break
    endif
    call add(ret, m[1])
    let nth += 1
  endwhile
  return ret
endfunction
"}}}

echo s:intrpl('\v%{w0+1}l\_.*%{w$+1}l', { 'w0': line('w0'), 'w$': line('w$') })
" =>  \v%1l\_.*%20l

" Phrase: show typed key readable format
"=============================================================================
let s:table = smalls#util#import('special_key_table')()
function! s:getchar() "{{{1
  let c = getchar()
  return type(c) == type(0) ? nr2char(c) : c
endfunction

function! s:test() "{{{1
  while 1
    redraw
    let char = s:getchar()
    if char ==# "\<C-j>"
      break
    endif

    call g:plog(get(s:table, char, char))
  endwhile
endfunction
"}}}
call s:test()

" Phrase: tab2space()
"=============================================================================
function! s:tab2space(str, tabstop) "{{{1
  return substitute(a:str, "\t", repeat(' ', a:tabstop), 'g')
endfunction
"}}}
call s:tab2space(getline('.'), &tabstop)

" Phrase: undojoin experiment
"=============================================================================
function! s:insert(chars)
  silent exec 'normal! i' a:chars "\<ESC>"
endfunction

function! s:undobreak()
  let &undolevels = &undolevels
  " silent exec 'normal!' "i\<C-g>u\<ESC>"
endfunction

function! s:test2()
  call s:undobreak()
  " undojoin
  call s:insert('aaa')
  exec 'normal! iaaaabbb' "\<Esc>"

  " undojoin
  call s:insert('bbb')
  undo
endfunction

call s:test2()

function! s:insert(chars)
  silent exec 'normal! i' a:chars "\<ESC>"
endfunction

function! s:undobreak()
  let &undolevels = &undolevels
  " silent exec 'normal!' "i\<C-g>u\<ESC>"
endfunction

let s:insert = {}
function! s:insert.a()
  call s:insert('aaa')
endfunction
function! s:insert.b()
  call s:insert('bbb')
endfunction
function! s:insert.c()
  call s:insert('ccc')
endfunction

function! s:test2()
  call s:insert.a()
  let org = winnr()
  exec 'wincmd w'
  exec org 'wincmd w'
  undojoin
  call s:insert.b()
  let org = winnr()
  exec 'wincmd w'
  exec org 'wincmd w'
  undojoin
  call s:insert.c()
  call append(line('$'), map(range(5), '""'))
  " undo
endfunction

call s:test2()
" let bufnr     = winbufnr(a:win)

" Phrase: hide cursor
"=============================================================================
function! s:highlight_preserve(hlname) "{{{1
  redir => HL_SAVE
  execute 'silent! highlight ' . a:hlname
  redir END
  return 'highlight ' . a:hlname . ' ' .
        \  substitute(matchstr(HL_SAVE, 'xxx \zs.*'), "\n", ' ', 'g')
endfunction

function! s:cw.cursor_hide() "{{{1
  let self._hl_cursor_cmd = s:highlight_preserve('Cursor')
  let self._t_ve_save = &t_ve

  highlight Cursor NONE
  let &t_ve=''
endfunction

function! s:cw.cursor_restore() "{{{1
  execute self._hl_cursor_cmd
  let &t_ve = self._t_ve_save
endfunction

" Phrase: highlight preserve
"=============================================================================
function! s:highlight_capture(hlname) "{{{1
  redir => HL_SAVE
  execute 'silent! highlight ' . a:hlname
  redir END
  let defstr = matchstr(HL_SAVE, 'xxx \zs.*')

  let R = { 'gui': ['','',''], 'cterm': ['','','']}
  for def in split(defstr, '\s')
    let [key,val] = split(def, '=')
    if     key ==# 'guibg'   | let R['gui'][0]   = val
    elseif key ==# 'guifg'   | let R['gui'][1]   = val
    elseif key ==# 'gui'     | let R['gui'][2]   = val
    elseif key ==# 'ctermbg' | let R['cterm'][0] = val
    elseif key ==# 'ctermfg' | let R['cterm'][2] = val
    elseif key ==# 'cterm'   | let R['cterm'][2] = val
    endif
  endfor
  return R
endfunction

let choosewin_cursor = s:highlight_capture('Normal')
let choosewin_cursor.gui[2]   = 'underline'
let choosewin_cursor.cterm[2] = 'underline'
let self.color_cursor = self.highlighter.register(choosewin_cursor)

" Phrase: reltimestr / 経過時間を計測
"=============================================================================
let start = reltime()
sleep 1.0
echo reltimestr(reltime(start))

" Phrase: Dictionary function name / 辞書関数の名前
"=============================================================================
let s:d = {}
function! s:d.fun1()
  echo s:dict_funname(self)
endfunction

function! s:d.fun2()
  echo s:dict_funname(self)
endfunction

function! s:dict_funname(dict)
  let signature = expand('<sfile>')
  let myfunc = matchstr(split(signature, '\V..')[-2],'\d\+')
  for v in items(a:dict)
    if string(v[1]) =~# "'" . myfunc . "'"
      return v[0]
    endif
  endfor
endfunction

call s:d.fun1()
" => fun1
call s:d.fun2()
" => fun2

" Phrase: Function name / スクリプトローカルな関数の名前を得る。
"=============================================================================
function! s:funname(format)
  " intended for use inner function
  let signature = expand('<sfile>')
  if a:format ==# 'raw'
    return signature
  elseif a:format ==# 'this'
    let s =  split(signature, '\.\.')[-2]
    return matchstr(s, '<SNR>\d\+_\zs.*\ze$')
  elseif a:format ==# 'this_with_SNR'
    let s =  split(signature, '\.\.')[-2]
    return matchstr(s, '\zs<SNR>\d\+_.*\ze$')
  endif
endfunction

function! s:this_function()
  echo s:funname('raw')
  " => function <SNR>266_this_function..<SNR>266_funname
  echo s:funname('this')
  " => this_function
  echo s:funname('this_with_SNR')
  " => <SNR>266_this_function
endfunction

call s:this_function()

" Phrase: exists() idiom | exists()
"=============================================================================
" 関数が存在すれば呼ぶ has_key() を使う必要はない。
if exists('*g:ezbar.parts._init')
  call g:ezbar.parts._init()
endif

" 環境変数が存在するか？
echo exists('$HOME')
" オプションが存在するか？機能するかは気にしない。
echo exists('&fileencoding')
" オプションが機能するか？
echo exists('+fileencoding')

" 変数が存在するか？
let bar = 0
echo exists('bar')

" List
let foo = [1,2,3]
echo exists('foo[0]')
" => 1
echo exists('foo[2]')
" => 1
echo exists('foo[3]')
" => 0

" Dictionary
let bar = {'a': 1, 'b': 2}
echo exists('bar')
" => 1
echo exists('bar.a')
" => 1
echo exists('bar.c')
" => 0

" Curly-braces-names
unlet! foo bar
let foo = 'bar' | echo exists('{foo}')
" => 0
let bar = ''    | echo exists('{foo}')
" => 1
unlet bar       | echo exists('{foo}')
" => 0

" Phrase: highlight pattern for rectangle change / 変更範囲の矩形ハイライト
"=============================================================================
call clearmatches()
let [sl, sc] = [line("'["), col("'[")]
let [el, ec] = [line("']"), col("']")]
echo [sl, sc]
echo [el, ec]
let pat = printf('\v\c%%>%dl%%>%dc.*%%<%dl%%<%dc', sl-1, sc-1, el+1, ec+1)
call matchadd('Visual', pat)

" Phrase: condition check variety / コンディション分岐の色々な方法
"======================================================================
function! s:way1(mode)
  if      a:mode == '1' | let range_str = 'one'
  elseif  a:mode == '2' | let range_str = "two"
  elseif  a:mode == '3' | let range_str = 'three'
  else                  | let range_str = 'other'
  endif
  echo range_str
endfunction

function! s:way2(num) abort
  " 絶対にたどり着くべきでないから存在しない変数
  " SHOULD_NOT_REACH_HERE を参照してエラーにする。
  let case =
        \ a:num ==# 11 ? 1 :
        \ a:num ==# 12 ? 2 :
        \ a:num ==# 13 ? 3 :
        \ a:num ==# 14 ? 4 :
        \ SHOULD_NOT_REACH_HERE
  echo case
endfunction

function! s:way3(mode)
  echo
        \ a:mode ==# '1' ? 'one'   :
        \ a:mode ==# '2' ? 'two'   :
        \ a:mode ==# '3' ? 'three' :
        \                  'other'
endfunction

" Phrase: pass args as-is / public 関数側の引数リストを変更に強くする。
"=============================================================================
" 引数をそのままたらい回す。
" s:phrase.start() の引数リストを変える度に、phrase#start() 側の引数リストに
" 変更を毎回加えるのは面倒。call() に a:000 を渡すことで不要になる。

let s:phrase = {}
function! s:phrase.start(ope, ...) "{{{1
  " hoghog
endfunction

function! phrase#start(...) "{{{1
  call call(s:phrase.start, a:000, s:phrase)
endfunction

" Phrase: cli complete: 特定の dir  配下のファイル名を補完
"=============================================================================
command! -nargs=? -complete=customlist,phrase#myfiles
      \ PhraseEdit :call phrase#start('edit'  , <f-args>)

function! phrase#myfiles(A, L, P) "{{{1
  let R = []
  for file in split(globpath(s:phrase_dir, '*'), "\n")
    let f = fnamemodify(file, ':p:t')
    if f =~# '^\V' . a:A
      call add(R, f)
    endif
  endfor
  return R
endfunction

" Phrase: global var default , プラグインの global 変数の設定
"======================================================================
" 方式1
" この方式の利点は、g:phrase_author の様に変数名をそのまま'g:'でかける
" 点。検索で引っかかるので。
function! s:set_options(options) "{{{1
  for [varname, value] in items(a:options)
    if !exists(varname)
      let {varname} = value
    endif
    unlet value
  endfor
endfunction

let s:options = {
      \ 'g:phrase_author':          expand("$USER"),
      \ 'g:phrase_basedir':         "~/.vim/phrase",
      \ 'g:phrase_ft_tbl':          {},
      \ 'g:phrase_author_priority': {},
      \ }

call s:set_options(s:options)

" 方式2
" 特に関数定義しなくても良いので楽。'g:phrase_author'
" で検索しても引っかからないのが少しイヤ。
let g:phrase_author = get(g:, 'phrase_author', expand("$USER"))

" 方式3
" 一番ベーシック
if exists('g:phrase_author')
  let g:phrase_author = expand("$USER")
endif

" Phrase: python's if __name__ == “__main__”
"======================================================================
" 明示的に :%so した時のみ s:runtest() が実行される。
" plugin の中のライブラリ開発中に便利(動作確認しながら作れる)。
if expand("%:p") !=# expand("<sfile>:p")
  finish
endif
call s:runtest()

" 例２: 明示的に source した場合に、g:loaded_XXX ガードを交わす。
if expand("%:p") ==# expand("<sfile>:p")
  unlet! g:loaded_phrase
endif
if exists('g:loaded_phrase')
  finish
endif

" Phrase: logger:
"======================================================================
" plugin 開発中のログ出力。'tail -f ~/vimlog.log' で見る。
function! s:plog(msg) "{{{1
  call vimproc#system('echo "' . PP(a:msg) . '" >> ~/vim.log')
endfunction

" Phrase: should and should not ensurerer
"======================================================================
" validate チェックのネストが深くなると、可読性、保守性が下がるので、
" try catch clause で囲って、throw するようにすると楽。
" 深い関数呼び出しからも一気に抜けれて便利。

" 例1)
function! Test(case, v)
  echo a:case
  try
    call s:should(empty(a:v), "should empty" )
    call s:should_not( empty(a:v), "empty not allowed" )
  catch
    echo ' => Exception: ' . v:exception
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
" #case1: pass empty
"  => Exception: empty not allowed
call Test("#case2: pass not empty", 'a')
" #case2: pass not empty
"  => Exception: should empty

" 例2)
function! s:ensure(expr, msg) "{{{1
  if !a:expr
    throw "phrase.vim: " . a:msg
  endif
endfunction

" プラグイン内での様々なチェック,
call s:ensure(!empty(category), 'empty category or &filetype')
call s:ensure(isdirectory(directory), "not directory '" . directory . "'")

" いちいち以下のようにやると行数が増えてつらい。
" condition の部分が長くなることもあるし。
if empty(category)
  throw 'phrase.vim: empty category or &filetype'
endif

" Phrase: ErrorCheck: いろいろなエラーチェック
"======================================================================
function! s:checker(check, ...)
　let expr = get(a:, 1, "ERROR")
　if a:check
　　throw expr
　endif
endfunction

function! Check1()
  return 1
endfunction
function! Check2()
  return 1
endfunction
call s:checker(Check1())
call s:checker(Check2(), "ERROR Check2")

command! -nargs=* Checker if <args> | throw "ERROR" | endif
Checker Check1()
Checker Check2()

function! s:throw(exp)
  throw a:exp
endfunction
let _ = Check1() && s:throw("ERROR")
let _ = Check2() && s:throw("ERROR")

" Phrase: v: g:, l:, w: as dictonary var / g: とかは辞書としてアクセス出来る。
"============================================================================
for [k,v] in items(v:)
  echo join(["v:" . k, PP(v) ]," = ")
  unlet v
endfor

" Phrase: List include? / List に要素が含まれるかのチェックは index() で可能
"============================================================================
" 含まれない場合は -1 が返る。

let list = ["ruby", "python", "perl"]
echo index(lis, "ruby")
" => 0
echo index(lis, "python")
" => 1
echo index(lis, "perl")
" => 2
echo index(lis, "lua")
" => -1

function! s:is_include(list, val)
  return index(a:list, a:val) != -1
endfunction
echo s:is_include(lis, "ruby")
" => 1
echo s:is_include(lis, "lua")
" => 0

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
" There are nine types of registers:      *registers* *E354*
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
for [num, line] in map(readfile("/home/t9md/.bashrc"),'[v:key+1, v:val]')
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
