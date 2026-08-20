const XMLHttpRequest = require('xhr2');
const { HelloServiceClient } = require('./hello_grpc_web_pb');
const { HelloRequest } = require('./hello_pb');

global.XMLHttpRequest = XMLHttpRequest;

function sayHello(){
  const client = new HelloServiceClient('http://127.0.0.1:9080/grpc/web', null, {
    format: 'text',
  });
  const req = new HelloRequest();
  req.setGreeting('jack');

  const call = client.sayHello(req, {}, (err, resp) => {
    if (err) {
      console.error('grpc error:', err.code, err.message);
    } else {
      console.log('reply:', resp.getReply());
    }
  });

  call.on('metadata', (metadata) => {
    console.log('Response headers:', metadata);
  });
}

function lotsOfReplies() {
  const client = new HelloServiceClient('http://127.0.0.1:9080/grpc/web', null, {
    format: 'text',
  });
  const req = new HelloRequest();
  req.setGreeting('rep');
  const stream = client.lotsOfReplies(req, {});

  stream.on('metadata', (metadata) => {
    console.log('Response headers:', metadata);
  });

  stream.on('data', (response) => {
    console.log('Reply:', response.getReply());
  });

  stream.on('end', () => {
    console.log('Stream ended');
  });

  stream.on('error', (err) => {
    console.error('Error:', err);
  });
}

lotsOfReplies()
sayHello()