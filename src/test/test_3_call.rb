require_relative 'common'

simple_test [6, 2, "hello\n", "just with a empty arg list\n", 55] do
    <<'HERE'
def func(a, b) {
    return a + b;
    EMIT "WTF\n";  /* won't print this */
}

def func_prn(a, b) {
    EMIT func(a, b);
    "hello\n"; /* if not returns explicitly, it will return the last value */
}


EMIT func(1, func(2, 3)); /* will print:
    6
*/
EMIT func_prn(1, 1); /* will print:
    2
    hello
*/

def no_arg()
{
   "just with a empty arg list\n";
}
EMIT no_arg();

/* redefining */
def sum(a) {
    if (a) {
        a + sum(a - 1);
    } else {
        0;
    }
}
EMIT sum(10);
HERE
end


simple_test_raise(CScript::RuntimeError) do
<<HERE
def deep(a) {
    if (a) {
        deep(a - 1);
    } else {
        EMIT b; /* crash: for stack printing */
    }
}

deep(10);


HERE
end
