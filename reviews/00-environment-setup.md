# Environment Setup

Initial environment preparation for the APISIX audit: Quickinstall, mTLS configuration, Docker setup, and the basic steps required before configuring any plugin (`config.yaml`, route-level plugin configuration, and plugin metadata configuration).

[⬅ Back to progress overview](../README.md)

---

## 14 August 2026
Result :
- Setup with Quickinstall Configuration APISIX
![Quickinstall](../documentation/20260814/apisix-quickinstall-result.png)

- mTLS Config Result
![mTLS Result](../documentation/20260814/mtls-result.png)

- Installation of Batch-Requests Plugin in Quickinstall
![Batch-Requests Quickinstall](../documentation/20260814/batch-requests-installation.png)

- APISIX Docker Configuration Preparation
![APISIX Docker Config 1](../documentation/20260814/apisix-docker-configuration-1.png)
![APISIX Docker Config 2](../documentation/20260814/apisix-docker-configuration-2.png)

Documentation Source:
- [SSL Configuration](https://www.youtube.com/watch?v=degTCVeAvLs)
- [APISIX Documentation] (https://apisix.apache.org/docs/apisix/)

## 15 August 2026
For this day, the report will focus on some general plugins.
### 1st Step to Set Plugins in APISIX
The most important step. If we don't do it, then plugin might not be able to be configured. 
#### Set config.yaml
Used as a system and core configuration. Plugins installation was also set in here. Here are additional setting from me for today
![Config Yaml August 15th](../documentation/20260815/config_yaml.png)

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

