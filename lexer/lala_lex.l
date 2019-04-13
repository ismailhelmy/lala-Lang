%{
   #include "defs.h"
%}

%option nounput yylineno

%%

int | entier | intero       return INT_KEYWORD;
float | flotte | flutter     return FLOAT_KEYWORD;
string | chaîne | stringa     return STRING_KEYWORD;
bool | booléen | booleano       return BOOLEAN_KEYWORD;
\+ | plus  | più           return ADD;
\- | minus | moins | meno   return SUBTRACT;
\/ | divide | diviser | dividersi {return DIVIDE;}
=  | equal | égal | pari   { return EQUAL; }
\*\* | power | puis | potere               return POWER;
\* | multiplier | multiply | moltiplicare               return MULTIPLY;
\^                   return BITWISE_XOR;
&                    return BITWISE_AND;
and | et | con               return LOGICAL_AND;
\|                   return BITWISE_OR;
or | or | ou | ovvero               return LOGICAL_OR;
not | ne | non                  return BITWISE_NOT;
==  | égal\? | pari\?               return LOGICAL_EQUAL;
!=  | neqal\? | nonpari\?                return NOT_EQUAL;
true | false | vrai | faux | vero | falso       return BOOLEAN;
[0-9]+[\.]?[0-9]*    return NUMBER;
\"\.*\"              return STRING;
[a-z_][a-zA-Z0-9]*   return VARIABLE;
if | si | se                  return IF;
else | autre | altro                return ELSE;
\{                   return SCOPE_BEGINING;
\}                   return SCOPE_END;
.                    printf("Unexpected character");

%%

int yywrap(void){
    return 1
}