/* file calcu.c */
/* (c) Donald Axel GPL - license */
/* ANSI - C program demonstration, command line calculator */
/* Recursive descent parser */
/* Improve: Make a HELP command. Add more variables.       */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "calcu.h"

#define stricmp strcasecmp
#define strnicmp strncasecmp

#define MAXL 8196
int degrees;
char gs[MAXL];
char *cp;
char *errorp;
double oldval;


int nextchar()
{
    ++cp;
    while (*cp == ' ')
        ++cp;
    return *cp;
}


int eatspace()
{
    while (*cp == ' ')
        ++cp;
    return *cp;
}


/* More local prototypes. This could, of course, be a separate file. */
double expression();
double product();
double bitwise();
double potens();
double signedfactor();
double factor();
double stdfunc();

double switchToDegrees(double value);
double switchToRadians(double value);

//my defined functions
double factorial(double num);

int evaluate(char *s, double *r)
{
    cp = s;
    eatspace();
    *r = bitwise();
    eatspace();
    if (*cp == '\n' && !errorp)
        return (0);
    else
        return (cp - s) + 11;
}

double bitwise()
{
    double dp;
    int ope;

    dp = expression();
    while ((ope = *cp) == '|' || ope == '&') {
        nextchar();
        if (ope == '|')
            dp = (double)((long)dp | (long)potens());
        else
            dp = (double)((long)dp & (long)potens());
    }
    eatspace();
    return dp;
}

double expression()
{
    double e;
    int opera2;

    e = product();
    while ((opera2 = *cp) == '+' || opera2 == '-') {
        nextchar();
        if (opera2 == '+')
            e += product();
        else
            e -= product();
    }
    eatspace();
    return e;
}


double product()
{
    double dp;
    int ope;

    dp = potens();
    while ((ope = *cp) == '*' || ope == '/') {
        nextchar();
        if (ope == '*')
            dp *= potens();
        else
            dp /= potens();
    }
    eatspace();
    return dp;
}


double potens()
{
    double dpo;

    dpo = signedfactor();
    while (*cp == '^') {
        nextchar();
        //what the heck was he thinking????
        //dpo = exp(log(dpo) * signedfactor());
        dpo = pow(dpo,signedfactor());
    }
    eatspace();
    return dpo;
}


double signedfactor()
{
    double ds;
    if (*cp == '-') {
        nextchar();
        ds = -factor();
    } else
        ds = factor();
    eatspace();
    return ds;
}


double factor()
{
    double df;

    switch (*cp) {
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
    case '.':
        df = strtod(cp, &cp);
        break;
    case '(':
        nextchar();
        df = bitwise();
        if (*cp == ')')
            nextchar();
        else
            errorp = cp;
        break;
    case 'x':
        nextchar();
        df = oldval;
        break;

    default:
        df = stdfunc();
    }

    eatspace();
    return df;
}


char *functionname[] =
{
    "abs", "sqrt", "sinh", "cosh", "tanh", "asin", "acos", "atan", "ln", "log", "exp", "sin", "cos", "tan", "fact", "floor", "ceil", "\0"
};

double stdfunc()
{
    double dsf;
    char **fnptr;
    int jj;

    eatspace();
    jj = 0;
    fnptr = functionname;
    while (**fnptr) {
        if(strncmp(*fnptr, cp, strlen(*fnptr)) == 0)
            break;

        ++fnptr;
        ++jj;
    }

    if (!**fnptr) {
        errorp = cp;
        return 1;
    }
    cp += (strlen(*fnptr) - 1);
    nextchar();
    dsf = factor();
    
    switch (jj) {
    case 0: dsf = fabs(dsf);  break;
    case 1: dsf = sqrt(dsf); break;
    case 2: dsf = sinh(dsf); break;
    case 3: dsf = cosh(dsf);  break;
    case 4: dsf = tanh(dsf);  break;
    case 5: dsf = switchToDegrees(asin(dsf));  break;
    case 6: dsf = switchToDegrees(acos(dsf));  break;
    case 7: dsf = switchToDegrees(atan(dsf));  break;
    case 8: dsf = log(dsf);  break;
    case 9: dsf = log10(dsf); break;
    case 10: dsf = exp(dsf);  break;
    case 11: dsf = sin(switchToRadians(dsf));  break;
    case 12: dsf = cos(switchToRadians(dsf));  break;
    case 13: dsf = tan(switchToRadians(dsf)); break;
    case 14: dsf = factorial(dsf); break;
    case 15: dsf = floor(dsf); break;
    case 16: dsf = ceil(dsf); break;
    default:{
            errorp = cp;
            return 4;
        }
    }
    
    eatspace();
    return dsf;
}

double factorial(double num)
{
    double ans = 1;
    int newNum = (int)num;
    while(newNum>1)
    {
        ans *= newNum;
        newNum--;
    }
    return ans;
}

double switchToDegrees(double value)
{
    if(degrees)
        return value*180/M_PI;
    else
        return value;
}

double switchToRadians(double value)
{
    if(!degrees)
        return value;
    else
        return value*M_PI/180;
}

void setIsDegrees(int d)
{
    degrees = d;
}


/* end calcu.c */