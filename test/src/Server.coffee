chai = require 'chai'
chai.should()
expect = chai.expect

Server = require '../../src/Server'

zmq = require 'zmq'
ports = require '../support/ports'

describe 'Server', ->
  describe '#stop', ->
    it 'should not error if the server has not been started', (done) ->
      server = new Server
        'ce-front-end':
          stream: ports()
          state: ports()
      server.stop (error) ->
        expect(error).to.not.be.ok
        done()

  describe '#start', ->
    it 'should start and be stoppable', (done) ->
      server = new Server
        'ce-front-end':
          stream: ports()
          state: ports()
      server.start (error) ->
        expect(error).to.not.be.ok
        server.stop (error) ->
          expect(error).to.not.be.ok
          done()

    it 'should error if it cannot bind to ce-front-end stream port', (done) ->
      server = new Server
        'ce-front-end':
          stream: 'invalid'
          state: ports()
      server.start (error) ->
        error.message.should.equal 'Invalid argument'
        done()

    it 'should error if it cannot bind to ce-front-end state port', (done) ->
      server = new Server
        'ce-front-end':
          stream: ports()
          state: 'invalid'
      server.start (error) ->
        error.message.should.equal 'Invalid argument'
        done()

  describe 'when started', ->
    beforeEach (done) ->
      @ceFrontEnd = 
        stream: zmq.socket 'sub'
        state: zmq.socket 'xreq'
      @ceFrontEnd.stream.subscribe ''
      ceFrontEndStreamPort = ports()
      ceFrontEndStatePort = ports()
      @server = new Server
        'ce-front-end':
          stream: ceFrontEndStreamPort
          state: ceFrontEndStatePort
      @server.start (error) =>
        @ceFrontEnd.stream.connect 'tcp://localhost:' + ceFrontEndStreamPort
        @ceFrontEnd.state.connect 'tcp://localhost:' + ceFrontEndStatePort
        done()

    afterEach (done) ->
      @ceFrontEnd.stream.close()
      @ceFrontEnd.state.close()
      @server.stop done

    it 'should respond to requests with the current market state', (done) ->
      @ceFrontEnd.state.on 'message', (message) =>
        state = JSON.parse message
        state.nextId.should.equal 0
        state.accounts.should.be.an 'object'
        done()
      @ceFrontEnd.state.send ''
