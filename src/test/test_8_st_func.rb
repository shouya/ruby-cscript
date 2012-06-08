require_relative 'common'


more_simple_test [1, 2, 3]

__END__

#file auto

def foo() { /* this file visible only */
    1;
}

EMIT foo();

#import "test_8_st_func.data"


EMIT foo() + 2;


