%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "../hash_table.c"
	#include "../structs.h"
	#include "../lexer/lex.yy.c"
	#include <stdarg.h>
	#include <ctype.h>
	int insertdeclaration(char *, char *);
	int yyerror(char *msg);
	int assign_var_expr(char *var_name, Value expr, int type);
	int scopeLevel = -1;
%}

%union{
    int valueInt;
    float valueFloat;
    char* valueString;
    char* variableName;
	char* typeName;
    _Bool valueBool;
};

%token <valueInt> INT
%token <valueFloat> FLOAT
%token <valueString> STRING
%token <variableName> VARIABLE
%token <valueBool> BOOLEAN
%type <typeName> typekeyword
%type <valueInt> intexpr
%type <valueFloat> floatexpr
%token <typeName> FLOAT_KEYWORD STRING_KEYWORD INT_KEYWORD BOOLEAN_KEYWORD
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

//%type <nPtr> value switchbody switchstmt expr unioperatorexpression body declaration assignment typekeyword constdeclaration
%%



/*
This section is for the body declaration
*/

start   : START body END
        ;


typekeyword : INT_KEYWORD {$$ = "int"; }
			| FLOAT_KEYWORD {$$ = "float"; }
			| STRING_KEYWORD {$$ = "string"; }
			| BOOLEAN_KEYWORD {$$ = "bool"; }
            ;

declaration : typekeyword VARIABLE SEMI_COLON {insertdeclaration($1, $2);}
            | OPEN_SQUARE ENTER VARIABLE WITH typekeyword CLOSED_SQUARE
            ;

assignment  : VARIABLE EQUAL intexpr SEMI_COLON  {Value val; val.valueInt = $3; assign_var_expr($1, val, 0); } 
			| VARIABLE EQUAL floatexpr SEMI_COLON {Value val; val.valueFloat = $3; assign_var_expr($1, val, 1); } 
			| VARIABLE EQUAL STRING SEMI_COLON {Value val; val.valueString = $3; assign_var_expr($1, val, 2); }
            | VARIABLE EQUAL functioncall SEMI_COLON {/*check if var and function exists*/}
            ;
OpenScope   : SCOPE_BEGINING { scopeLevel++; }

ClosedScope : SCOPE_END { scopeLevel--; }


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

switchstmt : SWITCH_KEYWORD OPEN_BRACKET VARIABLE CLOSED_BRACKET OpenScope switchbody DEFAULT_KEYWORD COLON ClosedScope
			;

whileloop   : WHILE_KEYWORD OPEN_BRACKET condition CLOSED_BRACKET OpenScope body ClosedScope 
            ;

forloop : FOR_KEYWORD OPEN_BRACKET assignment condition SEMI_COLON iteratoroperation CLOSED_BRACKET OpenScope body ClosedScope 
    	;

iteratoroperation : VARIABLE EQUAL intexpr
                | unioperatorexpression
                ;

intexpr : intexpr MULTIPLY intexpr {$$ = $1 * $3; }
		| intexpr DIVIDE intexpr
		| intexpr ADD intexpr
		| intexpr SUBTRACT intexpr
		| OPEN_BRACKET intexpr CLOSED_BRACKET 
		| INT
		| VARIABLE
		;

floatexpr : floatexpr MULTIPLY floatexpr
		| floatexpr DIVIDE floatexpr
		| floatexpr ADD floatexpr
		| floatexpr SUBTRACT floatexpr
		| OPEN_BRACKET floatexpr CLOSED_BRACKET 
		| FLOAT
		;

condition : intexpr LOGICAL_AND intexpr
          | intexpr LOGICAL_EQUAL intexpr
          | intexpr LOGICAL_OR intexpr
          | BITWISE_NOT intexpr
          | intexpr NOT_EQUAL intexpr
          | intexpr LESS_THAN intexpr
          | intexpr LESS_THAN_EQUAL intexpr
          | intexpr GREATER_THAN intexpr
          | intexpr GREATER_THAN_EQUAL intexpr
          ;

unioperatorexpression : 
          VARIABLE PLUS_EQUAL intexpr
        | VARIABLE MINUS_EQUAL intexpr
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
	if(found == 0)
	{
		symbol *s = malloc(sizeof(symbol));
		s->variableName = malloc(strlen(var_name));
		strcpy(s->variableName, var_name);
		s->type = malloc(strlen(type));
		strcpy(s->type, type);
		s->scopeId = scopeLevel + 1;
		int s1 = insertSymbol(s);
		if(s1) {
			//printTable();
		}
	}
	else {
		printf("LINE: %d variable with name %s already declared\n", yylineno, var_name);
	}
}

// type = 0 --> int,  type = 1 --> float, type = 2 -->string
int assign_var_expr(char *var_name, Value expr, int type)
{
	int found;
	symbol *sym = findSymbol(var_name, &found);
	if(found != 0)
	{
		if(strcmp(sym->type,"int") == 0 && type == 0)
		{
			updateSymbol(var_name, expr);
			//printTable();
		}
		else if (strcmp(sym->type,"float") == 0 && type == 1)
		{
			updateSymbol(var_name, expr);
			//printTable();
		}
		else if (strcmp(sym->type,"string") == 0 && type == 2)
		{
			updateSymbol(var_name, expr);
			//printTable();			
		}
		else
		{
			char *stype = malloc(7 * sizeof(char));
			switch(type)
			{
				case 0:
					stype = "int";
				break;
				case 1:
					stype = "float";
				break;
				case 2:
					stype = "string";
				break;
				default:
				stype = "no way";
			}
			printf("LINE:%d variable %s of type %s incompatible with type %s\n", yylineno, var_name, stype, sym->type);
		}
	}
	else
	{
		printf("LINE:%d undeclared variable named %s\n", yylineno, var_name);
	}
}

int main(void){
    yyparse();
	printTable();
    return 0;
}
int yyerror(char *msg){
    fprintf(stderr,"%s \n",msg);
    exit(1);
}