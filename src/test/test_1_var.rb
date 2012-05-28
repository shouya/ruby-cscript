require_relative 'common'


simple_test [10, 11] {
    <<HERE
/* testing variables definition and use */


a = 3; /* global */

b = 4; /* global */

if (c = 2 /* local */ ) {
    EMIT a + b + c + 1; /* print: 10 */
}

a = b + a;

EMIT a + b;


HERE
}

simple_test_raise(RuntimeError) {
    <<HERE
if (c = 2) {
    1;
}

EMIT c;
HERE
}
