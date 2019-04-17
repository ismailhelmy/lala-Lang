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
             | IF_KEYWORD logical_expr SCOPE_BEGINING body SCOPE_END ELSE_KEYWORD body
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