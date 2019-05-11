flex ../lexer/lala_lex.l
bison -d lala-yacc.y
gcc -o output.exe lala-yacc.tab.c
output.exe < testcode.lala