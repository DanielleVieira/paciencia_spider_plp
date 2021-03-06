:- use_module(library(clpfd)).
:-style_check(-discontiguous). %to ignore warnings

:-initialization(main).

% --------------------- DECK, PILES AND CARDS

card(Value, Turned, [Value, Turned]).

isTurned([_, true]).

createSuit(S) :-card( 1    , false, Ace),
                card( 2     , false, Two),
                card( 3     , false, Three),
                card( 4     , false, Four),
                card( 5     , false, Five),
                card( 6     , false, Six),
                card( 7     , false, Seven),
                card( 8     , false, Eight),
                card( 9     , false, Nine),
                card(10     , false, Ten),
                card(11  , false, Jack),
                card(12   , false, Queen),
                card(13  , false, King),
                append([Ace], [Two], X1),
	            append(X1, [Three], X3),
	            append(X3, [Four], X4),
	            append(X4, [Five], X5),
	            append(X5, [Six], X6),
	            append(X6, [Seven], X7),
                append(X7, [Eight], X8),
                append(X8, [Nine], X9),
	            append(X9, [Ten], X10),
                append(X10, [Jack], X11),
                append(X11, [Queen], X12),
	            append(X12, [King], S).

createDeck(D) :-createSuit(S1), createSuit(S2), createSuit(S3), createSuit(S4), createSuit(S5), createSuit(S6), createSuit(S7), createSuit(S8),
                append(S1, S2, X1),
                append(X1, S3, X2),
                append(X2, S4, X3),
                append(X3, S5, X4),
                append(X4, S6, X5),
                append(X5, S7, X6),
                append(X6, S8, X7),
                random_permutation(X7, D).


insertInHead(NewHead, Tail, [NewHead|Tail]).

take(0, _, []) :- !.
take(N, [H|TA], [H|TB]) :- N > 0, N2 is N - 1, take(N2, TA, TB).

drop(0,LastElements,LastElements) :- !.
drop(N,[_|Tail],LastElements) :- N > 0, N1 is N  - 1, drop(N1,Tail,LastElements).

transferElements(N, A, B, NA, NB) :- take(N, A, Elems), append(Elems, B, NB), drop(N, A, NA).

fillPiles(Deck, Piles, NewDeck) :-
                                    transferElements(5, Deck, [], NDeck1, NewPile1),
                                    transferElements(5, NDeck1, [], NDeck2, NewPile2),
                                    transferElements(5, NDeck2, [], NDeck3, NewPile3),
                                    transferElements(5, NDeck3, [], NDeck4, NewPile4),
                                    transferElements(4, NDeck4, [], NDeck5, NewPile5),
                                    transferElements(4, NDeck5, [], NDeck6, NewPile6),
                                    transferElements(4, NDeck6, [], NDeck7, NewPile7),
                                    transferElements(4, NDeck7, [], NDeck8, NewPile8),
                                    transferElements(4, NDeck8, [], NDeck9, NewPile9),
                                    transferElements(4, NDeck9, [], NDeck10, NewPile10),
                                    append([NewPile1], [NewPile2], P1),
                                    append(P1, [NewPile3], P2),
                                    append(P2, [NewPile4], P3),
                                    append(P3, [NewPile5], P4),
                                    append(P4, [NewPile6], P5),
                                    append(P5, [NewPile7], P6),
                                    append(P6, [NewPile8], P7),
                                    append(P7, [NewPile9], P8),
                                    append(P8, [NewPile10],P9),
                                    Piles = P9, NewDeck = NDeck10.


setLastTurned([],[]).
setLastTurned([[Value|_]|Pile], [[Value,true]|Pile]).

setAllLastsTurned([],[]).
setAllLastsTurned([Pile|Piles], [NewPile|NewPiles]) :-
    setLastTurned(Pile, NewPile), setAllLastsTurned(Piles, NewPiles).

createPiles(Deck, Piles, NewDeck) :-
    fillPiles(Deck, NewPiles, NewDeck), setAllLastsTurned(NewPiles, Piles).

%-----PRINT PILES-----------------------------------------------------------------------------------------------------------------

%for transpose matrix
:- use_module(library(clpfd)).

