#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <algorithm> // std::max
#include <iostream>
#include <fstream>
#include <iterator>
#include <string>
#include <sstream>
#include <vector>
#include <ncurses.h>
#include <panel.h>
#include <menu.h>
int mode = 0;
const int MODE_CREATE = 0;
const int MODE_PLAY = 1;
const int MODE_RULES = 2;
const int MODE_ERROR = 3;

WINDOW* createWindow;
PANEL*  createPanel;
	WINDOW* createChoicesWindow;

WINDOW* playWindow;
PANEL*  playPanel;
	WINDOW* innerBoard;
	WINDOW* outerBoard;
	WINDOW* playText;
	WINDOW* choicesWindow;
	MENU*   choices;
	ITEM **my_items;

WINDOW* rulesWindow;
PANEL*  rulesPanel;

WINDOW* errorWindow;
PANEL*  errorPanel;


char input[80];

const char* rules =
	"Rules:"
	"\\n\\nEach player takes turns making moves."
	"Pieces are moved by jumping over the opposing teams pieces in any direction."
	"The piece that has been jumped over is removed from the board."
	"If the move is available, the same piece can make multiple jumps in a row before the turn is over."
	"The game ends when any player is unable to make a move on their turn."
	"The board is then scored."
	"Players earn points for each island of pieces they have on the board."
	"An island is a group of piece from the same side that does not touch any pieces of the opposing player, including diagonoally."
	"Scores are by the number of pieces per island, added up for all islands for a player."
	"\\nScores per island:"
	"\\n\\t1 piece:  1 point"
	"\\n\\t2 pieces: 3 points"
	"\\n\\t3 pieces: 5 points"
	"\\n\\t4 pieces: 7 points"
	"\\n\\t5 pieces: 9 points\\n"
	"\\n\\nPress any key\\n";

const char* askAiLevel();
const char* askCreateOrJoin();
const char* askOpponentType();
const char* askSide();
const char* askYesNo();
void clearWindow();
void drawBoard(const char* str);
void endCurses();
const char* getChoice(int i);
int getChoiceIndex(const char* i);
WINDOW* getWindow();
const char* read();
// std::string read();
void setCursor(int x, int y);
void setMode(int newMode);
const char* showChoices(const char* choicesStrs[], int n_choices, WINDOW* window, WINDOW* subWindow);
const char* showCreateChoices(const char* choiceStrs[], int n_choices);
int showPositionChoices(int* choicesInts, int n_choices, bool canPass);
void showCreate();
void showError(const char* error);
void showPlay();
void showRules();
void startCurses();
void waitPress();
void write(const char* str);

// High Level Program Management (Init, Destroy)

auto startCurses () -> void {
	int width = std::max(56, COLS);
	int panelHeight = 40;

	initscr();
	// raw();
	keypad(stdscr, 1);
	atexit(endCurses);

	createWindow = newwin(
		panelHeight,
		width,
		0,
		0
	);
	createPanel = new_panel(createWindow);

		createChoicesWindow = derwin(
			createWindow,
			8,
			width,
			2,
			0
		);

	playWindow = newwin(
		panelHeight,
		width,
		0,
		0
	);
	playPanel = new_panel(playWindow);

		int playY = 1;
		int boardHeight = 4 + 2;
		int boardWidth = (8 * 2) - 1 + 2;
		innerBoard = derwin(
			playWindow,
			boardHeight, // lines
			boardWidth,  // cols
			playY,       // start y
			2            // start x
		);
		outerBoard = derwin(
			playWindow,
			boardHeight + 1,
			boardWidth + 1,
			playY - 1,
			0
		);
		playY = playY + (8 * 2) + 2 + 2;
		playText = derwin(
			playWindow,
			4,
			width,
			boardHeight + 2, // playY,
			0
		);
		playY = playY + 6;
		choicesWindow = derwin(
			playWindow,
			10,
			width,
			boardHeight + 6, // playY,
			0
		);

	rulesWindow = newwin(
		panelHeight,
		width,
		0,
		0
	);
	rulesPanel = new_panel(rulesWindow);
	waddstr(rulesWindow, rules);

	errorWindow = newwin(
		panelHeight,
		width,
		0,
		0
	);
	errorPanel = new_panel(errorWindow);

	mvprintw(LINES - 3, 0, "(r) Rules | (esc) Quit");
	refresh();
	
	setMode(MODE_CREATE);
}

auto endCurses () -> void {
	if (!isendwin()) {
		endwin();
	}
}

// Mode and Window Handling

