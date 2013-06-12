Server = require './Server'
nconf = require 'nconf'

# load configuration
nconf.argv()
config = nconf.get 'config'
if config
  nconf.file
    file: config
ceFrontEndPublisher = nconf.get 'ce-front-end-publisher'
ceFrontEndXReply = nconf.get 'ce-front-end-xreply'

server = new Server
  ceFrontEndPublisher: ceFrontEndPublisher
  ceFrontEndXReply: ceFrontEndXReply

server.start (error) ->
  if error
    console.log error
  else
    console.log 'ce-delta-hub started'
    console.log '\tceFrontEndPublisher: ' + ceFrontEndPublisher
    console.log '\tceFrontEndXReply: ' + ceFrontEndXReply
