#include "stdio.h"
#include "token_definitions.h"

extern int yylex();
extern int yylineo;
extern char* yytext;

int main(void)
{
    int token;
    token = yylex();
    while(token){
        switch (token)
        {
            case STRING_KEYWORD:
                printf("STRING KEYWORD\n");
                break;
            default:
                printf("Found token\n");
                break;
        }
        token = yylex();
    }
    printf("Done");
    return 0;
}