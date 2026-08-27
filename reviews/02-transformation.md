# Transformation

Category reference: https://apisix.apache.org/plugins/#Transformation

Plugins reviewed in this category: `proxy-rewrite`, `grpc-transcode`, `grpc-web`, `fault-injection`, `mocking`.

[⬅ Back to progress overview](../README.md)

---

## Proxy Rewrite
It's a plugin to rewrite requests that APISIX forwards to Upstream services. With it, we can finally access the certain path or location from Upstream services. We can also modify the methods, request destination Upstream addresses, request headers, and more.

### Configuration
![Proxy Rewrite Configuration](../documentation/20260819/gzip-configuration.png)
### Test Result
- Before
Only access the default location of nginx
![Before Proxy Rewrite](../documentation/20260819/proxy-rewrite-before.png)
- After
Access the specific location of nginx
![After Proxy Rewrite](../documentation/20260819/gzip-before.png)

## gRPC
gRPC stands for Google Remote Procedure Call. Was created in 2015 with plan to change or be an alternative from traditional REST, especially to communicate between servers (backend-to-backend). Very useful in microservices.

### Short gRPC Project
1. gRPC Example
Run it to create gRPC example project
```bash
docker run -d \
  --name grpc-example-server \
  -p 50051:50051 \
  api7/grpc-server-example:1.0.2
```
2. gRPCBinServer
Start a grpcbinserver
```
docker run -d \
  --name grpcbin \
  -p 9000:9000 \
  moul/grpcbin
```

### gRPC Transcode
The `grpc-transcode` Plugin transforms between HTTP requests and gRPC requests, as well as their corresponding responses.

With this Plugin enabled, APISIX accepts an HTTP request from the client, transcodes and forwards it to an upstream gRPC service. When APISIX receives the gRPC response, it will transform the response back to an HTTP response and send it to the client.

#### Configuration
1. Create proto resource
![gRPC Proto](../documentation/20260819/grpc-proto.png)
2. Create `grpc-transcode` route
![gRPC Transcode](../documentation/20260819/grpc-transcode-route.png)
#### Testing
![gRPC Transcode Result](../documentation/20260819/grpc-transcode-result.png)

### gRPC Web
gRPC is a high-performance RPC framework based on HTTP/2 and Protocol Buffers, but it is not natively supported by browsers. gRPC-Web defines at browser-compatible protocol for sending gRPC requests over HTTP/1.1 or HTTP/2.

## 20th August 2026
Continue reviewing plugins. The main focus are : gRPC Web, Fault Injection, Mocking, Security Plugins, and Traffic Plugins.

## gRPC Web
### Configuration
1. Create routes
```bash
curl "http://127.0.0.1:9180/apisix/admin/routes/grpc-web-route" -H "X-API-KEY: $admin_key" -X PUT -d '
{
  "uri": "/grpc/web/*",
  "plugins": {
    "grpc-web": {}
  },
  "upstream": {
    "scheme": "grpc",
    "type": "roundrobin",
    "nodes": {
      "172.17.0.1:9000": 1
    }
  }
}'
```
![grpc-web-config](../documentation/20260820/grpc-web-config.png)
2. Make sure to install requirement tools
Tools :
- protobuf
- protoc-gen-grpc-web
- protoc-gen-js
- nodejs

If you use Nixos, you may do this command to installed it temporary :
```bash
cd conf/
nix-shell
```

3. Generate gRPC-Web Client Code
```bash
curl -O https://raw.githubusercontent.com/moul/pb/master/hello/hello.proto
protoc \
  --js_out=import_style=commonjs:. \
  --grpc-web_out=import_style=commonjs,mode=grpcwebtext:. \
  hello.proto
```

4. Create a Client (`client.js`)
- Run it first

```bash
npm init -y
npm install xhr2 grpc-web google-protobuf
```
- Create `client.js`
Create it in the same directory with hello.proto. You can copy it from `conf/proto_conf/client.js`

### Testing
1. Make sure gRPC bin Active
![gRPC Bin Active](../documentation/20260820/grpcbin.png)
2. Run `client.js`
```bash
node client.js
```
3. Result
![gRPC Web Result](../documentation/20260820/grpc-web-result.png)

## Fault Injection
The plugin you should know if want to debugging. This plugin helps us to simulate error, high latency, test fallback, etc. It executes before other configured Plugins, ensuring that faults are applied consistently. This makes it ideal for scenarios like chaos engineering, where the behavior of your system under failure conditions is analyzed.

