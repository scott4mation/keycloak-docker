# Option 1 (recommended): pin BOTH stages to the SAME Keycloak version
# Update this one line to whatever version you want to run (e.g. 26.4.0)
ARG KEYCLOAK_VERSION=26.5.3

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION} AS builder

# (Optional) build-time args you may be passing from Railway
ARG KC_HEALTH_ENABLED
ARG KC_METRICS_ENABLED
ARG KC_FEATURES
ARG KC_DB
ARG KC_HTTP_ENABLED
ARG PROXY_ADDRESS_FORWARDING
ARG QUARKUS_TRANSACTION_MANAGER_ENABLE_RECOVERY
ARG KC_HOSTNAME
ARG KC_LOG_LEVEL
ARG KC_DB_POOL_MIN_SIZE

# Providers


# Theme
COPY --chown=keycloak:keycloak theme/keywind /opt/keycloak/themes/keywind

# Build an optimised Keycloak image with providers/theme included
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}

# (Optional) crypto policy override (keep if your template needed it)
COPY java.config /etc/crypto-policies/back-ends/java.config

# Copy the built Keycloak distribution from builder
COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized", "--import-realm"]
