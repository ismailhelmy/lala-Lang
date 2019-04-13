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

} symbol;

struct node {
    char* key;
    symbol* value;

    struct node * next;
} *table[CHAIN];

int getHash(char* variableName)
{
    // make an ascii sum of the string.
    int sum = 0;
    for(int i = 0; i < strlen(variableName); i++)
    {
        sum += variableName[i];
    }
    // get the modulu of the sum with the chain.
    return (sum % CHAIN);
}

bool insertSymbol(symbol * newSymbol)
{
    struct node * newNode;
    newNode->key = newSymbol->variableName;
    newNode->value = newSymbol;

    int index = getHash(newNode->key);

    // Check if the variable name exists in the table before.
    // namely, the variable name is seen before with the same scope id.
    if(searchSymbol(newSymbol))
    {
        return false;
    }

    // The symbol does not exist, meaning we can add it.
    if(table[index] == NULL)
    {
        // The linked list is empty, so we need to initialize it.
        table[index] = newNode;
        newNode->next = NULL;
    } else {

        // Adding the node in the head of the list, this is just faster.
        struct node* oldHead = table[index];
        newNode->next = oldHead;
        table[index] = newNode;
    }
    return true;
}

/// Searches for a symbol, returns true if it already exists.
/// Returns false if it does not.
bool searchSymbol(symbol * searchKey)
{
    int predictedIndex = getHash(searchKey->variableName);
    struct node* predictedNode = table[predictedIndex];

    while(predictedNode != NULL){
        if(strcmp(predictedNode->key, searchKey->variableName) && predictedNode->value->scope == searchKey->scope)
        {
            // We found it.
            return true;
        }
        predictedNode = predictedNode->next;
    }
    return false;
}



void main()
{
    char* name = "value";
    int hash = getHash(name);
    printf("Value of hash is : %d \n", hash);
}