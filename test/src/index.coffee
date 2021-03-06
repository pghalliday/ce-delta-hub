chai = require 'chai'
chai.should()
expect = chai.expect

ChildDaemon = require 'child-daemon'
zmq = require 'zmq'

State = require('currency-market').State

describe 'ce-delta-hub', ->
  it 'should take parameters from a file', (done) ->
    this.timeout 5000
    ceFrontEnd = 
      stream: zmq.socket 'sub'
      state: zmq.socket 'dealer'
    ceFrontEnd.stream.subscribe ''
    childDaemon = new ChildDaemon 'node', [
      'lib/src/index.js',
      '--config',
      'test/support/testConfig.json'
    ], new RegExp 'ce-delta-hub started'
    childDaemon.start (error, matched) =>
      expect(error).to.not.be.ok
      ceFrontEnd.stream.connect 'tcp://localhost:7000'
      ceFrontEnd.state.connect 'tcp://localhost:7001'
      ceFrontEnd.state.on 'message', (message) =>
        state = new State
          json: message
        state.nextDeltaSequence.should.equal 0
        state.accounts.should.be.an 'object'
        state.books.should.be.an 'object'
        childDaemon.stop (error) =>
          expect(error).to.not.be.ok
          ceFrontEnd.stream.close()
          ceFrontEnd.state.close()
          done()
      ceFrontEnd.state.send ''
