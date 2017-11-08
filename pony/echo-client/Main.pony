use "net"
use "buffered"

class EchoClientTCPConnectionNotify is TCPConnectionNotify
  var _out: OutStream

  new create(out: OutStream) =>
    _out = out

  fun ref received(
    conn: TCPConnection ref,
    data: Array[U8] iso,
    times: USize)
    : Bool
  =>
    _out.print("GOT:" + String.from_array(consume data))
    true

  fun ref connect_failed(conn: TCPConnection ref) =>
    None

class EchoStdinNotify is StdinNotify
  let _tcp : TCPConnection
  let _writer: Writer = Writer
  let _out : OutStream

  new iso create(tcp: TCPConnection, out: OutStream) =>
    _tcp = tcp
    _out = out

  fun ref apply(data: Array[U8 val] iso) =>
    let input: String val = String.from_iso_array(consume data)
    _out.write(input)

    for i in input.values() do
      if i == 13 then
        _out.print("")
        _tcp.writev(_writer.done())
      else
        _writer.u8(i)
      end
    end

actor Main
  new create(env: Env) =>
    try
      let tcp = TCPConnection(env.root as AmbientAuth,
        recover EchoClientTCPConnectionNotify(env.out) end, "127.0.0.1", "8989")
      env.input(EchoStdinNotify(tcp, env.out), 1024)

      var i: U32 = 0
      while i < 8 do
        env.out.print("Connect: " + i.string())
        TCPConnection(env.root as AmbientAuth,
          recover EchoClientTCPConnectionNotify(env.out) end, "127.0.0.1", "8989")
        i = i + 1
      end
    end
