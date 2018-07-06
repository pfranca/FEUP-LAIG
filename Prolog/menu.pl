
%=================%
%= @@ game menus =%
%=================%

mainMenu:-
	printMainMenu,
	getChar(Input),
	(
          Input = '1' -> gameModeMenu;
          Input = '2';

         write('Error: invalid input.'), nl,
		 write('Press <Enter> to continue.'), nl,
         get_char(_), !,
         mainMenu

    ).

printMainMenu:-
	write('\33\[2J'), % clearConsole %
	write('+++++++++++++++++++++++++++++++++'), nl,
	write('+   ..:: Xadrez Massacre ::..   +'), nl,
	write('+++++++++++++++++++++++++++++++++'), nl,
	write('+                               +'), nl,
	write('+   1. Play                     +'), nl,
	write('+   2. Exit                     +'), nl,
	write('+                               +'), nl,
    write('+++++++++++++++++++++++++++++++++'), nl,
write('Choose an option:'), nl.

gameModeMenu:-
	printgameModeMenu,
	get_char(Input),
	(
		Input = '1' -> startPvPGame;
		Input = '2';

		nl,
		write('Error: invalid input.'), nl,
		write('Press <Enter> to continue.'), nl,
        get_char(_), !,
		gameModeMenu
	).

printgameModeMenu:-
	write('\33\[2J'),
	write('+++++++++++++++++++++++++++++++++'), nl,
	write('+      ..:: Game Mode ::..      +'), nl,
	write('+++++++++++++++++++++++++++++++++'), nl,
	write('+                               +'), nl,
	write('+   1. Player vs. Player        +'), nl,
	write('+   2. Exit                     +'), nl,
	write('+                               +'), nl,
	write('+++++++++++++++++++++++++++++++++'), nl,
	write('Choose an option:'), nl.


 startPvPGame:-
         discardInputChar,
        createPvPGame(Game),
        playGame(Game).



	