auto setMode(int newMode) -> void {
	mode = newMode;
	if (mode == MODE_CREATE) {
		hide_panel(playPanel);
		hide_panel(rulesPanel);
		hide_panel(errorPanel);
		show_panel(createPanel);
	} else if (mode == MODE_PLAY) {
		hide_panel(createPanel);
		hide_panel(rulesPanel);
		hide_panel(errorPanel);
		show_panel(playPanel);
	} else if (mode == MODE_RULES) {
		hide_panel(createPanel);
		hide_panel(playPanel);
		hide_panel(errorPanel);
		show_panel(rulesPanel);
	} else if (mode == MODE_ERROR) {
		hide_panel(createPanel);
		hide_panel(playPanel);
		hide_panel(rulesPanel);
		show_panel(errorPanel);
	}

	update_panels();
	doupdate();
}

auto clearWindow() -> void {
	wclear(getWindow());
}

auto getWindow() -> WINDOW* {
	WINDOW* win;

	if (mode == MODE_CREATE) {
		win = createWindow;
	} else if (mode == MODE_PLAY) {
		win = playText;
	} else if (mode == MODE_RULES) {
		win = rulesWindow;
	}

	return win;
}

auto showCreate() -> void {
	if (mode != MODE_CREATE) {
		setMode(MODE_CREATE);
	}
}

auto showError(const char* error) -> void {
	int currentMode = mode;
	noecho();
	wclear(errorWindow);

	waddstr(errorWindow, "There was an error:\\n\\n  ");
	waddstr(errorWindow, error);
	waddstr(errorWindow, "\\n\\nPress any key");

	setMode(MODE_ERROR);
	wrefresh(getWindow());
	getch();
	echo();
	setMode(currentMode);
}

auto showPlay() -> void {
	if (mode != MODE_PLAY) {
		setMode(MODE_PLAY);
	}
}

auto showRules() -> void {
	int currentMode = mode;
	setMode(MODE_RULES);
	noecho();
	getch();
	echo();
	setMode(currentMode);
}

// IO

// auto read() -> const char* {
// 	char str[80];
// 	wgetstr(getWindow(), str);
// 	const char* s = std::string(str).c_str();
// 	return s;
// }

auto read() -> const char* {
	char c;
	int i = 0;
	c = getch();
	while(i < 80 && c != 10) {
		input[i] = c;
		i++;
		c = wgetch(getWindow());
	}
	input[i] = '\\0';
	// return std::string(result).c_str();
	const char* cc = input;
	return cc;
}

auto write(const char* str) -> void {
	waddstr(getWindow(), str);
	wrefresh(getWindow());
}

// Gambit Specifics

auto drawBoard(const char* str) -> void {
	mvwprintw(outerBoard, 0, 3, "1|2|3|4|5|6|7|8");
	mvwprintw(outerBoard, 2, 0, "A");
	mvwprintw(outerBoard, 3, 0, "B");
	mvwprintw(outerBoard, 4, 0, "C");
	mvwprintw(outerBoard, 5, 0, "D");
	for(int i = 0; i < 8; i++) {
		for(int j = 0; j < 4; j++) {
			mvwprintw(
				innerBoard,
				j + 1,
				(i * 2) + 1,
				"%c",
				str[i + (j * 8)]
			);
		}
	}
	box(innerBoard, 0, 0);
	wrefresh(outerBoard);
	wrefresh(innerBoard);
}

auto getChoice(int i) -> const char* {
	switch(i) {
		case 0: return "1A";
		case 1: return "2A";
		case 2: return "3A";
		case 3: return "4A";
		case 4: return "5A";
		case 5: return "6A";
		case 6: return "7A";
		case 7: return "8A";
		case 8: return "1B";
		case 9: return "2B";
		case 10: return "3B";
		case 11: return "4B";
		case 12: return "5B";
		case 13: return "6B";
		case 14: return "7B";
		case 15: return "8B";
		case 16: return "1C";
		case 17: return "2C";
		case 18: return "3C";
		case 19: return "4C";
		case 20: return "5C";
		case 21: return "6C";
		case 22: return "7C";
		case 23: return "8C";
		case 24: return "1D";
		case 25: return "2D";
		case 26: return "3D";
		case 27: return "4D";
		case 28: return "5D";
		case 29: return "6D";
		case 30: return "7D";
		case 31: return "8D";
	}

	return "1A";
}

