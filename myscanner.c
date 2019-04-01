#include <stdio.h>
#include "defs.h"

extern int yylex(); // gets token id
extern int yylineno; // has token line number
extern char* yytext; // has token value

int main(void) 
{	
	FILE * fp = fopen ("out.txt","w");
	int token;
	token = yylex();
	while (token){
		switch(token){
			case EMAIL:
			fprintf(fp,"Email: %s at line %d\n",yytext,yylineno);
			break;
			case PHONE:
			fprintf(fp,"Phone: %s at line %d\n",yytext,yylineno);
			break;
			case QUESTION:
			fprintf(fp,"Question: %s at line %d\n",yytext,yylineno);
			break;
		}
		token = yylex();
	}
	fclose (fp);
	printf("Done!\n");
	return 0;
}