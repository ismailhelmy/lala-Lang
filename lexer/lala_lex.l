%{
   #include "defs.h"
%}

%option nounput yylineno

%% 
num                  return NUMBER_KEYWORD;
string               return STRING_KEYWORD;
bool                 return BOOLEAN_KEYWORD;
\+                   return ADD;
\-                   return SUBTRACT;
\/                   return DIVIDE;
=                    return EQUAL;
\*\*                 return POWER;
\*                   return MULTIPLY;
\^                   return BITWISE_XOR;
&                    return BITWISE_AND;
and                  return LOGICAL_AND;
\|                   return BITWISE_OR;
or                   return LOGICAL_OR;
not                  return BITWISE_NOT;
==                   return LOGICAL_EQUAL;
!=                   return NOT_EQUAL;
true | false         return BOOLEAN;
[0-9]+[\.]?[0-9]*    return NUMBER;
\"\.*\"              return STRING;
[a-z_][a-zA-Z0-9]*   return VARIABLE;
.                    printf("Unexpected character");

%%
int yywrap(void){
    return 1
}