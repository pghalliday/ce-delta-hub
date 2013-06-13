zmq = require 'zmq'

module.exports = class Server
  constructor: (@options) ->
    @state = 
      nextId: 0
      accounts: Object.create null
    @ceFrontEndPublisher = zmq.socket 'pub'
    @ceFrontEndPublisher.setsockopt 'linger', 0
    @ceFrontEndXReply = zmq.socket 'xrep'
    @ceFrontEndXReply.setsockopt 'linger', 0
    @ceFrontEndXReply.on 'message', =>
      args = Array.apply null, arguments
      # send the state
      args[1] = JSON.stringify @state
      @ceFrontEndXReply.send args

  stop: (callback) =>
    @ceFrontEndPublisher.close()
    @ceFrontEndXReply.close()
    callback()

  start: (callback) =>
    @ceFrontEndPublisher.bind 'tcp://*:' + @options.ceFrontEndPublisher, (error) =>
      if error
        callback error
      else
        @ceFrontEndXReply.bind 'tcp://*:' + @options.ceFrontEndXReply, (error) =>
          if error
            @ceFrontEndPublisher.close()
            callback error
          else
            callback()
