#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "structs.h"

int yyerror(char *s);
int yylex(void);

void init_structs(void);
void addProblem(char *name);
void addVariable(char *name);
void createTable();
int isUA(variable_node *, variable_node *);
int isGU(variable_node *, variable_node *, variable_node *, variable_node *);
int isIU(variable_node *, variable_node *, variable_node *, variable_node *);
int isGIU(variable_node *, variable_node *, variable_node *, variable_node *);
int isUU(variable_node *, variable_node *, variable_node *, variable_node *);
variable_node *getIntersection(variable_node *, variable_node *);
variable_node *getUnion(variable_node *, variable_node *);
variable_node *getRelativeComplement(variable_node *, variable_node *);
entry *newEntry(char);
void attach(char*, entry*, entry*, int);
void printTable();
void itoa(int n, char s[]);
void reverse(char s[]);
void reIndex(int, int);
int isInSet(variable_node *, variable_node *);
void setInfoVar(entry *, variable_node *);
