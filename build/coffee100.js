(function() {
  this.DisplayDriver = (function() {
    function DisplayDriver() {
      var _ref;
      this.c = document.getElementById("coffee100Canvas");
      this.ctx = (_ref = this.c) != null ? _ref.getContext("2d") : void 0;
      this.width = 640;
      this.height = 480;
    }

    DisplayDriver.prototype.drawRectangle = function(r, g, b, x1, y1, x2, y2) {
      this.ctx.fillStyle = "rgb(" + (r * 8) + "," + (g * 8) + "," + (b * 8) + ")";
      return this.ctx.fillRect(x1, y1, x2, y2);
    };

    DisplayDriver.prototype.randomizeScreen = function() {
      var b, g, r, x, y, _i, _ref, _results;
      _results = [];
      for (x = _i = 0, _ref = this.width - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
        _results.push((function() {
          var _j, _ref1, _results1;
          _results1 = [];
          for (y = _j = 0, _ref1 = this.height - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
            r = Math.floor(Math.random() * 31);
            g = Math.floor(Math.random() * 31);
            b = Math.floor(Math.random() * 31);
            _results1.push(this.drawRectangle(r, g, b, x, y, x, y));
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    DisplayDriver.prototype.clockTick = function(deviceRegisters) {
      var b, color, command, data, g, r, rawColor, response, x1, x2, y1, y2;
      command = deviceRegisters[96];
      response = deviceRegisters[97];
      if (command === 0 && response === 0) {

      } else if (command === 1 && response === 1) {

      } else if (command === 0 && response === 1) {
        deviceRegisters[97] = 0;
      } else {
        if (deviceRegisters[98] === 1) {
          x1 = deviceRegisters[99];
          y1 = deviceRegisters[100];
          x2 = deviceRegisters[101];
          y2 = deviceRegisters[102];
          rawColor = deviceRegisters[103];
          r = (rawColor >>> 10) & 31;
          g = (rawColor >>> 5) & 31;
          b = rawColor & 31;
          return this.drawRectangle(r, g, b, x1, y1, x2, y2);
        } else {
          data = this.ctx.getImageData(deviceRegisters[99], deviceRegisters[100], 1, 1);
          color = data[0];
          color << 5;
          color = color & data[1];
          color << 5;
          color = color & data[2];
          return color;
        }
      }
    };

    return DisplayDriver;

  })();

  this.E100 = (function() {
    function E100(memoryWords) {
      this.memoryWords = memoryWords;
      if (this.memoryWords == null) {
        this.memoryWords = 65536;
      }
      this.deviceRegisters = new Int32Array(212);
      this.setPC(0);
      this.clearMemory();
      this.display = new window.DisplayDriver();
    }

    E100.prototype.startRunning = function() {
      var hasHalted;
      hasHalted = false;
      while (!hasHalted) {
        hasHalted = this.clockCycle();
      }
    };

    E100.prototype.driverLoop = function() {
      return this.display.clockTick(this.deviceRegisters);
    };

    E100.prototype.clockCycle = function() {
      var addr0, addr1, addr2, currentPC, opcode;
      this.driverLoop();
      currentPC = this.getPC();
      opcode = this.get(currentPC);
      addr0 = this.get(currentPC + 1);
      addr1 = this.get(currentPC + 2);
      addr2 = this.get(currentPC + 3);
      switch (opcode) {
        case 0:
          this.halt;
          return true;
        case 1:
          this.add(addr0, addr1, addr2);
          break;
        case 2:
          this.sub(addr0, addr1, addr2);
          break;
        case 3:
          this.mult(addr0, addr1, addr2);
          break;
        case 4:
          this.div(addr0, addr1, addr2);
          break;
        case 5:
          this.cp(addr0, addr1);
          break;
        case 6:
          this.and(addr0, addr1, addr2);
          break;
        case 7:
          this.or(addr0, addr1, addr2);
          break;
        case 8:
          this.not(addr0, addr1, addr2);
          break;
        case 9:
          this.sl(addr0, addr1, addr2);
          break;
        case 10:
          this.sr(addr0, addr1, addr2);
          break;
        case 11:
          this.cpfa(addr0, addr1, addr2);
          break;
        case 12:
          this.cpta(addr0, addr1, addr2);
          break;
        case 13:
          this.be(addr0, addr1, addr2);
          break;
        case 14:
          this.bne(addr0, addr1, addr2);
          break;
        case 15:
          this.bne(addr0, addr1, addr2);
          break;
        case 16:
          this.call(addr0, addr1);
          break;
        case 17:
          this.call(addr0, addr1);
          break;
        case 18:
          throw new Error("'in' instruction is deprecated");
          break;
        case 19:
          throw new Error("'out' is totally out(lol deprecated)");
      }
      return false;
    };

    E100.prototype.clearMemory = function() {
      return this.sram = new Int32Array(this.memoryWords);
    };

    E100.prototype.set = function(address, value) {
      if (address <= -2147483437) {
        return this.deviceRegisters[address + 2147483648] = value;
      } else {
        return this.sram[address] = value;
      }
    };

    E100.prototype.get = function(address) {
      if (address <= -2147483437) {
        console.log("Reading device address " + (address + 2147483648));
        return this.deviceRegisters[address + 2147483648];
      }
      return this.sram[address];
    };

    E100.prototype.setPC = function(value) {
      return this.pc = value;
    };

    E100.prototype.getPC = function() {
      return this.pc;
    };

    E100.prototype.incrementPC = function() {
      return this.pc += 4;
    };

    E100.prototype.halt = function() {
      return this.incrementPC();
    };

    E100.prototype.add = function(addr0, addr1, addr2) {
      this.set(addr0, this.get(addr1) + this.get(addr2));
      return this.incrementPC();
    };

    E100.prototype.sub = function(addr0, addr1, addr2) {
      this.set(addr0, this.get(addr1) - this.get(addr2));
      return this.incrementPC();
    };

    E100.prototype.mult = function(addr0, addr1, addr2) {
      this.set(addr0, this.get(addr1) * this.get(addr2));
      return this.incrementPC();
    };

    E100.prototype.div = function(addr0, addr1, addr2) {
      this.set(addr0, this.get(addr1) / this.get(addr2));
      return this.incrementPC();
    };

    E100.prototype.cp = function(addr0, addr1) {
      this.set(addr0, this.get(addr1));
      return this.incrementPC();
    };

    E100.prototype.and = function(addr0, addr1, addr2) {
      this.set(addr0, this.get(addr1) & this.get(addr2));
      return this.incrementPC();
    };

    E100.prototype.or = function(addr0, addr1, addr2) {
      this.set(addr0, this.get(addr1) | this.get(addr2));
      return this.incrementPC();
    };

    E100.prototype.not = function(addr0, addr1) {
      this.set(addr0, ~this.get(addr1));
      return this.incrementPC();
    };

    E100.prototype.sl = function(addr0, addr1, addr2) {
      this.set(addr0, this.get(addr1) << this.get(addr2));
      return this.incrementPC();
    };

    E100.prototype.sr = function(addr0, addr1, addr2) {
      this.set(addr0, this.get(addr1) >>> this.get(addr2));
      return this.incrementPC();
    };

    E100.prototype.cpfa = function(addr0, addr1, addr2) {
      this.set(addr0, this.get(addr1 + this.get(addr2)));
      return this.incrementPC();
    };

    E100.prototype.cpta = function(addr0, addr1, addr2) {
      this.set(addr1 + this.get(addr2), this.get(addr0));
      return this.incrementPC();
    };

    E100.prototype.be = function(addr0, addr1, addr2) {
      if (this.get(addr1) === this.get(addr2)) {
        return this.setPC(addr0);
      } else {
        return this.incrementPC();
      }
    };

    E100.prototype.bne = function(addr0, addr1, addr2) {
      if (this.get(addr1) !== this.get(addr2)) {
        return this.setPC(addr0);
      } else {
        return this.incrementPC();
      }
    };

    E100.prototype.blt = function(addr0, addr1, addr2) {
      if (this.get(addr1) < this.get(addr2)) {
        return this.setPC(addr0);
      } else {
        return this.incrementPC();
      }
    };

    E100.prototype.call = function(addr0, addr1) {
      this.incrementPC();
      this.set(addr1, this.getPC());
      return this.setPC(addr0);
    };

    E100.prototype.ret = function(addr0) {
      return this.setPC(this.get(addr0));
    };

    E100.prototype.testFunction = function() {
      return "hello world";
    };

    return E100;

  })();

}).call(this);
