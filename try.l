%{
#include "defs.h"
%}
%option nounput yylineno

%%
=						return EQUAL;
"raqm"					return T_RAQM;
"nus"					return T_NUS;

[a-zA-Z][_a-zA-Z0-9]*	return IDENTIFIER;
[1-9][0-9]*				return INTEGER;
\".*\"					return STRING;
[ \t\n]					;
.						printf("unexpected character\n");
%%

int yywrap(void)
{
	return 1;
}