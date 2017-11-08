<?php

interface Monad
{
    public static function pure($value);
    public function then(Callable $callbale); // aka bind
}

class Identity implements Monad
{
    private $value;

    private function __construct($v)
    {
        $this->value = $v;
    }
    public static function pure($v)
    {
        return new static($v);
    }

    public function then(callable $callback)
    {
        return call_user_func($callback, $this->value);
    }
}

class Maybe implements Monad
{
    private $value;

    private function __construct($v = null)
    {
        $this->value = $v;
    }

    public function isJust()
    {
        return !is_null($this->value);
    }

    public static function Just($v)
    {
        return new static($v);
    }

    public static function Nothing()
    {
        return new static();
    }

    public static function pure($v)
    {
        return new static($v);
    }

    public function then(Callable $callback)
    {
        if ($this->isJust()) {
            return call_user_func($callback, $this->value);
        } else {
            return static::Nothing();
        }
    }
}


function testIdentityMonad()
{
    echo __FUNCTION__ . PHP_EOL;
    $result = Identity::pure(1)
        ->then(function ($a) {
            return Identity::pure($a + 1);
        })
        ->then(function ($a) {
            return Identity::pure($a + 2);
        });
    var_dump($result);
}

function testMaybeMonad() {
    echo __FUNCTION__ . PHP_EOL;
    $result = Maybe::Just(10)
    ->then(function ($a) {
        echo '$a = ' . $a . PHP_EOL;
        return Maybe::Just($a + 1);
    })
    ->then(function ($a) {
        echo '$a = ' . $a . PHP_EOL;
        return Maybe::Nothing();
    })
    ->then(function ($a) {
        echo '$a = ' . $a . PHP_EOL;
        return Maybe::Just($a + 2);
    });
    var_dump($result);
}

class ListMonad implements Monad
{
    private $list;

    public function __construct($list = [])
    {
        $this->list = $list;
    }

    public static function pure($v)
    {
        $list = new static();
        $list->list[] = $v;
        return $list;
    }

    public function then(Callable $callback)
    {
        $mapped = array_map($callback, $this->list);
        $concated = array_reduce($mapped, function ($result, $r) {
            return array_merge($result, $r->list);
        }, []);
        return new ListMonad($concated);
    }
}

function testListMonad()
{
    echo __FUNCTION__ . PHP_EOL;
    $list1 = new ListMonad([1,3]);
    $list2 = new ListMonad([2,4]);
    $result = $list1
        ->then(function($a) use ($list2) {
            return $list2->then(function ($b) use ($a) {
                echo "$a + $b = " . ($a + $b) . PHP_EOL;
                return ListMonad::pure($a + $b);
            });
        });
    var_dump($result);
}

testIdentityMonad();
testMaybeMonad();
testListMonad();