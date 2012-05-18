/* Testing Support of Boolean Literals */

while (true) {
    % "here\n";
    break;
}

if (false) {
    % "incorrect\n";
} else {
    % "correct\n";
}

if (false == true) {
    % "incorrect\n";
} else {
    % "correct\n";
}


/*
 Should print:
    here
    correct
    correct
*/

