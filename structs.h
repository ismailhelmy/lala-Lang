#ifndef _STRUCTS_H_
#define _STRUCTS_H_

#include <stdio.h>

typedef enum { typeCon, typeId, typeOpr } nodeEnum;
typedef enum { typeint, typefloat, typestring, typebool, typevoid} conTypeEnum;
/* constants */
typedef struct {
    conTypeEnum type;
    /* value of constants */
	int flag;    /* 0-->int, 1-->float, 2-->char, 3-->string */
	char* value;
} conNodeType;

/* identifiers */
typedef struct {
    int i;  	/* subscript to sym array */
	int flag;    /* 0->int, 1->float, 2->char, 3->string, 4->bool, 5->const int, 6->const float, 7->const char, 8->const string, 9->const bool*/
	int permission; /* -1-> not declared, -2-> const, -3-> already defined */
	char* name;
    int scopeId;
} idNodeType;

/* operators */
typedef struct {
    int oper;                   /* operator */
    int nops;                   /* number of operands */
    struct nodeTypeTag *op[1];	/* operands, extended at runtime */
} oprNodeType;

typedef struct nodeTypeTag {
    nodeEnum type;              /* type of node */

    union {
        conNodeType con;        /* constants */
        idNodeType id;          /* identifiers */
        oprNodeType opr;        /* operators */
    };
} nodeType;

//extern char* symValue[26];
 char* symId[26];
 int symType[26];
 int symUsed[26];
 int symInit[26];
 int symBraces[26]; 
 FILE* yyin;
 FILE* yyout;

#endif