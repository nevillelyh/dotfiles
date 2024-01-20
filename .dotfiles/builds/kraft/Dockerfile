FROM azul/zulu-openjdk-alpine:17-latest
ARG VERSION=7.4.1

RUN apk add --no-cache bash curl

RUN adduser -D confluent
RUN mkdir /confluent
COPY kraft.sh /confluent
RUN chown -R confluent /confluent

USER confluent
WORKDIR /confluent

RUN curl -fsSL https://packages.confluent.io/archive/$(echo "${VERSION}" | sed 's/\.[^.]*$//')/confluent-community-${VERSION}.tar.gz | tar -C /confluent --strip-components 1 -xz

ENTRYPOINT ["/confluent/kraft.sh"]
