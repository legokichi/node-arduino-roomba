serialport = require("serialport")
express = require('express')
socket_io = require('socket.io')

serialport.list (err, ports)->
  console.log("serialport list", err, ports)
  portNum = 3
  if ports[portNum]?
    serial = new serialport.SerialPort(ports[portNum].comName, {
      baudrate: 115200,
      parser: serialport.parsers.readline("\n")
    }, false)
    serial.open =>
      console.log "serial open", ports[portNum]
      main(serial)
  else
    process.exit()

main = (serial)->
  app = express()
    .use(express.static(__dirname + "/htdoc/"))
    .listen(8080)
  io = socket_io
    .listen(app)

  serial.on 'data', (data)->
    console.log('data received: ' + data)

  write = (bfr)->
    serial.write bfr, (err, results)->
      console.log('err ' + err)
      console.log('results ' + results)
  wait = do ->
    tid = 0
    (a, b)->
      clearTimeout(tid)
      tid = setTimeout(b, a)

  write(new Buffer([128,131,146,0,0,0,0]))
  io.on 'connection', (socket)->
    console.log socket.client.id
    socket.on 'echo', (msg)->      console.log(msg); socket.emit("echo", msg)
    socket.on 'forward', (msg)->   console.log("forward");   write(new Buffer([128,131,146, 64>>8, 64, 64>>8, 64])); wait 10000, -> write(new Buffer([128,131,146,0,0,0,0]))
    socket.on 'turnRight', (msg)-> console.log("turnRight"); write(new Buffer([128,131,146, 64>>8, 64,-64>>8,-64])); wait  2000, -> write(new Buffer([128,131,146,0,0,0,0]))
    socket.on 'turnLeft', (msg)->  console.log("turnLeft");  write(new Buffer([128,131,146,-64>>8,-64, 64>>8, 64])); wait  2000, -> write(new Buffer([128,131,146,0,0,0,0]))
    socket.on 'back', (msg)->      console.log("back");      write(new Buffer([128,131,146,-64>>8,-64,-64>>8,-64])); wait  5000, -> write(new Buffer([128,131,146,0,0,0,0]))
    socket.on 'stop', (msg)->      console.log("stop");      write(new Buffer([128,131,146,0,0,0,0]))
    socket.on 'highspeed', (msg)-> console.log("highspeed"); write(new Buffer([128,131,146,255>>8,255,255>>8,255])); wait  5000, -> write(new Buffer([128,131,146,0,0,0,0]))
    



