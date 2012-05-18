require_relative 'common'


simple_test [
    "here\n",
    "correct\n",
    "correct\n"
] do
    <<'HERE'
/* Testing Support of Boolean Literals */

while (true) {
    EMIT "here\n";
    break;
}

if (false) {
    EMIT "incorrect\n";
} else {
    EMIT "correct\n";
}

if (false == true) {
    EMIT "incorrect\n";
} else {
    EMIT "correct\n";
}


/*
 Should print:
    here
    correct
    correct
*/

HERE
end