### Simple Configuration and Its Test
1. Inject Faults
Configuration to create an error without any condition.
- Config
```bash
curl "http://127.0.0.1:9180/apisix/admin/routes" -X PUT   -H "X-API-KEY: ${admin_key}"   -d '{
    "id": "fault-injection-route",
    "uri": "/anything",
    "plugins": {
      "fault-injection": {
        "abort": {
          "http_status": 404,
          "body": "APISIX Fault Injection"
        }
      }
    },
    "upstream": {
      "type": "roundrobin",
      "nodes": {
        "httpbin.org:80": 1
      }
    }
  }'
```
- Result

![Injects Fault](../documentation/20260820/fault-inject-config-1.png)

2. Inject Latencies
To testing the latency
- Config
```bash
curl "http://127.0.0.1:9180/apisix/admin/routes" -X PUT \
  -H "X-API-KEY: ${admin_key}" \
  -d '{
    "id": "fault-injection-route",
    "uri": "/anything",
    "plugins": {
      "fault-injection": {
        "delay": {
          "duration": 3
        }
      }
    },
    "upstream": {
      "type": "roundrobin",
      "nodes": {
        "httpbin.org:80": 1
      }
    }
  }'
```
- Result

![Injects Latencies](../documentation/20260820/fault-inject-config-2.png)

3. Inject Faults Conditionally 
Configuration to create an error with one or many conditions.
- Config
```bash
curl "http://127.0.0.1:9180/apisix/admin/routes" -X PUT \
  -H "X-API-KEY: ${admin_key}" \
  -d '{
    "id": "fault-injection-route",
    "uri": "/anything",
    "plugins": {
      "fault-injection": {
        "abort": {
          "http_status": 404,
          "body": "APISIX Fault Injection",
          "headers": {
            "X-APISIX-Remote-Addr": "$remote_addr"
          },
          "vars": [
            [
              [ "arg_name","==","john" ]
            ]
          ]
        }
      }
    },
    "upstream": {
      "type": "roundrobin",
      "nodes": {
        "httpbin.org:80": 1
      }
    }
  }'
```
- Result

![Injects Faults Conditionally](../documentation/20260820/fault-inject-config-2.png)

## Mocking
API Mocking (`mocking`), Plugin allows you to simulate API responses without forwarding requests to Upstream services. The Plugin supports customization of the response status code, body, headers, and more. This is particularly useful during development, testing, or debugging phases, where the actual Upstream service might be unavailable, under maintenance, or expensive to call.

### Configuration and Test
1. Simple Response
- Config
```bash
curl "http://127.0.0.1:9180/apisix/admin/routes" -X PUT \
  -H "X-API-KEY: ${admin_key}" \
  -d '{
    "id": "mocking-route",
    "uri": "/anything",
    "plugins": {
      "mocking": {
        "response_status": 201,
        "response_example": "{\"Lastname\":\"Brown\",\"Age\":56}"
      }
    },
    "upstream": {
      "type": "roundrobin",
      "nodes": {
        "httpbin.org:80": 1
      }
    }
  }'
```
- Result

![Mocking Simple](../documentation/20260820/mocking-simple-response.png)

2. JSON Response
- Config
```bash
curl "http://127.0.0.1:9180/apisix/admin/routes" -X PUT \
  -H "X-API-KEY: ${admin_key}" \
  -d '{
    "id": "mocking-route",
    "uri": "/anything",
    "plugins": {
      "mocking": {
        "response_schema": {
          "type": "object",
          "properties": {
            "id": {
              "type": "string",
              "example": "abcd"
            },
            "ip": {
              "type": "number",
              "example": 192.168
            },
            "random_str_arr": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "nested_obj": {
              "type": "object",
              "properties": {
                "random_str": {
                  "type": "string"
                },
                "child_nested_obj": {
                  "type": "object",
                  "properties": {
                    "random_bool": {
                      "type": "boolean",
                      "example": true
                    },
                    "random_int_arr": {
                      "type": "array",
                      "items": {
                        "type": "integer",
                        "example": 155
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    },
    "upstream": {
      "type": "roundrobin",
      "nodes": {
        "httpbin.org:80": 1
      }
    }
  }'
```
- Result

![Mocking JSON Response](../documentation/20260820/mocking-object-resp.png)

