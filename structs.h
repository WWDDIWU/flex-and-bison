#define PROBLEM 0
#define SUBPROBLEM 1

#define UA 0
#define GU 1
#define IU 2
#define GIU 3
#define UU 4

struct variable_node{
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

struct entry{
    char typ;
    int nr;
    struct output *right;
    struct output *left;

    char info[512];
};

struct print_node{
    struct entry *entry;
    struct print_node *next;
};

struct output{
    struct output *next;
    struct entry *entry;
    int port;
};

typedef struct variable_node variable_node;
typedef struct literal_node literal_node ;
typedef struct entry entry;
typedef struct print_node print_node;
typedef struct output output;
