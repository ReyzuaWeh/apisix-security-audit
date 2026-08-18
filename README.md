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