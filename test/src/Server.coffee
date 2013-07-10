chai = require 'chai'
chai.should()
expect = chai.expect

Server = require '../../src/Server'

zmq = require 'zmq'
ports = require '../support/ports'

State = require('currency-market').State
Engine = require('currency-market').Engine
Delta = require('currency-market').Delta
Operation = require('currency-market').Operation
Amount = require('currency-market').Amount

COMMISSION_ACCOUNT = 'commission'
COMMISSION_RATE = new Amount '0.001'
COMMISSION_REFERENCE = '0.1%'

describe 'Server', ->
  describe '#stop', ->
    it 'should not error if the server has not been started', (done) ->
      server = new Server
        commission:
          account: COMMISSION_ACCOUNT
        'ce-front-end':
          stream: ports()
          state: ports()
        'ce-engine':
          stream: ports()
          state: ports()
      server.stop (error) ->
        expect(error).to.not.be.ok
        done()

  describe '#start', ->
    it 'should start and be stoppable', (done) ->
      server = new Server
        commission:
          account: COMMISSION_ACCOUNT
        'ce-front-end':
          stream: ports()
          state: ports()
        'ce-engine':
          stream: ports()
          state: ports()
      server.start (error) ->
        expect(error).to.not.be.ok
        server.stop (error) ->
          expect(error).to.not.be.ok
          done()

    it 'should error if it cannot bind to ce-front-end stream port', (done) ->
      server = new Server
        commission:
          account: COMMISSION_ACCOUNT
        'ce-front-end':
          stream: 'invalid'
          state: ports()
        'ce-engine':
          stream: ports()
          state: ports()
      server.start (error) ->
        error.message.should.equal 'Invalid argument'
        done()

    it 'should error if it cannot bind to ce-front-end state port', (done) ->
      server = new Server
        commission:
          account: COMMISSION_ACCOUNT
        'ce-front-end':
          stream: ports()
          state: 'invalid'
        'ce-engine':
          stream: ports()
          state: ports()
      server.start (error) ->
        error.message.should.equal 'Invalid argument'
        done()

    it 'should error if it cannot bind to ce-engine stream port', (done) ->
      server = new Server
        commission:
          account: COMMISSION_ACCOUNT
        'ce-front-end':
          stream: ports()
          state: ports()
        'ce-engine':
          stream: 'invalid'
          state: ports()
      server.start (error) ->
        error.message.should.equal 'Invalid argument'
        done()

    it 'should error if it cannot bind to ce-engine state port', (done) ->
      server = new Server
        commission:
          account: COMMISSION_ACCOUNT
        'ce-front-end':
          stream: ports()
          state: ports()
        'ce-engine':
          stream: ports()
          state: 'invalid'
      server.start (error) ->
        error.message.should.equal 'Invalid argument'
        done()

  describe 'when started', ->
    beforeEach (done) ->
      @engine = new Engine
        commission:
          account: COMMISSION_ACCOUNT
          calculate: (params) ->
            amount: params.amount.multiply COMMISSION_RATE
            reference: COMMISSION_REFERENCE
      @ceFrontEnd = 
        stream: zmq.socket 'sub'
        state: zmq.socket 'dealer'
      @ceFrontEnd.stream.subscribe ''
      ceFrontEndStreamPort = ports()
      ceFrontEndStatePort = ports()
      @ceEngine = 
        stream: zmq.socket 'push'
        state: zmq.socket 'router'
      ceEngineStreamPort = ports()
      ceEngineStatePort = ports()
      @server = new Server
        commission:
          account: COMMISSION_ACCOUNT
        'ce-front-end':
          stream: ceFrontEndStreamPort
          state: ceFrontEndStatePort
        'ce-engine':
          stream: ceEngineStreamPort
          state: ceEngineStatePort
      @server.start (error) =>
        @ceFrontEnd.stream.connect 'tcp://localhost:' + ceFrontEndStreamPort
        @ceFrontEnd.state.connect 'tcp://localhost:' + ceFrontEndStatePort
        @ceEngine.stream.connect 'tcp://localhost:' + ceEngineStreamPort
        @ceEngine.state.connect 'tcp://localhost:' + ceEngineStatePort
        done()

    afterEach (done) ->
      @ceFrontEnd.stream.close()
      @ceFrontEnd.state.close()
      @ceEngine.stream.close()
      @ceEngine.state.close()
      @server.stop done

    it 'should respond to requests with the current market state', (done) ->
      @ceFrontEnd.state.on 'message', (message) =>
        state = new State
          json: message
        state.nextDeltaSequence.should.equal 0
        state.accounts.should.be.an 'object'
        state.books.should.be.an 'object'
        done()
      @ceFrontEnd.state.send ''

    it 'should publish deltas received from ce-engine instances', (done) ->
      @ceFrontEnd.stream.on 'message', (message) =>
        delta = new Delta
          json: message
        delta.sequence.should.equal 0
        operation = delta.operation
        operation.account.should.equal 'Peter'
        operation.sequence.should.equal 0
        deposit = operation.deposit
        deposit.currency.should.equal 'EUR'
        deposit.amount.compareTo(new Amount '5000').should.equal 0
        result = delta.result
        result.funds.compareTo(new Amount '5000').should.equal 0
        done()
      operation = new Operation
        reference: '550e8400-e29b-41d4-a716-446655440000'
        account: 'Peter'
        deposit:
          currency: 'EUR'
          amount: new Amount '5000'
      operation.accept
        sequence: 0
        timestamp: Date.now()
      @ceEngine.stream.send JSON.stringify @engine.apply operation
