:- use_module(library(random)).
:- use_module(library(system)).
:- use_module(library(clpfd)).
:- use_module(library(lists)).
:- use_module(library(samsort)).
:- use_module(library(system)).
:- include('menu.pl').
:- include('containers.pl').
:- include('GameClass.pl').
:- include('utilities.pl').



%=       ..:: Xadrez Massacre ::..     =%
%=                                     =%
%=  Type 'xadresm.' to start the game  =%
%=                                     =%

%=                                     =%
%=          ..:: Authors ::..          =%
%=                                     =%
%=   Pedro França && Pedro Ferreira    =%
%=             FEUP - 2017             =%



%====================%
%= @@ game launcher =%
%====================%


xadrezm :- 
          createPvPGame(Game),
        playGame(Game).


%===============================%
%= @@ player, pieces and cells =%
%===============================%

player(whitePlayer).
player(blackPlayer).

getPlayerName(whitePlayer, 'White').
getPlayerName(blackPlayer, 'Black').

pecas([bq,bq,bq,bq,bq,bq,bq,bq,bt,bt,bt,bt,bt,bt,bt,bt,bb,bb,bb,bb,bb,bb,bb,bb,bh,bh,bh,bh,bh,bh,bh,bh,
     wq,wq,wq,wq,wq,wq,wq,wq,wt,wt,wt,wt,wt,wt,wt,wt,wb,wb,wb,wb,wb,wb,wb,wb,wh,wh,wh,wh,wh,wh,wh,wh]).

pecas1([bt,emptyCell,emptyCell,wt,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,wh,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,bq,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,
     emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,bh]).

pecas2([bt,emptyCell,emptyCell,wt,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,wh,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,bq,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,
      emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell,emptyCell]).



getCellSymbol(emptyCell, ' ').

getCellSymbol(bq,'Q').
getCellSymbol(bt,'T').
getCellSymbol(bb,'B').
getCellSymbol(bh, 'H').

getCellSymbol(wq, 'q').
getCellSymbol(wt, 't').
getCellSymbol(wb, 'b').
getCellSymbol(wh, 'h').

pieceIsOwnedBy(wq, whitePlayer).
pieceIsOwnedBy(wt, whitePlayer).
pieceIsOwnedBy(wb, whitePlayer).
pieceIsOwnedBy(wh, whitePlayer).

pieceIsOwnedBy(bq, blackPlayer).
pieceIsOwnedBy(bt, blackPlayer).
pieceIsOwnedBy(bb, blackPlayer).
pieceIsOwnedBy(bh, blackPlayer).

pieceIsOwnedBy(emptyCell, null).


gameMode(pvp).


:-dynamic
    coords/1.

:-dynamic
       inputs/1.



%======================%
%= @@ main game cycle =%
%======================%

initializeBoard(Board):-
          pecas(Pecas),random_permutation(Pecas,Pecaspermutadas),part(Pecaspermutadas,8,Board).
          %pecas1(Pecas),part(Pecas,8,Board).
          %pecas2(Pecas),part(Pecas,8,Board).



playGame(Game):-


      assertBothPlayersHavePiecesOnTheBoard(Game),
     (
        assertCurrentPlayerCanMove(Game)->true;
        endGame(Game)
     ),

		   letHumanPlay(Game, ResultantGame),
       clear_coords,clear_inputs,
       playGame(ResultantGame).


endGame(Game):-
   getGameBoard(Game,Board),
   getGamePlayerTurn(Game,Player),
   printBoard(Board),

    (
      (Player=whitePlayer)->write('Game Over!'),nl,write('Black Player Win!');
      (Player=blackPlayer)->write('Game Over!'),nl,write('White Player Win!');
      true

    ),

   abort.



letHumanPlay(Game, ResultantGame):-
	getGameBoard(Game, Board), getGamePlayerTurn(Game, Player),

	repeat,

  clearConsole,
	printBoard(Board),
	printTurnInfo(Player), nl, nl,
  getPieceToBeMovedSourceCoords(SrcRow, SrcCol),
	validateChosenPieceOwnership(SrcRow, SrcCol, Board, Player),
	getDestinyCoords(SrcRow,SrcCol,Board,Player),
  (
    findall(TempCoords2,coords(TempCoords2),Coords),
    getListSize(Coords,Size),
    (Size = 0) -> write('This piece can not make a valid move. Choose another!'),false;
    printMoves(SrcRow,SrcCol,DestRow,DestCol,Game,TempGame)
  ),
   changePlayer(TempGame, ResultantGame), !.



