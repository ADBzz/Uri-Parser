%%%% -*- Mode: Prolog -*-

%Primo predicato per il controllo di schemi speciali.
%Schemi Special : 1|URI1
%                 2|mailto
%                 3|news
%                 4|tel/fax
%                 5|zos

uri_parse(URIString, URI) :-
    string_to_list(URIString, URIstl),
    
    stl_atom(URIstl, URI_List_Full),

    %Le URI hanno tutte il carattere ':', se URI_List_Full non lo ha
    %allora e' da scartare
    member(':', URI_List_Full),

    %Divido la lista e ricavo lo Scheme: URI_List_Scheme e' l'Uri
    %senza lo scheme
    split(URI_List_Full, :, Scheme, URI_Scheme),

    %Ritorna lo scheme e il numero di schema Uri.
    check_scheme(Scheme, Special),
    
    uri_parse(URI_Scheme, URI, Scheme, Special).


%uri_parse per URI1
uri_parse(URI_Scheme, URI, Scheme, 1) :-

    %Predicato per il riconoscimento di authority
    member_authority(URI_Scheme, Authority_Presence, URI_Check_Aut),
    

    %Se AuthorityPresence=1, cerco userinfo, se no ritorna [],
    %URI_Userinfo è post split dell'userinfo
    authority_userinfo(URI_Check_Aut, Authority_Presence, Userinfo,
		       URI_Userinfo),
    !,
    
    %Predicato per splittare l'host (obbligatorio se c'e' l'authority)
    split_host(URI_Userinfo, Host, URI_check_Host, Authority_Presence,
	       Port_Presence),

    check_host_dots(Host),

    not_last(Host, '.'),
    !,

    %Predicato per riconoscere la presenza di port
    check_port(URI_check_Host, Port, URI_check_Port, Port_Presence),

    %Controlla se port � formato da digits
    is_digits(Port),

    %Next:
    % 0. Stringa finita
    % 1. Path
    % 2. Query
    % 3. Fragment

    check_next(URI_check_Port, Next, URI_Next),

    check_path(URI_Next, URI_check_Path, Path, Next),

    check_next(URI_check_Path, Next1, URI_Next1),

    check_query(URI_Next1, URI_check_Query, Query, Next1),

    check_fragment(URI_check_Query, Fragment),
    !,
    uri_compose(Scheme, Userinfo, Host, Port, Path, Query, Fragment,
		A, B, C, D, E, F, G),

    URI = uri(A, B, C, D, E, F, G).



%uri_parse per mailto
uri_parse(URI_String, URI, _, 2) :-
    
    userinfo_mail(URI_String, Userinfo, Host),
    
    check_host(Host),
    
    check_host_dots(Host),
    
    uri_compose([], Userinfo, Host, [80], [], [], [],
		A, B, C, D, E, F, G),
    
    URI = uri(A, B, C, D, E, F, G).

%uri_parse per news
uri_parse(URI_String, URI, _, 3) :-
    
    check_host(URI_String),
    
    check_host_dots(URI_String),
    
    uri_compose([], [], URI_String, [80], [], [], [],
		A, B, C, D, E, F, G),

    URI = uri(A, B, C, D, E, F, G).

%uri_parse per tel e fax
uri_parse(Userinfo, URI, _, 4) :-
    
    check_id(Userinfo),
    
    uri_compose([], Userinfo, [], [], [], [], [],
		A, B, C, D, E, F, G),

    URI = uri(A, B, C, D, E, F, G).

%schema zos
uri_parse(URI_Scheme, URI, Scheme, 5) :-

    member_authority(URI_Scheme, Authority_Presence, URI_Check_Aut),
    
    authority_userinfo(URI_Check_Aut, Authority_Presence, Userinfo,
		       URI_Userinfo),
    
    split_host(URI_Userinfo, Host, URI_check_Host, Authority_Presence,
	       Port_Presence),
    
    not_last(Host, '.'),
    !,

    check_port(URI_check_Host, Port, URI_check_Port, Port_Presence),

    is_digits(Port),

    check_next(URI_check_Port, Next, URI_Next),

    %Predicato per il path partiolare di zos
    check_path_zos(URI_Next, URI_check_Path, Path, Next),

    check_next(URI_check_Path, Next1, URI_Next1),

    check_query(URI_Next1, URI_check_Query, Query, Next1),

    check_fragment(URI_check_Query, Fragment),
    !,
    
    uri_compose(Scheme, Userinfo, Host, Port, Path, Query, Fragment,
		A, B, C, D, E, F, G),

    URI = uri(A, B, C, D, E, F, G).

