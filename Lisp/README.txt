
-Description

Uriparse parses simplified URI Strings, splitting them in seven parameters:
	Scheme, Userinfo, Host, Port, Path, Query, Fragment.


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

		path ::= <id44> [‘(’ <id8> ‘)’]
		id44 ::= (<alfanum> | ‘.’)+
		id8 ::= (<alfanum>)+
		alfanum ::= <caratteri alfabetici e cifre>
			
	
-Functioning

uri-parse/1 : Has URI Strings as input and recognizes schemes;
			  once it recognizes the scheme, it calls uri-parse1/2 which uses the URI and its Scheme as lists of Chars.
			  uri-parse returns a list containing the different parameters of the URI.

These functions can be used to access each of the parameters individually:
	Each of these has an URI-Structure as input (output of uri-parse\1)
	and the desired parameter as output.

uri-scheme/1 : Extracts the scheme of the URI-Structure.

uri-userinfo/1 : Extracts the userinfo of the URI-Structure.

uri-host/1 : Extracts the host of the URI-Structure.

uri-port/1 : Extracts the port of the URI-Structure.

uri-path/1 : Extracts the path of the URI-Structure.

uri-query/1 : Extracts the query of the URI-Structure.

uri-fragment/1 : Extracts the fragment of the URI-Structure.

	
