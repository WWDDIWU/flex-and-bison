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

%start entry

%left PLUS MINUS MULTIPLY DIVIDE GTE LTE LT GT
%token <int_val> INT
%token <string_val> LABEL
%token OPA CPA COMMA IF EQ PIPE LF WWDDIWU VAR OBR CBR IS DOT CD SEMICOLON

%%

entry: function CD rulelist
    | rule

rulelist: function COMMA rulelist
        | math COMMA rulelist
        | function DOT LF
        | math DOT LF

math: math mathsym math
    | VAR
    | INT

isStatement: VAR IS math

mathsym: GTE | LTE | LT | GT | PLUS | MINUS | MULTIPLY | DIVIDE

rule: function DOT LF

function: LABEL OPA args CPA

list: OBR ls CBR

ls: le | le COMMA le

le: VAR | list |

args: args COMMA args
    | VAR
    | INT
    | LABEL
    | list

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
