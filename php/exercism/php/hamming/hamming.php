<?php

//
// This is only a SKELETON file for the "Hamming" exercise. It's been provided as a
// convenience to get you started writing code faster.
//

function distance($a, $b)
{
    if (strlen($a) !== strlen($b)) {
        throw new InvalidArgumentException('Input are of different length');
    }

    $dist = 0;
    $length = strlen($a);

    for ($i = 0; $i < $length; $i++) {
        if ($a[$i] !== $b[$i]) {
            $dist++;
        }
    }
    return $dist;
}
