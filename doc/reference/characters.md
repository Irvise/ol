Characters
==========

Characters are *small* numbers (aka *enums*) that may represent printed characters such as letters and digits, or not. The entire range of Unicode 14.0.0 (Sep 14, 2021) is supported.

Characters are written using the notation #\\<character\> or #\\<character name\> or #x\<hex scalar value\>.

The full list of character names:
```scheme
#\null          ==>  #x0
#\alarm         ==>  #x7
#\backspace     ==>  #x8
#\tab           ==>  #x9
#\newline       ==>  #xA
#\return        ==>  #xD
#\escape        ==>  #x1B
#\space         ==>  #x20
#\delete        ==>  #x7F
```

[char?](#char),  
[char->integer](#char-integer), [integer->char](#integer-char),  
[digit-value](#digit-value)

# char?
`(char? obj)`, *procedure*

Returns #true if *obj* is a character (enum), otherwise returns #false.

```scheme
(char? #\λ)             ==>  #true
(char? 100000)          ==>  #true
(char? #\space)         ==>  #true
(char? 1000000000000000000000000000000)  ==>  #false
```

# char->integer
`(char->integer char)`, *procedure*

Do nothing. Same as `idf` function.

```scheme
(char->integer #\return)    ==> 13
(char->integer #\!)         ==> 33
(char->integer #\λ)         ==> 955
```

# integer->char
`(integer->char n)`, *procedure*

Do nothing. Same as `idf` function.

> Note: If you want to see the unicode representation of a character, use the `string` function.
```scheme
(integer->char 13)          ==> 13
(integer->char 33)          ==> 33
(integer->char 955)         ==> 955

(string 955)                ==> "λ"
```

# digit-value
`(digit-value char)`, *procedure*

This procedure returns the numeric value (0 to 9) of its argument if it is a numeric digit (that is, if char-numeric?
returns #t), or #f on any other character.

```scheme
(digit-value #\3)         ==>  3      ; 0033, DIGIT THREE
(digit-value #\٤)         ==>  4      ; 0664, ARABIC-INDIC DIGIT FOUR
(digit-value #\૦)         ==>  0      ; 0AE6, GUJARATI DIGIT ZERO
(digit-value #x0EA6)      ==>  #false ; not a Unicode character
(digit-value #\ʩ)         ==>  #false ; 02A9, LATIN SMALL LETTER FENG DIGRAPH
(digit-value #\Ⅽ)         ==>  #false ; 216D, ROMAN NUMERAL ONE HUNDRED
```

<!-- # char=?
char=?
char<?
char>?
char<=?
char>=?

char-ci=?
char-ci<?
char-ci>?
char-ci<=?
char-ci>=? -->

<!-- (char-alphabetic? char) char library procedure
(char-numeric? char) char library procedure
(char-whitespace? char) char library procedure
(char-upper-case? letter) char library procedure
(char-lower-case? letter) char library procedure -->

<!-- (char-upcase char) char library procedure
(char-downcase char) char library procedure
(char-foldcase char) char library procedure -->

<!-- Note that many Unicode lowercase characters do not have
uppercase equivalents. -->
