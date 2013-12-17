" Phrase: クイックスタート
"=============================================================================
let s:V = vital#of('vital')
let s:Prelude = s:V.import('Prelude')
let s:List = s:V.import('Data.List')

let d = { 'A' : 1, 'C' : 3 }
echo string(d)
" { 'A' : 1, 'C' : 3 }
call s:Prelude.set_dictionary_helper(d,"A,B,C",0)
echo string(d)
" { 'A' : 1, 'B' : 0, 'C' : 3 }

let lst = [[1],[2,3]]
echo s:List.flatten(lst)
" [1,2,3]
echo lst
" [[1],[2,3]]
echo s:List.flatten([[1],[2,[3,4]]])
" phrase_file: phrase__vital.vim