/*
How to works?
1: Searches for the largest pile of the piles
2: Fills all lists so they are the size of the largest list
    It is mandatory to leave them with the same size so that it is possible to print the columns in their correct places.
3: Map each card with its string using the toStringCard,
   where the blankSpace value means that a space must be printed at this location.
4: Transpose the pile of piles.
4: Print piles
*/


%toStringCard(Value,turned , String).
toStringCard(blankSpace, true, "       ").
toStringCard(_,false, "|-----|").
toStringCard(1, true, "| Ace |").
toStringCard(2, true, "|  2  |").
toStringCard(3, true, "|  3  |").
toStringCard(4, true, "|  4  |").
toStringCard(5, true, "|  5  |").
toStringCard(6, true, "|  6  |").
toStringCard(7, true, "|  7  |").
toStringCard(8, true, "|  8  |").
toStringCard(9, true, "|  9  |").
toStringCard(10, true, "| 10  |").
toStringCard(11, true, "|Jack |").
toStringCard(12, true, "|Queen|").
toStringCard(13, true, "|King |").

%getCard and get turned in [card,turned]
getCard([Card|_], Card).
getTurned([_,Turned|_], Turned).

%pega o tamanho da maior lista da lista
%gets length of the biggest pile
maxlist([],0).
maxlist([Head|Tail],Max) :- maxlist(Tail,TailMax), length(Head, Num), Num > TailMax, Max is Num.
maxlist([Head|Tail],Max) :- maxlist(Tail,TailMax), length(Head, Num), Num =< TailMax, Max is TailMax.

% generates spaces to complete the piles in print
genSpaces(N, Elem, List) :- length(List,N),maplist(=(Elem),List).

%gen blankCards
completeSpaces(N, List, NewList) :- length(List, LenList), Qtd is N-LenList, genSpaces(Qtd, [blankSpace, true], Spaces), append(Spaces, List, NewList).

%Format Pile
formatPile(L,R) :- formatP(L,R).
formatP([],[]).
formatP([Card|T1],[H|T2]) :-
    getCard(Card, Value), getTurned(Card, Turned),
    toStringCard(Value, Turned, H),
    formatP(T1,T2).

%Format All Piles
formatPiles(Piles, NewPiles) :- maxlist(Piles, MaxListLength), formatPs(Piles, NewPiles, MaxListLength).
formatPs([],[], _).
formatPs([Pile|Piles], [P|NewPiles], MaxListLength) :-
    completeSpaces(MaxListLength, Pile, PileWithBlanckSpaces),
    formatPile(PileWithBlanckSpaces, FormatedPile), reverse(FormatedPile, P),
    formatPs(Piles, NewPiles, MaxListLength).


printP([]).
printP([Pile|Piles]) :-
    atomic_list_concat(Pile, ' ',List),
    writeln(List), printP(Piles).

printPiles(Piles) :-
    formatPiles(Piles, FormatedPiles),
    transpose(
        FormatedPiles, P),
    %writeln(P),
    writeln("|  0  | |  1  | |  2  | |  3  | |  4  | |  5  | |  6  | |  7  | |  8  | |  9  |"),
    writeln("|_____| |_____| |_____| |_____| |_____| |_____| |_____| |_____| |_____| |_____|"),
    printP(P).


%----MOVE CARDS---------------------------------------------------------------------------------------------------------------------

getByIndex([X], 0, X).
getByIndex([H|_], 0, H).
getByIndex([_|T], I, E) :- NewIndex is I-1, getByIndex(T, NewIndex, E).


getValue([Value, _], Value).

getHead([H|_], H).
getTail([_|Tail], Tail).

/*
How to works?
verifies, two by two, if the previous element + 1 is equal to the second element and if this holds until the required card.
*/
checkOrder(Value, [[Value|_]]) :- !.
checkOrder(Value, [C|Pile]) :-
    isTurned(C), getValue(C, CValue), Value is CValue,!;
    isTurned(C), getValue(C, CValue), getHead(Pile, C2), getValue(C2, C2Value), C2Value is CValue + 1, checkOrder(Value, Pile).

