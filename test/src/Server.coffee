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
        'ce-engine':
          stream: ports()
      server.stop (error) ->
        expect(error).to.not.be.ok
        done()

  describe '#start', ->
    it 'should start and be stoppable', (done) ->
      server = new Server
        'ce-front-end':
          stream: ports()
          state: ports()
        'ce-engine':
          stream: ports()
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
        'ce-engine':
          stream: ports()
      server.start (error) ->
        error.message.should.equal 'Invalid argument'
        done()

    it 'should error if it cannot bind to ce-front-end state port', (done) ->
      server = new Server
        'ce-front-end':
          stream: ports()
          state: 'invalid'
        'ce-engine':
          stream: ports()
      server.start (error) ->
        error.message.should.equal 'Invalid argument'
        done()

    it 'should error if it cannot bind to ce-engine stream port', (done) ->
      server = new Server
        'ce-front-end':
          stream: ports()
          state: ports()
        'ce-engine':
          stream: 'invalid'
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
      @ceEngine = 
        stream: zmq.socket 'push'
      ceEngineStreamPort = ports()
      @server = new Server
        'ce-front-end':
          stream: ceFrontEndStreamPort
          state: ceFrontEndStatePort
        'ce-engine':
          stream: ceEngineStreamPort
      @server.start (error) =>
        @ceFrontEnd.stream.connect 'tcp://localhost:' + ceFrontEndStreamPort
        @ceFrontEnd.state.connect 'tcp://localhost:' + ceFrontEndStatePort
        @ceEngine.stream.connect 'tcp://localhost:' + ceEngineStreamPort
        done()

    afterEach (done) ->
      @ceFrontEnd.stream.close()
      @ceFrontEnd.state.close()
      @server.stop done

    it 'should respond to requests with the current market state', (done) ->
      @ceFrontEnd.state.on 'message', (message) =>
        state = JSON.parse message
        state.nextSequence.should.equal 0
        state.accounts.should.be.an 'object'
        done()
      @ceFrontEnd.state.send ''

    it 'should publish deltas received from ce-engine instances', (done) ->
      @ceFrontEnd.stream.on 'message', (message) =>
        delta = JSON.parse message
        delta.sequence.should.equal 0
        operation = delta.operation
        operation.account.should.equal 'Peter'
        operation.sequence.should.equal 0
        operation.result.should.equal 'success'
        deposit = operation.deposit
        deposit.currency.should.equal 'EUR'
        deposit.amount.should.equal '5000'
        done()
      @ceEngine.stream.send JSON.stringify
        sequence: 0
        operation: 
          account: 'Peter'
          sequence: 0
          result: 'success'
          deposit:
            currency: 'EUR'
            amount: '5000'     
