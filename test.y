%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <stdbool.h>

    #define PROBLEM 0
    #define SUBPROBLEM 1

    #define UA 0
    #define GU 1
    #define IU 2
    #define GIU 3
    #define UU 4

    struct variable_node {
        char name[64];
        struct variable_node *next;
    };

    struct literal_node {
        char name[64];
        char info[512];
        int type;
        struct literal_node *next;
        struct variable_node *first_var;
        struct variable_node *current_variable;
    };

    struct entry {
        int nr;
        char typ;

        struct output *r;
        struct output *l;

        char info[512];
    };

    struct output {
        struct entry *nr;
        int port;
    };

    int yyerror(char *s);
    int yylex(void);

    void init_structs(void);
    void addProblem(char *name);
    void addVariable(char *name);
    void createTable();
    int isUA(struct variable_node *, struct variable_node *);
    int isGU(struct variable_node *, struct variable_node *, struct variable_node *, struct variable_node *);
    int isIU(struct variable_node *, struct variable_node *, struct variable_node *, struct variable_node *);
    int isGIU(struct variable_node *, struct variable_node *, struct variable_node *, struct variable_node *);
    int isUU(struct variable_node *, struct variable_node *, struct variable_node *, struct variable_node *);
    struct variable_node *getIntersection(struct variable_node *, struct variable_node *);
    struct variable_node *getUnion(struct variable_node *, struct variable_node *);
    struct variable_node *getRelativeComplement(struct variable_node *, struct variable_node *);

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

listodervar         : intodervar {addVariable($1);}
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
                    | VAR {addProblem("math"); addVariable($1);} mathsym math
                    | VAR IS {addProblem("is"); addVariable($1);} statement

math                : math mathsym math
                    | intodervar {addVariable($1);}

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
                    | intodervar {addVariable($1);}
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

void addVariable(char *name) {
    struct variable_node *temp_node = (struct variable_node *)(malloc(sizeof(struct variable_node)));

    strncpy(temp_node->name, name, 64);

    printf("New variable: %s, Last Variable of Current Node: %s\n", temp_node->name, current_node->current_variable->name);

    if (current_node->first_var == NULL) {
        current_node->first_var = temp_node;
        current_node->current_variable = temp_node;
    } else {
        current_node->current_variable->next = temp_node;
        current_node->current_variable = temp_node;
    }
}

void setInfo(char *info) {
    strncpy(current_node->info, info, 512);
}


int isUA(struct variable_node *nhp, struct variable_node *mq) {
    return (strcmp(getIntersection(nhp, mq)->name, "") == 1);
}

int isGU(struct variable_node *mp, struct variable_node *mq, struct variable_node *nhp, struct variable_node *nhq) {
    struct variable_node *mpImq = getIntersection(mp, mq);
    if (strncmp(mpImq->name, "", 1) == 0) {
        struct variable_node *nhpImpImq = getIntersection(mpImq, nhp);

        if (strncmp(nhpImpImq->name, "", 1) == 0) {
            struct variable_node *mqUnhp = getUnion(mq, nhp);
            struct variable_node *mpUnhq = getUnion(mp, nhq);

            struct variable_node *mpRCmqUnhp = getRelativeComplement(mp, mqUnhp);
            struct variable_node *mqRCmpUnhq = getRelativeComplement(mq, mpUnhq);

            if (strncmp(mpRCmqUnhp->name, "", 1) != 0 || strncmp(mqRCmpUnhq->name, "", 1) != 0) {
                return true;
            }
        }
    }

    return false;
}

int isIU(struct variable_node *mp, struct variable_node *mq, struct variable_node *nhp, struct variable_node *nhq) {
    struct variable_node *mpImq = getIntersection(mp, mq);

    if(strncmp(mpImq->name, "", 1) == 0) {
        struct variable_node *mqUnhp = getUnion(mq, nhp);
        struct variable_node *mpUnhq = getUnion(mp, nhq);

        struct variable_node *mpRCmqUnhp = getRelativeComplement(mp, mqUnhp);
        struct variable_node *mqRCmpUnhq = getRelativeComplement(mq, mpUnhq);

        if (strncmp(mpRCmqUnhp->name, "", 1) != 0 && strncmp(mqRCmpUnhq->name, "", 1) != 0) {
            return true;
        }
    }

    return false;
}

