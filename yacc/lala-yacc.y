%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "../hash_table.c"
	#include "../lexer/lex.yy.c"
	#include <stdarg.h>
	#include <ctype.h>
	int insertdeclaration(char *, char *);
	int yyerror(char *msg);
	void push(char *token);
	int assign_var_expr(char *var_name, Value expr, int type);
	void codegenjmp();
	void codegen();
	void codegen_assign(char *);
	int op(char *op);
	int cond(char *op);
	int ldVal();
	int condition(char* op, int statement);
	int scopeLevel = -1;
	int statement =0;
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
%type <typeName> typekeyword condition
%type <valueInt> intexpr
%type <valueFloat> floatexpr
%token <typeName> FLOAT_KEYWORD STRING_KEYWORD INT_KEYWORD BOOLEAN_KEYWORD ADD SUBTRACT DIVIDE MULTIPLY OPEN_BRACKET CLOSED_BRACKET BITWISE_NOT LOGICAL_EQUAL NOT_EQUAL LOGICAL_AND LOGICAL_OR LESS_THAN_EQUAL GREATER_THAN GREATER_THAN_EQUAL LESS_THAN
%token START END POWER BITWISE_XOR BITWISE_AND BITWISE_OR EQUAL
%token ELSEIF_KEYWORD VOID_KEYWORD DEFAULT_KEYWORD COLON CONST_KEYWORD BREAK_KEYWORD CASE_KEYWORD SWITCH_KEYWORD COMMENT WHILE_KEYWORD IF_KEYWORD ELSE_KEYWORD FOR_KEYWORD SEMI_COLON MODOLU PLUS_EQUAL MINUS_EQUAL IMPORT_KEYWORD COMMA SCOPE_BEGINING SCOPE_END
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

assignment  : VARIABLE EQUAL intexpr SEMI_COLON  {Value val; val.valueInt = $3; assign_var_expr($1, val, 0); codegen_assign($1);} 
			| VARIABLE EQUAL floatexpr SEMI_COLON {Value val; val.valueFloat = $3; assign_var_expr($1, val, 1); } 
			| VARIABLE EQUAL STRING SEMI_COLON {Value val; val.valueString = $3; assign_var_expr($1, val, 2); }
            | VARIABLE EQUAL functioncall SEMI_COLON {/*check if var and function exists*/}
            ;

ClosedScope : SCOPE_END { scopeLevel--; }

OpenScope : SCOPE_BEGINING { scopeLevel++; }

ifstmt :    IF_KEYWORD OPEN_BRACKET condition CLOSED_BRACKET OpenScope body ClosedScope elseifstmt elsestmt
{ statement = 1;}
       ;

functiondeclaration : typekeyword VARIABLE OPEN_BRACKET paramterlist CLOSED_BRACKET SEMI_COLON

functiondefinition : typekeyword VARIABLE OPEN_BRACKET paramterlist CLOSED_BRACKET OpenScope body ClosedScope
        ;
functioncall : VARIABLE OPEN_BRACKET paramterlist CLOSED_BRACKET;

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
    {statement = 2;}        ;

forloop : FOR_KEYWORD OPEN_BRACKET assignment condition SEMI_COLON iteratoroperation CLOSED_BRACKET OpenScope body ClosedScope 
   {statement = 3;} 	;

iteratoroperation : VARIABLE EQUAL intexpr
                | unioperatorexpression
                ;

intexpr : intexpr MULTIPLY {$2 = "MUL"; } intexpr  {op($2); $$ = $1 * $4; }
		| intexpr DIVIDE { $2 = "DIV"; } intexpr { op($2); $$ = $1 * $4; }
		| intexpr ADD { $2 = "ADD"; } intexpr { op($2); $$ = $1 + $4;  }
		| intexpr SUBTRACT { $2 = "SUB"; } intexpr  {op($2); $$ = $1 - $4;  }
		| OPEN_BRACKET intexpr CLOSED_BRACKET  {$$ = $2; push(yytext);}
		| INT { ldVal(); }
		| VARIABLE { ldVal();}
		;

floatexpr : floatexpr MULTIPLY {$2 = "MUL"; } floatexpr {op($2); $$ = $1 * $4; }
		| floatexpr DIVIDE {$2 = "DIV"; } floatexpr {op($2); $$ = $1 * $4; }
		| floatexpr ADD {$2 = "ADD"; } floatexpr {op($2); $$ = $1 * $4; }
		| floatexpr SUBTRACT {$2 = "SUB"; } floatexpr {op($2); $$ = $1 * $4; }
		| OPEN_BRACKET floatexpr CLOSED_BRACKET {$$ = $2; push(yytext);}
		| FLOAT { ldVal();}
		| VARIABLE { ldVal();}
		;

