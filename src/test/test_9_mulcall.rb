require_relative 'common'

more_simple_test [7, 6]

__END__


a = -> {|x|
        -> {|y|
            -> {|z|
                x + y + z;
            }
        };
    };

EMIT a(1)(2)(4);

p = a(1);

EMIT p(2)(3);


