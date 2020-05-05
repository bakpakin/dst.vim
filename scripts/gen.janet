# Generate real syntax file from template.

(def specials (seq [sym :in (all-bindings) :when (not= 'specials sym)]
                    (string "syntax keyword JanetCoreValue " (string/replace "|" "\\|" sym))))

(def template
`````
" Vim syntax file
" Language: Janet
" Maintainer: Calvin Rose

if exists("b:current_syntax")
    finish
endif

let s:cpo_sav = &cpo
set cpo&vim

if has("folding") && exists("g:janet_fold") && g:janet_fold > 0
    setlocal foldmethod=syntax
endif

syntax keyword JanetCommentTodo contained FIXME XXX TODO FIXME: XXX: TODO:

" Janet comments
syntax match JanetComment "#.*$" contains=JanetCommentTodo,@Spell

syntax match JanetStringEscape '\v\\%([ntvr0zfe"\\]|x[[0-9a-fA-F]]\{2}|u[[0-9a-fA-F]]\{4}|U[[0-9a-fA-F]]\{6})' contained
syntax region JanetString matchgroup=JanetStringDelimiter start=/"/ skip=/\\\\\|\\"/ end=/"/ contains=JanetStringEscape,@Spell
syntax region JanetBuffer matchgroup=JanetStringDelimiter start=/@"/ skip=/\\\\\|\\"/ end=/"/ contains=JanetStringEscape,@Spell
syntax region JanetString matchgroup=JanetStringDelimiter start="\z(`\+\)" end="\z1" contains=@Spell
syntax region JanetBuffer matchgroup=JanetStringDelimiter start="@\z(`\+\)" end="\z1" contains=@Spell

syntax keyword JanetConstant nil

syntax keyword JanetBoolean true
syntax keyword JanetBoolean false

" Janet special forms
syntax keyword JanetSpecialForm if
syntax keyword JanetSpecialForm do
syntax keyword JanetSpecialForm fn
syntax keyword JanetSpecialForm while
syntax keyword JanetSpecialForm def
syntax keyword JanetSpecialForm var
syntax keyword JanetSpecialForm quote
syntax keyword JanetSpecialForm quasiquote
syntax keyword JanetSpecialForm unquote
syntax keyword JanetSpecialForm splice
syntax keyword JanetSpecialForm set
syntax keyword JanetSpecialForm break

" Not really special forms, but useful to highlight
" All symbols from janet core.
$$SPECIALS$$

" Try symchars but handle old vim versions.
try
    let s:symcharnodig = '\!\$%\&\*\+\-./:<=>?@A-Z^_a-z|\x80-\U10FFFF'
    " Make sure we support large character ranges in this vim version.
    execute 'syntax match JanetSymbolDud "\v<%([' . s:symcharnodig . '])%([' . s:symchar . '])*>"'
catch
    let s:symcharnodig = '\!\$%\&\*\+\-./:<=>?@A-Z^_a-z'
endtry

" Janet Symbols
let s:symchar = '0-9' . s:symcharnodig
execute 'syntax match JanetSymbol "\v<%([' . s:symcharnodig . '])%([' . s:symchar . '])*>"'
execute 'syntax match JanetKeyword "\v<:%([' . s:symchar . '])*>"'
unlet! s:symchar s:symcharnodig

syntax match JanetQuote "'"

" Janet numbers
function! s:syntaxNumber(prefix, expo, digit)
  let l:digit = '[_' . a:digit . ']'
  execute 'syntax match JanetNumber "\v\c<[-+]?' . a:prefix . '%(' .
              \ l:digit . '+|' .
              \ l:digit . '+\.' . l:digit . '*|' .
              \ '\.' . l:digit . '+)%(' . a:expo . '[-+]?[' . a:digit . ']+)?>"'
endfunction
let s:radix_chars = "0123456789abcdefghijklmnopqrstuvwxyz"
for s:radix in range(2, 36)
    call s:syntaxNumber(s:radix . 'r', '\&', '[' . strpart(s:radix_chars, 0, s:radix) . ']')
endfor
call s:syntaxNumber('', '[&e]', '0123456789')
call s:syntaxNumber('0x', '\&', '0123456789abcdef')
unlet! s:radix_chars s:radix

" -*- TOP CLUSTER -*-
syntax cluster JanetTop contains=@Spell,JanetComment,JanetConstant,JanetQuote,JanetKeyword,JanetSymbol,JanetNumber,JanetString,JanetBuffer,JanetTuple,JanetArray,JanetTable,JanetStruct,JanetSpecialForm,JanetBoolean,JanetCoreValue

syntax region JanetTuple matchgroup=JanetParen start="("  end=")" contains=@JanetTop fold
syntax region JanetArray matchgroup=JanetParen start="@("  end=")" contains=@JanetTop fold
syntax region JanetTuple matchgroup=JanetParen start="\[" end="]" contains=@JanetTop fold
syntax region JanetArray matchgroup=JanetParen start="@\[" end="]" contains=@JanetTop fold
syntax region JanetTable matchgroup=JanetParen start="{"  end="}" contains=@JanetTop fold
syntax region JanetStruct matchgroup=JanetParen start="@{"  end="}" contains=@JanetTop fold

" Highlight superfluous closing parens, brackets and braces.
syntax match JanetError "]\|}\|)"

syntax sync fromstart

" Highlighting
hi def link JanetComment Comment
hi def link JanetSymbol Identifier
hi def link JanetNumber Number
hi def link JanetConstant Constant
hi def link JanetKeyword Keyword
hi def link JanetSpecialForm Special
hi def link JanetCoreValue Special
hi def link JanetString String
hi def link JanetBuffer String
hi def link JanetStringDelimiter String
hi def link JanetBoolean Boolean

hi def link JanetQuote SpecialChar
hi def link JanetParen Delimiter

let b:current_syntax = "janet"

let &cpo = s:cpo_sav
unlet! s:cpo_sav
`````)

(spit "syntax/janet.vim" (string/replace "$$SPECIALS$$" (string/join specials "\n") template))
