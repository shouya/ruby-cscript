require './common'

more_simple_test [1]

__END__

def func() {
  return 0 if 0;
  return 1 if 1;
  return 2;
}


EMIT func();


