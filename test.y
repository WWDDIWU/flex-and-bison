%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int yyerror(char *s);
    int yylex(void);

    int lineno = 0;
    int sum = 0;
%}

%union {
    int int_val;
    char *string_val;
}

%start line

%token <string_val> LABEL
%token <int_val> INT
%type <string_val> hornclause
%type <string_val> args
%token VAR
%token FLOAT
%token OBR
%token CBR
%token IS
%token DOT
%token CD
%token SEMICOLON
%token OPA
%token CPA
%token COMMA
%token GTE
%token LTE
%token IF
%token LT
%token GT
%token EQ
%token PIPE
%token PLUS
%token MINUS
%token MULTIPLY
%token DIVIDE
%token LF
%token WWDDIWU

%%

line: LF | hornclause LF line {printf("%s", $1);};

hornclause: LABEL OPA args CPA DOT {printf("%s", $3);};

args: LABEL {$$ = $1}
    | INT {$$ = $1}
    | FLOAT {$$ = $1}
    | args COMMA args {$$ = $1}

%%

int yyerror(char *s)
{
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c

  printf("Error: %s at symbol %s\n", s, yytext);
  exit(1);
}

int main() {
    yyparse();
    return 0;
}
