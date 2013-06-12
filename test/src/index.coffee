chai = require 'chai'
chai.should()
expect = chai.expect

ChildDaemon = require 'child-daemon'
zmq = require 'zmq'

describe 'ce-operation-hub', ->
  describe 'on start', ->
    beforeEach ->
      @ceFrontEndXRequest = zmq.socket 'xreq'
      @ceFrontEndSubscriber = zmq.socket 'sub'
      @ceFrontEndSubscriber.subscribe ''

    afterEach ->
      @ceFrontEndXRequest.close()
      @ceFrontEndSubscriber.close()

    it 'should take parameters from a file', (done) ->
      this.timeout 5000
      childDaemon = new ChildDaemon 'node', [
        'lib/src/index.js',
        '--config',
        'test/support/testConfig.json'
      ], new RegExp 'ce-delta-hub started'
      childDaemon.start (error, matched) =>
        expect(error).to.not.be.ok
        @ceFrontEndSubscriber.connect 'tcp://localhost:8000'
        @ceFrontEndXRequest.connect 'tcp://localhost:8001'
        @ceFrontEndXRequest.on 'message', (message) =>
          state = JSON.parse message
          state.nextId.should.equal 0
          state.accounts.should.be.an 'object'
          childDaemon.stop (error) =>
            expect(error).to.not.be.ok
            done()
        @ceFrontEndXRequest.send ''