%Fatti

digit('1').
digit('2').
digit('3').
digit('4').
digit('5').
digit('6').
digit('7').
digit('8').
digit('9').
digit('0').

%Predicati di utility

%Ritorna l'ultimo elemento in lista
last([_| Xs], X) :-
    last(Xs, X).

last([X], X).

%Controlla l'ultimo elemento in lista
not_last([], _).
not_last(Str, X) :-
    last(Str, Y),
    X \= Y.

%Rimuove uno slash  (/) SOLO SE è primo nella lista
delete_slash(Y, [Y|Xs], Xs). 

%Divide la lista in due parti rimuovendo l'elemento cercato

split([Y|Xs], Y, [], Xs) :- !.

split([X|Xs], Y, [X|Ys], Rest):-
    X\==Y,
    split(Xs, Y, Ys, Rest),
    !.

%converte una lista di codici in una di atomi
stl_atom([], []).
stl_atom([X|Xs], [Y|Ys]) :-
    char_code(Y, X),
    stl_atom(Xs, Ys).

%Not Member
not_member(X,[X|_]) :-
    !,
    fail.
not_member(X,[_|Xs]) :-
    !,
    not_member(X,Xs).
not_member(_,[]).

%formatta le liste in atomi
list_format([], []).
list_format(Str, Str_out) :-
    atomic_list_concat(Str, Str_out).

%Verifica se l'ip è composto da digits
check_digit([X,Y,Z|Rest],Rest):-
    digit(X),
    digit(Y),
    digit(Z).

check_digit([X,Y|Rest],Rest):-
    digit(X),
    digit(Y).

check_digit([X|Rest],Rest):-
    digit(X).

%Verifica se la lista � composta da digits
is_digits([]).
is_digits([80]).
is_digits([X|Xs]) :-
    digit(X),
    is_digits(Xs).

%Appiattisce una lista
flatten([], []) :- !.
flatten([L|Xs], Result) :-
    !,
    flatten(L, Y),
    flatten(Xs, Ys),
    append(Y, Ys, Result).
flatten(L, [L]).

%Predicati di riconoscimento

%verifica la validità dell' identificatore
check_id([]).

check_id([X | Xs]) :-
    X\=':', X\='/', X\='?', X\='#', X\='@',
    check_id(Xs).

%Controlla se è una URI speciale
check_scheme([z,o,s], 5).
check_scheme([f,a,x], 4).
check_scheme([t,e,l], 4).
check_scheme([n,e,w,s], 3).
check_scheme([m,a,i,l,t,o], 2).
check_scheme(Xs, 1) :-
    Xs \= [z,o,s],
    Xs \= [f,a,x],
    Xs \= [t,e,l],
    Xs \= [n,e,w,s],
    Xs \= [m,a,i,l,t,o].


%Verifica se è presente l'authority
member_authority([], Boolean, []) :-
    Boolean is 0.

member_authority(['/', '/'|Xs], Boolean, Xs) :-
    Boolean is 1.

member_authority(Str, Boolean, Rest) :-
    Boolean is 0,
    Rest = Str.

%Verifica se nell'authority è presente Userinfo e divide
%la stringa in prima e dopo Userinfo
authority_userinfo(Str, 0,[], Str).

authority_userinfo(Str, 1, Userinfo, Rest) :-
    member('@', Str),
    !,
    split(Str, '@', Userinfo, Rest),
    check_id(Userinfo).

authority_userinfo(Str, 1, [], Str).

%Ritorna l'userinfo per i casi mailto (senza authority)
userinfo_mail(Str, Str, []) :-
    not_member('@', Str).

userinfo_mail(Str, Userinfo, Rest) :-
    split(Str, '@', Userinfo, Rest),
    check_id(Userinfo).

%divide la stringa all'host
split_host(Str, [], Str, 0, 0).

split_host(Str, Host, Rest,1, Port_Presence) :-
    member(':', Str),
    split(Str, ':', Sx, Dx),
    check_host(Sx),
    Host = Sx,
    Rest = Dx,
    Port_Presence is 1.

