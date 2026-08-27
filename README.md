# JOB DESCRIPTION
Audit APISIX API gateway configuration for security best practices, including WAF rules, rate limiting, authentication, and SSL/TLS configuration

# Progress

This document summarizes the daily progress of the APISIX API Gateway configuration audit. Full details for each plugin category are split into the [`reviews/`](./reviews) folder for easier reading and navigation. Categories follow the official [Apache APISIX Plugin Hub](https://apisix.apache.org/plugins/) grouping.

| Date | Focus | Details |
|---|---|---|
| 14 August 2026 | Initial APISIX setup: Quickinstall, mTLS configuration, Batch-Requests plugin installation, Docker configuration | [Environment Setup](./reviews/00-environment-setup.md) |
| 15 August 2026 | Basic steps to enable plugins (`config.yaml`, route/metadata plugin configuration) | [Environment Setup](./reviews/00-environment-setup.md) |
| 15 August 2026 | Public API setup | [Security](./reviews/03-security.md) |
| 15 August 2026 | Plugin review: Batch Requests, Redirect, Echo | [General](./reviews/01-general.md) |
| 18 August 2026 | Plugin review: Real-IP & Response-Rewrite, Server Info | [General](./reviews/01-general.md) |
| 19 August 2026 | Plugin review: Server Info, Gzip | [General](./reviews/01-general.md) |
| 19 August 2026 | Plugin review: Proxy Rewrite, gRPC (Transcode & Web intro) | [Transformation](./reviews/02-transformation.md) |
| 20 August 2026 | Plugin review: gRPC Web, Fault Injection, Mocking | [Transformation](./reviews/02-transformation.md) |
| 20 August 2026 | Plugin review: Cors, URI Blocker, IP Restriction, UA Restriction, Referer Restriction, Consumer Restriction, CSRF | [Security](./reviews/03-security.md) |
| 20 August 2026 | Plugin review: Limit Req, Limit Conn, Limit Count, Proxy Cache | [Traffic](./reviews/04-traffic.md) |
| 22 August 2026 | Plugin review (continued): Request Validation, Proxy Mirror, API Breaker, Traffic Split, Request ID, Proxy Control, Client Control | [Traffic](./reviews/04-traffic.md) |
| 25 August 2026 | Plugin review: Prometheus, HTTP/TCP/Kafka Logger, Syslog, Clickhouse Logger, Log Rotate | [Observability](./reviews/05-observability.md) |
| 25 August 2026 | Plugin review: Serverless Pre/Post Function | [Serverless](./reviews/06-serverless.md) |
|27 August 2025 | Reformating documentation and create Auto TLS Configuration  | [Auto-TLS](./auto-tls/README.md) |

## Category Reference

Categories in `reviews/` mirror the [Apache APISIX Plugin Hub](https://apisix.apache.org/plugins/):

- **General** — https://apisix.apache.org/plugins/#General
- **Transformation** — https://apisix.apache.org/plugins/#Transformation
- **Security** — https://apisix.apache.org/plugins/#Security
- **Traffic** — https://apisix.apache.org/plugins/#Traffic
- **Observability** — https://apisix.apache.org/plugins/#Observability
- **Serverless** — https://apisix.apache.org/plugins/#Serverless
