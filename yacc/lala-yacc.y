%{
    #include <stdio.h>
    #include <stdlib.h>
    extern int yylex();
%}

%union{
    int valueInt;
    float valueFloat;
    char* valueString;
    char* variableName;
    bool valueBool;
};