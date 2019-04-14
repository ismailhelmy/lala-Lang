%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "hash_table.c"
    extern int yylex();
%}

%union{
    int valueInt;
    float valueFloat;
    char* valueString;
    char* variableName;
    bool valueBool;
};

%token <valueInt> INT
%token <valueFloat> FLOAT
%token <valueString> STRING
%token <variableName> VARIABLE
%token <valueBool> BOOLEAN
%token INT_KEYWORD STRING_KEYWORD BOOLEAN_KEYWORD FLOAT_KEYWORD ADD SUBTRACT MULTIPLY DIVIDE POWER BITWISE_XOR BITWISE_AND BITWISE_OR BITWISE_NOT LOGICAL_EQUAL NOT_EQUAL LOGICAL_AND LOGICAL_OR EQUAL VARIABLE  
%token WHILE_KEYWORD IF_KEYWORD FOR_KEYWORD LESS_THAN LESS_THAN_EQUAL GREATER_THAN GREATER_THAN_EQUAL SEMI_COLON MODOLU PLUS_EQUAL MINUS_EQUAL IMPORT_KEYWORD COMMA OPEN_BRACKET CLOSED_BRACKET SCOPE_BEGINING SCOPE_END
%right SUBTRACT
%left ADD
%left MULTIPLY
%left DIVIDE
%right MODOLU
%nonassoc PLUS_EQUAL MINUS_EQUAL


%%
/*
* int | float -> num
*/

/*
This section is for the body declaration
*/


num     : INT 
        | FLOAT
        ;
body    : ifstmt body
        | whilestmt body  
        | forstmt body
        | assignment body

/* 
This section is for assignment
*/

type : FLOAT | INT | STRING | BOOLEAN
assignment  : INT_KEYWORD VARIABLE EQUAL INT SEMI_COLON
            | STRING_KEYWORD VARIABLE EQUAL STRING SEMI_COLON
            | FLOAT_KEYWORD VARIABLE EQUAL FLOAT SEMI_COLON
            | BOOLEAN_KEYWORD VARIABLE EQUAL BOOLEAN SEMI_COLON
            | VARIABLE EQUAL VARIABLE SEMI_COLON
            | VARIABLE EQUAL type SEMI_COLON
            | VARIABLE EQUAL math_expr SEMI_COLON


math_expr   : VARIABLE 
            | num
            | math_expr SUBTRACT math_expr
            | math_expr ADD math_expr
            | math_expr DIVIDE math_expr 
            | math_expr MULTIPLY math_expr
            | math_expr MODOLU math_expr
            | OPEN_BRACKET math_expr CLOSED_BRACKET

/*
This section is for if statements
*/


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


ifstmt      : IF_KEYWORD OPEN_BRACKET logical_expr CLOSED_BRACKET SCOPE_BEGINING body SCOPE_END




/*
This section is for while statements
*/

whilestmt   : WHILE_KEYWORD OPEN_BRACKET logical_expr CLOSED_BRACKET SCOPE_BEGINING body SCOPE_END
            | 

/*
This section is for for statements
*/

forstmt     : FOR_KEYWORD OPEN_BRACKET
