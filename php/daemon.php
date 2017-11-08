<?php

// [Linux Daemon Writing HOWTO](http://www.netzmafia.de/skripten/unix/linux-daemon-howto.html)

function daemonize()
{
    $pid = pcntl_fork();
    if ($pid < 0) {
        // error
        exit(1);
    } else if ($pid > 0) {
        // exit parent process
        exit(0);
    }

    // Change file mode mask
    umask(0);

    // first child become an new session leader
    $sid = posix_setsid();
    if ($sid < 0) {
        exit(1);
    }

    // See: https://stackoverflow.com/questions/881388/what-is-the-reason-for-performing-a-double-fork-when-creating-a-daemon
    // Session -> Process Group -> Process
    // Only session leader can have tty, when session leader was killed, the session can't take controll of tty
    $pid = pcntl_fork();
    if ($pid < 0) {
        exit(1);
    } else if ($pid > 0) {
        exit(0);
    }

    fclose(STDIN);
    fclose(STDOUT);
    fclose(STDERR);

    // now we are in daemon
}

daemonize();

$i = 0;
while (1) {
    sleep(1);
    file_put_contents("output", $i++);
}
