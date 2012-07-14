require './common'

more_simple_test [10, 12, 14, 16, 18, 20]

__END__

i = 0;
i = i + 1 while i < 10;
EMIT i;  # 10

EMIT i if i % 2 == 0 while ((i < 20) && (i = i + 1)); # 12-20 (step 2)


