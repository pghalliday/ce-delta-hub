ce-delta-hub
============

[![Build Status](https://travis-ci.org/pghalliday/ce-delta-hub.png?branch=master)](https://travis-ci.org/pghalliday/ce-delta-hub)
[![Dependency Status](https://gemnasium.com/pghalliday/ce-delta-hub.png)](https://gemnasium.com/pghalliday/ce-delta-hub)

Nexus for receiving currency exchange state deltas from ce-engine instances and forwarding them to ce-front-end instances.


## Configuration

configuration should be placed in a file called `config.json` in the root of the project

```javascript
{
  // Deposits commission payments into this account ID
  "commission": {
    "account": "commission"
  },
  // Supplies the current market state and streams deltas to `ce-front-end` instances
  "ce-front-end": {
    // Port for 0MQ `pub` socket 
    "stream": 7000,
    // Port for 0MQ `router` socket 
    "state": 7001
  },
  // Requests current market state and listens for deltas from `ce-engine` instances
  "ce-engine": {
    // Port for 0MQ `pull` socket 
    "stream": 7002,
    // Port for 0MQ `dealer` socket 
    "state": 7003
  }
}
```

## Starting and stopping the server

Forever is used to keep the server running as a daemon and can be called through npm as follows

```
$ npm start
$ npm stop
```

Output will be logged to the following files

- `~/.forever/forever.log` Forever output
- `./out.log` stdout
- `./err.log` stderr

## API

### State

The following format is used to transmit the state to `ce-front-end` instances that request it using an empty request to the `state` socket

```javacript
```

### Deltas

All deltas follow this format

```javascript
{
  "sequence": 1234567890
  "operation": {
    // operation parameters
    ...
  },
  "result": {
    // result parameters
    ...
  }
}
```

Where the `sequence` must be sequential. Seen `sequence`s will be ignored, unseen `sequence`s will be applied once the internal state has caught up.
As the same deltas will be received from multiple `ce-engine` instances, only 1 of each delta will be forwarded to the `ce-front-end` instances.

The following deltas are supported and will be forwarded.

#### `deposit`

On successful deposit

```javascript
{
  "sequence": 1234567890,
  "operation": {
    "reference": "550e8400-e29b-41d4-a716-446655440000",
    "account": "Peter",
    "sequence": 9876543210,
    "timestamp": 1371737390976,
    "result": "success",
    "deposit": {
      "currency": "EUR",
      "amount": "5000"
    }
  }
}
```

#### `submit`

On a successfully submitted order

```javascript
{
  "sequence": 1234567890,
  "operation": {
    "reference": "550e8400-e29b-41d4-a716-446655440000",
    "account": "Peter",
    "sequence": 9876543210,
    "timestamp": 1371737390976,
    "result": "success",
    "submit": {
      "bidCurrency": "BTC",
      "offerCurrency": "EUR",
      "bidPrice": "100",
      "bidAmount": "50"
    }
  }
}
```

## Roadmap

### Deltas

#### `withdraw`

On successful withdrawal

```javascript
{
  "sequence": 1234567890,
  "operation": {
    "reference": "550e8400-e29b-41d4-a716-446655440000",
    "account": "Peter",
    "sequence": 9876543210,
    "timestamp": 1371737390976,
    "result": "success",
    "withdraw": {
      "currency": "EUR",
      "amount": "5000"
    }
  }
}
```

#### `cancel`

On successfully cancelled order

```javascript
{
  "sequence": 1234567890,
  "operation": {
    "reference": "550e8400-e29b-41d4-a716-446655440000",
    "account": "Peter",
    "sequence": 9876543210,
    "timestamp": 1371737390976,
    "result": "success",
    "cancel": {
      "sequence": 64523428495
    }
  }
}
```

#### `trade`

On trade execution

```javascript
{
  "sequence": 1234567890,
  "trade": {
    ?
  }
}
```

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Test your code using: 

```
$ npm test
```

### Using Vagrant
To use the Vagrantfile you will also need to install the following vagrant plugins

```
$ vagrant plugin install vagrant-omnibus
$ vagrant plugin install vagrant-berkshelf
```

The cookbook used by vagrant is located in a git submodule so you will have to intialise that after cloning

```
$ git submodule init
$ git submodule update
```

## License
Copyright &copy; 2013 Peter Halliday  
Licensed under the MIT license.
