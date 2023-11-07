%{
// Orshak Ivan, 19.10.2019

#include <stdio.h>
#include <string.h>

char ParserBuf[100] = {0};

#ifndef __linux

#include <conio.h>
#define clear "CLS"

#else

#include <unistd.h>
#include <termios.h>

#define clear "clear"

int _getch()
{
    int ch;

    struct termios oldt, newt;

    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);

    ch = getchar();

    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);

    return ch;
}

#endif
%}

/* %option caseless (or do it like that)*/
%option noyywrap

%%
[\\][e][x][i][t] return 0;
[sS][eE][lL][eE][cC][tT] if (ParserBuf[99] != -1) strcat(ParserBuf, "SELECT ");
[fF][rR][oO][mM] if (ParserBuf[99] != -1) strcat(ParserBuf, "FROM ");
[wW][hH][eE][rR][eE] if (ParserBuf[99] != -1) strcat(ParserBuf, "WHERE ");
"\n" if (ParserBuf[0] != 0) {{strcat(ParserBuf, "\n"); printf("\x1b[32mRequest:\x1B[0;37;40m %s", ParserBuf); memset(ParserBuf, 0, sizeof(ParserBuf));}}

[a-zA-Z][a-zA-Z0-9]* {if (ParserBuf[99] != -1) {strcat(ParserBuf, yytext); strcat(ParserBuf, " ");}}

[0-9]+[a-zA-Z0-9]* {memset(ParserBuf, 0, sizeof(ParserBuf)); strcpy(ParserBuf, "\x1b[4mIdentifier couldnt start w/ numbers\x1B[0;37;40m"); ParserBuf[99] = -1;}
[a-zA-Z0-9]*[^a-zA-Z0-9\n\40]+.* {memset(ParserBuf, 0, sizeof(ParserBuf)); strcpy(ParserBuf, "\x1b[4mIdentifier contain undefined symbols\x1B[0;37;40m"); ParserBuf[99] = -1;}
%%

void DaemonCap()
{
	system(clear);
	
	printf("\x1b[43;34m##     #####  ##  ##   ####  #####  ##### \n"
		   "##     ##      ####   ##  ## ##  ## ##  ##\n"
		   "##     ####     ##    ###### #####  ##### \n"
		   "##     ##      ####   ##  ## ##     ##    \n"
		   "###### #####  ##  ##  ##  ## ##     ##    \n\x1B[0;37;40m");
					
	return;
}

int RequestHandler()
{
	switch(_getch())
 	{
		case '1':
			DaemonCap();
			printf("Enter \\exit to finish\nConsole reading:\n");
			return yylex();
		case '0':
			DaemonCap();
			printf("\x1b[31mClosing program...\n\x1B[0;37;40m");
			printf("Press any key...\n");
			_getch();
			system(clear);
			exit(0);
		default:
			return 1;
	}
}

int main()
{
	char Errs[2][100] = {{"Parsing finished correctly!\n"}, {"Unknown command!\n"}};
	
	while(1)
	{
		DaemonCap();
		printf("=========================================\n"
		"1.Read from conlose\n"
		"0.Exit\n");
	
		printf("\x1b[31m%s\x1B[0;37;40m", Errs[RequestHandler()]);
		printf("Press any key...\n");
		_getch();
	}
	
	return 0;
}