replaceElemAtPos([_|T], 0, X, [X|T]).
replaceElemAtPos([H|T], I, X, [H|R]) :- I > 0, I1 is I - 1, replaceElemAtPos(T, I1, X, R).

getCardsToMove(Card, Pile, OldPile, NewPile) :- getCardsToMove(Card, Pile, NewPile), dropCardsToMove(Card, Pile, OldPile), !.

dropCardsToMove(Card, [Card|Pile], Pile).
dropCardsToMove(Card, [_|Pile], LastElements) :- dropCardsToMove(Card, Pile, LastElements).

getCardsToMove(Card, [Card|_], [Card]).
getCardsToMove(Card, [C|Pile],  [C|Resp]) :- getCardsToMove(Card, Pile, Resp).

checkIsPossibleMove(_, Pile) :- length(Pile, 0).
checkIsPossibleMove(CardValue, [[Value|_]|_]) :- CardValue is Value - 1,!.

moveCardsTo(CardValue, IndexPileFrom, IndexPileTo, Piles, NewPiles) :-
    % get pile from -> check order in pile from ->
    % getElement(s) to move -> get pile to ->
    % append Elements ++ pileTo ->
    % replace new and old list in pies for return
    getByIndex(Piles, IndexPileFrom, PileFrom), getByIndex(Piles, IndexPileTo, PileTo),
    checkOrder(CardValue, PileFrom),checkIsPossibleMove(CardValue, PileTo),
    getCardsToMove([CardValue, true], PileFrom, NewPileFrom, ElementsToMove),
    append(ElementsToMove, PileTo, NewPileTo),
    setLastTurned(NewPileFrom, PileFromLastTrue),
    replaceElemAtPos(Piles, IndexPileFrom, PileFromLastTrue, Piles2),
    replaceElemAtPos(Piles2, IndexPileTo, NewPileTo, NewPiles),!.

%CHECK COMPLETED PILES------------------------------------------------------------------------------------------------------------

isCompletedPile([[13,true]|_], 13) :- !.
isCompletedPile([C|Cards], N) :-
    isTurned(C), getValue(C, CValue), getHead(Cards, C2), isTurned(C2), getValue(C2, C2Value), C2Value is CValue + 1, 
    NN is N + 1,
    isCompletedPile(Cards, NN).

checkCompletedPiles([], [], Qtd, Qtd) :- !.
checkCompletedPiles([Pile|Piles], [NewPile|NewPiles], Qtd, NewQtd) :-
    isCompletedPile(Pile, 1), drop(13, Pile, DropedPile), setLastTurned(DropedPile, NewPile) , Q is Qtd + 1, checkCompletedPiles(Piles, NewPiles, Q, NewQtd);
    NewPile = Pile, checkCompletedPiles(Piles, NewPiles, Qtd, NewQtd).

%test
%checkCompletedPiles([[[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true],[13,true], [13,true]],[],[[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true],[13,true]],[],[]], N, 0, QTD).

%CHECK COMPLETED PILES------------------------------------------------------------------------------------------------------------

%-----ChackWon----------------------------------------------------------------------------------------------------------
won(8).
%-----ChackWon----------------------------------------------------------------------------------------------------------

%-----DEAL--------------------------------------------------------------------------------------------------------------

oneCardPerPile([]).
oneCardPerPile([Pile|Piles]) :- length(Pile, LenPile), LenPile > 0, oneCardPerPile(Piles).

%++++++++++++++++Note. Verify if length(Deck) >= 10+++++++++++++++
%one card perPile

setCardTurned([Value,_], [Value, true]).

deal([Card|Deck], [Pile], [P], Deck) :-
        setCardTurned(Card, NCard),insertInHead(NCard, Pile, P), !.

deal([Card|Deck], [Pile|Piles], [P|RespPiles], RespDeck) :-
    setCardTurned(Card, NCard), insertInHead(NCard, Pile, P), deal(Deck, Piles, RespPiles, RespDeck).

%-- MOVE CARDS ----------------------------------------------------------------------------------------------------------------

%-- check if the order of the cards below a card is correct
% checkOrder(Card, Pile).
checkOrder([V, T], [[V1, T1]]) :-
    V == V1, T == true -> true; false.
