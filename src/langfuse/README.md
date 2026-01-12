# Langfuse on Azure Web App (v3 with ClickHouse)

This directory contains the configuration to deploy [Langfuse](https://langfuse.com/) (v3) to Azure Web App for Containers using Docker Compose.

**Configuration**:
*   **Web App**: `langfuse/langfuse:3.39.0` (Pinned for stability)
*   **Database**: `postgres` (Sidecar)
*   **Cache/Queue**: `redis` (Sidecar)
*   **Analytics**: `clickhouse` (Sidecar) - **Required for v3+**
*   **Blob Storage**: `minio` (Sidecar) - **S3 implementation**

> [!WARNING]
> **COMPLEXITY ALERT**: This "All-in-One" setup runs **4 containers** (Web, DB, Redis, ClickHouse) on a single Azure Web App. This requires a **Premium** App Service Plan (P1v3 or higher) for sufficient memory and CPU. Do not attempt this on Basic/Free tiers.

> [!WARNING]
> **DATA LOSS RISK**: All sidecars (Postgres, Redis, ClickHouse) are ephemeral. **Data will be lost on restart** unless strict persistence is configured.

## Deployment Steps

1.  **Create an Azure Web App for Containers**:
    *   Publish: **Docker Container**
    *   Operating System: **Linux**
    *   SKU: **Premium V3 P1v3** (Required).

2.  **Configure Docker**:
    *   Select **Docker Compose (Preview)**.
    *   Upload the `docker-compose.yml` file from this directory.

3.  **Environment Variables**:
    Go to **Settings** -> **Environment variables** in the Azure Portal and add:

    | Variable | Description | Example/Value |
    | :--- | :--- | :--- |
    | `NEXTAUTH_SECRET` | 32-byte hex string | `openssl rand -hex 32` |
    | `SALT` | 32-byte hex string | `openssl rand -hex 32` |
    | `ENCRYPTION_KEY` | 32-byte hex string | `openssl rand -hex 32` |
    | `NEXTAUTH_URL` | Your App URL | `https://<your-app>.azurewebsites.net` |
    | `WEBSITES_ENABLE_APP_SERVICE_STORAGE` | **CRITICAL** | `true` |

## Alternative: Manual UI Configuration (NOT RECOMMENDED)
Because you now need 4 containers, manually adding them in the Azure Portal UI is tedious and error-prone. **Using Docker Compose (Option 2 above) is strongly recommended.**

If you MUST go manual (Main + 3 Sidecars):
1.  **Main**: `langfuse/langfuse:latest` (Port 3000)
2.  **Sidecar 1**: `postgres:latest` (Port 5432)
3.  **Sidecar 2**: `redis:7-alpine` (Port 6379)
4.  **Sidecar 3**: `clickhouse/clickhouse-server:24` (Ports 8123 AND 9000)

**Env Vars (Localhost)**:
*   `CLICKHOUSE_URL` = `http://127.0.0.1:8123`
*   `CLICKHOUSE_MIGRATION_URL` = `clickhouse://127.0.0.1:9000`
*   `CLICKHOUSE_USER` = `default`
*   `CLICKHOUSE_PASSWORD` = `langfuse`
*   *(Plus all the other localhost vars for DB and Redis)*
