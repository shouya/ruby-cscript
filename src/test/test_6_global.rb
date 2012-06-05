require_relative 'common'

more_simple_test [11, 8, 'hello, world' * 2, 'hello']

__END__

#file auto

d = "hello";

a = 1;  /* will be promoted to global */
global a, b = a + 2, c = d + ", world";


#import "test_6_global.data"
EMIT a;
EMIT b;
EMIT c;
EMIT d;         /* local variable won't be influenced */

