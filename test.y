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
        char typ;
        int nr;
        struct output *right;
        struct output *left;

        char info[512];
    };

    struct print_node {
        struct entry *entry;
        struct print_node *next;
    };

    struct output {
        struct entry *entry;
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
    struct entry *newEntry(char);
    void attach(char*, struct entry*, struct entry*, int);
    void printTable();
    void itoa(int n, char s[]);
    void reverse(char s[]);

    int lineno = 0;
    int sum = 0;
    int g_index = 0;

    struct literal_node *start_node;
    struct literal_node *current_node;
    struct print_node *printList;
    struct print_node *startprintList;
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


entry               : functionselect DOT {createTable();} LF entry
                    | slash {$$= "";} // epsilon

functionselect      : function CD rulelist { $$ = $1;}
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
    printList = NULL;
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
    temp_node->next = NULL;

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

    if (mpImq != NULL) {
        struct variable_node *nhpImpImq = getIntersection(mpImq, nhp);

        if (nhpImpImq == NULL) {
            struct variable_node *mqUnhp = getUnion(mq, nhp);
            struct variable_node *mpUnhq = getUnion(mp, nhq);

            struct variable_node *mpRCmqUnhp = getRelativeComplement(mp, mqUnhp);
            struct variable_node *mqRCmpUnhq = getRelativeComplement(mq, mpUnhq);

            if (mpRCmqUnhp != NULL || mqRCmpUnhq != NULL) {
                return true;
            }
        }
    }

    return false;
}

int isIU(struct variable_node *mp, struct variable_node *mq, struct variable_node *nhp, struct variable_node *nhq) {
    struct variable_node *mpImq = getIntersection(mp, mq);

    if(mpImq == NULL) {
        struct variable_node *mqUnhp = getUnion(mq, nhp);
        struct variable_node *mpUnhq = getUnion(mp, nhq);

        struct variable_node *mpRCmqUnhp = getRelativeComplement(mp, mqUnhp);
        struct variable_node *mqRCmpUnhq = getRelativeComplement(mq, mpUnhq);

        if (mpRCmqUnhp != NULL && mqRCmpUnhq != NULL) {
            return true;
        }
    }

    return false;
}

int isGIU(struct variable_node *mp, struct variable_node *mq, struct variable_node *nhp, struct variable_node *nhq) {
    struct variable_node *mpImq = getIntersection(mp, mq);

    if(mpImq != NULL) {
        struct variable_node *mpImqInhp = getIntersection(mpImq, nhp);

        if(mpImqInhp == NULL) {
            struct variable_node *mqUnhp = getUnion(mq, nhp);
            struct variable_node *mpUnhq = getUnion(mp, nhq);

            struct variable_node *mpRCmqUnhp = getRelativeComplement(mp, mqUnhp);
            struct variable_node *mqRCmpUnhq = getRelativeComplement(mq, mpUnhq);

            if (mpRCmqUnhp == NULL && mqRCmpUnhq == NULL) {
                return true;
            }
        }
    }

    return false;
}

int isUU(struct variable_node *mp, struct variable_node *mq, struct variable_node *nhp, struct variable_node *nhq) {
    struct variable_node *mpImq = getIntersection(mp, mq);

    if(mpImq != NULL) {
        struct variable_node *mqUnhp = getUnion(mq, nhp);
        struct variable_node *mpUnhq = getUnion(mp, nhq);

        struct variable_node *mpRCmqUnhp = getRelativeComplement(mp, mqUnhp);
        struct variable_node *mqRCmpUnhq = getRelativeComplement(mq, mpUnhq);

        if (mpRCmqUnhp == NULL || mqRCmpUnhq == NULL) {
            return true;
        }
    }

    return false;
}

int getDependency(struct variable_node *l, struct variable_node *r, struct variable_node *help_l, struct variable_node *help_r) {
    if(isGU(l, r, help_l, help_r)){
        return GU;
    } else if (isUU(l, r, help_l, help_r)) {
        return UU;
    } else if (isGIU(l, r, help_l, help_r)) {
        return GIU;
    } else if (isIU(l, r, help_l, help_r)) {
        return IU;
    } else if (isUA(help_l, r)) {
        return UA;
    }

    return 0;
}

struct variable_node *getIntersection(struct variable_node *left, struct variable_node *right) {

    struct variable_node *_start_node = NULL;
    struct variable_node *_current_node = NULL;

    struct variable_node *tmp_right = right;
    while(left != NULL) {
        while(tmp_right != NULL) {
            if (strcmp(left->name, right->name) == 0) {
                _current_node = (struct variable_node *)(malloc(sizeof(struct variable_node)));

                if(_start_node == NULL) {
                    _start_node = _current_node;
                }
                strncpy(_current_node->name, left->name, 64);
                if (left->next != NULL && tmp_right->next != NULL) {
                    _current_node->next = (struct variable_node *)(malloc(sizeof(struct variable_node)));
                    _current_node = _current_node->next;
                }
            }
            tmp_right = tmp_right->next;
        }
        tmp_right = right;
        left = left->next;
    }

