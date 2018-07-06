pressEnterToContinue:-
	write('Press <Enter> to continue.'), nl,
	waitForEnter, !.


waitForEnter:-
get_char(_).


clearConsole:-
	clearConsole(40), !.

clearConsole(0).
clearConsole(N):-
	nl,
	N1 is N-1,
	clearConsole(N1).

getChar(Input):-
	get_char(Input),
	get_char(_).

getCode(Input):-
	get_code(TempInput),
	get_code(_),
	Input is TempInput - 48.

getInt(Input):-
	get_code(TempInput),
	Input is TempInput - 48.

discardInputChar:-
	get_code(_).


part([], _, []).
part(L, N, [DL|DLTail]) :-
   length(DL, N),
   append(DL, LTail, L),
   part(LTail, N, DLTail).


 clear_coords:-
    retractall(coords(_)).

  clear_inputs:-
    retractall(inputs(_)).