goog = goog or goog = require: ->

goog.require 'spark.core.Object'
goog.require 'goog.events'
goog.require 'goog.events.EventTarget'


describe 'spark.core.Object', ->

  it 'should set options passed to constructor', ->
    options = name: 'Fatih', age: 27
    object  = new spark.core.Object options

    expect(object.options).toBe options
    expect(object.options.name).toBe 'Fatih'


  it 'should set data passed to constructor', ->
    data   = name: 'Fatih', age: 27
    object = new spark.core.Object null, data

    expect(object.data).toBe data
    expect(object.data.name).toBe 'Fatih'
    expect(object.data.age).not.toBe 20


  it 'should set options with setOptions method', ->
    options = name: 'Fatih'
    object  = new spark.core.Object

    expect(object.options.name).toBeUndefined()

    object.setOptions options

    expect(object.options.name).toBe 'Fatih'


  it 'should set data with setData method', ->
    data   = name: 'Fatih'
    object = new spark.core.Object

    expect(object.data).toBeUndefined()

    object.setData data

    expect(object.data.name).toBe 'Fatih'


  it 'should get options with getOptions method', ->
    options = name: 'Fatih'
    object  = new spark.core.Object options

    expect(object.getOptions()).toBe options


  it 'should get an option with getOption method', ->
    options = name: 'Fatih'
    object  = new spark.core.Object options

    expect(object.getOption('name')).toBe 'Fatih'
    expect(object.getOption('age')).toBeNull()


  it 'should get data with getData method', ->
    data   = name: 'Fatih'
    object = new spark.core.Object null, data

    expect(object.getData()).toBe data


  it 'should return uid', ->
    object = new spark.core.Object

    expect(object.getUid()).toBeDefined()
    expect(typeof object.getUid()).toBe 'string'


  it 'should listen and fire events', ->
    object = new spark.core.Object
    value  = null
    data   = hello: 'world'

    object.on   'EventName', -> value = 12
    object.emit 'EventName'

    expect(value).toBe 12

    object.on   'AnotherEvent', (e) -> value = e.data
    object.emit 'AnotherEvent', data

    expect(value).toBe data


  it 'should listen and immediately unlisten the event if listened by once', ->
    object = new spark.core.Object
    value  = null

    object.on   'EventName', -> value = 12
    object.emit 'EventName'

    expect(value).toBe 12

    object.once 'AnotherEvent', -> value = 22
    object.emit 'AnotherEvent'

    expect(value).toBe 22

    object.emit 'EventName'
    expect(value).toBe 12

    object.emit 'AnotherEvent'
    expect(value).not.toBe 22
    expect(value).toBe 12


  it 'should unlisten event with off', ->
    object = new spark.core.Object
    value  = null
    cb     = -> value = 12

    object.on   'EventName', cb
    object.emit 'EventName'

    expect(value).toBe 12

    shouldNotUnlistened = object.off 'EventName' # cb is missing
    expect(shouldUnlistened).toBeFalsy()

    shouldUnlistened = object.off 'EventName', cb
    expect(shouldUnlistened).toBeTruthy()

  it 'should call multiple listeners', ->
    object  = new spark.core.Object
    results = []

    object.on 'Add', -> results.push 1
    object.on 'Add', -> results.push 2
    object.on 'Add', -> results.push 3

    object.emit 'Add'
    object.emit 'Add'

    expect(results.length).toEqual 6


  it 'should freeze Object', ->
    o = new spark.core.Object
    o.prop = 42
    o.freeze()
    o.prop = 43

    expect(o.prop).toBe 42


  it 'should be frozen when instantiated with frozen true in options', ->
    o = new spark.core.Object frozen: yes
    o.prop = 42

    expect(o.prop).toBeUndefined()


  describe 'destroy', ->

    it 'should be destroyable and return the destroyed state', ->

      o = new spark.core.Object
      expect(o.isDestroyed()).toBeFalsy()

      o.destroy()
      expect(o.isDestroyed()).toBeTruthy()


    it 'should set options and data to null', ->

      o = new spark.core.Object { hello: 'world' }, { uid: 12, name: 'acet' }

      expect(o.getData().uid).toBe 12
      expect(o.getOptions().hello).toBe 'world'

      o.destroy()

      expect(o.getData()).toBeNull()
      expect(o.getOptions()).toBeNull()


    it 'should emit events before and after destroy', ->
      flag = no
      obj  = new spark.core.Object

      obj.once 'Destroyed', -> flag = yes
      obj.destroy()

      expect(flag).toBeTruthy()


    it 'should unlisten all events', ->
      c = 0
      o = new spark.core.Object

      o.on 'event1', -> c++
      o.on 'event2', -> c++
      o.on 'event3', -> c++

      f1 = o.emit 'event1'
      f2 = o.emit 'event2'
      f3 = o.emit 'event3'

      expect(c).toBe 3
      expect(f1).toBeTruthy()
      expect(f2).toBeTruthy()
      expect(f3).toBeTruthy()

      o.destroy()

      f4 = o.emit 'event1'
      f5 = o.emit 'event2'
      f6 = o.emit 'event3'

      expect(c).toBe 3
      expect(f4).toBeFalsy()
      expect(f5).toBeFalsy()
      expect(f6).toBeFalsy()
