#check "hello, world"

inductive mynat: Type
| zero: mynat
| succ: mynat -> mynat

def add: mynat -> mynat -> mynat
| m mynat.zero := m
| m (mynat.succ n) := mynat.succ (add m n)

#check add mynat.zero mynat.zero
