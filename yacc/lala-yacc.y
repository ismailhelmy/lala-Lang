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
%token COMMENT WHILE_KEYWORD IF_KEYWORD ELSE_KEYWORD FOR_KEYWORD LESS_THAN LESS_THAN_EQUAL GREATER_THAN GREATER_THAN_EQUAL SEMI_COLON MODOLU PLUS_EQUAL MINUS_EQUAL IMPORT_KEYWORD COMMA OPEN_BRACKET CLOSED_BRACKET SCOPE_BEGINING SCOPE_END
%token MODULU
%token ENTER OPEN_SQUARE CLOSED_SQUARE WITH
%right SUBTRACT
%left ADD
%left MULTIPLY
%right DIVIDE
%right MODOLU
%right LOGICAL_AND LOGICAL_EQUAL LOGICAL_OR NOT_EQUAL BITWISE_AND BITWISE_XOR BITWISE_OR
%nonassoc PLUS_EQUAL MINUS_EQUAL BITWISE_NOT

%%

/*
This section is for the body declaration
*/

start   : START body END {printf("ACCEPTED");}
        ;


num     : num INT {printf("ACCEPTED");}
        | num FLOAT 
        | INT 
        | FLOAT
        ;

keyword     : FLOAT_KEYWORD
            | INT_KEYWORD
            | STRING_KEYWORD
            | BOOLEAN_KEYWORD
            ;

declaration : keyword VARIABLE SEMI_COLON { printf("A variable with the name : %s declared using c style.\n", $2);}
            | OPEN_SQUARE ENTER VARIABLE WITH keyword CLOSED_SQUARE { printf("A variable with the name : %s declared using LA LA style.\n", $3);}
            ;

assignment  : VARIABLE EQUAL expr SEMI_COLON { printf("A variable with the name : %s is assigned value\n",$1);}
            | keyword VARIABLE EQUAL expr SEMI_COLON { printf("A variable with the name : %s is assigned value of an expression\n",$2);}
            ;

ifstmt :    IF_KEYWORD OPEN_BRACKET condition CLOSED_BRACKET SCOPE_BEGINING body SCOPE_END { printf("An if condition was declared right here.");}
       ;

whileloop   : WHILE_KEYWORD OPEN_BRACKET condition CLOSED_BRACKET SCOPE_BEGINING body SCOPE_END 
{ printf("An While loop was declared right here.");}
  
            ;

forloop : FOR_KEYWORD OPEN_BRACKET assignment condition SEMI_COLON expr SEMI_COLON CLOSED_BRACKET SCOPE_BEGINING body SCOPE_END 
{ printf("An For Loop was declared right here.");}
     ;
       
expr    : unioperatorexpression
            | expr MULTIPLY expr 
            | expr DIVIDE expr
            | num
            | expr ADD expr
            | expr SUBTRACT expr
            | VARIABLE
            | BOOLEAN
            | expr LOGICAL_AND expr
            | expr LOGICAL_EQUAL expr
            | OPEN_BRACKET expr CLOSED_BRACKET
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

body    : assignment body {printf("ACCEPTED");}
        | declaration body
        | ifstmt body
        | whileloop body
        | forloop body
        | comment body
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