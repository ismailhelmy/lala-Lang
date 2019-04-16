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
%token INT_KEYWORD STRING_KEYWORD BOOLEAN_KEYWORD FLOAT_KEYWORD ADD SUBTRACT MULTIPLY DIVIDE POWER BITWISE_XOR BITWISE_AND BITWISE_OR BITWISE_NOT LOGICAL_EQUAL NOT_EQUAL LOGICAL_AND LOGICAL_OR EQUAL
%token WHILE_KEYWORD IF_KEYWORD ELSE_KEYWORD FOR_KEYWORD LESS_THAN LESS_THAN_EQUAL GREATER_THAN GREATER_THAN_EQUAL SEMI_COLON MODOLU PLUS_EQUAL MINUS_EQUAL IMPORT_KEYWORD COMMA OPEN_BRACKET CLOSED_BRACKET SCOPE_BEGINING SCOPE_END
%right SUBTRACT
%left ADD
%left MULTIPLY
%right DIVIDE
%right MODOLU
%nonassoc PLUS_EQUAL MINUS_EQUAL


%%

/*
This section is for the body declaration
*/

start   : SCOPE_BEGINING body SCOPE_END {printf("ACCEPTED");}
        ;


num     : num INT {printf("ACCEPTED");}
        | num FLOAT 
        | INT 
        | FLOAT 
        | math_expr
        ;
body    : assignment body {printf("ACCEPTED");}
        | assignment
        | ifstmt body
        | ifstmt
        ;

/* 
This section is for assignment
*/

type : num | STRING | BOOLEAN;
assignment  : INT_KEYWORD VARIABLE EQUAL INT SEMI_COLON
            | STRING_KEYWORD VARIABLE EQUAL STRING SEMI_COLON
            | FLOAT_KEYWORD VARIABLE EQUAL FLOAT SEMI_COLON
            | BOOLEAN_KEYWORD VARIABLE EQUAL INT SEMI_COLON
            | VARIABLE EQUAL VARIABLE SEMI_COLON
            | VARIABLE EQUAL type SEMI_COLON
            | VARIABLE EQUAL math_expr SEMI_COLON


math_expr   : VARIABLE 
            | num
            | math_expr SUBTRACT math_expr
            | VARIABLE ADD math_expr
            | VARIABLE DIVIDE math_expr 
            | VARIABLE MULTIPLY math_expr
            | VARIABLE MODOLU math_expr
            | OPEN_BRACKET math_expr CLOSED_BRACKET

/*
This section is for if statements
*/

ifstmt       : IF_KEYWORD logical_expr SCOPE_BEGINING body SCOPE_END body
             | IF_KEYWORD logical_expr SCOPE_BEGINING body SCOPE_END ELSE_KEYWORD ifstmt
             ;


logical_expr : OPEN_BRACKET logical_expr CLOSED_BRACKET
             | math_expr LOGICAL_EQUAL logical_expr
             | math_expr NOT_EQUAL logical_expr
             | math_expr LOGICAL_AND logical_expr
             | math_expr LOGICAL_OR logical_expr
             | math_expr GREATER_THAN_EQUAL logical_expr
             | math_expr LESS_THAN_EQUAL logical_expr
             | math_expr GREATER_THAN logical_expr
             | math_expr LESS_THAN logical_expr
             | BITWISE_NOT logical_expr
             | BOOLEAN
             | INT LOGICAL_EQUAL INT
             | STRING LOGICAL_EQUAL STRING
             | FLOAT LOGICAL_EQUAL FLOAT
             | VARIABLE LOGICAL_EQUAL VARIABLE
             ;

/*
This section is for while statements
*/
whilestmt : WHILE_KEYWORD '(' logical_expr ')' SCOPE_BEGINING body SCOPE_END
          ;


/*
This section is for for statements
*/
forloop : FOR_KEYWORD '(' assignment SEMI_COLON logical_expr SEMI_COLON math_expr ')'
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