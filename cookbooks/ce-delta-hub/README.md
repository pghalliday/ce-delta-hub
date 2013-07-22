cookbook-ce-delta-hub
=====================

Chef cookbook to install and start a ce-delta-hub instance

## Depends

- nodejs
- git
- zeromq (https://github.com/pghalliday/cookbook-zeromq.git)

## Attributes

Attributes are specified under the `ce_delta_hub` keyspace.

- `node[:ce_delta_hub][:repository]` - the Git repository to install `ce-delta-hub` from (defaults to "https://github.com/pghalliday/ce-delta-hub.git")
- `node[:ce_delta_hub][:destination]` - the directory to install `ce-delta-hub` to (defaults to "/opt/ce-delta-hub")
- `node[:ce_delta_hub][:user]` - the user to install and start `ce-delta-hub` as (defaults to "ce-delta-hub")
- `node[:ce_delta_hub][:commission][:account]` - the accoutn ID of the account to receive commission payments (defaults to "commission")
- `node[:ce_delta_hub][:ce_front_end][:stream]` - the port to bind the `ce-delta-hub` to publish market state deltas to `ce-front-end` instances (defaults to "5000")
- `node[:ce_delta_hub][:ce_front_end][:state]` - the port to bind the `ce-delta-hub` to respond to state requests from `ce-front-end` instances (defaults to "5001")
- `node[:ce_delta_hub][:ce_engine][:stream]` - the port to bind the `ce-delta-hub` to receive to deltas streamed from `ce-engine` instances (defaults to "5002")
- `node[:ce_delta_hub][:ce_engine][:state]` - the port to bind the `ce-delta-hub` to make state requests to `ce-engine` instances (defaults to "5003")

## Recipes

### default

- Installs `ce-delta-hub`
- Runs npm install to get dependencies
- Runs npm start to start the `ce-delta-hub`

## License
Copyright &copy; 2013 Peter Halliday  
Licensed under the MIT license.