checkTower(SrcRow,SrcCol,Board,Player):-
            checkTowerT(SrcRow,SrcCol,Board,Player),
            checkTowerB(SrcRow,SrcCol,Board,Player),
            checkTowerL(SrcRow,SrcCol,Board,Player),
            checkTowerR(SrcRow,SrcCol,Board,Player).

checkBispe(SrcRow,SrcCol,Board,Player):-
            checkBispeTR(SrcRow,SrcCol,Board,Player),
            checkBispeTL(SrcRow,SrcCol,Board,Player),
            checkBispeBR(SrcRow,SrcCol,Board,Player),
            checkBispeBL(SrcRow,SrcCol,Board,Player).

checkQueen(SrcRow,SrcCol,Board,Player):-
            checkTowerT(SrcRow,SrcCol,Board,Player),
            checkTowerB(SrcRow,SrcCol,Board,Player),
            checkTowerL(SrcRow,SrcCol,Board,Player),
            checkTowerR(SrcRow,SrcCol,Board,Player),
            checkBispeTR(SrcRow,SrcCol,Board,Player),
            checkBispeTL(SrcRow,SrcCol,Board,Player),
            checkBispeBR(SrcRow,SrcCol,Board,Player),
            checkBispeBL(SrcRow,SrcCol,Board,Player).

checkHorse(SrcRow,SrcCol,Board,Player):-
             checkHorseTR(SrcRow,SrcCol,Board,Player),
             checkHorseTL(SrcRow,SrcCol,Board,Player),
             checkHorseRT(SrcRow,SrcCol,Board,Player),
             checkHorseRB(SrcRow,SrcCol,Board,Player),
             checkHorseBR(SrcRow,SrcCol,Board,Player),
             checkHorseBL(SrcRow,SrcCol,Board,Player),
             checkHorseLB(SrcRow,SrcCol,Board,Player),
             checkHorseLT(SrcRow,SrcCol,Board,Player).


getDestinyCoords(SrcRow,SrcCol,Board,Player):-

  getMatrixElemAt(SrcRow, SrcCol, Board, Cell),

   (
        (Cell=wt;Cell=bt) -> checkTower(SrcRow,SrcCol,Board,Player);
        (Cell=wb;Cell=bb) -> checkBispe(SrcRow,SrcCol,Board,Player);
        (Cell=wq;Cell=bq) -> checkQueen(SrcRow,SrcCol,Board,Player);
        (Cell=wh;Cell=bh) -> checkHorse(SrcRow,SrcCol,Board,Player);
        true

      ).

 % -----------------------------------------CHECK BISPE -----------------------------------------------------


checkBispeTR(SrcRow,SrcCol,Board,Player):-
     DestRow is SrcRow-1,
     DestCol is SrcCol+1,
            (


              (DestRow = 8;DestRow = -1;DestCol = 8;DestCol = -1) -> true;

             false
             ).


checkBispeTR(SrcRow,SrcCol,Board,Player):-

          DestRow is SrcRow-1,
          DestCol is SrcCol+1,

         getMatrixElemAt(DestRow,DestCol,Board,Cell),

            (

            (Cell== emptyCell) -> false;
          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);


             false

          ).

checkBispeTR(SrcRow,SrcCol,Board,Player):-
          DestRow1 is SrcRow-1,
          DestCol1 is SrcCol+1,

          getMatrixElemAt(DestRow1,DestCol1,Board,Cell),


           (

             (Cell== emptyCell) -> (checkBispeTR(DestRow1,DestCol1,Board,Player));
            true


             ).


checkBispeTL(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow-1,
          DestCol is SrcCol-1,

            (
              (DestRow = 8;DestRow = -1;DestCol = 8;DestCol = -1) -> true;

             false
             ).


checkBispeTL(SrcRow,SrcCol,Board,Player):-
        DestRow is SrcRow-1,
        DestCol is SrcCol-1,


          getMatrixElemAt(DestRow,DestCol,Board,Cell),



       (


            (Cell== emptyCell) -> false;
          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);


             false

          ).


