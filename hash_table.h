#ifndef _HASH_TABLE_H_
#define _HASH_TABLE_H_

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "structs.h"

// Pretty much any prime number is okay for the chain value
// Also the chain has to be greater than 50
#define CHAIN 53

union Value{
    int valueInt;
    float valueFloat;
    char* valueString;
    char* variableName;
    int valueBool;
    nodeType* nPtr;  
};

typedef union Value Value;

struct symbol{
    Value value;
    char* variableName;
    char* type;
    int scope;
    struct symbol* next;
    int isConstant; // 0 for variables, and 1 for constants
}*block[CHAIN];

typedef struct symbol symbol;

struct node {
    char* key;
    symbol* value;

    struct node * next;
} *table[CHAIN];

int getHash(char* variableName);

/// Searches for a symbol, returns true if it already exists.
/// Returns false if it does not.
int searchSymbol(symbol * searchKey);

int insertSymbol(symbol * newSymbol);

/// Finds the symbol, and returns it.
/// If the status code is false, then the symbol is not found.
symbol * findSymbol(char* variableName, int * statusCode);

void updateNodeEntry(struct node * p, Value newVal);

int updateSymbol(char * variableName, Value val);

void printTableEntry(struct node* startingNode);

void printTable();

symbol* createSymbol(char * name, char* type, Value value, int scope, int isConstant);


#endif // !_HASH_TABLE_H



