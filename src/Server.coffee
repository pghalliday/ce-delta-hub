zmq = require 'zmq'

module.exports = class Server
  constructor: (@options) ->
    @state = 
      nextSequence: 0
      accounts: Object.create null
    @ceFrontEnd = 
      stream: zmq.socket 'pub'
      state: zmq.socket 'router'
    @ceEngine = 
      stream: zmq.socket 'pull'
      state: zmq.socket 'dealer'
    @ceFrontEnd.stream.setsockopt 'linger', 0
    @ceFrontEnd.state.setsockopt 'linger', 0
    @ceFrontEnd.state.on 'message', (ref) =>
      # send the state
      @ceFrontEnd.state.send [ref, JSON.stringify @state]
    @ceEngine.stream.setsockopt 'linger', 0
    @ceEngine.state.setsockopt 'linger', 0
    @ceEngine.stream.on 'message', (message) =>
      @ceFrontEnd.stream.send message

  stop: (callback) =>
    @ceFrontEnd.stream.close()
    @ceFrontEnd.state.close()
    @ceEngine.stream.close()
    callback()

  start: (callback) =>
    @ceFrontEnd.stream.bind 'tcp://*:' + @options['ce-front-end'].stream, (error) =>
      if error
        callback error
      else
        @ceFrontEnd.state.bind 'tcp://*:' + @options['ce-front-end'].state, (error) =>
          if error
            @ceFrontEnd.stream.close()
            callback error
          else
            @ceEngine.stream.bind 'tcp://*:' + @options['ce-engine'].stream, (error) =>
              if error
                @ceFrontEnd.stream.close()
                @ceFrontEnd.state.close()
                callback error
              else
                @ceEngine.state.bind 'tcp://*:' + @options['ce-engine'].state, (error) =>
                  if error
                    @ceFrontEnd.stream.close()
                    @ceFrontEnd.state.close()
                    @ceEngine.stream.close()
                    callback error
                  else
                    callback()
