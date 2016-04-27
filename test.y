%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #define PROBLEM 0
    #define SUBPROBLEM 1

    int yyerror(char *s);
    int yylex(void);

    void init_structs(void);
    void addProblem(char *name);
    void addVariable(char *name, int hilf);

    struct variable_node {
        char name[64];
        int pos;
        int hilfvariable;
        struct variable_node *next;
    };

    struct literal_node {
        char name[64];
        char expression[512];
        int type;
        struct literal_node *next;
        struct variable_node *first_var;
        struct variable_node *current_variable;
    };


    int lineno = 0;
    int sum = 0;

    struct literal_node *start_node;
    struct literal_node *current_node;
%}

%union {
    int int_val;
    char *string_val;
}

%start entry

%left PLUS MINUS MULTIPLY DIVIDE GTE LTE LT GT IS
%token <string_val> LABEL INT VAR
%type <string_val> entry function functionselect intodervar innerlist element listodervar list
%token OPA CPA COMMA IF EQ PIPE LF WWDDIWU OBR CBR DOT CD SEMICOLON slash

%%

list                : OBR innerlist CBR {$$ = ""}

innerlist           : element PIPE listodervar
                    | element

element             : listodervar
                    | listodervar COMMA endingelement
                    | {$$ = ""}// epsilon

endingelement       : listodervar
                    | listodervar COMMA endingelement

listodervar         : intodervar {addVariable($1,1);}
                    | list

intodervar          : INT {$$ = $1}
                    | VAR {$$ = $1}
                    | OPA INT CPA {$$ = $2}


entry               : functionselect DOT LF entry
                    | slash {$$= "";}// epsilon

functionselect      : function CD rulelist {$$ = $1;}
                    | function {$$ = $1;}

rulelist            : statement COMMA rulelist
                    | statement

statement           : {addProblem("math");} math
                    | function
                    | VAR {addProblem("math"); addVariable($1,1);} mathsym math
                    | VAR IS {addProblem("is"); addVariable($1,1);} statement

math                : math mathsym math
                    | intodervar {addVariable($1,1);}

mathsym             : GTE
                    | LTE
                    | LT
                    | GT
                    | PLUS
                    | MINUS
                    | MULTIPLY
                    | DIVIDE

function            : LABEL {addProblem($1);} OPA args CPA

args                : args COMMA args
                    | intodervar {addVariable($1, 1);}
                    | LABEL {printf("args: %s\n", $1)}
                    | list

%%

int yyerror(char *s) {
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c

  printf("Error: %s at symbol %s\n", s, yytext);
  exit(1);
}

int main() {

    init_structs();

    yyparse();
    return 0;
}

void init_structs() {
    start_node = (struct literal_node *)(malloc(sizeof(struct literal_node)));
    current_node = (struct literal_node *)(malloc(sizeof(struct literal_node)));
    current_node->type = -1;
}

void addProblem(char *name) {
    struct literal_node *temp_node = (struct literal_node *)(malloc(sizeof(struct literal_node)));

    // initialize node
    strncpy(temp_node->name, name, 64);

    temp_node->first_var = NULL;

    if(current_node->type == -1) {
        temp_node->type = PROBLEM;

        start_node = temp_node;
        start_node->next = NULL;

        current_node = start_node;
    } else {
        temp_node->type = SUBPROBLEM;

        current_node->next = temp_node;
        current_node = temp_node;
    }

    printf("New problem: %s\n",name);
}

void addVariable(char *name, int hilf) {
    struct variable_node *temp_node = (struct variable_node *)(malloc(sizeof(struct variable_node)));

    strncpy(temp_node->name, name, 64);
    temp_node->hilfvariable = hilf;

    printf("New variable: %s, Last Variable of Current Node: %s\n", temp_node->name, current_node->current_variable->name);

    if (current_node->first_var == NULL) {
        current_node->first_var = temp_node;
        current_node->current_variable = temp_node;
    } else {
        current_node->current_variable->next = temp_node;
        current_node->current_variable = temp_node;
    }
}
