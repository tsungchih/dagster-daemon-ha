ARG DAGSTER_VERSION
FROM docker.io/dagster/dagster-celery-k8s:${DAGSTER_VERSION}

ENV LEADER_CHECK_INTERVAL=5

RUN apt update \
    && apt install -y curl jq

ADD entrypoint.sh /entrypoint.sh
