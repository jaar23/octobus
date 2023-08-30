import uuid4
import net

type
  Subscriber* = object
    connection: Socket
    connectionId*: Uuid
    disconnected*: bool = false


proc newSubscriber*(conn: Socket): ref Subscriber =
  result = (ref Subscriber)()
  result.connectionId = uuid4()
  result.connection = conn


proc notify*(subscriber: ref Subscriber): void =
  subscriber.connection.send("1\n")


proc send*(subscriber: ref Subscriber, data: string): void =
  subscriber.connection.send(data)


proc trySend*(subscriber: ref Subscriber, data: string): bool =
  let sent = subscriber.connection.trySend(data)
  if not sent:
    subscriber.disconnected = true

  return sent


proc close*(subscriber: ref Subscriber): void =
  echo "connection close..."
  subscriber.connection.close()


proc ping*(subscriber: ref Subscriber): bool =
  let sent = subscriber.connection.trySend("\n")
  if not sent:
    subscriber.disconnected = true
    return false
  let ack = subscriber.connection.recvLine()
  if ack != "":
    return true
  else:
    subscriber.disconnected = true
    return false


proc isDisconnected*(subscriber: ref Subscriber): bool = subscriber.disconnected
# proc timeout*(subscriber: Subscriber): bool =
#   subscriber.connection.
# proc closed(socket: Socket): bool =
#   return socket.closed

# proc isClose*(subscriber: Subscriber): void =
#   subscriber.connection.closed
