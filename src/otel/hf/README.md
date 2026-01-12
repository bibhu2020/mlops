---
title: Otel
emoji: 🐨
colorFrom: green
colorTo: yellow
sdk: docker
pinned: false
license: mit
short_description: Open Telemetry
---

# OpenTelemetry on Hugging Face Spaces

This configuration allows you to run Jaeger (OpenTelemetry) on Hugging Face Spaces.

## Important Note regarding Ports
Hugging Face Spaces typically expose **only one public port** (default: 7860).
Standard Jaeger Setup requires multiple ports:
- `16686`: UI
- `4317`: OTLP gRPC
- `4318`: OTLP HTTP

To solve this, we use an **Nginx** reverse proxy inside the container to listen on `7860` and route traffic:
- `http://<SPACE_URL>/` -> Jaeger UI
- `http://<SPACE_URL>/v1/traces` -> OTLP HTTP Receiver

**gRPC (port 4317) is NOT available** externally in this setup. You must configure your clients to use the **OTLP HTTP Exporter** instead.

## How to Deploy

1. Create a new [Hugging Face Space](https://huggingface.co/new-space).
2. Choose **Docker** as the SDK.
3. Upload the files in this directory (`Dockerfile`, `nginx.conf`) to the root of your Space's repository.

## Client Configuration

When sending traces from your application to this Space, use the OTLP HTTP exporter:

```python
# Example in Python
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter

exporter = OTLPSpanExporter(
    endpoint="https://YOUR-SPACE-NAME.hf.space/v1/traces"
)
```
