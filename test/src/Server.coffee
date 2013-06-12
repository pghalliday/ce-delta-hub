chai = require 'chai'
chai.should()
expect = chai.expect

Server = require '../../src/Server'

zmq = require 'zmq'

describe 'Server', ->
  describe '#stop', ->
    it 'should not error if the server has not been started', (done) ->
      server = new Server
        ceFrontEndPublisher: '8000'
        ceFrontEndXReply: '8001'
      server.stop (error) ->
        expect(error).to.not.be.ok
        done()

  describe '#start', ->
    it 'should start and be stoppable', (done) ->
      server = new Server
        ceFrontEndPublisher: '8000'
        ceFrontEndXReply: '8001'
      server.start (error) ->
        expect(error).to.not.be.ok
        server.stop (error) ->
          expect(error).to.not.be.ok
          done()

    it 'should error if it cannot bind to ceFrontEndXReply address', (done) ->
      server = new Server
        ceFrontEndPublisher: '8000'
        ceFrontEndXReply: 'invalid'
      server.start (error) ->
        error.message.should.equal 'Invalid argument'
        done()

    it 'should error if it cannot bind to ceFrontEndPublisher address', (done) ->
      server = new Server
        ceFrontEndPublisher: 'invalid'
        ceFrontEndXReply: '8001'
      server.start (error) ->
        error.message.should.equal 'Invalid argument'
        done()

  describe 'when started', ->
    beforeEach (done) ->
      @ceFrontEndXRequest = zmq.socket 'xreq'
      @ceFrontEndSubscriber = zmq.socket 'sub'
      @ceFrontEndSubscriber.subscribe ''
      @server = new Server
        ceFrontEndPublisher: '8000'
        ceFrontEndXReply: '8001'
      @server.start (error) =>
        @ceFrontEndSubscriber.connect 'tcp://localhost:8000'
        @ceFrontEndXRequest.connect 'tcp://localhost:8001'
        done()

    afterEach (done) ->
      @ceFrontEndXRequest.close()
      @ceFrontEndSubscriber.close()
      @server.stop done

    it 'should respond to requests with the current market state', (done) ->
      @ceFrontEndXRequest.on 'message', (message) =>
        state = JSON.parse message
        state.nextId.should.equal 0
        state.accounts.should.be.an 'object'
        done()
      @ceFrontEndXRequest.send ''
