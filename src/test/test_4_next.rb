require_relative 'common'


simple_test [
    ["now redo\n"] * 2,
    "now break\n",
    5,
    ["now next\n"] * 2
] {
    <<'HERE'
/* This program is intended to try the loop features:
    * next
    * break
    * redo
*/

/* test of redo & break */
b = 3;
a = 1;
while (a = a + 1)  { /* a: 1 + 1 => 2 */
    if (b = b - 1) { /* b: 2 -> 1 -> 0 (reject) */
        a = a + b; /* a: +2 -> +1 => 5 */
        EMIT "now redo\n"; /* print this twice */
        redo;
    }
    EMIT "now break\n"; /* and print this once */
    break;
}

EMIT a; /* should output 5  */


a = 11;
while (a = a - 3) {
    if (a = a - 1) {
        EMIT "now next\n";
        next;
    }
    EMIT "break\n";
    break; /* won't be triggered */
}


HERE
}
