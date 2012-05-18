
require_relative 'common'


simple_test [
    "helloworld\n",
    'hello ' * 4,
    "\n",
    "good night\n",
    'string #{text}' + "\n",
    "but here\n",
    "this is right way currently\n"
] do
<<'HERE'
/* This test is just for strings */

EMIT "hello" + "world" + "\n"; /* testing string concatenation */
/* should output `hello world" */

EMIT "hello " * 4; /* testing repeat */
EMIT "\n";
/* should output `hello hello hello hello ' */


/* testing strings' storage and recall */
a = "good night\n";
EMIT a;
/* should output `good night'  */

/* this won't be interpreted */
a = "string #{text}\n";
EMIT a;

if ("" + "") { /* empty string == false */
   EMIT "not here\n";
} else {
   EMIT "but here\n";
}

if ("yes") {
   EMIT "this is right way currently\n";
}

HERE
end