checkOrder([V, T], [LastCardP|LastPile]) :-
    LastPile = [CardP|_],
    LastCardP = [V1, T1],
    (V == V1, T == true ->
        true;
    (isValidOrder(CardP, LastCardP) ->
        checkOrder([V, T], LastPile);
     false)).

%-- MOVE CARDS ----------------------------------------------------------------------------------------------------------------



%-- HINT ----------------------------------------------------------------------------------------------------------------

% used in run
thereAreEmptyPiles([]):- false.
thereAreEmptyPiles([Pile|Piles]) :-
    length(Pile, L),
    L == 0 -> true;
    thereAreEmptyPiles(Piles).

%-- checks if one card is smaller than another card
isValidOrder([V, T], [Vnext, T2]) :-
    V1 is (V - 1),
    V1 == Vnext,
    T ,
    T2 -> true;
    false.

isTurned([_, T], T).

%-- looks for a possible letter to give hint
getPossibleCard([], [-1, false]).
getPossibleCard([C], C).
getPossibleCard([C|ResultantePile], Card) :-
    ResultantePile = [NextC|Ps],
   isValidOrder(NextC, C),
   isTurned(NextC, T1),
   isTurned(C, T2),
   T1 == true,
   T2 == true -> getPossibleCard(ResultantePile, Card);
   Card = C.

genHintOfCard(NCard, NLastCard, Card, LastCard, Str) :-
    isValidOrder(LastCard, Card) -> Card = [VCard, TCard],
    toStringCard(VCard, TCard, StrC),
    string_concat("Card: ", StrC, Str1),
    string_concat(Str1, "-- Pile: ", Str2),
    string_concat(Str2, NCard, Str3),
    string_concat(Str3, "-->", Str4),
    string_concat(Str4, NLastCard, Str5),
    string_concat(Str5, "\n", Str6),
    Str = Str6;
    Str = "".

invalidCard(C) :- C = [-1, false].
isValidCard([V,_]) :- V > 0, V =< 13 -> true; false.

genHintPerPile(_, _, _, _, [], "").
genHintPerPile(Card, NCard, PileCard, PilesCounter, [Pile|Piles], Str) :-
    (length(Pile, L), L == 0 -> invalidCard(LastCard); Pile = [LastCard|_]),
    (isValidCard(Card) ->
        (NCard =\= PilesCounter ->
            genHintOfCard(NCard, PilesCounter, Card, LastCard, Str1),
            PilesCounter2 is (PilesCounter + 1),
            genHintPerPile(Card, NCard, PileCard, PilesCounter2, Piles, Str2),
            string_concat(Str1, Str2, Str3), Str = Str3;
          PilesCounter2 is (PilesCounter + 1),
          genHintPerPile(Card, NCard, PileCard, PilesCounter2, Piles, Str));
      Str = "").


auxHint(_, [], _, "").
auxHint(NCard, [PileCard|Ps], Piles, Response) :-
    getPossibleCard(PileCard, Card),
    genHintPerPile(Card, NCard, PileCard, 0, Piles, Str1),
    NCard2 is (NCard + 1),
    auxHint(NCard2, Ps, Piles, Str2),
    string_concat(Str1, Str2, Str3),
    Response = Str3.

hint(Piles, HintResponse) :-
    auxHint(0, Piles, Piles, Response),
    HintResponse = Response.

%--HINT-------------------------------------------------------------------------------------------------------------------------

%--GRAPHICS---------------------------------------------------------------------------------------------------------------------

