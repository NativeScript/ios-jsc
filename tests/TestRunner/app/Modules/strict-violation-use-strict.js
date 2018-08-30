"use strict";

function f() {
    x = 5;
    delete x; // with 'use strict' should fail, but by default should be tolerated
}
