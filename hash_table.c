#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// Pretty much any prime number is okay for the chain value
// Also the chain has to be greater than 50
#define CHAIN 53

union Value{
    int valueInt;
    float valueFloat;
    char* valueString;
    char* variableName;
    int valueBool;
};

typedef union Value Value;

struct symbol{
    Value value;
    char* variableName;
    char* type;
    int scope;
};

typedef struct symbol symbol;

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

/// Searches for a symbol, returns true if it already exists.
/// Returns false if it does not.
int searchSymbol(symbol * searchKey)
{
    int predictedIndex = getHash(searchKey->variableName);
    struct node* predictedNode = table[predictedIndex];

    while(predictedNode != NULL){
        if(strcmp(predictedNode->key, searchKey->variableName) && predictedNode->value->scope == searchKey->scope)
        {
            // We found it.
            return 1;
        }
        predictedNode = predictedNode->next;
    }
    return 0;
}

int insertSymbol(symbol * newSymbol)
{
    struct node * newNode = malloc(sizeof(struct node));
    newNode->key = newSymbol->variableName;
    newNode->value = newSymbol;
    int index = getHash(newNode->key);

    // Check if the variable name exists in the table before.
    // namely, the variable name is seen before with the same scope id.
    int found = searchSymbol(newSymbol);
    if(found == 1)
    {
        return 0;
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
    return 1;
}

/// Finds the symbol, and returns it.
/// If the status code is false, then the symbol is not found.
symbol * findSymbol(char* variableName, int * statusCode)
{
    int predictedIndex = getHash(variableName);

    struct node* predictedNode = table[predictedIndex];

    while(predictedNode != NULL)
    {
        if(strcmp(variableName, predictedNode->value->variableName) == 0)
        {
            *statusCode = 1;
            return predictedNode->value;
        }
        predictedNode = predictedNode->next;
    }
    *statusCode = 0;
    return NULL;
}

void printTableEntry(struct node* startingNode)
{
    struct node* p = startingNode;

    while(p != NULL)
    {
        printf("%s\t%s\t%d\t", p->value->variableName, p->value->type, (p->value->value.valueInt));
        p = p->next;
    }
}

void printTable()
{
    printf("id\ttype\tvalue\n");
    for(int i = 0; i < CHAIN; i++)
    {
        printTableEntry(table[i]);
    }
    printf("\n");
}

void main()
{
    char* name = "value";
    symbol * mysymbol = malloc(sizeof(symbol));
    mysymbol->variableName = malloc(strlen(name));
    strcpy(mysymbol->variableName, name);
    mysymbol->value.valueInt = 5;
    mysymbol->scope = 1;
    mysymbol->type = "int";
    int hey = insertSymbol(mysymbol);
    if(hey == 1)
    {
        printf("We have inserted that symbol perfectly, cool %d\n", 0);
    }
    int isFound;
    mysymbol = findSymbol(name, &isFound);
    if(isFound)
    {
        printf("Found the symbol with name %s, with value: %d\n", name, mysymbol->value.valueInt);
    }
    printTable();
}