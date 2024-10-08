%{
#include <stdlib.h>
#include <string.h>
#include "calc3.h"
#include "calc3.tab.h"
void yyerror(char *);
%}

%%

[a-zA-Z] {
    yylval.sIndex = *yytext;
    return VARIABLE;
}

0[Xx][0-9A-Fa-f]+ {
    yylval.iValue = strtol(yytext, NULL, 16);
    return INTEGER;
}

0[0-7]+ {
    yylval.iValue = strtol(yytext, NULL, 8); // Parsing octal numbers
    return INTEGER;
}

[0-9]+[a-zA-Z]* {
    char *numStr = strdup(yytext);
    for (int i = 0; numStr[i] != '\0'; ++i) {
        if (numStr[i] < '0' || numStr[i] > '9') {
            numStr[i] = '\0';
            break;
        }
    }
    yylval.iValue = atoi(numStr);
    free(numStr);
    return INTEGER;
}

[-()<>=+*/;{}.&|%^] {
    return *yytext;
}

">=" return GE;
"<=" return LE;
"==" return EQ;
"!=" return NE;
"while" return WHILE;
"if" return IF;
"else" return ELSE;
"write" return WRITE;
"++" { return INC; }
"--" { return DEC; }
"for" { return FOR; }
"<<" { return LSHIFT; }
">>" { return RSHIFT; }
"&&" { return AND; }
"||" { return OR; }
"+=" { return ADD_ASSIGN; }
"-=" { return SUB_ASSIGN; }
"*=" { return MUL_ASSIGN; }
"/=" { return DIV_ASSIGN; }
"%=" { return MOD_ASSIGN; }
"&=" { return AND_ASSIGN; }
"|=" { return OR_ASSIGN; }
"^=" { return XOR_ASSIGN; }
"<<=" { return LSHIFT_ASSIGN; }
">>=" { return RSHIFT_ASSIGN; }

[ \t\n]+ ; /* ignore whitespace */

\/\/[^\n]*        /* single-line comments */
\/\*([^*]|\*+[^*/])*\*+\/    /* multi-line comments */

[0-9]+"."[0-9]+ { // Match floating-point numbers
    yylval.dValue = atof(yytext);
    return FLOAT;
}

. yyerror("Unknown character");
%%

int yywrap(void) {
    return 1;
}
