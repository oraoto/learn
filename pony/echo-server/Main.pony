use "net"
use "collections"

class EchoServerConnectionNotify is TCPConnectionNotify
  let env: Env
  let id: U64
  let server: EchoServer

  new iso create(env': Env, id': U64, server': EchoServer) =>
    env = env'
    id = id'
    server = server'

  fun ref accepted(conn: TCPConnection ref) : None val =>
    server.add_client(id, conn)

  fun ref closed(conn: TCPConnection ref) : None val =>
    server.remove_client(id)

  fun ref received(conn: TCPConnection ref, data: Array[U8] iso, times: USize) : Bool =>
    let recv = String.from_array(consume data)
    env.out.print("Recv: " + recv)
    server.broadcast(recv)
    true

  fun ref connect_failed(conn: TCPConnection ref) =>
    None

actor EchoServer
  let clients: Map[U64, TCPConnection] = clients.create(1024)
  let env: Env

  new create(env': Env) =>
    env = env'

  be add_client(id: U64, client: TCPConnection) =>
    try
      clients.insert(id, client)?
    end

  be remove_client(id: U64) =>
    try
      clients.remove(id)?
    end

  be broadcast(message: String) =>
    env.out.print("Broadcast to " + clients.size().string() + " clients")
    for c in clients.values() do
      c.write(message)
    end

class EchoServerListenNotify is TCPListenNotify
  let env: Env
  var next_id: U64 = 0
  let server: EchoServer

  new create(env': Env) =>
    env = env'
    server = EchoServer(env)

  fun ref connected(listen: TCPListener ref): TCPConnectionNotify iso^ =>
    next_id = next_id + 1
    EchoServerConnectionNotify(env, next_id, server)

  fun ref not_listening(listen: TCPListener ref) =>
    None


actor Main
  new create(env: Env) =>
    env.out.print("Start echo-server at 127.0.0.1:8989")
    try
      TCPListener(env.root as AmbientAuth,
        recover EchoServerListenNotify(env) end, "127.0.0.1", "8989")
    end
