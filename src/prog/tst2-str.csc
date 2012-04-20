/* This test is just for strings */


% "hello" + "world" + "\n"; /* testing string concatenation */
/* should output `hello world" */

% "hello " * 4; /* testing repeat */
% "\n";
/* should output `hello hello hello hello ' */


/* testing strings' storage and recall */
a = "good night\n";
% a;
/* should output `good night'  */

/* this won't interpreted */
a = "string #{text}\n";
% a;

if ("" + "") {
   % "not here\n";
} else {
   % "but here\n";
}

if ("yes") {
   % "this is right way currently\n";
}

/*

The program will output:

<< THESE
helloworld
hello hello hello hello 
good night
string #{text}
but here
this is right way currently
HESE

*/
