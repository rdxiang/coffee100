class @DisplayDriver
  constructor: () ->
    @c = document.getElementById("coffee100Canvas")
    @ctx = @c?.getContext("2d")
    @width = 640
    @height = 480
  drawRectangle : (r,g,b,x1,y1,x2,y2) ->
    @ctx.fillStyle = "rgb(#{r*8},#{g*8},#{b*8})"
    @ctx.fillRect(x1,y1,x2,y2)
  randomizeScreen : () ->
    for x in [0..(@width - 1)]
      for y in [0..(@height - 1)]
        r = Math.floor(Math.random()*31)
        g = Math.floor(Math.random()*31)
        b = Math.floor(Math.random()*31)
        @drawRectangle(r,g,b,x,y,x,y)
  clockTick : (deviceRegisters) ->
    command = deviceRegisters[96]
    response = deviceRegisters[97]
    if command is 0 and response is 0
      return
    else if command is 1 and response is 1
      return
    else if command is 0 and response is 1
      deviceRegisters[97] = 0
      return
    else
      if (deviceRegisters[98] is 1)
        x1 = deviceRegisters[99]
        y1 = deviceRegisters[100]
        x2 = deviceRegisters[101]
        y2 = deviceRegisters[102]
        rawColor = deviceRegisters[103]
        r = (rawColor >>> 10) & 31
        g = (rawColor >>> 5) & 31
        b = (rawColor) & 31
        @drawRectangle r,g,b,x1,y1,x2,y2
      else
        data = @ctx.getImageData(deviceRegisters[99],deviceRegisters[100],1,1)
        color = data[0]
        color << 5
        color = color & data[1]
        color << 5
        color = color & data[2]
        return color

class @E100

  constructor:(memoryWords) ->
    @memoryWords = memoryWords
    @memoryWords ?= 65536
    @deviceRegisters = new Int32Array 212
    @setPC 0
    @clearMemory()
    @display = new window.DisplayDriver()

  startRunning: () ->
    @clockCycle()

  driverLoop: () ->
    @display.clockTick(@deviceRegisters)


  clockCycle: () ->
    @driverLoop()
    currentPC = @getPC()
    opcode = @get(currentPC)
    addr0 = @get(currentPC+1)
    addr1 = @get currentPC + 2
    addr2 = @get currentPC + 3

    switch opcode
      when 0
        return
      when 1
        @add addr0, addr1, addr2
      when 2
        @sub addr0, addr1, addr2
      when 3
        @mult addr0, addr1, addr2
      when 4
        @div addr0, addr1, addr2
      when 5
        @cp addr0, addr1
      when 6
        @and addr0, addr1, addr2
      when 7
        @or addr0, addr1, addr2
      when 8
        @not addr0, addr1, addr2
      when 9
        @sl addr0, addr1, addr2
      when 10
        @sr addr0, addr1, addr2
      when 11
        @cpfa addr0, addr1, addr2
      when 12
        @cpta addr0, addr1, addr2
      when 13
        @be addr0, addr1, addr2
      when 14
        @bne addr0, addr1, addr2
      when 15
        @bne addr0, addr1, addr2
      when 16
        @call addr0, addr1
      when 17
        @call addr0, addr1
      when 18
        throw new Error("'in' instruction is deprecated")
      when 19
        throw new Error("'out' is totally out(lol deprecated)")

    @clockCycle()



  clearMemory: () ->
    @sram = new Int32Array @memoryWords

  set: (address, value) ->
    if address >= 0x80000000
      @deviceRegisters[address-0x80000000] = value
    else
      @sram[address] = value

  get: (address) ->
    if address >= 0x80000000
      return @deviceRegisters[address-0x80000000]
    @sram[address]


  setPC: (value) ->
    @pc = value

  getPC: () ->
    @pc

  incrementPC: () ->
    @pc += 4

  add: (addr0, addr1, addr2) ->
    @set(addr0, @get(addr1) + @get(addr2))
    @incrementPC()

  sub: (addr0, addr1, addr2) ->
    @set addr0, @get(addr1) - @get(addr2)
    @incrementPC()

  mult: (addr0, addr1, addr2) ->
    @set addr0, @get(addr1) * @get(addr2)
    @incrementPC()

  div: (addr0, addr1, addr2) ->
    @set addr0, @get(addr1) / @get(addr2)
    @incrementPC()

  cp: (addr0, addr1) ->
    @set addr0, @get(addr1)
    @incrementPC()

  and: (addr0, addr1, addr2) ->
    @set addr0, @get(addr1) & @get(addr2)
    @incrementPC()

  or: (addr0, addr1, addr2) ->
    @set addr0, @get(addr1) | @get(addr2)
    @incrementPC()

  not: (addr0, addr1) ->
    @set addr0, ~@get(addr1)
    @incrementPC()

  sl: (addr0, addr1, addr2) ->
    @set addr0, @get(addr1) << @get(addr2)
    @incrementPC()

  sr: (addr0, addr1, addr2) ->
    @set addr0, @get(addr1) >>> @get(addr2)
    @incrementPC()

  cpfa: (addr0, addr1, addr2) ->
    @set addr0, @get(addr1 + @get(addr2))
    @incrementPC()

  cpta: (addr0, addr1, addr2) ->
    @set (addr1 + @get(addr2)), @get(addr0)
    @incrementPC()

  be: (addr0, addr1, addr2) ->
    if @get(addr1) is @get(addr2)
      @setPC addr0
    else
      @incrementPC()

  bne: (addr0, addr1, addr2) ->
    if @get(addr1) isnt @get(addr2)
      @setPC addr0
    else
      @incrementPC()

  blt: (addr0, addr1, addr2) ->
    if @get(addr1) < @get(addr2)
      @setPC addr0
    else
      @incrementPC()

  call: (addr0, addr1) ->
    @incrementPC()
    @set(addr1, @getPC())
    @setPC addr0


  ret: (addr0) ->
    @setPC @get(addr0)

  testFunction: ->
    return "hello world"




