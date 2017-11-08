use "collections"

actor Main
  new create(env: Env) =>
    // Actor reference must be tag
    let act1 : Actor tag = Actor(1, "A", env)

    let act2 : Actor = Actor(2, "B", env)
    act1.sayhi()
    act2.sayhi()

    // can't call function of tag
    // act1.do_nothing()
    // env.out.print(act1.id)
    act1.set_id(3)
    // act1.sayhi()

    let stage1 = Stage
    stage1.add_actor(act1)
    stage1.add_actor(act2)
    stage1.sayhi(5)

    let stage2 = Stage
    stage1.add_actor(act1)
    stage1.add_actor(act2)
    stage2.sayhi(10)

fun actor_as_ref(act: Actor ref): U32 =>
    act.id

class Something
  var id: U32 = 0

  fun ref set_id(id': U32) =>
    id = id'

actor Stage
  let actors: Map[U32, Actor] = actors.create(100)
  var next_id : U32 = 0

  be add_actor(act: Actor) =>
    try
      actors.insert(next_id, act)?
      act.set_id(next_id)
      next_id = next_id + 1
    end

  be sayhi(n: U32) =>
    for a in actors.values() do
      a.sayhi()
    end

actor Actor
  // ! can't assign to a let or embed definition more than once
  // let id: U32
  var id: U32
  let name: String
  let env: Env

  let some_ref: Something = Something

  // actor constructor cannot specify receiver capability
  new create(id': U32, name': String, env': Env) =>
    id = id'
    env = env'
    name = name'

  be sayhi() =>
    env.out.print("I'am " + name + id.string())

  // actor behaviour cannot specify receiver capability
  be set_id(id': U32) =>
    do_nothing()
    id = id'

  fun do_nothing(): None =>
    None

  fun box get_some_ref(): this->Something =>
    some_ref

