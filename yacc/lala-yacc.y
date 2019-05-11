%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "../hash_table.c"
	#include "../structs.h"
	#include "../lexer/lex.yy.c"
	#include <stdarg.h>
	int insertdeclaration(char *, char *);
	int yyerror(char *msg);
%}

%union{
    int valueInt;
    float valueFloat;
    char* valueString;
    char* variableName;
    _Bool valueBool;
	char *type;
};

%token <valueInt> INT
%token <valueFloat> FLOAT
%token <valueString> STRING
%token <variableName> VARIABLE
%token <valueBool> BOOLEAN
%token <type> FLOAT_KEYWORD STRING_KEYWORD INT_KEYWORD BOOLEAN_KEYWORD
%token START END ADD SUBTRACT MULTIPLY DIVIDE POWER BITWISE_XOR BITWISE_AND BITWISE_OR BITWISE_NOT LOGICAL_EQUAL NOT_EQUAL LOGICAL_AND LOGICAL_OR EQUAL
%token ELSEIF_KEYWORD VOID_KEYWORD DEFAULT_KEYWORD COLON CONST_KEYWORD BREAK_KEYWORD CASE_KEYWORD SWITCH_KEYWORD COMMENT WHILE_KEYWORD IF_KEYWORD ELSE_KEYWORD FOR_KEYWORD LESS_THAN LESS_THAN_EQUAL GREATER_THAN GREATER_THAN_EQUAL SEMI_COLON MODOLU PLUS_EQUAL MINUS_EQUAL IMPORT_KEYWORD COMMA OPEN_BRACKET CLOSED_BRACKET SCOPE_BEGINING SCOPE_END
%token MODULU
%token ENTER OPEN_SQUARE CLOSED_SQUARE WITH
%right EQUAL
%left SUBTRACT ADD
%left MULTIPLY
%right DIVIDE
%right MODOLU
%right LOGICAL_AND LOGICAL_EQUAL LOGICAL_OR NOT_EQUAL BITWISE_AND BITWISE_XOR BITWISE_OR
%nonassoc PLUS_EQUAL MINUS_EQUAL BITWISE_NOT

%type <type> typekeyword
//%type <nPtr> value switchbody switchstmt expr num unioperatorexpression body declaration assignment typekeyword constdeclaration
%%



/*
This section is for the body declaration
*/

start   : START body END
        ;


num     : INT
		| FLOAT
        ;

value : num
        | STRING
        | BOOLEAN
        ;

typekeyword : INT_KEYWORD
			| FLOAT_KEYWORD
			| STRING_KEYWORD
			| BOOLEAN_KEYWORD
            ;

declaration : typekeyword VARIABLE SEMI_COLON {printf("eh %s\n", $1); /*insertdeclaration($1, $2);*/ printf("accepted\n");}
            | OPEN_SQUARE ENTER VARIABLE WITH typekeyword CLOSED_SQUARE
            | constdeclaration
            ;

assignment  : VARIABLE EQUAL expr SEMI_COLON  {/*check if expr of same type as var,check if variable exists, assign value to var*/} 
            | typekeyword VARIABLE EQUAL expr SEMI_COLON {/*check if expr of same type as var,check if variable doesnt exist, assign value to var*/} 
            | VARIABLE EQUAL functioncall SEMI_COLON {/*check if var and function exists*/}
            ;
OpenScope   : SCOPE_BEGINING

ClosedScope : SCOPE_END
constdeclaration : CONST_KEYWORD typekeyword VARIABLE EQUAL value SEMI_COLON
            ;

ifstmt :    IF_KEYWORD OPEN_BRACKET condition CLOSED_BRACKET OpenScope body ClosedScope elseifstmt elsestmt
       ;

functiondeclaration : typekeyword VARIABLE OPEN_BRACKET paramterlist CLOSED_BRACKET SEMI_COLON

functiondefinition : typekeyword VARIABLE OPEN_BRACKET paramterlist CLOSED_BRACKET OpenScope body ClosedScope
        ;
functioncall : VARIABLE OPEN_BRACKET paramterlist CLOSED_BRACKET

paramterlist : typekeyword VARIABLE paramterlist
            | COMMA typekeyword VARIABLE paramterlist
            |
            ;

elseifstmt : ELSEIF_KEYWORD OPEN_BRACKET condition CLOSED_BRACKET OpenScope body ClosedScope elseifstmt
            |
            ;

elsestmt : ELSE_KEYWORD OpenScope body ClosedScope
        |
        ;


switchbody : CASE_KEYWORD INT COLON OpenScope body ClosedScope switchbody
			|
        	;

switchstmt : SWITCH_KEYWORD OPEN_BRACKET VARIABLE CLOSED_BRACKET OpenScope switchbody ClosedScope
			;

whileloop   : WHILE_KEYWORD OPEN_BRACKET condition CLOSED_BRACKET OpenScope body ClosedScope 
            ;

forloop : FOR_KEYWORD OPEN_BRACKET assignment condition SEMI_COLON iteratoroperation CLOSED_BRACKET OpenScope body ClosedScope 
    	;

iteratoroperation : VARIABLE EQUAL expr
                | unioperatorexpression
                ;
       
expr    : expr MULTIPLY expr 
            | expr DIVIDE expr
            | num 
            | expr ADD expr 
            | expr SUBTRACT expr 
            | VARIABLE 
            | BOOLEAN 
            | expr LOGICAL_AND expr 
            | expr LOGICAL_EQUAL expr
            | OPEN_BRACKET expr CLOSED_BRACKET
            | STRING
            ;

condition : expr LOGICAL_AND expr
          | expr LOGICAL_EQUAL expr
          | expr LOGICAL_OR expr
          | BITWISE_NOT expr
          | expr NOT_EQUAL expr
          | expr LESS_THAN expr
          | expr LESS_THAN_EQUAL expr
          | expr GREATER_THAN expr
          | expr GREATER_THAN_EQUAL expr
          ;

unioperatorexpression : 
          VARIABLE PLUS_EQUAL expr
        | VARIABLE MINUS_EQUAL expr
        ;

body    : assignment body
        | declaration body
        | ifstmt body
        | whileloop body
        | forloop body
        | comment body
        | switchstmt body
        | functiondeclaration body
        | functiondefinition body
        | unioperatorexpression SEMI_COLON body
        |
        ;
comment : COMMENT 
        ;


%%
//1 = insert, else 0
//type: 1 --> int, 2--> float, 3--> string, 4--> bool 
int insertdeclaration(char *type, char *var_name)
{
	int found;
	symbol *sym = findSymbol(var_name, &found);
	if(found != 0)
	{
		symbol *s = malloc(sizeof(symbol));
		s->variableName = malloc(strlen(var_name));
		strcpy(s->variableName, var_name);
		s->type = malloc(strlen(type));
		strcpy(s->type, type);
		int s1 = insertSymbol(s);
		if(s1) {
			printf("success!");
			printTable();
		}
	}
}


int main(void){
    yyparse();
    return 0;
}
int yyerror(char *msg){
    fprintf(stderr,"%s \n",msg);
    exit(1);
}