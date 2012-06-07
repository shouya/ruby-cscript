require_relative 'common'


more_simple_test [1, 1, 0, 3, 99, 0,
    (2..100).select {|x| (2..Math.sqrt(x).to_i).all? {|i| x % i != 0 } }]


__END__


EMIT 1 % 2;
EMIT 3 % 2;
EMIT 4 % 2;
EMIT 100 % 97;
EMIT 999 % 100;
EMIT 7 % 7;


def is_prime(n) {
    i = 1;
    if (n == 1) return false;

    while ((i = i + 1) < n) {
        if (n % i == 0) {
            return false;
        }
    }
    return true;
}

i = 1;
while (i <= 100) {
   if (is_prime(i)) {
       EMIT i;
   }
   i = i + 1;
}

