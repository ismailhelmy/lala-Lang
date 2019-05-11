#!/bin/bash
flex ../lexer/lala_lex.l
bison -d lala-yacc.y
gcc lala-yacc.tab.c
./a.out < testcode.lala