split_host(Str, Host, Rest, 1, Port_Presence) :-
    not_member(':', Str),
    member('/', Str),
    split(Str, '/', Host, Dx),
    check_id(Host),
    Rest = ['/'|Dx],
    Port_Presence is 0.

split_host(Str, Host, Rest, 1, Port_Presence) :-
    not_member(':', Str),
    member('?', Str),
    split(Str, '?', Host, Dx),
    check_id(Host),
    Rest = ['?'|Dx],
    Port_Presence is 0.

split_host(Str, Host, Rest, 1, Port_Presence) :-
    not_member(':', Str),
    member('#', Str),
    split(Str, '#', Host, Dx),
    check_id(Host),
    Rest = ['#'|Dx],
    Port_Presence is 0.

split_host(Str, Host, [], 1, Port_Presence) :-
    not_member(':', Str),
    not_member('?', Str),
    not_member('#', Str),
    check_host(Str),
    Host = Str,
    Port_Presence is 0.

%Verifica i punti dell'host
check_host_dots([]).
check_host_dots([X|Xs]) :-
    X \= '.',
    last(Xs, O),
    O \= '.',
    dots_aux([X|Xs]).

dots_aux([]).
dots_aux([_]).
dots_aux([X, Y|Xs]) :-
    X = '.',
    Y \= X,
    dots_aux(Xs).

dots_aux([X|Xs]) :-
    X \= '.',
    dots_aux(Xs).


%riconosce l'host nel caso rimanente
check_host(Str) :-
    not_member('.',Str),
    check_host_chars(Str).

check_host(Str) :-
    member('.',Str),
    split(Str, '.', Sx, Dx),
    check_host_chars(Sx),
    check_host(Dx).

%veriica se l'host è composto dai giusti caratteri
check_host_chars([]).
check_host_chars([X | Xs]) :-
    X\=':', X\='/', X\='?',
    X\='.', X\='#', X\='@',
    check_host_chars(Xs).

%Verifica la presenza di port: 1 se è presente, altrimenti 0.
check_port(Str, [80], Str, 0).

check_port(Str, Str, [], 1) :-
    not_member('/',Str),
    not_member('?',Str),
    not_member('#',Str).

check_port(Str, Port, L, 1) :-
    split(Str, '/', Port, Dx),
    not_member('#', Port),
    not_member('?', Port),
    append(['/'], Dx, L).

check_port(Str, Port, L, 1) :-
    split(Str, '?', Port, Dx),
    not_member('#', Port),
    not_member('/', Port),
    append(['?'], Dx, L).

check_port(Str, Port, L, 1) :-
    split(Str, '#', Port, Dx),
    not_member('/', Port),
    not_member('?', Port),
    append(['#'], Dx, L).

%Verifica e restituisce path, restituisce Rest
check_path(Str, Str, [], 0).

check_path(Str, ['?'|Str], [], 2).

check_path(Str, ['#'|Str], [], 3).

check_path(Str, Rest, Path, 1) :-
    split_path(Str, L1, Rest),
    is_path(L1, Path, []).

split_path(Str, L1, ['?'|Dx]) :-
    split(Str, '?', L1, Dx),
    not_member('#', L1).

split_path(Str, L1, ['#'|Dx]) :-
    not_member('?', Str),
    split(Str, '#', L1, Dx).

split_path(Str, Str, []) :-
    not_member('?', Str),
    not_member('#', Str).

%Usa la stringa senza query/fragment per analizzare il path
is_path([], [], _).

is_path(Str, Str, _) :-
    check_id(Str).

is_path(Str, Path, Acc) :-
    member('/', Str),
    split(Str, '/', Sx, Dx),
    check_id(Sx),
    is_path(Dx, Partial, [Acc|Dx]),
    append(Sx, ['/'], Comp),
    Path_toFlat = [Comp|Partial],
    flatten(Path_toFlat, Path).

%check_path per il caso speciale zos
%check_path_zos(URI_Next, URI_check_Path, Path, Next).
check_path_zos(Str, Str, [], 0).

check_path_zos(Str, Rest, Path, 1) :-
    split_path_zos(Str, Id44, Id8, Rest),
    append(Id44, Id8, Path).

