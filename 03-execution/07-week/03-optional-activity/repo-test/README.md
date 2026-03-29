version: '3.8'

services:
  postgres:
    image: postgres:15
    container_name: postgres_liquibase
    restart: always
    environment:
      POSTGRES_DB: liquibase_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5435:5432"
    volumes:
      - pg_data:/var/lib/postgresql/data

  liquibase:
    image: liquibase/liquibase:latest
    container_name: liquibase_runner
    depends_on:
      - postgres
    volumes:
      - ./liquibase:/liquibase
    working_dir: /liquibase
    command: >
      --defaultsFile=liquibase.properties update

volumes:
  pg_data: