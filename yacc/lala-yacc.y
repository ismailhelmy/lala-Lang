%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "../hash_table.h"
	#include "../structs.h"
	#include "../lexer/lex.yy.c"
	#include <stdarg.h>
	//void ftoa(float n,char res[], int afterpoint);
    nodeType *opr(int oper, int nops, ...);
	nodeType *id(int flag, char name[], int per);
	nodeType *getid(char name[]);
	nodeType *con(char* s, int flag);
	int insertSymbol(symbol * newSymbol);
	void freeNode(nodeType *p);
	int ex(nodeType *p);
    extern int yylex();
    void yyerror(char *msg);
    int isLogical = 0;
	int level = -1;
	int scopeId = 0;
	int isDeclaration = 0 ;
	void openScope();
	void closeScope();
	#define nestingStackMaxLength 15
	int NestingStack[15];
	char *my_itoa(int num, char *str);

%}

%union{
    int valueInt;
    float valueFloat;
    char* valueString;
    char* variableName;
    _Bool valueBool;
    nodeType* nPtr;
	conTypeEnum conType;
};

%token <valueInt> INT
%token <valueFloat> FLOAT
%token <valueString> STRING
%token <variableName> VARIABLE
%token <valueBool> BOOLEAN
%token START END INT_KEYWORD STRING_KEYWORD BOOLEAN_KEYWORD FLOAT_KEYWORD ADD SUBTRACT MULTIPLY DIVIDE POWER BITWISE_XOR BITWISE_AND BITWISE_OR BITWISE_NOT LOGICAL_EQUAL NOT_EQUAL LOGICAL_AND LOGICAL_OR EQUAL
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

%type <nPtr> value switchbody switchstmt expr num unioperatorexpression body declaration assignment typekeyword constdeclaration

%%



/*
This section is for the body declaration
*/

start   : START body END /*{printf("ACCEPTED");}*/
        ;


num     :INT { char c[] = {}; my_itoa($1, c);  $$ = con(c,0);}
		| FLOAT /*{ char c[] = {}; //ftoa($1, c, 10);  $$ = con(c,1);}*/
        ;

value : num {$$ = $1;}
        | STRING{ $$ = con($1,3);}
        | BOOLEAN {if ($1) $$ = con("true",4); else $$ = con("false",4); }
        ;

typekeyword : FLOAT_KEYWORD { $$ = con("float",3);}
            | INT_KEYWORD	{ $$ = con("int",3);}
            | STRING_KEYWORD{ $$ = con("string",3);}
            | BOOLEAN_KEYWORD{ $$ = con("bool",3);}
            ;

declaration : typekeyword VARIABLE SEMI_COLON {
						isDeclaration = 1;
					        if ($1 == getid("int"))  
								$$ = id( 0, $2, 0);
								else if($1 == getid("float")) $$ = id(1, $2, 0);
								else if  ($1 == getid("char")) $$ = id(2, $2, 0);
								else if  ($1 == getid("string")) $$ = id(3, $2, 0);
								else if($1 == getid("boolean")) $$ = id( 4, $2, 0);
                                }
						
            | OPEN_SQUARE ENTER VARIABLE WITH typekeyword CLOSED_SQUARE {
						isDeclaration = 1;
					        if ($5 == getid("int") ) $$ = id( 0, $3, 0);
								else if($5 == getid("float")) $$ = id(1, $3, 0);
								else if  ($5 == getid("char")) $$ = id(2, $3, 0);
								else if  ($5 == getid("string")) $$ = id(3, $3, 0);
								else if($5 == getid("boolean") ) $$ = id( 4, $3, 0);
                                }
            | constdeclaration {$$ = $1;}
            ;

assignment  : VARIABLE EQUAL expr SEMI_COLON  { $$ = opr(EQUAL, 2, getid($1), $3);}
            | typekeyword VARIABLE EQUAL expr SEMI_COLON { printf("A variable with the name : %s is assigned value of an expression\n",$2);}
            | VARIABLE EQUAL functioncall SEMI_COLON
            ;
OpenScope   : SCOPE_BEGINING {openScope();}

ClosedScope : SCOPE_END {closeScope();}
constdeclaration : CONST_KEYWORD typekeyword VARIABLE EQUAL value SEMI_COLON { $$  = opr(EQUAL,2,getid($3),$5);}
            ;

ifstmt :    IF_KEYWORD OPEN_BRACKET condition CLOSED_BRACKET OpenScope body ClosedScope elseifstmt elsestmt { printf("An if condition was declared right here.");}
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


switchbody : CASE_KEYWORD INT COLON OpenScope body ClosedScope switchbody {$$ = opr(SWITCH_KEYWORD,2,$2,$5);} 
			| { $$ = NULL; }
        ;

switchstmt : SWITCH_KEYWORD OPEN_BRACKET VARIABLE CLOSED_BRACKET OpenScope switchbody ClosedScope
			 {$$ = opr(SWITCH_KEYWORD,2,getid($3),$6);};

whileloop   : WHILE_KEYWORD OPEN_BRACKET condition CLOSED_BRACKET OpenScope body ClosedScope 
{ printf("A While loop was declared right here.\n");}
  
            ;

forloop : FOR_KEYWORD OPEN_BRACKET assignment condition SEMI_COLON iteratoroperation CLOSED_BRACKET OpenScope body ClosedScope 
    ;

