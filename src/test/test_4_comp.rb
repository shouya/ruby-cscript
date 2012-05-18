require_relative 'common'

simple_test ["correct\n"] * 9 do
    <<'HERE'

/* This file is for test comparison functions */

if (1 < 2) {
    EMIT "correct\n";
} else {
    EMIT "incorrect\n";
}


if (2 <= 2) {
    EMIT "correct\n";
} else {
    EMIT "incorrect\n";
}



if (3 > 2) {
    EMIT "correct\n";
} else {
    EMIT "incorrect\n";
}



if (3 >= 3) {
    EMIT "correct\n";
} else {
    EMIT "incorrect\n";
}

if (6 != 5) {
    EMIT "correct\n";
} else {
    EMIT "incorrect\n";
}

if (5 == 5) {
    EMIT "correct\n";
} else {
    EMIT "incorrect\n";
}

if ("yes" > "no") {
    EMIT "correct\n";
} else {
    EMIT "incorrect\n";
}

if ("a" <= "b") {
    EMIT "correct\n";
} else {
    EMIT "incorrect\n";
}

if ("aa" > "a") {
    EMIT "correct\n";
} else {
    EMIT "incorrect\n";
}

/* it should output all 'correct' */

HERE

end