checkBispeTL(SrcRow,SrcCol,Board,Player):-
          DestRow1 is SrcRow-1,
          DestCol1 is SrcCol-1,


          getMatrixElemAt(DestRow1,DestCol1,Board,Cell),


           (

             (Cell== emptyCell) -> (checkBispeTL(DestRow1,DestCol1,Board,Player));
            true


             ).


checkBispeBR(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow+1,
          DestCol is SrcCol+1,

            (

            (DestRow = 8;DestRow = -1;DestCol = 8;DestCol = -1) -> true;

             false

             ).


checkBispeBR(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow+1,
          DestCol is SrcCol+1,



           getMatrixElemAt(DestRow,DestCol,Board,Cell),

         (

            (Cell== emptyCell) -> false;
          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);


            false

          ).


 checkBispeBR(SrcRow,SrcCol,Board,Player):-
         DestRow1 is SrcRow+1,
         DestCol1 is SrcCol+1,


          getMatrixElemAt(DestRow1,DestCol1,Board,Cell),


           (

             (Cell== emptyCell) -> (checkBispeBR(DestRow1,DestCol1,Board,Player));
             true


             ).


 checkBispeBL(SrcRow,SrcCol,Board,Player):-
              DestRow is SrcRow+1,
              DestCol is SrcCol-1,

             (

            (DestRow = 8;DestRow = -1;DestCol = 8;DestCol = -1) -> true;
            false

             ).


checkBispeBL(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow+1,
          DestCol is SrcCol-1,



          getMatrixElemAt(DestRow,DestCol,Board,Cell),

         (


            (Cell== emptyCell) -> false;
          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);

            false

          ).

checkBispeBL(SrcRow,SrcCol,Board,Player):-

         DestRow1 is SrcRow+1,
         DestCol1 is SrcCol-1,


          getMatrixElemAt(DestRow1,DestCol1,Board,Cell),


           (

             (Cell== emptyCell) -> (checkBispeBL(DestRow1,DestCol1,Board,Player));
             true
             ).

% -----------------------------------------CHECK TOWER -----------------------------------------------------


 checkTowerT(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow-1,
          DestCol is SrcCol,

         (
            (DestRow = 8;DestRow = -1;DestCol = 8;DestCol = -1) -> true;
             false
          ).


 checkTowerT(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow-1,
          DestCol is SrcCol,


          getMatrixElemAt(DestRow,DestCol,Board,Cell),


          (
            (Cell== emptyCell) -> false;
          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);

             false

          ).


 checkTowerT(SrcRow,SrcCol,Board,Player):-
          DestRow1 is SrcRow-1,
          DestCol1 is SrcCol,

          getMatrixElemAt(DestRow1,DestCol1,Board,Cell),


           (

             (Cell== emptyCell) -> (checkTowerT(DestRow1,DestCol1,Board,Player));
              true
           ).


 checkTowerB(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow+1,
          DestCol is SrcCol,

            (


              (DestRow = 8;DestRow = -1;DestCol = 8;DestCol = -1) -> true;
               false
             ).

checkTowerB(SrcRow,SrcCol,Board,Player):-


          DestRow is SrcRow+1,
          DestCol is SrcCol,



          getMatrixElemAt(DestRow,DestCol,Board,Cell),

          (
            (Cell== emptyCell) -> false;
          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);


              false


           ).

checkTowerB(SrcRow,SrcCol,Board,Player):-
          DestRow1 is SrcRow+1,
          DestCol1 is SrcCol,


          getMatrixElemAt(DestRow1,DestCol1,Board,Cell),


           (

             (Cell== emptyCell) -> (checkTowerB(DestRow1,DestCol1,Board,Player));
            true


             ).


checkTowerL(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow,
          DestCol is SrcCol-1,

            (


              (DestRow = 8;DestRow = -1;DestCol = 8;DestCol = -1) -> true;

             false
             ).


checkTowerL(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow,
          DestCol is SrcCol-1,



          getMatrixElemAt(DestRow,DestCol,Board,Cell),

          (
            (Cell== emptyCell) -> false;
          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);


                false
           ).


checkTowerL(SrcRow,SrcCol,Board,Player):-
          DestRow1 is SrcRow,
          DestCol1 is SrcCol-1,


          getMatrixElemAt(DestRow1,DestCol1,Board,Cell),


           (

             (Cell== emptyCell) -> (checkTowerL(DestRow1,DestCol1,Board,Player));
            true
            ).



checkTowerR(SrcRow,SrcCol,Board,Player):-
            DestRow is SrcRow,
            DestCol is SrcCol+1,

            (

             (DestRow = 8;DestRow = -1;DestCol = 8;DestCol = -1) -> true;
             false
             ).


checkTowerR(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow,
          DestCol is SrcCol+1,


          getMatrixElemAt(DestRow,DestCol,Board,Cell),

          (

          	(Cell== emptyCell) -> false;
          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);

            false

           ).


checkTowerR(SrcRow,SrcCol,Board,Player):-
          DestRow1 is SrcRow,
          DestCol1 is SrcCol+1,

          getMatrixElemAt(DestRow1,DestCol1,Board,Cell),


           (

             (Cell== emptyCell) -> (checkTowerR(DestRow1,DestCol1,Board,Player));
             true
           ).


 % ----------------------------------------- CHECK HORSE-----------------------------------------------------


checkHorseTR(SrcRow,SrcCol,Board,Player):-
         DestRow is SrcRow-2,
         DestCol is SrcCol+1,

         (

           (DestRow = 8;DestRow = 9;DestRow = -1;DestRow = -2;DestCol = 8;DestCol = 9;DestCol = -1;DestCol = -2) -> true;
             false

            ).


       checkHorseTR(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow-2,
          DestCol is SrcCol+1,

           getMatrixElemAt(DestRow,DestCol,Board,Cell),

          (

            (Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer) ->  validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer) ->  validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer) ->  validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);

             true

           ).


checkHorseTL(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow-2,
          DestCol is SrcCol-1,
            (

             (DestRow = 8;DestRow = 9;DestRow = -1;DestRow = -2;DestCol = 8;DestCol = 9;DestCol = -1;DestCol = -2) -> true;

             false
             ).


checkHorseTL(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow-2,
          DestCol is SrcCol-1,


           getMatrixElemAt(DestRow,DestCol,Board,Cell),


          (


          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);


             true

          ).


checkHorseRT(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow-1,
          DestCol is SrcCol+2,
            (


              (DestRow = 8;DestRow = 9;DestRow = -1;DestRow = -2;DestCol = 8;DestCol = 9;DestCol = -1;DestCol = -2) -> true;

             false
             ).


checkHorseRT(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow-1,
          DestCol is SrcCol+2,


           getMatrixElemAt(DestRow,DestCol,Board,Cell),


          (


          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);


              true

          ).



checkHorseRB(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow+1,
          DestCol is SrcCol+2,
            (


              (DestRow = 8;DestRow = 9;DestRow = -1;DestRow = -2;DestCol = 8;DestCol = 9;DestCol = -1;DestCol = -2) -> true;

             false
             ).


checkHorseRB(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow+1,
          DestCol is SrcCol+2,


           getMatrixElemAt(DestRow,DestCol,Board,Cell),


          (


          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);


               true

          ).


checkHorseBR(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow+2,
          DestCol is SrcCol+1,
            (


             (DestRow = 8;DestRow = 9;DestRow = -1;DestRow = -2;DestCol = 8;DestCol = 9;DestCol = -1;DestCol = -2) -> true;

             false
             ).

checkHorseBR(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow+2,
          DestCol is SrcCol+1,


           getMatrixElemAt(DestRow,DestCol,Board,Cell),


          (


          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);


             true

          ).

 checkHorseBL(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow+2,
          DestCol is SrcCol-1,
            (


              (DestRow = 8;DestRow = 9;DestRow = -1;DestRow = -2;DestCol = 8;DestCol = 9;DestCol = -1;DestCol = -2) -> true;

             false
             ).


checkHorseBL(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow+2,
          DestCol is SrcCol-1,


           getMatrixElemAt(DestRow,DestCol,Board,Cell),


          (


          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);


            true

          ).


checkHorseLB(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow+1,
          DestCol is SrcCol-2,
            (


             (DestRow = 8;DestRow = 9;DestRow = -1;DestRow = -2;DestCol = 8;DestCol = 9;DestCol = -1;DestCol = -2) -> true;

             false
             ).


checkHorseLB(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow+1,
          DestCol is SrcCol-2,


           getMatrixElemAt(DestRow,DestCol,Board,Cell),


          (


          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer)-> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);

               true

          ).

 checkHorseLT(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow-1,
          DestCol is SrcCol-2,
            (


             (DestRow = 8;DestRow = 9;DestRow = -1;DestRow = -2;DestCol = 8;DestCol = 9;DestCol = -1;DestCol = -2) -> true;

             false
             ).



checkHorseLT(SrcRow,SrcCol,Board,Player):-
          DestRow is SrcRow-1,
          DestCol is SrcCol-2,


           getMatrixElemAt(DestRow,DestCol,Board,Cell),


          (


          	(Cell==bt,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bq,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bh,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==bb,Player == whitePlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wt, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wb, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wq, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);
            (Cell==wh, Player== blackPlayer) -> validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player);


              true

          ).




validateMove(SrcRow,SrcCol,DestRow,DestCol,Board,Player):-


     DestRow1 is DestRow+1,
     DestCol1 is DestCol+1,

       listPushBack([],DestRow1,TempCoords3),
       listPushBack(TempCoords3,DestCol1,TempCoords4),
       assert(inputs(TempCoords4)),

       listPushBack([],DestRow,TempCoords),
       listPushBack(TempCoords,DestCol,TempCoords2),
       assert(coords(TempCoords2)).





printMoves(SrcRow,SrcCol,DestRow,DestCol,Game,TempGame):-
           nl,
           nl,
           write('Please choose one of the destiny coordinates presented and press <Enter> - example: 3f.'),
           nl,
           nl,
           write('[[X,Y]]:'),nl,
           findall(TempCoords2,coords(TempCoords2),Coords),
           findall(TempCoords4,inputs(TempCoords4),Coords2),
           write(Coords2),nl,
           inputCoords(DRowCoord,DColCoord),
            (
            member([DRowCoord,DColCoord],Coords) -> makeMove(SrcRow,SrcCol,DestRow,DestCol,DRowCoord,DColCoord,Game,TempGame);
            write('Error: invalid input.'), nl,!,
            printMoves(SrcRow,SrcCol,DestRow,DestCol,Game,TempGame)
            ).



makeMove(SrcRow,SrcCol,DestRow,DestCol,DRowCoord,DColCoord,Game,TempGame):-


     getGameBoard(Game, Board),
	   % get piece to be moved
	   getMatrixElemAt(SrcRow, SrcCol, Board, Cell),
     getGamePlayerTurn(Game,Player),
	   % empty source cell
	   setMatrixElemAtWith(SrcRow, SrcCol, emptyCell , Board, TempBoard),

     % place piece on destiny cell

	   setMatrixElemAtWith(DRowCoord, DColCoord, Cell, TempBoard, ResultantBoard),
     clear_coords,clear_inputs,
      (
         Player == whitePlayer -> decNumBlackPieces(Game, TGame);
         Player  == blackPlayer -> decNumWhitePieces(Game, TGame);
         true

      ),

     % save the board
     setGameBoard(ResultantBoard, TGame, TempGame).



assertBothPlayersHavePiecesOnTheBoard(Game):-
	getGameNumWhitePieces(Game, NumWhitePieces),
	getGameNumBlackPieces(Game, NumBlackPieces),
	(

  (NumWhitePieces > 0)->true;
  write('Game Over! White Player has no pieces left!'),nl,
  false
  ),

  (
  (NumBlackPieces > 0)->true;
  write('Game Over! Black Player has no pieces left!'),nl,
  false
  ).


assertCurrentPlayerCanMove(Game):-
	assertCurrentPlayerCanMove(7, Game).
assertCurrentPlayerCanMove(Row, Game):-
  (
    (Row < 0) -> false;
     true
  ),

  Row >= 0,
	Row1 is Row - 1,
	(
		assertCurrentPlayerCanMove(Row, 7, Game);
		assertCurrentPlayerCanMove(Row1, Game)
	).
assertCurrentPlayerCanMove(Row, Column, Game):-
	Column >= 0,
	Column1 is Column - 1,

  getGamePlayerTurn(Game, Player),
  getGameBoard(Game, Board),
  getMatrixElemAt(Row,Column,Board,Cell),

    (
      (Cell=emptyCell)->true;
      (Player=blackPlayer,Cell=wt) -> true;
      (Player=blackPlayer,Cell=wb) -> true;
      (Player=blackPlayer,Cell=wq) -> true;
      (Player=blackPlayer,Cell=wh) -> true;
      (Player=whitePlayer,Cell=bt) -> true;
      (Player=whitePlayer,Cell=bb) -> true;
      (Player=whitePlayer,Cell=bq) -> true;
      (Player=whitePlayer,Cell=bh) -> true;
      getDestinyCoords(Row,Column,Board,Player)

    ),


    (
    findall(TempCoords2,coords(TempCoords2),Coords),
    getListSize(Coords,Size),
    (Size = 0) -> clear_coords,assertCurrentPlayerCanMove(Row, Column1, Game);
    clear_coords,clear_inputs,true
     ).


 %%% 1. current player; 2. next player.
changePlayer(Game, ResultantGame):-
	getGamePlayerTurn(Game, Player),
	(
		Player == whitePlayer ->
			NextPlayer = blackPlayer;
		NextPlayer = whitePlayer
	),

setGamePlayerTurn(NextPlayer, Game, ResultantGame).




getPieceToBeMovedSourceCoords(SrcRow, SrcCol):-
	parse_input(pede,Please insert the coordinates of the piece you wish to move and press <Enter> - example: 3f.),nl,
	inputCoords(SrcRow, SrcCol), nl.


inputCoords(SrcRow, SrcCol):-

  %discardInputChar,
	% read row
	getInt(RawSrcRow),

	% read column
	getInt(RawSrcCol),

	% discard enter
	discardInputChar,

	% process row and column

	SrcRow is (RawSrcRow-1),
  SrcCol is (RawSrcCol-49).


 validateChosenPieceOwnership(SrcRow, SrcCol, Board, Player):-
	getMatrixElemAt(SrcRow, SrcCol, Board, Piece),
	pieceIsOwnedBy(Piece, Player),!.

   validateChosenPieceOwnership(_, _, _, _):-
	write('INVALID PIECE!'), nl,
	write('A player can only move his/her own pieces.'), nl,
	pressEnterToContinue, nl,
	!,fail.


%=================%
%= Board drawing =%
%=================%

printTurnInfo(Player):-
	getPlayerName(Player, PlayerName),
    write('# It is '), write(PlayerName), write(' player\'s turn to play.'), nl, !.

printBoard([Line | Tail]):-
	printColumnIdentifiers, nl,
	printInitialSeparator, nl,
	rowIdentifiersList(RowIdentifiers),
	printRemainingBoard([Line | Tail], RowIdentifiers),
	nl, !.

printColumnIdentifiers:-
nl,
nl,
	write('        a     b     c     d     e     f     g     h').

printInitialSeparator:-
	write('      _______________________________________________').

rowIdentifiersList(['  1  ', '  2  ', '  3  ', '  4  ', '  5  ', '  6  ', '  7  ', '  8  ']).

printRemainingBoard([], []).
printRemainingBoard([Line | Tail], [RowIdentifiersListHead | RowIdentifiersListTail]):-
	printBoardRow(Line, RowIdentifiersListHead),
	printRemainingBoard(Tail, RowIdentifiersListTail).

printBoardRow([], []).
printBoardRow(Line, RowIdentifiersListHead):-
	length(Line, Length),
	createSeparatorN(Length, '_____|', Separator),
	createSeparatorN(Length, '     |', Separator2),
	write('     '), write('|'), printList(Separator2), nl,
	write(RowIdentifiersListHead), write('|'), printBoardRowValues(Line), nl,
	write('     '), write('|'), printList(Separator), nl.

createSeparatorN(0, _, []).
createSeparatorN(N, SS, [SS | Ls]):-
	N1 is N-1,
	createSeparatorN(N1, SS, Ls).

printBoardRowValues([]).
printBoardRowValues([Head | Tail]):-
   getCellSymbol(Head, Piece),
	write('  '), write(Piece), write('  |'),
    printBoardRowValues(Tail).