condition : intexpr LOGICAL_AND {$2 = "AND"; } intexpr {condition($2,statement);  }
          | intexpr LOGICAL_EQUAL {$2 = "JE"; } intexpr {condition($2,statement);  }
          | intexpr LOGICAL_OR {$2 = "OR"; } intexpr {condition($2,statement); }
          | BITWISE_NOT {$1 = "NOT"; } intexpr {condition($1,statement); }
          | intexpr NOT_EQUAL {$2 = "JNE"; } intexpr {condition($2,statement); }
          | intexpr LESS_THAN {$2 = "JLT"; } intexpr {condition($2,statement); }
          | intexpr LESS_THAN_EQUAL {$2 = "JLE"; }intexpr {condition($2,statement); }
          | intexpr GREATER_THAN {$2 = "JGT"; } intexpr {condition($2,statement); }
          | intexpr GREATER_THAN_EQUAL {$2 = "JGE"; } intexpr {condition($2,statement); }
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
char codegen_stack[100][10];
int top=0;
char temp[3] = "R0";
char label[3]="L0";

int ld_count = 0;
//functions for code generation
void push(char *token)
{
	strcpy(codegen_stack[++top], token); 
}

int ldVal()
{
	char *LD = "LD ";
	push(LD);
	char *reg = temp;
	push(reg);
	push(yytext);
	codegen();
	ld_count++;
}

int op(char *op)
{
	temp[1] -= ld_count;
	ld_count = 0;
	push(op);
	char *src1 = temp;
	push(src1);
	temp[1]++;
	char *src2 = temp;
	push(src2);
	temp[1]++;
	char *dst = temp;
	push(dst);
	printf("%s %s %s %s \n", codegen_stack[top-3], codegen_stack[top-2], codegen_stack[top-1], codegen_stack[top]);
    top -= 2;
	if(temp[1] >= '8') temp[1] -= 8;
}
int condition(char* op, int statement){

if (statement == 0) // Normal operation
{
	push(op);
	temp[1]-=1;
	char* src1 = temp;
    push(src1);
	temp[1]-=1;
	char* src2 = temp;
	push(src2);
//	push(yytext);
	codegen();
	push("JE");
	temp[1]-=1;
	char* src11 = temp;
    push(src11);
	temp[1]+=1;
	char* src22 = temp;
	push(src22);

}
else if(statement == 1) // if 
{
   push(op);
	
		temp[1]-=1;
	char* src1 = temp;
    push(src1);
	temp[1]-=1;
	char* src2 = temp;
	push(src2);
//	push(yytext);
	codegen();
	push("JE");
	temp[1]-=1;
	char* src11 = temp;
    push(src11);
	temp[1]+=1;
	char* src22 = temp;
	push(src22);
	char*lbl =label;
	push(lbl);
	

	codegenjmp();
}
else if (statement == 2) // While
{

}

else if (statement == 3) //For 
{

}
}
int jmps(char *op)
{
	push(op);
	char*lbl =label;
		temp[1]-=1;
	char* src1 = temp;
    push(src1);
	temp[1]-=1;
	char* src2 = temp;
	push(src2);
	push(lbl);
//	push(yytext);
	codegenjmp();
}
int cond(char *opr )
{
	jmps(opr);

}

void codegen_assign(char * var_name)
{
	temp[1]--;
	char *ST = "ST ";
	push(ST);
	push(var_name);
	push(temp);
    printf("%s %s %s \n", codegen_stack[top-2], codegen_stack[top-1], codegen_stack[top]);
    top -= 2;
    strcpy(codegen_stack[top], temp);
    temp[1]++; //gemerate new temp var
	if(temp[1] >= '8') temp[1] -= 8;
}

void codegen()
{
    printf("%s %s %s \n", codegen_stack[top-2], codegen_stack[top-1], codegen_stack[top]);
    top -= 2;
    strcpy(codegen_stack[top], temp);
    temp[1]++; //gemerate new temp var
}

void codegenjmp(){
	 printf("%s %s %s %s \n",codegen_stack[top-3], codegen_stack[top-2], codegen_stack[top-1], codegen_stack[top]);
    top -= 3;
    strcpy(codegen_stack[top], temp);
    temp[1]--; //gemerate new temp var
}


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
		printf("ERROR@LINE %d: variable with name %s already declared\n", mylineno, var_name);
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
			printf("ERROR@LINE %d: variable %s of type %s incompatible with type %s\n", mylineno, var_name, stype, sym->type);
		}
	}
	else
	{
		printf("ERROR@LINE %d: undeclared variable named %s\n", mylineno, var_name);
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