auto getChoiceIndex(const char* i) -> int {
	if(i == "1A") return 0;
	if(i == "2A") return 1;
	if(i == "3A") return 2;
	if(i == "4A") return 3;
	if(i == "5A") return 4;
	if(i == "6A") return 5;
	if(i == "7A") return 6;
	if(i == "8A") return 7;
	if(i == "1B") return 8;
	if(i == "2B") return 9;
	if(i == "3B") return 10;
	if(i == "4B") return 11;
	if(i == "5B") return 12;
	if(i == "6B") return 13;
	if(i == "7B") return 14;
	if(i == "8B") return 15;
	if(i == "1C") return 16;
	if(i == "2C") return 17;
	if(i == "3C") return 18;
	if(i == "4C") return 19;
	if(i == "5C") return 20;
	if(i == "6C") return 21;
	if(i == "7C") return 22;
	if(i == "8C") return 23;
	if(i == "1D") return 24;
	if(i == "2D") return 25;
	if(i == "3D") return 26;
	if(i == "4D") return 27;
	if(i == "5D") return 28;
	if(i == "6D") return 29;
	if(i == "7D") return 30;
	if(i == "8D") return 31;
	if(i == "Pass") return 32;
	if(i == "Esc") return 33;

	return 0;
}

// Menus

auto showChoices(const char* choicesStrs[], int n_choices, WINDOW* window, WINDOW* subWindow) -> const char* {
	int i;
	my_items = (ITEM **)calloc(n_choices + 1, sizeof(ITEM *));
	
	for(i = 0; i < n_choices; ++i) {
		my_items[i] = new_item(choicesStrs[i], "");
	}
	my_items[n_choices] = (ITEM *)NULL;

	choices = new_menu((ITEM **)my_items);
	set_menu_win(choices, window);
	set_menu_sub(choices, subWindow);
	post_menu(choices);
	wrefresh(window);
	wrefresh(subWindow);
	noecho();
	int c;
	const char* m;
	do {
		c = getch();
		switch(c) {
			case KEY_DOWN:
				menu_driver(choices, REQ_DOWN_ITEM);
				break;
			case KEY_UP:
				menu_driver(choices, REQ_UP_ITEM);
				break;
			case 10: /* Enter */
				m = item_name(current_item(choices)); // item_value
				break;
			case 'r':
				showRules();
				break;
		}
		wrefresh(subWindow);
	} while(c != 27 && c != 10);
	echo();
	unpost_menu(choices);
	free_menu(choices);
	for(i = 0; i < n_choices; ++i)
			free_item(my_items[i]);
	wrefresh(subWindow);
	wrefresh(window);
	if (c == 27) return "Esc";
	return m;
}

auto askCreateOrJoin() -> const char* {
	const char** choiceStrs = (const char**)calloc(2, sizeof(const char *));
	choiceStrs[0] = "Create";
	choiceStrs[1] = "Join";
	return showCreateChoices(choiceStrs, 2);
}

auto askAiLevel() -> const char* {
	const char** choiceStrs = (const char**)calloc(3, sizeof(const char *));
	choiceStrs[0] = "Easy";
	choiceStrs[1] = "Medium";
	choiceStrs[2] = "Hard";
	return showCreateChoices(choiceStrs, 3);
}

auto askOpponentType() -> const char* {
	const char** choiceStrs = (const char**)calloc(2, sizeof(const char *));
	choiceStrs[0] = "AI";
	choiceStrs[1] = "Human";
	return showCreateChoices(choiceStrs, 2);
}

auto askSide() -> const char* {
	const char** choiceStrs = (const char**)calloc(2, sizeof(const char *));
	choiceStrs[0] = "X (Goes first)";
	choiceStrs[1] = "O (Goes second)";
	return showCreateChoices(choiceStrs, 2);
}

auto askYesNo() -> const char* {
	const char** choiceStrs = (const char**)calloc(2, sizeof(const char *));
	choiceStrs[0] = "Yes";
	choiceStrs[1] = "No";
	return showCreateChoices(choiceStrs, 2);
}

auto showCreateChoices(const char* choiceStrs[], int n_choices) -> const char* {
	return showChoices(choiceStrs, n_choices, createWindow, createChoicesWindow);
}

auto showPositionChoices(int* choicesInts, int n_choices, bool canPass) -> int {
	int add = canPass ? 1 : 0;
	const char** choiceStrs = (const char**)calloc(n_choices + add, sizeof(const char *));
	int i;
	for(i = 0; i < n_choices; ++i) {
		choiceStrs[i] = getChoice(choicesInts[i]);
	}
	if (canPass) {
		choiceStrs[n_choices] = (char*)"Pass";
		n_choices++;
	}
	const char* choice = showChoices(choiceStrs, n_choices, playWindow, choicesWindow);

	return getChoiceIndex(choice);
}

// Utilities

auto waitPress() -> void {
	getch();
}

auto setCursor(int x, int y) -> void {
	wmove(getWindow(), y, x);
}
