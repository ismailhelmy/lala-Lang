%{
    #include <stdio.h>
    #include <stdlib.h>
   // #include "hash_table.c"
    extern int yylex();
    void yyerror(char *msg);
%}

%union{
    int valueInt;
    float valueFloat;
    char* valueString;
    char* variableName;
    _Bool valueBool;
};

%token <valueInt> INT
%token <valueFloat> FLOAT
%token <valueString> STRING
%token <variableName> VARIABLE
%token <valueBool> BOOLEAN
%token START END INT_KEYWORD STRING_KEYWORD BOOLEAN_KEYWORD FLOAT_KEYWORD ADD SUBTRACT MULTIPLY DIVIDE POWER BITWISE_XOR BITWISE_AND BITWISE_OR BITWISE_NOT LOGICAL_EQUAL NOT_EQUAL LOGICAL_AND LOGICAL_OR EQUAL
%token ELSEIF_KEYWORD COLON CONST_KEYWORD BREAK_KEYWORD CASE_KEYWORD SWITCH_KEYWORD COMMENT WHILE_KEYWORD IF_KEYWORD ELSE_KEYWORD FOR_KEYWORD LESS_THAN LESS_THAN_EQUAL GREATER_THAN GREATER_THAN_EQUAL SEMI_COLON MODOLU PLUS_EQUAL MINUS_EQUAL IMPORT_KEYWORD COMMA OPEN_BRACKET CLOSED_BRACKET SCOPE_BEGINING SCOPE_END
%token MODULU
%token ENTER OPEN_SQUARE CLOSED_SQUARE WITH
%right EQUAL
%left SUBTRACT ADD
%left MULTIPLY
%right DIVIDE
%right MODOLU
%right LOGICAL_AND LOGICAL_EQUAL LOGICAL_OR NOT_EQUAL BITWISE_AND BITWISE_XOR BITWISE_OR
%nonassoc PLUS_EQUAL MINUS_EQUAL BITWISE_NOT

%type <valueInt> expr num

%%

/*
This section is for the body declaration
*/

start   : START body END /*{printf("ACCEPTED");}*/
        ;


num     : num INT /*{printf("ACCEPTED");}*/
        | num FLOAT 
        | INT 
        | FLOAT
        ;

value : num
        | STRING
        | BOOLEAN
        ;

typekeyword : FLOAT_KEYWORD
            | INT_KEYWORD
            | STRING_KEYWORD
            | BOOLEAN_KEYWORD
            ;

declaration : typekeyword VARIABLE SEMI_COLON { printf("A variable with the name : %s declared using c style.\n", $2);}
            | OPEN_SQUARE ENTER VARIABLE WITH typekeyword CLOSED_SQUARE { printf("A variable with the name : %s declared using LA LA style.\n", $3);}
            | constdeclaration
            ;

assignment  : VARIABLE EQUAL expr SEMI_COLON { printf("A variable with the name : %s is assigned value\n",$1);}
            | typekeyword VARIABLE EQUAL expr SEMI_COLON { printf("A variable with the name : %s is assigned value of an expression : %d\n",$2, $4);}
            ;

constdeclaration : CONST_KEYWORD typekeyword VARIABLE EQUAL value SEMI_COLON
            ;

ifstmt :    IF_KEYWORD OPEN_BRACKET condition CLOSED_BRACKET SCOPE_BEGINING body SCOPE_END elseifstmt elsestmt { printf("An if condition was declared right here.");}
       ;

functiondeclaration : typekeyword VARIABLE OPEN_BRACKET paramterlist CLOSED_BRACKET SEMI_COLON

functiondefinition : typekeyword VARIABLE OPEN_BRACKET paramterlist CLOSED_BRACKET SCOPE_BEGINING body SCOPE_END
        ;

paramterlist : typekeyword VARIABLE paramterlist
            | COMMA typekeyword VARIABLE paramterlist
            |
            ;

elseifstmt : ELSEIF_KEYWORD OPEN_BRACKET condition CLOSED_BRACKET SCOPE_BEGINING body SCOPE_END elseifstmt
            |
            ;

elsestmt : ELSE_KEYWORD SCOPE_BEGINING body SCOPE_END
        |
        ;


switchbody : CASE_KEYWORD INT COLON SCOPE_BEGINING body SCOPE_END switchbody
            |
        ;

switchstmt : SWITCH_KEYWORD OPEN_BRACKET VARIABLE CLOSED_BRACKET SCOPE_BEGINING switchbody SCOPE_END
        ;

whileloop   : WHILE_KEYWORD OPEN_BRACKET condition CLOSED_BRACKET SCOPE_BEGINING body SCOPE_END 
{ printf("A While loop was declared right here.\n");}
  
            ;

forloop : FOR_KEYWORD OPEN_BRACKET assignment condition SEMI_COLON iteratoroperation CLOSED_BRACKET SCOPE_BEGINING body SCOPE_END 
 { printf("A For Loop was declared right here.");}
     ;

iteratoroperation : VARIABLE EQUAL expr
                | unioperatorexpression
                ;
       
expr    : expr MULTIPLY expr { $$ = $1 * $3; }
            | expr DIVIDE expr { $$ = $1 / $3; }
            | num { $$ = $1; }
            | expr ADD expr { $$ = $1 + $3; }
            | expr SUBTRACT expr { $$ = $1 - $3; }
            | VARIABLE { $$ = $1; }
            | BOOLEAN { $$ = $1; }
            | expr LOGICAL_AND expr { $$ = $1 & $3; }
            | expr LOGICAL_EQUAL expr { $$ = $1 == $3; }
            | OPEN_BRACKET expr CLOSED_BRACKET { $$ = ($2); }
            | STRING { $$ = $1; }
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

body    : assignment body /*{printf("ACCEPTED");}*/
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
#include"../lexer/lex.yy.c"
int main(void){
    yyparse();
    return 0;
}
void yyerror(char *msg){
    fprintf(stderr,"%s \n",msg);
    exit(1);
}