zmq = require 'zmq'

module.exports = class Server
  constructor: (@options) ->
    @state = 
      nextId: 0
      accounts: Object.create null
    @ceFrontEnd = 
      stream: zmq.socket 'pub'
      state: zmq.socket 'xrep'
    @ceFrontEnd.stream.setsockopt 'linger', 0
    @ceFrontEnd.state.setsockopt 'linger', 0
    @ceFrontEnd.state.on 'message', =>
      args = Array.apply null, arguments
      # send the state
      args[1] = JSON.stringify @state
      @ceFrontEnd.state.send args

  stop: (callback) =>
    @ceFrontEnd.stream.close()
    @ceFrontEnd.state.close()
    callback()

  start: (callback) =>
    @ceFrontEnd.stream.bind 'tcp://*:' + @options['ce-front-end'].stream, (error) =>
      if error
        callback error
      else
        @ceFrontEnd.state.bind 'tcp://*:' + @options['ce-front-end'].state, (error) =>
          if error
            @ceFrontEnd.state.close()
            callback error
          else
            callback()
