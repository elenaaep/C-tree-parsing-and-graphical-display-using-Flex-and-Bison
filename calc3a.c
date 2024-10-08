#include <stdio.h>
#include "calc3.h"
#include "calc3.tab.h"

#define SYMBOL_TABLE_SIZE 52

int sym[SYMBOL_TABLE_SIZE];

int getVarIndex(char var) {
    if (var >= 'a' && var <= 'z') {
        return var - 'a';
    } else if (var >= 'A' && var <= 'Z') {
        return 26 + (var - 'A');
    }
    return -1; // Invalid index
}

int ex(nodeType *p) {
    if (!p) return 0;
    switch(p->type) {
        case typeCon: return p->con.val;
        case typeId: return sym[getVarIndex(p->id.i)];
        case typeOper:
            switch(p->opr.oper) {
                case WHILE: 
                    while(ex(p->opr.op[0])) 
                        ex(p->opr.op[1]); 
                    return 0;
                case IF: 
                    if (ex(p->opr.op[0]))
                        ex(p->opr.op[1]);
                    else if (p->opr.nops > 2)
                        ex(p->opr.op[2]);
                    return 0;
                case WRITE: 
                    printf("%d\n", ex(p->opr.op[0])); 
                    return 0;
                case ';': 
                    ex(p->opr.op[0]); 
                    return ex(p->opr.op[1]);
                case '=': 
                    return sym[getVarIndex(p->opr.op[0]->id.i)] = ex(p->opr.op[1]);
                case ADD_ASSIGN: 
                    return sym[getVarIndex(p->opr.op[0]->id.i)] += ex(p->opr.op[1]);
                case SUB_ASSIGN: 
                    return sym[getVarIndex(p->opr.op[0]->id.i)] -= ex(p->opr.op[1]);
                case MUL_ASSIGN: 
                    return sym[getVarIndex(p->opr.op[0]->id.i)] *= ex(p->opr.op[1]);
                case DIV_ASSIGN: 
                    return sym[getVarIndex(p->opr.op[0]->id.i)] /= ex(p->opr.op[1]);
                case MOD_ASSIGN: 
                    return sym[getVarIndex(p->opr.op[0]->id.i)] %= ex(p->opr.op[1]);
                case AND_ASSIGN: 
                    return sym[getVarIndex(p->opr.op[0]->id.i)] &= ex(p->opr.op[1]);
                case OR_ASSIGN: 
                    return sym[getVarIndex(p->opr.op[0]->id.i)] |= ex(p->opr.op[1]);
                case XOR_ASSIGN: 
                    return sym[getVarIndex(p->opr.op[0]->id.i)] ^= ex(p->opr.op[1]);
                case LSHIFT_ASSIGN: 
                    return sym[getVarIndex(p->opr.op[0]->id.i)] <<= ex(p->opr.op[1]);
                case RSHIFT_ASSIGN: 
                    return sym[getVarIndex(p->opr.op[0]->id.i)] >>= ex(p->opr.op[1]);
                case UMINUS: 
                    return -ex(p->opr.op[0]);
                case '+': 
                    return ex(p->opr.op[0]) + ex(p->opr.op[1]);
                case '-': 
                    return ex(p->opr.op[0]) - ex(p->opr.op[1]);
                case '*': 
                    return ex(p->opr.op[0]) * ex(p->opr.op[1]);
                case '/': 
                    return ex(p->opr.op[0]) / ex(p->opr.op[1]);
                case '%': 
                    return ex(p->opr.op[0]) % ex(p->opr.op[1]);
                case '<': 
                    return ex(p->opr.op[0]) < ex(p->opr.op[1]);
                case '>': 
                    return ex(p->opr.op[0]) > ex(p->opr.op[1]);
                case GE: 
                    return ex(p->opr.op[0]) >= ex(p->opr.op[1]);
                case LE: 
                    return ex(p->opr.op[0]) <= ex(p->opr.op[1]);
                case NE: 
                    return ex(p->opr.op[0]) != ex(p->opr.op[1]);
                case EQ: 
                    return ex(p->opr.op[0]) == ex(p->opr.op[1]);
                case INC:
                    {
                        int varIndex = getVarIndex(p->opr.op[0]->id.i);
                        sym[varIndex]++;
                        return sym[varIndex];
                    }
                case DEC:
                    {
                        int varIndex = getVarIndex(p->opr.op[0]->id.i);
                        sym[varIndex]--;
                        return sym[varIndex];
                    }
                case FOR:
                    for (ex(p->opr.op[0]); 
                         p->opr.op[1] ? ex(p->opr.op[1]) : 1; 
                         ex(p->opr.op[2]))
                    {
                        ex(p->opr.op[3]);
                    }
                   // return 0;
                case '&':
                    return ex(p->opr.op[0]) & ex(p->opr.op[1]);
                case '|':
                    return ex(p->opr.op[0]) | ex(p->opr.op[1]);
                case '^':
                    return ex(p->opr.op[0]) ^ ex(p->opr.op[1]);
                case LSHIFT:
                    return ex(p->opr.op[0]) << ex(p->opr.op[1]);
                case RSHIFT:
                    return ex(p->opr.op[0]) >> ex(p->opr.op[1]);
                case AND:
                    return ex(p->opr.op[0]) && ex(p->opr.op[1]);
                case OR:
                    return ex(p->opr.op[0]) || ex(p->opr.op[1]);
            }
    }
    return 0;
}