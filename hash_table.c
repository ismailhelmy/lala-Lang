#include <stdbool.h>
#include <stdio.h>
#include <string.h>

// Pretty much any prime number is okay for the chain value
// Also the chain has to be greater than 50
#define CHAIN 53

typedef union {
    int valueInt;
    float valueFloat;
    char* valueString;
    char* variableName;
    bool valueBool;
} Value;

typedef struct {
    Value value;
    char* variableName;
    char* type;
    int scope;

} symbol;int getHash();

typedef struct{
    char* key;
    symbol* value;
} node;

int getHash(char* variableName)
{
    // make an ascii sum of the string.
    int sum = 0;
    for(int i = 0; i < strlen(variableName); i++)
    {
        sum += variableName[i];
    }
    return (sum % CHAIN);
}

void main()
{
    char* name = "value";
    int hash = getHash(name);
    printf("Value of hash is : %d \n", hash);
}