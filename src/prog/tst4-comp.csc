/* This file is for test comparison functions */

if (1 < 2) {
    % "correct\n";
} else {
    % "incorrect\n";
}


if (2 <= 2) {
    % "correct\n";
} else {
    % "incorrect\n";
}



if (3 > 2) {
    % "correct\n";
} else {
    % "incorrect\n";
}



if (3 >= 3) {
    % "correct\n";
} else {
    % "incorrect\n";
}

if (6 != 5) {
    % "correct\n";
} else {
    % "incorrect\n";
}

if (5 == 5) {
    % "correct\n";
} else {
    % "incorrect\n";
}

if ("yes" > "no") {
    % "correct\n";
} else {
    % "incorrect\n";
}

if ("a" <= "b") {
    % "correct\n";
} else {
    % "incorrect\n";
}

if ("aa" > "a") {
    % "correct\n";
} else {
    % "incorrect\n";
}

/* it should output all 'correct' */

