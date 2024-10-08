%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "calc3.h"
/* prototypes */
nodeType *opr(int oper, int nops, ...);
nodeType *id(int i);
nodeType *con(int value);
void freeNode(nodeType *p);
int ex(nodeType *p);
int yylex(void);
void yyerror(char *s);
int sym[52]; /* symbol table */
%}

%union {
    int iValue; /* integer value */
    char sIndex; /* symbol table index */
    nodeType *nPtr; /* node pointer */
     double dValue;
}

%token <iValue> INTEGER
%token <dValue> FLOAT
%token <sIndex> VARIABLE
%token WHILE IF WRITE FOR
%token INC DEC
%token LSHIFT RSHIFT
%token AND OR
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN AND_ASSIGN OR_ASSIGN XOR_ASSIGN LSHIFT_ASSIGN RSHIFT_ASSIGN
%nonassoc IFX
%nonassoc ELSE
%left GE LE EQ NE '>' '<'
%left '+' '-'
%left '*' '/'
%left '&' '|' '^'
%left LSHIFT RSHIFT
%left AND OR
%nonassoc UMINUS
%type <nPtr> stmt expr stmt_list expr_opt

%%
program:
    function { exit(0); }
;

function:
    function stmt { ex($2); freeNode($2); }
    | /* NULL */
;

stmt:
    ';' { $$ = opr(';', 2, NULL, NULL); }
    | expr ';' { $$ = $1; }
    | WRITE expr ';' { $$ = opr(WRITE, 1, $2); }
    | VARIABLE '=' expr ';' { $$ = opr('=', 2, id($1), $3); }
    | VARIABLE ADD_ASSIGN expr ';' { $$ = opr(ADD_ASSIGN, 2, id($1), $3); }
    | VARIABLE SUB_ASSIGN expr ';' { $$ = opr(SUB_ASSIGN, 2, id($1), $3); }
    | VARIABLE MUL_ASSIGN expr ';' { $$ = opr(MUL_ASSIGN, 2, id($1), $3); }
    | VARIABLE DIV_ASSIGN expr ';' { $$ = opr(DIV_ASSIGN, 2, id($1), $3); }
    | VARIABLE MOD_ASSIGN expr ';' { $$ = opr(MOD_ASSIGN, 2, id($1), $3); }
    | VARIABLE AND_ASSIGN expr ';' { $$ = opr(AND_ASSIGN, 2, id($1), $3); }
    | VARIABLE OR_ASSIGN expr ';' { $$ = opr(OR_ASSIGN, 2, id($1), $3); }
    | VARIABLE XOR_ASSIGN expr ';' { $$ = opr(XOR_ASSIGN, 2, id($1), $3); }
    | VARIABLE LSHIFT_ASSIGN expr ';' { $$ = opr(LSHIFT_ASSIGN, 2, id($1), $3); }
    | VARIABLE RSHIFT_ASSIGN expr ';' { $$ = opr(RSHIFT_ASSIGN, 2, id($1), $3); }
    | WHILE '(' expr ')' stmt { $$ = opr(WHILE, 2, $3, $5); }
    | IF '(' expr ')' stmt %prec IFX { $$ = opr(IF, 2, $3, $5); }
    | IF '(' expr ')' stmt ELSE stmt { $$ = opr(IF, 3, $3, $5, $7); }
    | FOR '(' stmt expr_opt ';' expr_opt ')' stmt { $$ = opr(FOR, 4, $3, $4, $6, $8); }
    | '{' stmt_list '}' { $$ = $2; }
;

stmt_list:
    stmt { $$ = $1; }
    | stmt_list stmt { $$ = opr(';', 2, $1, $2); }
;

expr_opt:
    /* empty */ { $$ = NULL; }
    | expr { $$ = $1; }
;

expr: 
    INTEGER { $$ = con($1); }
    | VARIABLE { $$ = id($1); }
    | '-' expr %prec UMINUS { $$ = opr(UMINUS, 1, $2); }
    | expr '+' expr { $$ = opr('+', 2, $1, $3); }
    | INC expr { $$ = opr(INC, 1, $2); } // Prefix increment
    | DEC expr { $$ = opr(DEC, 1, $2); } // Prefix decrement
    | expr INC { $$ = opr(INC, 1, $1); } // Postfix increment
    | expr DEC { $$ = opr(DEC, 1, $1); } // Postfix decrement
    | expr '-' expr { $$ = opr('-', 2, $1, $3); }
    | expr '*' expr { $$ = opr('*', 2, $1, $3); }
    | expr '/' expr { $$ = opr('/', 2, $1, $3); }
    | expr '%' expr { $$ = opr('%', 2, $1, $3); }
    | expr '<' expr { $$ = opr('<', 2, $1, $3); }
    | expr '>' expr { $$ = opr('>', 2, $1, $3); }
    | expr '&' expr { $$ = opr('&', 2, $1, $3); }
    | expr '|' expr { $$ = opr('|', 2, $1, $3); }
    | expr '^' expr { $$ = opr('^', 2, $1, $3); }
    | expr LSHIFT expr { $$ = opr(LSHIFT, 2, $1, $3); }
    | expr RSHIFT expr { $$ = opr(RSHIFT, 2, $1, $3); }
    | expr AND expr { $$ = opr(AND, 2, $1, $3); }
    | expr OR expr { $$ = opr(OR, 2, $1, $3); }
    | expr GE expr { $$ = opr(GE, 2, $1, $3); }
    | expr LE expr { $$ = opr(LE, 2, $1, $3); }
    | expr NE expr { $$ = opr(NE, 2, $1, $3); }
    | expr EQ expr { $$ = opr(EQ, 2, $1, $3); }
    | '(' expr ')' { $$ = $2; }
    
;
%%

nodeType *con(int value) {
    nodeType *p;
    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");
    /* copy information */
    p->type = typeCon;
    p->con.val = value;
    return p;
}

nodeType *id(int i) {
    nodeType *p;
    /* allocate node */
    if ((p = malloc(sizeof(nodeType))) == NULL)
        yyerror("out of memory");
    /* copy information */
    p->type = typeId;
    p->id.i = i;
    return p;
}

nodeType *opr(int oper, int nops, ...) {
    va_list ap;
    nodeType *p;
    int i;
    /* allocate node, extending op array */
    if ((p = malloc(sizeof(nodeType) + (nops-1) * sizeof(nodeType *))) == NULL)
        yyerror("out of memory");
    /* copy information */
    p->type = typeOper;
    p->opr.oper = oper;
    p->opr.nops = nops;
    va_start(ap, nops);
    for (i = 0; i < nops; i++)
        p->opr.op[i] = va_arg(ap, nodeType*);
    va_end(ap);
    return p;
}

void freeNode(nodeType *p) {
    int i;
    if (!p) return;
    if (p->type == typeOper) {
        for (i = 0; i < p->opr.nops; i++)
            freeNode(p->opr.op[i]);
    }
    free(p);
}

void yyerror(char *s) {
    fprintf(stdout, "%s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}

