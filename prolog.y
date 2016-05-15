%{
    #include "main.h"

    int lineno = 0;
    int sum = 0;
    int g_index = 0;

    literal_node *start_node;
    literal_node *current_node;

    print_node *printList;
    print_node *startprintList;
    print_node *prevprintList;
%}

%union {
    int int_val;
    char *string_val;
}

%expect 12

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
    start_node = (literal_node *)(malloc(sizeof(literal_node)));
    current_node = (literal_node *)(malloc(sizeof(literal_node)));
    current_node->type = -1;
}

void addProblem(char *name) {
    literal_node *temp_node = (literal_node *)(malloc(sizeof(literal_node)));

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
    variable_node *temp_node = (variable_node *)(malloc(sizeof(variable_node)));
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


int isUA(variable_node *nhp, variable_node *mq) {
    return (strcmp(getIntersection(nhp, mq)->name, "") == 1);
}

int isGU(variable_node *mp, variable_node *mq, variable_node *nhp, variable_node *nhq) {
    variable_node *mpImq = getIntersection(mp, mq);

    if (mpImq != NULL) {
        variable_node *nhpImpImq = getIntersection(mpImq, nhp);

        if (nhpImpImq == NULL) {
            variable_node *mqUnhp = getUnion(mq, nhp);
            variable_node *mpUnhq = getUnion(mp, nhq);

            variable_node *mpRCmqUnhp = getRelativeComplement(mp, mqUnhp);
            variable_node *mqRCmpUnhq = getRelativeComplement(mq, mpUnhq);

            if (mpRCmqUnhp != NULL || mqRCmpUnhq != NULL) {
                return true;
            }
        }
    }

    return false;
}

int isIU(variable_node *mp, variable_node *mq, variable_node *nhp, variable_node *nhq) {
    variable_node *mpImq = getIntersection(mp, mq);

    if(mpImq == NULL) {
        variable_node *mqUnhp = getUnion(mq, nhp);
        variable_node *mpUnhq = getUnion(mp, nhq);

        variable_node *mpRCmqUnhp = getRelativeComplement(mp, mqUnhp);
        variable_node *mqRCmpUnhq = getRelativeComplement(mq, mpUnhq);

        if (mpRCmqUnhp != NULL && mqRCmpUnhq != NULL) {
            return true;
        }
    }

    return false;
}

int isGIU(variable_node *mp, variable_node *mq, variable_node *nhp, variable_node *nhq) {
    variable_node *mpImq = getIntersection(mp, mq);

    if(mpImq != NULL) {
        variable_node *mpImqInhp = getIntersection(mpImq, nhp);

        if(mpImqInhp == NULL) {
            variable_node *mqUnhp = getUnion(mq, nhp);
            variable_node *mpUnhq = getUnion(mp, nhq);

            variable_node *mpRCmqUnhp = getRelativeComplement(mp, mqUnhp);
            variable_node *mqRCmpUnhq = getRelativeComplement(mq, mpUnhq);

            if (mpRCmqUnhp == NULL && mqRCmpUnhq == NULL) {
                return true;
            }
        }
    }

    return false;
}

int isUU(variable_node *mp, variable_node *mq, variable_node *nhp, variable_node *nhq) {
    variable_node *mpImq = getIntersection(mp, mq);

    if(mpImq != NULL) {
        variable_node *mqUnhp = getUnion(mq, nhp);
        variable_node *mpUnhq = getUnion(mp, nhq);

        variable_node *mpRCmqUnhp = getRelativeComplement(mp, mqUnhp);
        variable_node *mqRCmpUnhq = getRelativeComplement(mq, mpUnhq);

        if (mpRCmqUnhp == NULL || mqRCmpUnhq == NULL) {
            return true;
        }
    }

    return false;
}

int getDependency(variable_node *l, variable_node *r, variable_node *help_l, variable_node *help_r) {
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

variable_node *getIntersection(variable_node *left, variable_node *right) {

    variable_node *_start_node = NULL;
    variable_node *_current_node = NULL;

    variable_node *tmp_right = right;
    while(left != NULL) {
        while(tmp_right != NULL) {
            if (strcmp(left->name, right->name) == 0) {
                _current_node = (variable_node *)(malloc(sizeof(variable_node)));

                if(_start_node == NULL) {
                    _start_node = _current_node;
                }
                strncpy(_current_node->name, left->name, 64);
                if (left->next != NULL && tmp_right->next != NULL) {
                    _current_node->next = (variable_node *)(malloc(sizeof(variable_node)));
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

variable_node *getUnion(variable_node *left, variable_node *right) {
    variable_node *_start_node = NULL;
    variable_node *_current_node = NULL;

    while(left != NULL) {
        if (_current_node != NULL) {
            _current_node->next = (variable_node *)(malloc(sizeof(variable_node)));
            _current_node = _current_node->next;
        } else {
            _current_node = (variable_node *)(malloc(sizeof(variable_node)));
            _start_node = _current_node;
        }

        strncpy(_current_node->name, left->name, 64);
        _current_node->next = NULL;

        left = left->next;
    }

    while(right != NULL) {
        if (_current_node != NULL) {
            _current_node->next = (variable_node *)(malloc(sizeof(variable_node)));
            _current_node = _current_node->next;
        } else {
            _current_node = (variable_node *)(malloc(sizeof(variable_node)));
            _start_node = _current_node;
        }

        strncpy(_current_node->name, right->name, 64);
        _current_node->next = NULL;

        right = right->next;
    }

    _current_node = _start_node;

    while(_current_node != NULL) {
        variable_node *tmp_node = _current_node->next;
        variable_node *last_tmp_node = _current_node;

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

variable_node *getRelativeComplement(variable_node *in, variable_node *of) {
    variable_node *_start_node = (variable_node *)(malloc(sizeof(variable_node)));
    variable_node *_current_node = _start_node;
    variable_node *of_start_node = of;

    while(in != NULL) {
        while(of != NULL) {
            if(strcmp(in->name, of->name) != 0) {
                strncpy(_current_node->name, in->name, 64);
                _current_node->next = (variable_node *)(malloc(sizeof(variable_node)));
                _current_node = _current_node->next;
            }
            of = of->next;
        }
        of = of_start_node;
        in = in->next;
    }

    return _start_node;
}

variable_node *getHelpers(literal_node *start_literal, literal_node *current_literal) {
    variable_node *_start_node = (variable_node *)(malloc(sizeof(variable_node)));
    variable_node *_current_node = _start_node;

    variable_node *literal_tmp_node = (variable_node *)(malloc(sizeof(variable_node)));
    literal_tmp_node = current_literal->first_var;

    while(literal_tmp_node != NULL) {
        strncpy(_current_node->name, literal_tmp_node->name, 64);
        if(literal_tmp_node->next != NULL) {
            _current_node->next = (variable_node *)(malloc(sizeof(variable_node)));
            _current_node = _current_node->next;
        } else {
            _current_node->next = NULL;
        }
        literal_tmp_node = literal_tmp_node->next;
    }

    _current_node = _start_node;

    while(start_literal != current_literal) {
        variable_node *current_var_node = (variable_node *)(malloc(sizeof(variable_node)));
        current_var_node = start_literal->first_var;

        while(current_var_node != NULL) {
            variable_node *previous = NULL;

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

entry *newEntry(char typ) {
    entry *_entry = (entry *)(malloc(sizeof(entry)));
    _entry->typ = typ;
    _entry->nr = ++g_index;
    _entry->left = NULL;
    _entry->right = NULL;

    if (printList == NULL) {
        printList = (print_node*)(malloc(sizeof(print_node)));
        printList->entry = _entry;
        startprintList = printList;
        prevprintList = NULL;
    } else {
        prevprintList = printList;
        printList->next = (print_node*)(malloc(sizeof(print_node)));
        printList = printList->next;
        printList->entry = _entry;
    }

    return _entry;
}

void attach(char *side, entry *entryNode, entry *attacher, int port) {
    if (strcmp(side, "right") == 0) {
        entryNode->right = (output *)(malloc(sizeof(output)));
        entryNode->right->entry = attacher;
        entryNode->right->port = port;
    } else if (strcmp(side, "left") == 0) {
        entryNode->left = (output *)(malloc(sizeof(output)));
        entryNode->left->entry = attacher;
        entryNode->left->port = port;
    }
}

void createTable() {

    printf("CreateTable();\n");
    literal_node *current_literal = start_node->next;

    // Create E node
    entry *eNode = newEntry('E');

    //entry *cNode = newEntry('C');
    //attach("right", eNode, cNode, 1);

    int index = 0;
    literal_node *prev_literal = NULL;
    entry *prev_e = eNode;
    entry *cNode = NULL;

    while(current_literal != NULL) {
        entry *uNode = newEntry('U');
        entry *prev_a;

        // TODO: uNode->info
        if (index == 0) {
            attach("right", eNode, uNode, 1);

            entry *aNode = newEntry('A');
            attach("left", uNode, aNode, 1);

            prev_a = aNode;

        } else {
            if (index == 1) {
                cNode = newEntry('C');
                reIndex(1);
            }

            //attach("right", cNode, uNode, 1);

            variable_node *help_l = getHelpers(start_node, prev_literal);
            variable_node *help_r = getHelpers(start_node, current_literal);

            int dep = getDependency(prev_literal->first_var, current_literal->first_var, help_l, help_r);

            switch(dep) {
                case UA:
                    break;
                case GU:
                    (void)0;
                    entry *tmp_node_u = newEntry('U');
                    entry *tmp_node_g = newEntry('G');

                    attach("left", tmp_node_g, tmp_node_u, 2);
                    attach("left", uNode, tmp_node_g, 1);
                    attach("right", prev_a, tmp_node_u, 1);

                    entry *tmp_node_a = newEntry('A');

                    attach("left", tmp_node_u, tmp_node_a, 1);
                    attach("right", tmp_node_g, tmp_node_a, 1);

                    prev_a = tmp_node_a;

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

        entry *connectionNode = newEntry('U');

        attach("left", prev_e, connectionNode, 2);
        attach("left", prev_a, connectionNode, 1);

        prev_e = connectionNode;

        prev_literal = current_literal;
        current_literal = current_literal->next;

        index++;
    }

    entry *rNode = newEntry('R');
    attach("left", prev_e, rNode, 1);

    printTable();

}

void printTable() {
    printf("<Nr>\t<Typ>\t(<LNr> <LPort>)\t(<RNr> <RPort>)\tInfo\n");
    printList = startprintList;
    while(printList != NULL) {
        entry *start = printList->entry;
        output *right = start->right ? start->right : (output *)(malloc(sizeof(output)));
        output *left = start->left ? start->left : (output *)(malloc(sizeof(output)));

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

        printf("%d\t%c\t(%s, %s)\t\t(%s, %s)\t\t%s\n", nr, typ, lnr, lport, rnr, rport, info);

        printList = printList->next;
    }
}

void reIndex(int prev_index) {
    print_node *tempList = startprintList;

    while(tempList->entry->nr != prev_index) {
        tempList = tempList->next;
    }

    print_node *tmpNext = tempList->next;

    printList->entry->nr = prev_index + 1;
    printf("print list entry: %c, %d\n", printList->entry->typ, printList->entry->nr);
    printf("tempList->entry: %c, %d\n", tempList->entry->typ, tempList->entry->nr);
    printf("tempList->entry->left->entry: %c, %d\n", tempList->entry->left->entry->typ, tempList->entry->left->entry->nr);
    printf("tempList->entry->right->entry: %c, %d\n", tempList->entry->right->entry->typ, tempList->entry->right->entry->nr);
    attach("right", printList->entry, tempList->entry->right->entry, 1);
    attach("right", tempList->entry, printList->entry, 1);


    tempList->next = printList;

    printList->next = tmpNext;

    printList = prevprintList;
    prevprintList->next = NULL;

    tempList = tmpNext;

    while(tempList != NULL){
        tempList->entry->nr += 1;
        tempList = tempList->next;
    }

    //printTable();
    //printf("\n\n\n");
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
