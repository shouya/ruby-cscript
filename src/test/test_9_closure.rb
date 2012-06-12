require_relative 'common'

more_simple_test [10, 11, 12]

__END__


def add(x) {
    return -> (y) {
        x + y;
    };
}

add5 = add(5);
EMIT add5(5);   /* => 10 */

add3 = add(3);
EMIT add3(add5(3)); /* => 11 */

EMIT add3(9); /* => 12 */

