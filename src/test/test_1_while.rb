
require_relative 'common'


simple_test [*(1..10).to_a.reverse,
             *([1234, 5678] * 2)] {
    <<HERE
/* testing while */

a = 10;
while (a) {
    EMIT a;
    a = a - 1;
    /* print 10 .. 1 */
}
/* loop forever here */


while (0)
    EMIT 9999;
/* never display 9999 */

b = 3;
while (b = b - 1) {
    EMIT 1234;
    EMIT 5678;
    /*
    print '1234 \n 5678'   twice
    */
}

HERE
}

