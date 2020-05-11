FROM fedora:31

LABEL maintainer="AptoGéo/Mathieu MAST"

# Env variables
ENV PG_VERSION_MAJOR 12
ENV PG_VERSION_MINOR 2
ENV PGIS_VERSION 30_${PG_VERSION_MAJOR}
ENV POSTGRESQL_DATA_DIR /var/lib/pgsql/${PG_VERSION_MAJOR}/data
ENV DB_NAME postgis
ENV DB_USER postgis
ENV DB_PASSWD postgis

# Add the PostgreSQL PGP key to verify the official yum repository packages
RUN rpm --import https://yum.postgresql.org/RPM-GPG-KEY-PGDG-${PG_VERSION_MAJOR}

# Add PostgreSQL's repository
RUN dnf -y install https://download.postgresql.org/pub/repos/yum/${PG_VERSION_MAJOR}/fedora/fedora-31-x86_64/pgdg-fedora-repo-latest.noarch.rpm

# Packages
RUN dnf install -y postgresql${PG_VERSION_MAJOR}-server postgresql${PG_VERSION_MAJOR}-contrib procps-ng net-tools postgis${PGIS_VERSION} postgis${PGIS_VERSION}-client && dnf -y clean all

# Use postgres user
USER postgres

# Init PostgreSQL
RUN /usr/pgsql-${PG_VERSION_MAJOR}/bin/initdb -D ${POSTGRESQL_DATA_DIR} -A trust 2>&1 < /dev/null

# PostgreSQL configuration
RUN echo "host all  all    0.0.0.0/0  md5" >> ${POSTGRESQL_DATA_DIR}/pg_hba.conf
RUN echo "listen_addresses='*'" >> ${POSTGRESQL_DATA_DIR}/postgresql.conf

# Create 'postgis' user with 'postgis' password
RUN /usr/pgsql-${PG_VERSION_MAJOR}/bin/pg_ctl -D ${POSTGRESQL_DATA_DIR} start && \
    sleep 5 && \
    psql --command "CREATE USER ${DB_USER} WITH SUPERUSER PASSWORD '${DB_PASSWD}';" && \
    createdb -O ${DB_USER} ${DB_NAME} && \
    psql --dbname ${DB_NAME} --command "CREATE EXTENSION postgis;" && \
    /usr/pgsql-${PG_VERSION_MAJOR}/bin/pg_ctl -D ${POSTGRESQL_DATA_DIR} stop

USER root
EXPOSE 5432
VOLUME ${POSTGRESQL_DATA_DIR}
CMD su - postgres -c "/usr/pgsql-${PG_VERSION_MAJOR}/bin/pg_ctl -D ${POSTGRESQL_DATA_DIR} start" && tail -f /dev/null
