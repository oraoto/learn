
$cflags = llvm-config --cflags
cl /MD $cflags.split(' ') -c main.c

$libs = llvm-config --ldflags --libs # core analysis engine
link main.obj $libs.split(' ')


