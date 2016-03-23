/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     LABEL = 258,
     INT = 259,
     VAR = 260,
     FLOAT = 261,
     OBR = 262,
     CBR = 263,
     IS = 264,
     DOT = 265,
     CD = 266,
     SEMICOLON = 267,
     OPA = 268,
     CPA = 269,
     COMMA = 270,
     GTE = 271,
     LTE = 272,
     IF = 273,
     LT = 274,
     GT = 275,
     EQ = 276,
     PIPE = 277,
     PLUS = 278,
     MINUS = 279,
     MULTIPLY = 280,
     DIVIDE = 281,
     LF = 282,
     WWDDIWU = 283
   };
#endif
/* Tokens.  */
#define LABEL 258
#define INT 259
#define VAR 260
#define FLOAT 261
#define OBR 262
#define CBR 263
#define IS 264
#define DOT 265
#define CD 266
#define SEMICOLON 267
#define OPA 268
#define CPA 269
#define COMMA 270
#define GTE 271
#define LTE 272
#define IF 273
#define LT 274
#define GT 275
#define EQ 276
#define PIPE 277
#define PLUS 278
#define MINUS 279
#define MULTIPLY 280
#define DIVIDE 281
#define LF 282
#define WWDDIWU 283




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 13 "test.y"
{
    int int_val;
    char *string_val;
}
/* Line 1529 of yacc.c.  */
#line 110 "test.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

