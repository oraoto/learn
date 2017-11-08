actor Main
  new create(env: Env) =>
    env.out.print("Learn types")

    let dafultWombat = Wombat.create("A")
    let hungryWombat = Wombat.hungry("B", 1)

    let aardvark = Aardvrk.create("Aa")
    aardvark.eat(1)

    aardvark.slowEat(10, env)
    env.out.print("First slowEat return")
    aardvark.slowEat(10, env)
    env.out.print("Second slowEat return")

    let bob = Bob.create()
    let alice = Alice.create()
    let test1 = TestTraitInterface.create()
    test1.testTrait(bob)
    test1.testInterface(bob)
    test1.testInterface(alice)

    for color in ColorList().values() do
      env.out.print("")
    end

    var x: (String | None) = None

// 类
// 类型都是大小开头
class Wombat
  // let字段只能在构造器初始化，不能改
  let name: String

  // 变量字段
  // _表示私有
  var _hunger_level: U64

  // new 定义一个构造器
  new create(name': String) =>
    // 全部字段都要赋值
    name = name'
    _hunger_level = 0

  new hungry(name': String, hunger': U64) =>
    name = name'
    _hunger_level = hunger'

  // fun 定义一个函数
  // 最后一个表达式是返回值
  fun hunger(): U64 => _hunger_level

  // ref表示调用者必须是引用类型，引用类型是可变的
  // ref是一个reference capability 引用能力
  // 默认参数为0
  fun ref set_hunger(to: U64 = 0): U64 => _hunger_level = to

  // 析构函数
  fun _final(): None => None

// 原生类型 Primitives
// 没有字段
// 用户定义的原生类型只有一个实例（非用户定义呢？）

// Actor
actor Aardvrk
  let name: String
  var _hunger_level: U64 = 0

  new create(name': String) =>
    name = name'

  be eat(amount: U64) =>
    _hunger_level = _hunger_level - amount.min(_hunger_level)

  be slowEat(amount: U64, env: Env) =>
    var amount' = amount
    var one: U64 = 1
    while amount' > 0 do
      env.out.print("eat")
      _hunger_level = _hunger_level - one.min(_hunger_level)
      amount' = amount' - 1
    end

// Trait
trait Named
  fun name(): String => "Bob"

interface HasName
  fun name(): String

class Bob is Named
  // empty constructor ?
  // 没有构造函数时，Bob.create()返回的是iso!
  new create() => None

class Alice
  new create() => None
  fun name(): String => "Alice"

class TestTraitInterface
  new create() => None

  fun testTrait(named: Named): String =>
    named.name()

  // fun testInterface(hasName: HasName box): String =>
  // fun testInterface(hasName: HasName ref): String =>
  fun testInterface(hasName: HasName): String =>
    hasName.name()

// ref is not a subcap of iso
// iso! is not a subcap of iso

// Type aliases
primitive Red
primitive Green
primitive Blue

type Color is (Red | Green | Blue)

primitive ColorList
  fun apply(): Array[Color] =>
    [Red; Green; Blue]

interface HasAge
  fun age(): U32

interface HasAddress
  fun address(): String

type Person is (HasName & HasAge & HasAddress)
