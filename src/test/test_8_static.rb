require_relative 'common'

more_simple_test [
    3, 4, 200,
    2, 3, 4, 100
]

__END__

#file auto

global g_1 = 1;
static s_1 = 2, s_2 = s_1 + 1;

l_1 = 100;

#import "test_8_static.data"


EMIT s_1;
EMIT s_2;
EMIT g_1;
EMIT l_1;



