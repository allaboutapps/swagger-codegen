FROM maven:3.9.1-eclipse-temurin-11

RUN set -x \
    && apt-get update && apt-get install -y -q --no-install-recommends \
    bash ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV GEN_DIR /opt/swagger-codegen
WORKDIR ${GEN_DIR}
VOLUME  ${MAVEN_HOME}/.m2/repository

# Required from a licensing standpoint
COPY ./LICENSE ${GEN_DIR}

# Required to compile swagger-codegen
COPY ./google_checkstyle.xml ${GEN_DIR}

# Modules are copied individually here to allow for caching of docker layers between major.minor versions
# NOTE: swagger-generator is not included here, it is available as swaggerapi/swagger-generator
COPY ./modules/swagger-codegen-maven-plugin ${GEN_DIR}/modules/swagger-codegen-maven-plugin
COPY ./modules/swagger-codegen-cli ${GEN_DIR}/modules/swagger-codegen-cli
COPY ./modules/swagger-codegen ${GEN_DIR}/modules/swagger-codegen
COPY ./modules/swagger-generator ${GEN_DIR}/modules/swagger-generator
COPY ./pom.xml ${GEN_DIR}

# Pre-compile swagger-codegen-cli
RUN mvn clean package -DskipTests
RUN mvn -am -pl "modules/swagger-codegen-cli" package -DskipTests

# This exists at the end of the file to benefit from cached layers when modifying docker-entrypoint.sh.
COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["help"]
