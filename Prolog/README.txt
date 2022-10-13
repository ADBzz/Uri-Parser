
-Description

Uriparse parses simplified URI Strings, splitting them in seven parameters:
	Scheme, Userinfo, Host, Port, Path, Query, Fragment.

This program identifies the following grammars:

URI ::= URI1 | URI2
URI1 ::= scheme ‘:’ [authorithy] [[‘/’] [path] [‘?’ query] [‘#’ fragment]]
URI2 ::= scheme `:’ scheme-syntax

scheme ::= <identifier>

authorithy ::= ‘//’ [ userinfo ‘@’ ] host [‘:’ port]

userinfo ::= <identifier>

host ::= <identifier-host> [‘.’ <identifier-host>]* | IP-Address

port ::= <digit>+

IP-address ::= <NNN.NNN.NNN.NNN – with N as a Digit>

path ::= <identifier> [‘/’ <identifier>]* [‘/’]

query ::= <characters without ‘#’>+

fragment ::= <characters>+

<identifier> ::= <characters without ‘/’, ‘?’, ‘#’, ‘@’, e ‘:’>+

<identifier-host> ::= <characters without ‘.’, ‘/’, ‘?’, ‘#’, ‘@’, e ‘:’>+

<digit> ::= ‘0’ |‘1’ |‘2’ |‘3’ |‘4’ |‘5’ |‘6’ |‘7’ |‘8’ |‘9’

Special Syntaxes which are also accepted: ():

-mailto	scheme-syntax::= [userinfo [‘@’ host]]

-news	scheme-syntax ::= [host]

-tel/fax	scheme-syntax ::= [userinfo]

-zos: this scheme is examined just like URI1 up until path.

		path ::= <id44> [‘(’ <id8> ‘)’]
		id44 ::= (<alfanum> | ‘.’)+
		id8 ::= (<alfanum>)+
		alfanum ::= <characters alfabetici e cifre>
		
-Functioning

Give the input String  to uri_parse/2, which transforms it in a list of atoms in order to recognize its scheme. 
Then, the other parameters are recognized by uri_parse/4.
The output of uri_parse/1 is an URI String structured as such: uri(Scheme, Userinfo, Host, Port, Path, Query, Fragment).

You can also use uri_display/2 to stream the result on file, while uri_display/1 streams it on console.

The comments are still in italian, I'll translate them when I manage to find the time.

	