int isGIU(struct variable_node *mp, struct variable_node *mq, struct variable_node *nhp, struct variable_node *nhq) {
    struct variable_node *mpImq = getIntersection(mp, mq);

    if(strncmp(mpImq->name, "", 1) != 0) {
        struct variable_node *mpImqInhp = getIntersection(mpImq, nhp);

        if(strncmp(mpImqInhp->name, "", 1) == 0) {
            struct variable_node *mqUnhp = getUnion(mq, nhp);
            struct variable_node *mpUnhq = getUnion(mp, nhq);

            struct variable_node *mpRCmqUnhp = getRelativeComplement(mp, mqUnhp);
            struct variable_node *mqRCmpUnhq = getRelativeComplement(mq, mpUnhq);

            if (strncmp(mpRCmqUnhp->name, "", 1) == 0 && strncmp(mqRCmpUnhq->name, "", 1) == 0) {
                return true;
            }
        }
    }

    return false;
}

int isUU(struct variable_node *mp, struct variable_node *mq, struct variable_node *nhp, struct variable_node *nhq) {
    struct variable_node *mpImq = getIntersection(mp, mq);

    if(strncmp(mpImq->name, "", 1) != 0) {
        struct variable_node *mqUnhp = getUnion(mq, nhp);
        struct variable_node *mpUnhq = getUnion(mp, nhq);

        struct variable_node *mpRCmqUnhp = getRelativeComplement(mp, mqUnhp);
        struct variable_node *mqRCmpUnhq = getRelativeComplement(mq, mpUnhq);

        if (strncmp(mpRCmqUnhp->name, "", 1) == 0 || strncmp(mqRCmpUnhq->name, "", 1) == 0) {
            return true;
        }
    }

    return false;
}

struct variable_node *getRelativeComplement(struct variable_node *left, struct variable_node *right) {
    return left;
}

struct variable_node *getIntersection(struct variable_node *left, struct variable_node *right) {

    struct variable_node *start_node = (struct variable_node *)(malloc(sizeof(struct variable_node)));
    struct variable_node *current_node = start_node;
    strncpy(start_node->name, "", 1);

    while(left != NULL) {
        while(right != NULL) {
            if (strcmp(left->name, right->name) == 0) {
                strncpy(current_node->name, left->name, 64);
                current_node->next = (struct variable_node *)(malloc(sizeof(struct variable_node)));
                current_node = current_node->next;
            }
            right = right->next;
        }
        left = left->next;
    }

    return start_node;

}

struct variable_node *getUnion(struct variable_node *left, struct variable_node *right) {
    struct variable_node *start_node = (struct variable_node *)(malloc(sizeof(struct variable_node)));
    struct variable_node *current_node = start_node;

    while(left != NULL) {
        strncpy(current_node->name, left->name, 64);
        current_node->next = (struct variable_node *)(malloc(sizeof(struct variable_node)));
        current_node = current_node->next;

        left = left->next;
    }

    while(right != NULL) {
        strncpy(current_node->name, left->name, 64);
        current_node->next = (struct variable_node *)(malloc(sizeof(struct variable_node)));
        current_node = current_node->next;

        left = left->next;
    }

    current_node = start_node;

    while(current_node != NULL) {
        struct variable_node *tmp_node = current_node->next;
        struct variable_node *last_tmp_node = current_node;

        while(tmp_node != NULL) {
            if(strcmp(current_node->name, tmp_node->name) == 0){
                last_tmp_node->next = tmp_node->next;
            }
            last_tmp_node = tmp_node;
            tmp_node = tmp_node->next;
        }
    }

    return start_node;
}



void createTable() {
    // Create E node
    
}
