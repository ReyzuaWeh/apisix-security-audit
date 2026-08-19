# JOB DESCRIPTION
Audit APISIX API gateway configuration for security best practices, including WAF rules, rate limiting, authentication, and SSL/TLS configuration

# Progress
Here are the progress every day on working it

## 14 August 2026
Result :
- Setup with Quickinstall Configuration APISIX
![Quickinstall](documentation/20260814/apisix-quickinstall-result.png)

- mTLS Config Result
![mTLS Result](documentation/20260814/mtls-result.png)

- Installation of Batch-Requests Plugin in Quickinstall
![Batch-Requests Quickinstall](documentation/20260814/batch-requests-installation.png)

- APISIX Docker Configuration Preparation
![APISIX Docker Config 1](documentation/20260814/apisix-docker-configuration-1.png)
![APISIX Docker Config 2](documentation/20260814/apisix-docker-configuration-2.png)

Documentation Source:
- [SSL Configuration](https://www.youtube.com/watch?v=degTCVeAvLs)
- [APISIX Documentation] (https://apisix.apache.org/docs/apisix/)

## 15 August 2026
For this day, the report will be focus on sum general plugins.
### 1st Step to Set Plugins in APISIX
The most important step. If we don't do it, then plugin might not be able to be configured. 
#### Set config.yaml
Used as a system and core configuration. Plugins installation was also set in here. Here are additional setting from me for today
![Config Yaml August 15th](./documentation/20260815/config_yaml.png)

#### Route Plugin Configuration
Plugin configuration directly in a route config
```bash
curl http://127.0.0.1:9180/apisix/admin/routes/<id> -H "X-API-KEY: $admin_key" -X PUT -d '
{ ... }
'
# <id> is the identifier for each routes and its plugins configs
```

#### Metadata Plugin Configuration
Specific plugin configuration
```bash
curl http://127.0.0.1:9180/apisix/admin/plugin_metadata/<plugin-name> -H "X-API-KEY: $admin_key" -X PUT -d '
{ ... }'
```

### Public API
It's an important plugin. If not installed it, then it will be a problem for some plugin. **Why?** Because we need it to make sure some our plugins configuration to be able reached by client. It even stated on some plugins like `Batch Requests`
- Set Public API
```bash
curl http://127.0.0.1:9180/apisix/admin/routes/<id> -H "X-API-KEY: $admin_key" -X PUT -d '
{
    "uri": <public-endpoint>,
    "plugins": {
        "public-api": {
            "uri": <internal-route>
            # if this uri is not set, then it will be set same as public endpoint
        }
    }
}
```
- Batch Requests (Before)
![Before Set Public API](./documentation/20260815/batch-requests-before.png)
- Batch Requests (After)
![After Set Public API](documentation/20260815/public-api-after.png)

### Batch Requests
The Batch Requests is a plugin that used for requesting some data at the same time. It's so usefull for client. Because of it, client doesn't have to open many HTTP Requests, reduce its latency, and handshake TLS. However, in APISIX side, it's still receiving all requests. It can also be more heavier.
- Config
```bash
curl http://127.0.0.1:9180/apisix/admin/plugin_metadata/batch-requests -H "X-API-KEY: $admin_key" -X PUT -d '
{
    "max_body_size": 4194304
}'
# to publish publicly
curl http://127.0.0.1:9180/apisix/admin/routes/br -H "X-API-KEY: $admin_key" -X PUT -d '
{
    "uri": "/apisix/batch-requests",
    "plugins": {
        "public-api": {}
    }
}'
```
- Result
![Batch Requests Test](documentation/20260815/batch-requests-test.png)

[Source documentation](https://apisix.apache.org/docs/apisix/plugins/batch-requests/)
### Redirect
As the name, the focus of this plugin is for redirecting. But, this is more than regullar redirect. It can redirect from http to https, can redirecting to different domain, and can even set read regex if client type or anything. 

- Before Redirect
![Result Before Redirect](./documentation/20260815/redirect-before.png)
- After Redirect
![Result After Redirect](./documentation/20260815/redirect-after.png)

[Source documentation](https://apisix.apache.org/docs/apisix/plugins/redirect/)

### Echo

Similar to the `echo` command in CLI, this plugin helps return additional information in the response when making a request.

![Echo Result](./documentation/20260815/echo-result.png)

[Source documentation](https://apisix.apache.org/docs/apisix/plugins/echo/)

## 18th August 2026
Continue the previous progress. Still focusing in plugins review. The main focus now is Real-IP, Response-Rewrite, and Server info. Make sure to installed it first in `config.yml`

### Real-IP && Response-Rewrite
Real-IP is used to create same IP address for clients to identify them. With it, we can now know from which client the Requests came. **Why?** Because there is cases when we needed to really know them. 

Response Rewrite is to edit or create additional information from response. **WHY WITH REAL-IP?** Because we wanna know is the Real-IP really works or not. If we didn't use it, then we can not possibly know it's really change the IP or not. For that, we can use this plugin for debugging.

```bash
curl "http://127.0.0.1:9180/apisix/admin/routes/real-ip-route" \
  -X PATCH \
  -H "X-API-KEY: ${admin_key}" \
  -d '{
    "plugins": {
      "real-ip": {
        "source": "arg_realip",
        "trusted_addresses": [
          <legal-proxy-ip-to-inform>
        ]
      },
      "response-rewrite": {
        "headers": {
          "remote_addr": "$remote_addr",
          "remote_port": "$remote_port"
        }
      }
    }
  }'
#   Remote addr and port is for revealing the Real-IP

```
- Config
![Real IP Debug Config](./documentation/20260818/real-ip-debug-config.png)
- Testing
![Real IP Debug Test](./documentation/20260818/real-ip-debug-test.png)

### Server Info
Used to periodically reports basic server information to etcd. The most importantly, to recap it. Foe the rest, will be informed later.

## 19th August 2026
More review of plugins. The focus are server-info, gzip, proxy-rewrite, grpc-transcode, and grpc-web

### Server Info
#### The configuration
1. Set it in config.yaml
![config.yaml Setting](./documentation/20260819/server-info-config-1.png)
2. Activate control API in APISIX
![config.yaml APISIX Setting](./documentation/20260819/server-info-config-2.png)

#### Test Result
![Server Info Succes Result](./documentation/20260819/server-info-result.png)
### Gzip
It's used to minimize a big responses. Same as, zip command in file manager. However, it's oriented in response and client should have to set `Accept-Encoding` header firts to use it.

#### Configuration
![Gzip Configuration](./documentation/20260819/gzip-configuration.png)
#### Test Result
- Before
Only base response
![Before Gzip](./documentation/20260819/gzip-before.png)
- After
Can change it to zip if it's too big
![After Gzip](./documentation/20260819/gzip-after.png)

### Proxy Rewrite
It's a plugin to rewrite requests that APISIX forwards to Upstream services. With it, we can finally access the certain path or location from Upstream services. We can also modify the methods, request destination Upstream addresses, request headers, and more.

#### Configuration
![Proxy Rewrite Configuration](./documentation/20260819/gzip-configuration.png)
#### Test Result
- Before
Only access the default location of nginx
![Before Proxy Rewrite](./documentation/20260819/proxy-rewrite-before.png)
- After
Access the specific location of nginx
![After Proxy Rewrite](./documentation/20260819/gzip-before.png)

### gRPC
gRPC stands for Google Remote Procedure Call. Was created in 2015 with plan to change or be an alternative from traditional REST, especially to communicate between servers (backend-to-backend). Very usefull in microservices.

#### Short gRPC Project
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

#### gRPC Transcode
The `grpc-transcode` Plugin transforms between HTTP requests and gRPC requests, as well as their corresponding responses.

With this Plugin enabled, APISIX accepts an HTTP request from the client, transcodes and forwards it to an upstream gRPC service. When APISIX receives the gRPC response, it will transform the response back to an HTTP response and send it to the client.

##### Configuration
1. Create proto resource
![gRPC Proto](./documentation/20260819/grpc-proto.png)
2. Create `grpc-transcode` route
![gRPC Transcode](./documentation/20260819/grpc-transcode-route.png)
##### Testing
![gRPC Transcode Result](./documentation/20260819/grpc-transcode-result.png)

#### gRPC Web
gRPC is a high-performance RPC framework based on HTTP/2 and Protocol Buffers, but it is not natively supported by browsers. gRPC-Web defines a browser-compatible protocol for sending gRPC requests over HTTP/1.1 or HTTP/2.
