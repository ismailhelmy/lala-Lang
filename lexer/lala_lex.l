%{
  //include "defs.h"
   #include <stdlib.h>
   #include <stdio.h>
   #include <string.h>
   #include "../yacc/lala-yacc.tab.h"
   void invalidToken();
   int mylineno = 1;
%}

%option nounput yylineno

%%

int|entier|intero                     { return INT_KEYWORD; }
float|flotte|flutter                  { return FLOAT_KEYWORD; }
string|chaîne|stringa                 { return STRING_KEYWORD; }
bool|booléen|booleano                 { return BOOLEAN_KEYWORD; }

\+|plus|più                           { return ADD; }
\-|minus|moins|meno                   { return SUBTRACT; }
\/|divide|diviser|dividersi           { return DIVIDE;}
=|equal|égal|pari                     { return EQUAL; }
\*\*|pow|puis|potere                  { return POWER; }
\*|multiplier|multiply|moltiplicare   { return MULTIPLY; }
"%"                                   { return MODULU; }

\^                                    { return BITWISE_XOR; }
&                                     { return BITWISE_AND; }
\|                                    { return BITWISE_OR; }
not|ne|non                            { return BITWISE_NOT; }

"and"|"et"|"con"                            { return LOGICAL_AND; }
"or"|"ou"|"ovvero"                          { return LOGICAL_OR; }
==|égal\?|pari\?                      { return LOGICAL_EQUAL; }
!=|neqal\?|nonpari\?                  { return NOT_EQUAL; }

if|si|se                              { return IF_KEYWORD; }
else|autre|altro                      { return ELSE_KEYWORD; }
while|quoique|sebbene                 { return WHILE_KEYWORD; }
for|pendant|per                       { return FOR_KEYWORD; }
import|importer|importare             { return IMPORT_KEYWORD; }

","                                   { return COMMA; }
"{"                                   { return SCOPE_BEGINING; }
"}"                                   { return SCOPE_END; }
">="                                  { return GREATER_THAN_EQUAL; }
">"                                   { return GREATER_THAN; }
"<"                                   { return LESS_THAN; }
"<="                                  { return LESS_THAN_EQUAL; }
"+="                                  { return PLUS_EQUAL; }
"-="                                  { return MINUS_EQUAL; }
";"                                   { return SEMI_COLON; }
"("                                   { return OPEN_BRACKET; }
")"                                   { return CLOSED_BRACKET; }
(-)?[0-9]+                            { yylval.valueInt = atoi(yytext); return INT; }
(-)?[0-9]*\.?[0-9]+                   { yylval.valueFloat = atof(yytext); return FLOAT;}
\".*\"                                { yylval.valueString = strdup(yytext); return STRING; }
[a-z_][a-zA-Z0-9]*                    { yylval.variableName = strdup(yytext); return VARIABLE; }
true|false|vrai|faux|vero|falso       { return BOOLEAN; }

Epilogue|"A hint of a tear in both"   { return END; }
WINTER|"Another day of sun"           { return START; }

\n                                    { mylineno++; }
[ \t\r\v\f]+                          { ; }

.                                     { invalidToken(); }

%%

int yywrap(void){
    return 1;
}

void invalidToken(){
   printf("Error in line %d : %s \n", mylineno, yytext);
}