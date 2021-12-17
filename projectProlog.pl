/* digit */
digit(Input) :- term_string(TermInput, Input), integer(TermInput), !.
digit255(Input) :- term_string(TermInput, Input), integer(TermInput),
                   TermInput >= 0, TermInput < 256.

/* caratteri non validi per identificatore */
id(64). %@
id(47). %/
id(63). %?
id(35). %#
id(58). %:

/* caratteri non validi per identificatore_host */
idH(64). %@
idH(47). %/
idH(63). %?
idH(35). %#
idH(58). %:
idH(46). %.

/* elimina gli spazi */

elimina_spazi([], []).
elimina_spazi([255 | Tail], Tail ) :- !.
elimina_spazi([Head | Tail], [Head, X]) :-  elimina_spazi(Tail, X).

/* controllo identificatore, passando in input una stringa,
che viene convertita in lista di codici ASCII */

identificatore(Input) :- string_codes(Input, List_input), ide(List_input).

ide([L| _]) :- id(L), ! , fail.
ide([_ | Ls]) :- ide(Ls).
ide([_]).

/* controllo identificatore_host, passando in input una stringa,
che viene convertita in lista di codici ASCII */
identificatore_host(Input) :- string_codes(Input, List_input), ids(List_input).

ids([L| _]) :- idH(L), ! , fail.
ids([_ | Ls]) :- ids(Ls).
ids([_]).

/* scheme */
scheme(Input) :- identificatore(Input), !.

/* host */
host(Input) :- identificatore_host(Input), !.
host(Input) :- indirizzo_ip(Input), !.
host(Input) :- string_codes(Input, List_input), member(46, List_input),
               point(List_input), !.

point(List_input) :- listPos(List_input, 46, Pos),
                     atom_codes(Atom, List_input),
                     sub_atom(Atom, 0, Pos, After, SubAtom),
                     identificatore_host(SubAtom),
                     length(List_input, X),
                     Pos2 is Pos+1,
                     C is X-Pos2,
                     sub_atom(Atom, Pos2, C, After1, SubAtom1),
                     identificatore_host(SubAtom1).

/* userinfo */
userinfo(Input) :- identificatore(Input), !.

/* port */
port(Input) :- digit255(Input), !.

/* authority */
authority(Input) :-  atom_codes(Input, List_input), aut(List_input).

aut([X, X | Y]) :- X == 47, userinfo(Y).
aut([X, X | Y]) :- X == 47, host(Y).

listPos([X|_], X, 0).
listPos([_|Tail], X, Pos) :- listPos(Tail, X, P), Pos is P+1.

userinfo(Y) :- string_codes(Y, Z),
               member(64, Z), !,
               listPos(Z, 64, Pos),
               atom_string(Z, List),
               sub_atom(List, 0, Pos, After, Q),
               identificatore(Q),
               host(Y).

authority(Input) :- host(Input).

host(Y) :- string_codes(Y, List_input),
           member(58, List_input), !,
           listPos(List_input, 58, Pos),
           length(List_input, X),
           atom_string(List, List_input),
           Pos2 is Pos+1,
           C is X-Pos2,
           sub_atom(List, Pos2, C, After, SubAtom),
           port(SubAtom).

/* indirizzo_ip */
indirizzo_ip(Input):- atom_codes(Input, List_input), validate_point(List_input).

validate_point(L):- nth1(12, L, 46), nth1(8, L, 46), nth1(4, L, 46),
                    string_codes(String, L),
                    split_string(String, ".", "", List_string),
                    length(List_string, 4),
                    validate_number(List_string).

validate_number([L | Ls]):- digit(L), validate_number(Ls), !.
validate_number([]).

/* path */
path(Input) :- identificatore(Input), !.
path(Input) :- string_codes(Input, List_input), member(47, List_input),
               slash(List_input), !.

slash(List_input) :- listPos(List_input, 47, Pos),
                     atom_codes(Atom, List_input),
                     sub_atom(Atom, 0, Pos, After, SubAtom),
                     identificatore(SubAtom),
                     length(List_input, X),
                     Pos2 is Pos+1,
                     C is X-Pos2,
                     sub_atom(Atom, Pos2, C, After1, SubAtom1),
                     identificatore(SubAtom1).

/* query */
query(Input) :- string_codes(Input, List_input), member(35, List_input), !, fail.
query(Input).

/* fragment */
fragment(Input).

/* scheme_syntax */
scheme_syntax(Input) :- mailto(Input), !.
scheme_syntax(Input) :- news(Input), !.
scheme_syntax(Input) :- telfax(Input), !.


/* mailto */
mailto(Input) :- userinfo(Input), !.
mailto(Input) :- string_codes(Input, List_input),
                 member(64, List_input),
                 at(List_input), !.

at(List_input) :- listPos(List_input, 64, Pos),
                  atom_codes(Atom, List_input),
                  sub_atom(Atom, 0, Pos, After, SubAtom),
                  userinfo(SubAtom),
                  length(List_input, X),
                  Pos2 is Pos+1,
                  C is X-Pos2,
                  sub_atom(Atom, Pos2, C, After1, SubAtom1),
                  host(SubAtom1).

/* news */
news(Input) :- host(Input), !.

/* tel e fax */
telfax(Input) :- userinfo(Input), !.
