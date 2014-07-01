serialport = require("serialport")

portNum = 2
serialport.list (err, ports)->
  console.log("serialport list", err, ports)
  if ports[portNum]?
    serial = new serialport.SerialPort(ports[portNum].comName, {
      baudrate: 9600,
      parser: serialport.parsers.readline("\n")
    }, false)
    serial.open =>
      console.log "serial open", ports[portNum]
      serial.on 'data', (data)->
        console.log('data received: ' + data)
      do recur = ->
        wait 1000, ->
          turnRight()
          wait 1000, ->
            turnLeft()
            recur()
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
