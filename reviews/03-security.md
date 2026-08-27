# Security

Category reference: https://apisix.apache.org/plugins/#Security

Plugins reviewed in this category: `public-api`, `cors`, `uri-blocker`, `ip-restriction`, `ua-restriction`, `referer-restriction`, `consumer-restriction`, `csrf`.

[⬅ Back to progress overview](../README.md)

---

## Public API
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

![Before Set Public API](../documentation/20260815/batch-requests-before.png)

- Batch Requests (After)

![After Set Public API](../documentation/20260815/public-api-after.png)


## Security Plugins

### Cors
The `cors` plugin allows you to enable Cross-Origin Resource Sharing (CORS). CORS is an HTTP-header based mechanism which allows a server to specify any origins (domain, scheme, or port) other than its own, and instructs browsers to allow the loading of resources from those origins.
- Configuration
```bash
curl "http://127.0.0.1:9180/apisix/admin/routes" -X PUT   -H "X-API-KEY: ${admin_key}"   -d '{
    "id": "cors-route",
    "uri": "/cors",
    "plugins": {
      "cors": {
        "allow_origins": "http://sub.domain.com,http://sub2.domain.com",
        "allow_methods": "GET,POST",
        "allow_headers": "headr1,headr2",
        "expose_headers": "ex-headr1,ex-headr2",
        "max_age": 50,
        "allow_credential": true
      }
    },
    "upstream": {
      "nodes": {
        "httpbin.org:80": 1
      },
      "type": "roundrobin"
    }
  }'
```
- Result

Without Origin Header

![Cors Without Origin](../documentation/20260820/cors-test-without-origin.png)

With Origin Header

![Cors With Origin](../documentation/20260820/cors-test-with-origin.png)

### URI Blocker
The `uri-blocker` plugin intercepts user requests with a set of `block_rules`. It's using blacklist mechanism. Will be helpful if there's some URI that doesn't want to be public

- Configuration
```bash
curl -i http://127.0.0.1:9180/apisix/admin/routes/1 -H "X-API-KEY: $admin_key" -X PUT -d '
{
    "uri": "/*",
    "plugins": {
        "uri-blocker": {
            "block_rules": ["root.exe", "root.m+"]
        }
    },
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "127.0.0.1:1980": 1
        }
    }
}'
```
- Result

![URI Blocker Test Result](../documentation/20260820/uri-blocker-result.png)

### IP Restriction
The `ip-restriction` plugin supports restricting access to Upstream resources by IP addresses, through either configuring a whitelist or blacklist of IP addresses. Restricting IP to resources helps prevent unauthorized access and harden API security.

- Configuration
You may choose between *whitelist* or *blacklist* option
```bash
curl "http://127.0.0.1:9180/apisix/admin/routes" -X PUT \
  -H "X-API-KEY: ${admin_key}" \
  -d '{
    "id": "ip-restriction-route",
    "uri": "/ip-restrict",
    "plugins": {
      "ip-restriction": {
        "whitelist": [
          "192.168.0.1/24"
        ],
        "message": "Access denied"
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

Before

![Before IP Restriction](../documentation/20260820/ip-restrict-before.png)

After

![After IP Restriction](../documentation/20260820/ip-restrict-after.png)

### UA Restriction
The `ua-restriction` plugin supports restricting access to upstream resources through either configuring an allowlist or denylist of user agents. A common use case is to prevent web crawlers from overloading the upstream resources and causing service degradation.

- Configuration
```bash
curl "http://127.0.0.1:9180/apisix/admin/routes" -X PUT   -H "X-API-KEY: ${admin_key}"   -d '{
    "id": "ua-restriction-route",
    "uri": "/ua-res",
    "plugins": {
      "ua-restriction": {
        "bypass_missing": false,
        "denylist": [
          "(Baiduspider)/(\\d+)\\.(\\d+)",
          "bad-bot-1"
        ],
        "message": "Access denied"
      }
    },
    "upstream": {
      "type": "roundrobin",
      "nodes": {
        "web2:80": 1
      }
    }
  }'
```
- Result

Non Forbidden Agent

![Non Forbidden Result](../documentation/20260820/ua-res-noblock.png)

Forbidden Agent

![Forbidden Agent Result](../documentation/20260820/ua-res-block.png)

### Referer Restriction
The `referer-restriction` Plugin can be used to restrict access to a Service or a Route by whitelisting/blacklisting the `Referer` request header.
- Configuration
```bash
curl http://127.0.0.1:9180/apisix/admin/routes/1 -H "X-API-KEY: $admin_key" -X PUT -d '
{
    "uri": "/index.html",
    "upstream": {
        "type": "roundrobin",
        "nodes": {
            "web1:80": 1
        }
    },
    "plugins": {
        "referer-restriction": {
            "bypass_missing": true,
            "whitelist": [
                "xx.com",
                "*.xx.com"
            ]
        }
    }
}'
```
- Result

Allowed Referer

![Allowed Result](../documentation/20260820/referer-allow.png)

Not-Allowed Referer

![Not-Allowed Result](../documentation/20260820/referer-not-allow.png)

### Consumer Restriction
The `consumer-restriction` Plugin enables access controls based on Consumer name, Route ID, Service ID, or Consumer Group ID. The concept of this plugin is the same as *user authentication*. It will be perfect if you combine it with auth plugins.

- Configuration
1. Create a consumer
```bash
curl "http://127.0.0.1:9180/apisix/admin/consumers" -X PUT \
  -H "X-API-KEY: ${admin_key}" \
  -d '{
    "username": "<consumer-name>"
  }'
```
2. Create consumer's auth
```bash
curl "http://127.0.0.1:9180/apisix/admin/consumers/JohnDoe/credentials" -X PUT \
  -H "X-API-KEY: ${admin_key}" \
  -d '{
    "id": "<consumer-auth-cred>",
    "plugins": {
      "key-auth": {
        "key": "<consumer-key>"
      }
    }
  }'
```

3. Create a Route with Key Auth
```bash
curl "http://127.0.0.1:9180/apisix/admin/routes" -X PUT   -H "X-API-KEY: ${admin_key}"   -d '{
    "id": "consumer-restricted-route",
    "uri": "/get-consume",
    "plugins": {
      "key-auth": {},
      "consumer-restriction": {
        "whitelist": [<consumer-username>]
      }
    },
    "upstream" : {
      "nodes": {
        "httpbin.org":1
      }
    }
  }'
```

- Result

Allowed Consumer

![Allowed Consumer](../documentation/20260820/consumer-allow.png)

Not-Allowed Consumer

![Not-Allowed Consumer](../documentation/20260820/consumer-not-allow.png)

### CSRF 
The `csrf` Plugin can be used to protect your API against CSRF attacks using the Double Submit Cookie method.

This Plugin considers the GET, HEAD and OPTIONS methods to be safe operations (safe-methods) and such requests are not checked for interception by an attacker. Other methods are termed as unsafe-methods

- Configuration
```bash
curl -i http://127.0.0.1:9180/apisix/admin/routes/1 -H "X-API-KEY: $admin_key" -X PUT-d '
{
  "uri": "/<uri>",
  "plugins": {
    "csrf": {
      "key": "<csrf-secret-key>"
    }
  },
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "<upstream-server>": 1
    }
  }
}'
```
- Get CSRF
```bash
curl -i http://127.0.0.1:9080/<uri>
```
![Get CSRF](../documentation/20260820/csrf-get.png)

- Result

![No CSRF Post](../documentation/20260820/csrf-no-csrf.png)


