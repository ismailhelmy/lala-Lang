%{
   #include <stdlib.h>
   #include <stdio.h>
   #include <string.h>
   #include "../yacc/lala-yacc.tab.h"
   void invalidToken();
   int mylineno = 1;
%}

%%
\/\*.*\*\/                            { return COMMENT; }

int                                   { yylval.typeName = strdup(yytext); return typekeyword; }
float|flotte|flutter                  { yylval.typeName = strdup(yytext); return typekeyword; }
string|chaîne|stringa                 { yylval.typeName = strdup(yytext); return typekeyword; }
bool|booléen|booleano                 { yylval.typeName = strdup(yytext); return typekeyword; }

\+|plus|più                           { yylval.typeName = "ADD"; return ADD; }
\-|minus|moins|meno                   { return SUBTRACT; }
\/|divide|diviser|dividersi           { return DIVIDE;}
=|equal|égal|pari                     { return EQUAL; }
\*\*|pow|puis|potere                  { return POWER; }
\*|multiplier|multiply|moltiplicare   { yylval.typeName = "MUL"; return MULTIPLY; }
"%"                                   { return MODULU; }

\^                                    { return BITWISE_XOR; }
&                                     { return BITWISE_AND; }
\|                                    { return BITWISE_OR; }
not|ne|non                            { return BITWISE_NOT; }

"and"|"et"|"con"                      { return LOGICAL_AND; }
"or"|"ou"|"ovvero"                    { return LOGICAL_OR; }
==|égal\?|pari\?                      { return LOGICAL_EQUAL; }
!=|neqal\?|nonpari\?                  { return NOT_EQUAL; }

if|si|se                              { return IF_KEYWORD; }
else|autre|altro                      { return ELSE_KEYWORD; }
while|quoique|sebbene                 { return WHILE_KEYWORD; }
for|pendant|per                       { return FOR_KEYWORD; }
import|importer|importare             { return IMPORT_KEYWORD; }

const                                 { return CONST_KEYWORD; }
switch                                { return SWITCH_KEYWORD; }
case                                  { return CASE_KEYWORD; }
"else if"                             { return ELSEIF_KEYWORD; }
void                                  { return VOID_KEYWORD; }
break                                 { return BREAK_KEYWORD; }
default                               { return DEFAULT_KEYWORD; }



Epilogue|"A hint of a tear in both"   { return END; }
WINTER|"Another day of sun"           { return START; }
ENTER                                 { return ENTER; }
WITH                                  { return WITH; }

true|false|vrai|faux|vero|falso       { return BOOLEAN; }

","                                   { return COMMA; }
":"                                   { return COLON; }
"["                                   { return OPEN_SQUARE; }
"]"                                   { return CLOSED_SQUARE; }
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
(-)?[0-9]+                            { yylval.val->iVal = atoi(yytext); yylval.val->type = INT_TYPE; return INT; }
(-)?[0-9]*\.?[0-9]+                   { yylval.val->fVal = atof(yytext); yylval.val->type = FLOAT_TYPE; return FLOAT;}
\".*\"                                { yylval.val->sVal = strdup(yytext); yylval.val->type = STRING_TYPE; return STRING; }
[a-zA-Z_][a-z_A-Z0-9]*                { yylval.variableName = strdup(yytext); return VARIABLE; }



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