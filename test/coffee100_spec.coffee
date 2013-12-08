require('displayDriver.js')
describe "E100", ->
  describe "Instruction Tests", ->
    e100 = null
    beforeEach ->
      e100 = new E100(500)
      e100.set(0,5)
      e100.set(1,2)
    it "should add correctly", ->
      e100.add 2, 1, 0
      expect(e100.get 2).toBe 7
    it "should subtract correctly", ->
      e100.sub 2, 1, 0
      expect(e100.get 2).toBe -3
    it "should multiply correctly", ->
      e100.mult 2, 1, 0
      expect(e100.get 2).toBe 10
    it "should divide correctly", ->
      e100.div 2, 1, 0
      expect(e100.get 2).toBe 0
    it "should copy correctly", ->
      e100.cp 2, 1
      expect(e100.get 2).toBe 2
    it "should 'and' correctly", ->
      e100.and 2, 1, 0
      expect(e100.get 2).toBe 2 & 5
    it "should 'or' correctly", ->
      e100.or 2, 1, 0
      expect(e100.get 2).toBe 2 | 5
    it "should 'not' correctly", ->
      e100.not 2, 1
      expect(e100.get 2).toBe ~2
    it "should left shift correctly", ->
      e100.sl 2, 1, 0
      expect(e100.get 2).toBe 2 << 5
    it "should right shift correctly", ->
      e100.sr 2, 1, 0
      expect(e100.get 2).toBe 2 >>> 5
    it "should cpfa?? lolol correctly", ->
      e100.set(6, 40)
      e100.cpfa 2, 1, 0
      expect(e100.get 2).toBe 40
    it "should cpta?? lolol  correctly", ->
      e100.set(2,3)
      e100.cpta 2, 1, 0
      expect(e100.get 6).toBe 3
    it "should be correctly", ->
      e100.be 2, 1, 0
      expect(e100.getPC()).toBe 4
    it "should bne correctly", ->
      e100.bne 2, 1, 0
      expect(e100.getPC()).toBe 2
    it "should 'blt' (less than?) correctly", ->
      e100.blt 2, 1, 0
      expect(e100.getPC()).toBe 2
    it "should call correctly", ->
      e100.call 1, 0
      expect(e100.getPC()).toBe 1
      expect(e100.get 0 ).toBe 4
    it "should ret correctly", ->
      e100.ret 1
      expect(e100.getPC()).toBe 2

