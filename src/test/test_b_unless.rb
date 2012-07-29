
require_relative './common'

more_simple_test [1, 2]


__END__

unless (1 + 1 == 2) {
    EMIT 0;
} else {
    EMIT 1;
}

EMIT 2 unless 1 + 1 == 3;

EMIT 3 unless 1 + 1 == 2;


