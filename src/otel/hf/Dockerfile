FROM jaegertracing/all-in-one:latest AS jaeger

FROM nginx:alpine

# Copy Jaeger binary from official image
COPY --from=jaeger /go/bin/all-in-one-linux /usr/local/bin/jaeger-all-in-one

# Install necessary runtime dependencies
RUN apk add --no-cache libc6-compat ca-certificates

# Setup necessary directories and permissions for non-root user (HF runs as 1000)
RUN mkdir -p /tmp/client_temp \
    /tmp/proxy_temp_path \
    /tmp/fastcgi_temp \
    /tmp/uwsgi_temp \
    /tmp/scgi_temp \
    && chmod -R 777 /tmp

# Copy Nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# Environment variables for Jaeger
ENV COLLECTOR_OTLP_ENABLED=true
ENV LOG_LEVEL=info

# Expose the single port HF uses
EXPOSE 7860

# We need a start script that runs both services
RUN echo "#!/bin/sh" > /start.sh && \
    echo "nginx &" >> /start.sh && \
    echo "/usr/local/bin/jaeger-all-in-one &" >> /start.sh && \
    echo "wait -n" >> /start.sh && \
    echo "exit $?" >> /start.sh && \
    chmod +x /start.sh

# Switch to user 1000 to match HF environment (optional but good practice to test locally)
USER 1000

CMD ["/start.sh"]
