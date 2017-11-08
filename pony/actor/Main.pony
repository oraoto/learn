actor Main
  new create(env: Env) =>
    let act = Listener(MyNotify)

actor Listener
  var _notify: Notify

  new create(notify': Notify iso) =>
    _notify = consume notify'

  // can only pass actor as ref in be
  be notify() =>
    _notify.notify(this)

interface Notify
  fun ref notify(listener: Listener ref) => None

class MyNotify is Notify

  fun ref notify(listener: Listener ref) => None