iteratoroperation : VARIABLE EQUAL expr
                | unioperatorexpression
                ;
       
expr    : expr MULTIPLY expr /*{ $$ = $1 * $3; }*/
            | expr DIVIDE expr /*{ $$ = $1 / $3; }*/
            | num /*{ $$ = $1; }*/
            | expr ADD expr /*{ $$ = $1 + $3; }*/
            | expr SUBTRACT expr /*{ $$ = $1 - $3; }*/
            | VARIABLE /*{ $$ = $1; }*/
            | BOOLEAN /*{ $$ = $1; }*/
            | expr LOGICAL_AND expr /*{ $$ = $1 & $3; }*/
            | expr LOGICAL_EQUAL expr /*{ $$ = $1 == $3; }*/
            | OPEN_BRACKET expr CLOSED_BRACKET /*{ $$ = ($2); }*/
            | STRING /*{ $$ = $1; }*/
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
          VARIABLE PLUS_EQUAL expr{$$ = opr(PLUS_EQUAL,2,getid($1),$3);}
        | VARIABLE MINUS_EQUAL expr{$$=opr(MINUS_EQUAL,2,getid($1),$3);}
        ;

body    : assignment body /*{printf("ACCEPTED");}*/
        | declaration body
        | ifstmt body
        | whileloop body
        | forloop body
        | comment body{$$ = $2;}
        | switchstmt body
        | functiondeclaration body
        | functiondefinition body
        | unioperatorexpression SEMI_COLON body
        |{ $$ = opr(9999, 0);}
        ;
comment : COMMENT 
        ;


%%
#define SIZEOF_NODETYPE ((char *)&p->con - (char *)p)  

char *my_itoa(int num, char *str)
{
        if(str == NULL)
        {
                return NULL;
        }
        sprintf(str, "%d", num);
        return str;
}

nodeType *con(char* s, int flag) { 
	nodeType *p;      
	
	/* allocate node */     
	if ((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");      
		
	/* copy information */ 
	p->type = typeCon;
	p->con.value = strdup(s);
	p->con.flag = flag;
	return p; 
}

nodeType *id( int flag, char name[], int per) {

	//Implementing new entry in the symbol table :)
	struct symbol *STEntry = malloc(sizeof(struct symbol));
	(*STEntry).variableName = name;
	(*STEntry).classType = flag;
	if(level!=-1)
		(*STEntry).scopeId = NestingStack[level];
	if(per == -2)
		(*STEntry).isConstant = 1;
	else
		(*STEntry).isConstant = 0;


	nodeType *p;

	/* allocate node */
	if ((p = malloc(sizeof(nodeType))) == NULL)
		yyerror("out of memory");


	if( insertSymbol(STEntry) )
	{
		p->type = typeId;
		p->id.scopeId = NestingStack[level];
		p->id.name = strdup(name);
		p->id.permission = per;
		p->id.flag = flag;
		p->id.permission = isDeclaration;
		isDeclaration = 0;
		return p;

	}

	p->id.name = strdup(name);
	p->type = typeId;
	p->id.permission = -3;
	return p;
}

nodeType *getid(char name[]) {
	nodeType *p;
	
	/* allocate node */     
	if ((p = malloc(sizeof(nodeType))) == NULL)         
		yyerror("out of memory");
		
	int j = 0;	
	//while(symId[j] != NULL) {
	for(j = 0; j < 26; j++) {
		if(symId[j] != NULL){
			if(strcmp(symId[j], name) == 0) {
				p->type = typeId;     
				p->id.i = j;
				p->id.name = strdup(name);
				
				if(symBraces[j] == -5) {
					p->id.permission = -1;
				}
				else if(symType[j] == 5 || symType[j] == 6 || symType[j] == 7 || symType[j] == 8 || symType[j] == 9){
					p->id.permission = -2;
				}
				else{
					p->id.permission = 0;
				}
				p->id.flag = symType[j];
				return p;
			}
		}
	}
	
	p->type = typeId;     
	p->id.name = strdup(name);
	p->id.permission = -1;
	return p;	
}

nodeType *opr(int oper, int nops, ...) { 
	va_list ap;     
	nodeType *p;     
	int i;      

	/* allocate node, extending op array */     
	if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)         
		yyerror("out of memory");      
		
	/* copy information */     
	p->type = typeOpr;     
	p->opr.oper = oper;     
	p->opr.nops = nops;     
	va_start(ap, nops);     
	for (i = 0; i < nops; i++)         
		p->opr.op[i] = va_arg(ap, nodeType*); 
		
	va_end(ap);     
	return p; 
}	

void freeNode(nodeType *p) {     
	int i;      
	if (!p) 
		return;     
		
	if (p->type == typeOpr) {         
		for (i = 0; i < p->opr.nops; i++)             
			freeNode(p->opr.op[i]);     
	}     
	
	free (p); 
} 


void openScope(){
	level = level + 1;
	if(level!=-1)
		NestingStack[level] = scopeId;
	scopeId = scopeId + 1;

}


void closeScope(){

	level = level -1;

	if(level ==-1)
		printTable();

}


int main(void){
    yyparse();
    return 0;
}
void yyerror(char *msg){
    fprintf(stderr,"%s \n",msg);
    exit(1);
}