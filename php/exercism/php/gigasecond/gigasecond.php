<?php

function from(DateTime $datetime)
{
    $gigasecond = new DateInterval('PT1000000000S');
    $newDatetime = clone($datetime);
    return $newDatetime->add($gigasecond);
}