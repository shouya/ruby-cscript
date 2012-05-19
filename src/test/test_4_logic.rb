
require_relative 'common'

simple_test \
    ['foo',
     ['foo', 'bar'],
     ['bar', 'foo'],
     'bar',
     'baz',
     3,
     false,
     3,
     false,
     true,
     true] do

    <<'HERE'

    def foo() {
        EMIT "foo";
        true;
    }

    def bar() {
        EMIT "bar";
        false;
    }

    
    foo() || bar(); /* emit foo */
    foo() && bar(); /* emit foo, bar */
    bar() || foo(); /* emit bar, foo */
    bar() && foo(); /* emit bar */

    EMIT "" || "baz"; /* emit baz */
    EMIT 0 || 3;      /* emit 3 */
    EMIT 0 || 0;      /* emit false */
    EMIT 3 || 5;      /* emit 3 */
    EMIT !6;          /* emit false */
    EMIT !false;      /* emit true */
    EMIT !true || !false && !false; /* emit true */

HERE
end