spiderLogo :-
    nl,writeln(" _______  _______  ___      ___   _______  _______  ___   ______    _______ "),
       writeln("|       ||       ||   |    |   | |       ||   _   ||   | |    _ |  |       |"),
       writeln("|  _____||   _   ||   |    |   | |_     _||  |_|  ||   | |   | ||  |    ___|"),
       writeln("| |_____ |  | |  ||   |    |   |   |   |  |       ||   | |   |_||_ |   |___ "),
       writeln("|_____  ||  |_|  ||   |___ |   |   |   |  |       ||   | |    __  ||    ___|"),
       writeln(" _____| ||       ||       ||   |   |   |  |   _   ||   | |   |  | ||   |___ "),
       writeln("|_______||_______||_______||___|   |___|  |__| |__||___| |___|  |_||_______|"),
       writeln("                                                                            "),
       writeln("                              ////      \\\\\\\\                                "),
       writeln("                              \\\\\\\\  ,,  ////                                "),
       writeln("                               \\\\\\\\ ()  ////                                 "),
       writeln("                              ....(    )....                                "),
       writeln("		             ////(  X	)\\\\\\\\                              "),
       writeln("                            //// ||||||| ////                               "),
       writeln("                            \\\\\\\\         ////                               "),
       writeln("                             \\\\\\\\       ////                                ").





    helpGame :-
    nl, writeln("  |---------------------------------HELP--------------------------------|"),
        writeln("  |Start:            start (1)                                          |"),
        writeln("  |Reset Game:       reset (2)                                          |"),
        writeln("  |Help:             help  (3)                                          |"),
        writeln("  |Hint:             hint  (4)                                          |"),
        writeln("  |print piles:      print (5)                                          |"),
        writeln("  |deal:             deal  (6)                                          |"),
        writeln("  |Completed Suits:  suits (7)                                          |"),
        writeln("  |Quit Game:        quit  (8)                                          |"),
        writeln("  |_____________________________________________________________________|"),
        writeln("  |Move cards:    move(9) (press Enter)                                 |"),
        writeln("  |               <card value> <output pile number> <input pile number> |"),
        writeln("  |Cards:         Ace(1) 2 3 4 5 6 7 8 9 10 Jack(11) Queen(12) King(13) |"),
        writeln("  |---------------------------------------------------------------------|"),nl.





    congrats :-
    nl, writeln(" __     __          __          ___       _        "),
        writeln(" \\ \\   / /          \\ \\        / (_)     | |   "),
        writeln("  \\ \\_/ /__  _   _   \\ \\  /\\  / / _ _ __ | |  "),
        writeln("   \\   / _ \\| | | |   \\ \\/  \\/ / | | '_ \\| | "),
        writeln("    | | (_) | |_| |    \\  /\\  /  | | | | |_|     "),
        writeln("    |_|\\___/ \\__,_|     \\/  \\/   |_|_| |_(_)   "),
        writeln("   _____                            _         _       _   _                 _          "),
        writeln("  / ____|                          | |       | |     | | (_)               | |         "),
        writeln(" | |     ___  _ __   __ _ _ __ __ _| |_ _   _| | __ _| |_ _  ___  _ __  ___| |         "),
        writeln(" | |    / _ \\| '_ \\ / _` | '__/ _` | __| | | | |/ _` | __| |/ _ \\| '_ \\/ __| |     "),
        writeln(" | |___| (_) | | | | (_| | | | (_| | |_| |_| | | (_| | |_| | (_) | | | \\__ \\_|       "),
        writeln("  \\_____\\___/|_| |_|\\__, |_|  \\__,_|\\__|\\__,_|_|\\__,_|\\__|_|\\___/|_| |_|___(_)"),
        writeln("                     __/ |                                                             "),
        writeln("                    |___/                                                              "),nl.





    bye :-
    nl, writeln("                    ____             _ _                        "),
        writeln("                   |  _ \\           | | |                      "),
        writeln("                   | |_) |_   _  ___| | |      / _ \\           "),
        writeln("                   |  _ <| | | |/ _ \\ | |    \\_\\(_)/_/       "),
        writeln("                   | |_) | |_| |  __/_|_|    \\_//\"\\\\_       "),
        writeln("                   |____/ \\__, |\\___(_|_)      /   \\         "),
        writeln("                         |___/                                  ").

%--GRAPHICS---------------------------------------------------------------------------------------------------------------------


main:-
    spiderLogo,
    helpGame,
    run(_, _, 0, false).% 0 is value initialy of suits

readInput(X) :-
        read_line_to_codes(user_input, X3),
        string_to_atom(X3,X2),
        atom_number(X2,X).