    return _start_node;

}

struct variable_node *getUnion(struct variable_node *left, struct variable_node *right) {
    struct variable_node *_start_node = NULL;
    struct variable_node *_current_node = NULL;

    while(left != NULL) {
        if (_current_node != NULL) {
            _current_node->next = (struct variable_node *)(malloc(sizeof(struct variable_node)));
            _current_node = _current_node->next;
        } else {
            _current_node = (struct variable_node *)(malloc(sizeof(struct variable_node)));
            _start_node = _current_node;
        }

        strncpy(_current_node->name, left->name, 64);
        _current_node->next = NULL;

        left = left->next;
    }

    while(right != NULL) {
        if (_current_node != NULL) {
            _current_node->next = (struct variable_node *)(malloc(sizeof(struct variable_node)));
            _current_node = _current_node->next;
        } else {
            _current_node = (struct variable_node *)(malloc(sizeof(struct variable_node)));
            _start_node = _current_node;
        }

        strncpy(_current_node->name, right->name, 64);
        _current_node->next = NULL;

        right = right->next;
    }

    _current_node = _start_node;

    while(_current_node != NULL) {
        struct variable_node *tmp_node = _current_node->next;
        struct variable_node *last_tmp_node = _current_node;

        while(tmp_node != NULL) {
            if(strcmp(_current_node->name, tmp_node->name) == 0){
                last_tmp_node->next = tmp_node->next;
            }
            last_tmp_node = tmp_node;
            tmp_node = tmp_node->next;
        }

        _current_node = _current_node->next;
    }

    return _start_node;
}

struct variable_node *getRelativeComplement(struct variable_node *in, struct variable_node *of) {
    struct variable_node *_start_node = (struct variable_node *)(malloc(sizeof(struct variable_node)));
    struct variable_node *_current_node = _start_node;
    struct variable_node *of_start_node = of;

    while(in != NULL) {
        while(of != NULL) {
            if(strcmp(in->name, of->name) != 0) {
                strncpy(_current_node->name, in->name, 64);
                _current_node->next = (struct variable_node *)(malloc(sizeof(struct variable_node)));
                _current_node = _current_node->next;
            }
            of = of->next;
        }
        of = of_start_node;
        in = in->next;
    }

    return _start_node;
}

struct variable_node *getHelpers(struct literal_node *start_literal, struct literal_node *current_literal) {
    struct variable_node *_start_node = (struct variable_node *)(malloc(sizeof(struct variable_node)));
    struct variable_node *_current_node = _start_node;

    struct variable_node *literal_tmp_node = (struct variable_node *)(malloc(sizeof(struct variable_node)));
    literal_tmp_node = current_literal->first_var;

    while(literal_tmp_node != NULL) {
        strncpy(_current_node->name, literal_tmp_node->name, 64);
        if(literal_tmp_node->next != NULL) {
            _current_node->next = (struct variable_node *)(malloc(sizeof(struct variable_node)));
            _current_node = _current_node->next;
        } else {
            _current_node->next = NULL;
        }
        literal_tmp_node = literal_tmp_node->next;
    }

    _current_node = _start_node;

    while(start_literal != current_literal) {
        struct variable_node *current_var_node = (struct variable_node *)(malloc(sizeof(struct variable_node)));
        current_var_node = start_literal->first_var;

        while(current_var_node != NULL) {
            struct variable_node *previous = NULL;

            while(_current_node != NULL) {
                if(strcmp(current_var_node->name, _current_node->name) == 0) {
                    if(previous != NULL) {
                        previous->next = _current_node->next;
                        _current_node = previous;
                    } else {
                        _start_node = _current_node->next;
                        _current_node = _start_node;
                    }
                }
                previous = _current_node;
                if(_current_node != NULL) {
                    _current_node = _current_node->next;
                }
            }
            _current_node = _start_node;
            current_var_node = current_var_node->next;
        }

        start_literal = start_literal->next;
    }

    return _start_node;
}

struct entry *newEntry(char typ) {
    struct entry *_entry = (struct entry *)(malloc(sizeof(struct entry)));
    _entry->typ = typ;
    _entry->nr = ++g_index;
    _entry->left = NULL;
    _entry->right = NULL;

    if (printList == NULL) {
        printList = (struct print_node*)(malloc(sizeof(struct print_node)));
        printList->entry = _entry;
        startprintList = printList;
    } else {
        printList->next = (struct print_node*)(malloc(sizeof(struct print_node)));
        printList = printList->next;
        printList->entry = _entry;
    }

