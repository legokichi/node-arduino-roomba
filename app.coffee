express = require('express')
serialport = require("serialport")
socket_io = require('socket.io')

app = express()
  .use(express.static(__dirname + "/htdoc/"))
  .listen(8080)

io = socket_io
  .listen(app)
  .set("log level", 3)


portNum = 0
serialport.list (err, ports)->
  console.log("serialport list", err, ports)
  if ports[portNum]?
    serial = new serialport.SerialPort(ports[portNum].comName, {
      baudrate: 9600,
      parser: serialport.parsers.readline("\n")
    }, false)
    serial.open =>
      console.log "serial open", ports[portNum]
      wait 100, ->
        turnRight()
        wait 100, ->
          turnLeft()
      serial.on 'data', (data)->
        console.log('data received: ' + data)
    io.on 'connection', (socket)->
      console.log socket.client.id
      
      socket.on 'forward', (msg)-> console.log("forward"); forward()
      socket.on 'turnRight', (msg)-> console.log("turnRight"); turnRight()
      socket.on 'turnLeft', (msg)-> console.log("turnLeft"); turnLeft()
      socket.on 'back', (msg)-> console.log("back"); back()
      socket.on 'hogehoge', (msg)-> console.log(msg); socket.emit("hugahuga", msg)

    wait = (n, cb)-> setTimeout(cb, n)
    forward = -> write(48)
    turnRight = -> write(49)
    turnLeft = -> write(50)
    back = -> write(51)

    write = (n)->
      serial.write new Buffer([n]), (err, results)->
        console.log('err ' + err)
        console.log('results ' + results)
  else
    process.exit()