check_path_zos(Str, ['?'|Str], [], 2).

check_path_zos(Str, ['#'|Str], [], 3).

split_path_zos(Str, Id44, [], ['?'|Rest]) :-
    not_member('(', Str),
    split(Str, '?', Id44, Rest),
    check_Id44(Id44).

split_path_zos(Str, Id44, [], ['#'|Rest]) :-
    not_member('(', Str),
    split(Str, '#', Id44, Rest),
    check_Id44(Id44).

split_path_zos(Str, Id44, Id8, Rest) :-
    split(Str, '(', Id44, L),
    split(L, ')', I, Rest),
    check_Id8(I),
    check_Id44(Id44),
    append(['('], I, Id),
    append(Id, [')'], Id8).

%Controlla Id8
check_Id8([]).
check_Id8([X|Xs]) :-
    length([X|Xs], P),
    P < 9,
    char_type(X, alnum),
    check_Id8(Xs).

%Controlla Id44
check_Id44(Str) :-
    length(Str, P),
    P < 45,
    is_Id44(Str, 0).

%Funzione ausiliaria per check_Id44
is_Id44([], _).
is_Id44(['.'|Xs], Cont) :-
    Cont > 0,
    length(Xs, P),
    P > 0,
    Q is Cont + 1,
    is_Id44(Xs, Q).

is_Id44([X|Xs], Cont) :-
    char_type(X, alnum),
    Q is Cont + 1,
    is_Id44(Xs, Q).

%Ricava dalla stringa la Query se il valore next è = 2
check_query(Str, Str, [], Next) :-
    Next \= 2.

check_query(Str, [], Str, 2) :-
    not_member('#', Str).

check_query(Str, Rest, Query, 2) :-
    split(Str, '#', Query, Rest),
    not_member('#', Query),
    not_member('#', Rest).

%Ricava il fragment (Fine di URI1!).
check_fragment([], []).
check_fragment(['#'|Xs], Xs).
check_fragment(Str, Str).

%Formatta URI
uri_compose(Scheme, Userinfo, Host, 80, Path, Query, Fragment,
	    A, B, C, 80, E, F, G) :-
    list_format(Scheme, A),
    list_format(Userinfo, B),
    list_format(Host, C),
    list_format(Path, E),
    list_format(Query, F),
    list_format(Fragment, G).

uri_compose(Scheme, Userinfo, Host, Port, Path, Query, Fragment,
	    A, B, C, D, E, F, G) :-
    list_format(Scheme, A),
    list_format(Userinfo, B),
    list_format(Host, C),
    list_format(Port, L),
    atom_number(L, D),
    list_format(Path, E),
    list_format(Query, F),
    list_format(Fragment, G).



%Verifica cosa si trova dopo Authority
check_next([], 0, []).

check_next([X|Xs], 1, Xs) :-
    X = '/'.

check_next([X|Xs], 2, Xs) :-
    X = '?'.

check_next([X|Xs], 3, Xs) :-
    X = '#'.


%Stampa l'uri passato in input.
uri_display(uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment)) :-

    write("Scheme:  "),
    write(Scheme),
    nl,
    write("Userinfo:  "),
    write(Userinfo),
    nl,
    write("Host:  "),
    write(Host),
    nl,
    write("Port:  "),
    write(Port),
    nl,
    write("Path:  "),
    write(Path),
    nl,
    write("Query:  "),
    write(Query),
    nl,
    write("Fragment:  "),
    write(Fragment),
    nl.


%uri_display\2
%Stampa l'uri passato in input.
uri_display(uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment),
	    Stream) :-

    write(Stream, "Scheme:  "),
    write(Stream, Scheme),
    nl(Stream),
    write(Stream, "Userinfo:  "),
    write(Stream, Userinfo),
    nl(Stream),
    write(Stream, "Host:  "),
    write(Stream, Host),
    nl(Stream),
    write(Stream, "Port:  "),
    write(Stream, Port),
    nl(Stream),
    write(Stream, "Path:  "),
    write(Stream, Path),
    nl(Stream),
    write(Stream, "Query:  "),
    write(Stream, Query),
    nl(Stream),
    write(Stream, "Fragment:  "),
    write(Stream, Fragment),
    nl(Stream).












    
    
					
    