    return _entry;
}

void attach(char *side, struct entry *entryNode, struct entry *attacher, int port) {
    if (strcmp(side, "right") == 0) {
        entryNode->right = (struct output *)(malloc(sizeof(struct output)));
        entryNode->right->entry = attacher;
        entryNode->right->port = port;
    } else if (strcmp(side, "left") == 0) {
        entryNode->left = (struct output *)(malloc(sizeof(struct output)));
        entryNode->left->entry = attacher;
        entryNode->left->port = port;
    }
}

void createTable() {

    printf("CreateTable();\n");
    struct literal_node *current_literal = start_node->next;

    // Create E node
    struct entry *eNode = newEntry('E');

    struct entry *cNode = newEntry('C');
    attach("left", eNode, cNode, 1);

    int index = 0;
    struct literal_node *prev_literal = NULL;
    struct entry *prev_e = eNode;

    while(current_literal != NULL) {
        struct entry *uNode = newEntry('U');
        struct entry *last_e;

        // TODO: uNode->info
        if (index == 0) {
            attach("right", cNode, uNode, 1);

            struct entry *aNode = newEntry('A');
            attach("right", uNode, aNode, 1);

            struct entry *ccNode = newEntry('C');
            attach("right", aNode, ccNode, 1);

            last_e = ccNode;

        } else {
            attach("left", cNode, uNode, 1);

            struct variable_node *help_l = getHelpers(start_node, prev_literal);
            struct variable_node *help_r = getHelpers(start_node, current_literal);

            int dep = getDependency(prev_literal->first_var, current_literal->first_var, help_l, help_r);

            switch(dep) {
                case UA:
                    break;
                case GU:
                    1+2;
                    struct entry *tmp_node_u = newEntry('U');
                    struct entry *tmp_node_g = newEntry('G');

                    attach("right", tmp_node_g, tmp_node_u, 2);
                    attach("right", uNode, tmp_node_g, 1);
                    attach("left", last_e, tmp_node_u, 1);

                    struct entry *tmp_node_a = newEntry('A');

                    attach("right", tmp_node_u, tmp_node_a, 1);
                    attach("left", tmp_node_g, tmp_node_a, 1);

                    last_e = tmp_node_a;

                    printf("isGU\n");
                    break;
                case IU:
                    break;
                case GIU:
                    break;
                case UU:
                    break;
                default:
                    break;
            }
        }

        struct entry *connectionNode = newEntry('U');

        attach("right", prev_e, connectionNode, 2);
        attach("right", last_e, connectionNode, 1);

        prev_e = connectionNode;

        prev_literal = current_literal;
        current_literal = current_literal->next;

        index++;
    }

    struct entry *rNode = newEntry('R');
    attach("right", prev_e, rNode, 1);

    printTable();

}

void printTable() {
    printf("<Nr>\t<Typ>\t(<RNr> <RPort>)\t(<LNr> <LPort>)\tInfo\n");
    printList = startprintList;
    while(printList != NULL) {
        struct entry *start = printList->entry;
        struct output *right = start->right ? start->right : (struct output *)(malloc(sizeof(struct output)));
        struct output *left = start->left ? start->left : (struct output *)(malloc(sizeof(struct output)));

        int nr = start->nr;
        char typ = start->typ;

        char *rnr = (char*)malloc(16*sizeof(char));
        char *lnr = (char*)malloc(16*sizeof(char));
        char *rport = (char*)malloc(16*sizeof(char));
        char *lport = (char*)malloc(16*sizeof(char));

        right->entry ? itoa(right->entry->nr, rnr) : strcpy(rnr, " ");
        left->entry ? itoa(left->entry->nr, lnr) : strcpy(lnr, " ");

        right->entry ? itoa(right->port, rport) : strcpy(rport, " ");
        left->entry ? itoa(left->port, lport) : strcpy(lport, " ");

        char info[512] = "tbd.";

        printf("%d\t%c\t(%s, %s)\t\t(%s, %s)\t\t%s\n", nr, typ, rnr, rport, lnr, lport, info);

        printList = printList->next;
    }
}

void itoa(int n, char s[])
{
    int i, sign;

    if ((sign = n) < 0)  /* record sign */
        n = -n;          /* make n positive */
    i = 0;
    do {       /* generate digits in reverse order */
        s[i++] = n % 10 + '0';   /* get next digit */
    } while ((n /= 10) > 0);     /* delete it */
    if (sign < 0)
        s[i++] = '-';
    s[i] = '\0';
    reverse(s);
}

void reverse(char s[])
{
    int i, j;
    char c;

    for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
        c = s[i];
        s[i] = s[j];
        s[j] = c;
    }
}