run(Deck, Piles, QtdSuit, Started) :-
                            won(QtdSuit), congrats,nl, exit;
                            write("Command?? "), readInput(X),
                            (X =:= 1 -> start(Deck, Piles, QtdSuit, Started); true),
                            (X =:= 2 -> reset(Deck, Piles, QtdSuit, Started); true),
                            (X =:= 3 -> help(Deck, Piles, QtdSuit, Started); true),
                            (X =:= 4 -> hint(Deck, Piles, QtdSuit, Started); true),
                            (X =:= 5 -> print(Deck, Piles, QtdSuit, Started); true),
                            (X =:= 6 -> deal(Deck, Piles, QtdSuit, Started); true),
                            (X =:= 7 -> suits(Deck, Piles, QtdSuit, Started); true),
                            (X =:= 8 -> exit; true),
                            (X =:= 9 -> move(Deck, Piles, QtdSuit, Started); true),
                            (X > 8   -> run(Deck, Piles, QtdSuit, Started); true),
                            (X < 1   -> run(Deck, Piles, QtdSuit, Started); true).

%---------start
/*
FOR TESTS
auxCreateDeckAndPiles(Deck, Piles) :-
    Deck = [[12,true],[8,true],[4,true],[3,true],[1,true],[13,true],[9,true],[1,true],[6,true],[2,true],[2,true],[13,true],[5,true],[12,true],[11,true],[13,true],[3,true],[4,true],[5,true],[7,true],[1,true],[8,true],[9,true],[8,true],[1,true],[12,true],[7,true],[8,true],[3,true],[13,true],[10,true],[7,true],[5,true],[9,true],[9,true],[8,true],[2,true],[7,true],[3,true],[6,true],[5,true],[3,true],[11,true],[10,true],[13,true],[5,true],[4,true],[8,true],[4,true],[13,true],[13,true],[2,true],[7,true],[7,true],[3,true],[5,true],[1,true],[6,true],[11,true],[1,true],[7,true],[11,true],[5,true],[6,true],[9,true],[10,true],[11,true],[6,true],[2,true],[11,true],[1,true],[9,true],[9,true],[3,true],[1,true],[13,true],[12,true],[8,true],[10,true],[10,true],[12,true],[5,true],[6,true],[2,true],[6,true],[10,true],[10,true],[2,true],[4,true],[12,true],[12,true],[12,true],[4,true],[10,true],[6,true],[8,true],[9,true],[3,true],[11,true],[11,true],[7,true],[4,true],[4,true],[2,true]],
    Piles = [[[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true],[13,true]],
            [[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true],[13,true]],
            [[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true],[13,true]],
            [[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true],[13,true]],
            [[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true],[13,true]],
            [[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true],[13,true]],
            [[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true],[13,true]],
            [[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true],[13,true]],
            [[8,true],[1,true],[12,true],[11,true]],
            [[9,true],[9,true],[7,true],[3,true]]].

auxCreateDeckAndPiles(Deck, Piles) :-
    Deck = [[12,true],[8,true],[4,true],[3,true],[1,true],[13,true],[9,true],[1,true],[6,true],[2,true],[2,true],[13,true],[5,true],[12,true],[11,true],[13,true],[3,true],[4,true],[5,true],[7,true],[1,true],[8,true],[9,true],[8,true],[1,true],[12,true],[7,true],[8,true],[3,true],[13,true],[10,true],[7,true],[5,true],[9,true],[9,true],[8,true],[2,true],[7,true],[3,true],[6,true],[5,true],[3,true],[11,true],[10,true],[13,true],[5,true],[4,true],[8,true],[4,true],[13,true],[13,true],[2,true],[7,true],[7,true],[3,true],[5,true],[1,true],[6,true],[11,true],[1,true],[7,true],[11,true],[5,true],[6,true],[9,true],[10,true],[11,true],[6,true],[2,true],[11,true],[1,true],[9,true],[9,true],[3,true],[1,true],[13,true],[12,true],[8,true],[10,true],[10,true],[12,true],[5,true],[6,true],[2,true],[6,true],[10,true],[10,true],[2,true],[4,true],[12,true],[12,true],[12,true],[4,true],[10,true],[6,true],[8,true],[9,true],[3,true],[11,true],[11,true],[7,true],[4,true],[4,true],[2,true]],
    Piles = [[[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true],[12,true]],
            [[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true]],
            [[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true]],
            [[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true]],
            [[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true]],
            [[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true]],
            [[1,true],[2,true],[3,true],[4,true],[5,true],[6,true],[7,true],[8,true],[9,true],[10,true],[11,true],[12,true]],
            [[13,true]],
            [[12,true]],
            [[9,true],[9,true],[7,true],[3,true]]].
*/

