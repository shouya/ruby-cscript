require_relative 'common'


more_simple_test [4, 10]


__END__

outer_var = 10;

a = ->(a) { a + 1; };
b = ->(x) { a(x); };

c = -> { outer_var; };

outer_var = 100;

EMIT b(3);
EMIT c();


