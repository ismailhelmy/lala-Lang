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
    int scopeId;
    int classType;
    struct symbol* next;
    int isConstant; // 0 for variables, and 1 for constants
}*block[CHAIN];

typedef struct symbol symbol;

struct node {
    char* key;
    symbol* value;
    struct tableNode* t_node;
    struct node * next;
};

struct tableNode {
    int scopeId, parentScopeId;
    struct tableNode *prev_sib, *next_sib; // pointing on nodes in same level their parent would be the same 
    struct tableNode *child, *parent; // pointing on parent and child 
}; 

//the parent symbol table
struct node * table[CHAIN];

int getHash(char* variableName)
{
    // make an ascii sum of  the string.
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
        if(strcmp(predictedNode->key, searchKey->variableName) && predictedNode->value->scopeId == searchKey->scopeId)
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

void updateNodeEntry(struct node * p, Value newVal)
{
    if(strcmp(p->value->type,"int") == 0)
    {
        p->value->value.valueInt = newVal.valueInt;
    }else if(strcmp(p->value->type, "string") == 0)
    {
        p->value->value.valueString = newVal.valueString;
    }else if(strcmp(p->value->type, "float") == 0)
    {
        p->value->value.valueFloat = newVal.valueFloat;
    }else if(strcmp(p->value->type,"boolean") == 0)
    {
        p->value->value.valueBool = newVal.valueBool;
    }
}

// Update a table entry
int updateSymbol(char * variableName, Value val)
{
    int predictedIndex = getHash(variableName);

    struct node * predictedNode = table[predictedIndex];

    while(predictedNode != NULL)
    {
        if(strcmp(variableName, predictedNode->value->variableName) == 0)
        {
            // Cannot change constant values.
            if(predictedNode->value->isConstant == 1)
            {
                return 0;
            }
            updateNodeEntry(predictedNode, val);
            return 1;
        }
    }
    return 0;
}

void printTableEntry(struct node* startingNode)
{
    struct node* p = startingNode;

    while(p != NULL)
    {
        if(strcmp(p->value->type,"int") == 0)
        {
            printf("%s\t%s\t%d\t%d\t%d\n", p->value->variableName, p->value->type, (p->value->value.valueInt), p->value->isConstant, p->value->scopeId);
        }else if(strcmp(p->value->type, "string") == 0)
        {
            printf("%s\t%s\t%s\t%d\t%d\n", p->value->variableName, p->value->type, p->value->value.valueString, p->value->isConstant, p->value->scopeId);
        }else if(strcmp(p->value->type, "float") == 0)
        {
            printf("%s\t%s\t%f\t%d\t%d\n", p->value->variableName, p->value->type, p->value->value.valueFloat, p->value->isConstant, p->value->scopeId);
        }else if(strcmp(p->value->type,"boolean") == 0)
        {
            printf("%s\t%s\t%s\t\n", p->value->variableName, p->value->type, p->value->value.valueBool == 1? "true": "false");
        }
        p = p->next;
    }
}

void printTable()
{
    printf("id\ttype\tvalue\t\tisConstant\tscope\n------------------------------------------------------\n");
    for(int i = 0; i < CHAIN; i++)
    {
        printTableEntry(table[i]);
    }
    printf("\n");
}

symbol* createSymbol(char * name, char* type, Value value, int scope, int isConstant)
{
    symbol * mysymbol = malloc(sizeof(symbol));
    mysymbol->variableName = malloc(strlen(name));
    strcpy(mysymbol->variableName, name);
    mysymbol->type = malloc(strlen(type));
    strcpy(mysymbol->type, type);
    mysymbol->scopeId = scope;
    mysymbol->value = value;
    mysymbol->isConstant = isConstant;

    return mysymbol;
}

// void main(void)
// {
//     char* name = "value";
//     symbol * mysymbol = malloc(sizeof(symbol));
//     mysymbol->variableName = malloc(strlen(name));
//     strcpy(mysymbol->variableName, name);
//     mysymbol->value.valueInt = 5;
//     mysymbol->scopeId = 1;
//     mysymbol->type = "int";
//     int hey = insertSymbol(mysymbol);
//     if(hey == 1)
//     {
//         printf("We have inserted that symbol perfectly, cool %d\n", 0);
//     }
//     int isFound;
//     mysymbol = findSymbol(name, &isFound);
//     if(isFound)
//     {
//         printf("Found the symbol with name %s, with value: %d\n", name, mysymbol->value.valueInt);
//     }
//     //printTable();

//     Value val;
//     val.valueFloat = 10.5f;
//     symbol * secondSymbol = createSymbol("ismail", "float", val, 0, 1);

//     val.valueBool = 0;
//     symbol * thirdSymbol = createSymbol("isFound" , "boolean", val, 2, 1);

//     int insert = insertSymbol(secondSymbol);
//     insertSymbol(thirdSymbol);
//     printTable();
//     Value newVal;
//     newVal.valueBool = 1;
//     updateSymbol("isFound", newVal);
//     printf("Updated isFound to true\n");
//     printTable();

//     newVal.valueString = "ibrahim";
//     insertSymbol(createSymbol("name", "string", newVal, 2, 0));
//     printf("\nAdded a new string variable\n");
//     printTable();

//     newVal.valueString = "ismail";
//     updateSymbol("name", newVal);
//     printTable();

// }