start(_, _, QtdSuit, false) :-
    createDeck(D),
    createPiles(D, P, DD),
    %auxCreateDeckAndPiles(DD,P), %for tests
    printPiles(P),nl,
    run(DD, P, QtdSuit, true).

start(Deck,Piles, QtdSuit,true) :-
    writeln("Is Started!!!"),
    run(Deck, Piles, QtdSuit, true).

%---------reset
reset(_, _, QtdSuit, true) :-
    start(_,_, QtdSuit,false).

reset(Deck,Piles, QtdSuit,false) :- 
    writeln("Not Started!!!"),run(Deck, Piles, QtdSuit, false).

%---------help

help(Deck, Piles, QtdSuit, Started) :-
    helpGame,nl,
    run(Deck, Piles, QtdSuit, Started).

%---------hint

hint(Deck, Piles, QtdSuit, true) :-
        (thereAreEmptyPiles(Piles) ->
          writeln("\nThere are empty piles that can be used in moves.");
        true),
        hint(Piles, HintResponse),
        (HintResponse == "", length(Deck, L), L >= 10 ->
            writeln("No hint at the moment. But you can deal a new card into each tableau at the column.");
            (HintResponse == "" ->
              writeln("No hint at the moment.");
            writeln("\n--------------HINT-------------"),
            writeln(HintResponse), writeln("-------------------------------\n"))),
        run(Deck, Piles, QtdSuit, true).

hint(Deck, Piles, QtdSuit,false):-
    writeln("Is not Started!!!"),
    run(Deck, Piles, QtdSuit, false).

%---------print

print(Deck, Piles, QtdSuit, true) :-
    printPiles(Piles),nl,
% write(Piles),nl,
    run(Deck, Piles, QtdSuit, true).

print(Deck, Piles, QtdSuit, false) :-
    writeln("Not Started"),
    run(Deck, Piles, QtdSuit, false).

%---------deal

deal(Deck, Piles, QtdSuit, true) :-
    length(Deck, LenDeck), LenDeck < 1,writeln("No more cards!!!"), run(Deck, Piles, QtdSuit, true);
    %or
    oneCardPerPile(Piles), deal(Deck, Piles, NP, ND), printPiles(NP), nl, run(ND, NP, QtdSuit, true);
    %or
    writeln("All piles must contain at least one card."), run(Deck, Piles, QtdSuit, true).

deal(Deck, Piles, QtdSuit, false) :-
    writeln("Not Started"),
    run(Deck, Piles, QtdSuit, false).

%---------suits

suits(Deck, Piles, QtdSuit, true) :-
    write("Suits completed: "),writeln(QtdSuit),
    run(Deck, Piles, QtdSuit, true).

suits(Deck, Piles, QtdSuit, false) :-
    writeln("Not Started"),
    run(Deck, Piles, QtdSuit, false).

%----------move

move(Deck, Piles, QtdSuit, true) :-
    write("Card? "), readInput(CardValue),
    write("Pile from? "), readInput(IndexPileFrom),
    write("Pile to? "), readInput(IndexPileTo),
    
    moveCardsTo(CardValue, IndexPileFrom, IndexPileTo, Piles, NewPiles) -> 
    
        checkCompletedPiles(NewPiles, CheckedPiles, QtdSuit, NewQtd),
        write("Completed Piles: "), writeln(NewQtd), 
        printPiles(CheckedPiles), nl, run(Deck, CheckedPiles, NewQtd, true)
        
        ;

        writeln("Invalid or impossible movement!"), run(Deck, Piles, QtdSuit, true).

move(Deck, Piles, QtdSuit, false) :-
    writeln("Not Started"),
    run(Deck, Piles, QtdSuit, false).

%----------exit

exit :-
    bye, % ! para cortar aqui e nao retroceder
    sleep(2),
    halt(0).
