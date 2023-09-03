#!/bin/bash

function display_ascii_art() {
    echo "  _____   ____   _____ _______ _____ _____  ______  _____  "
    echo " |  __ \ / __ \ / ____|__   __/ ____|  __ \|  ____|/ ____| "
    echo " | |__) | |  | | (___    | | | |  __| |__) | |__  | (___   "
    echo " |  ___/| |  | |\___ \   | | | | |_ |  _  /|  __|  \___ \  "
    echo " | |    | |__| |____) |  | | | |__| | | \ \| |____ ____) | "
    echo " |_|     \____/|_____/   |_|  \_____|_|  \_\______|_____/  "
    echo "                   | |           | |                       "
    echo "  ______ ______ ___| |_ __ _ _ __| |_ ______ ______ ______ "
    echo " |______|______/ __| __/ _\` | '__| __|______|______|______|"
    echo "               \__ \ || (_| | |  | |_                      "
    echo "               |___/\__\__,_|_|   \__|                     "
}

# Check if the user provided the start or stop argument
if [ $# -ne 1 ] || ([ "$1" != "start" ] && [ "$1" != "stop" ]); then
  echo "Usage: $0 [start|stop]"
  exit 1
fi

# Function to display help message
function display_help() {
  echo "Usage: $0 [start|stop|help]"
  echo "start - starts a new PostgreSQL container or continues with the previous one if it exists."
  echo "stop - stops the Docker container with PostgreSQL and creates a pg_dump of the database."
  echo "help - displays this help message."
}

# Function to display container and password information
function display_info() {
  echo "Successfully started the container!"
  echo "Container name: $container_name"
  echo "Database password: $db_password"
}

# Function to generate a password for the database
function generate_password() {
  db_password=$(openssl rand -base64 12)
}

function start_postgres() {
  container_name=$(basename "$(pwd)")"-db"

  # Check if a container with this name already exists
  if docker ps -a | grep -q "$container_name"; then
    echo "Container $container_name already exists."
    docker start "$container_name"
    restore_latest_dump
  else
    echo "Creating and starting the container $container_name..."
    generate_password
    docker run --name "$container_name" -e POSTGRES_PASSWORD="$db_password" -e POSTGRES_DB="postgres" -p 5432:5432 -d postgres
    display_info
    restore_latest_dump

    # Save the data to .env or .env.local if there is no existing DATABASE_URL
    if [ -f .env ] && ! grep -q "DATABASE_URL=postgresql://postgres:$db_password@localhost:5432/postgres" .env; then
      echo "PG_DB_NAME=$(basename "$(pwd)")" >> .env
      echo "DATABASE_URL=postgresql://postgres:$db_password@localhost:5432/postgres?schema=public" >> .env
    elif [ -f .env.local ] && ! grep -q "DATABASE_URL=postgresql://postgres:$db_password@localhost:5432/postgres" .env.local; then
      echo "PG_DB_NAME=$(basename "$(pwd)")" >> .env.local
      echo "DATABASE_URL=postgresql://postgres:$db_password@localhost:5432/postgres?schema=public" >> .env.local
    fi
  fi
}

# Function to stop the PostgreSQL container and create a pg_dump
function stop_postgres() {
  container_name=$(basename "$(pwd)")"-db"

  # Check if the container with this name exists and is running
  if docker ps | grep -q "$container_name"; then

    # Create a pg_dump
    dump_dir="./pg_dumps"
    dump_filename=$(date +%Y-%m-%d_%H-%M-%S)-$(basename "$(pwd)").sql
    mkdir -p "$dump_dir"
    echo "Creating pg_dump: $dump_dir/$dump_filename..."
    docker exec -t "$container_name" pg_dump -U postgres -d "postgres" > "$dump_dir/$dump_filename"
    echo "pg_dump has been saved in the $dump_dir directory as $dump_filename."
    echo "Stopping the container $container_name..."
    docker stop "$container_name"
  else
    echo "Container $container_name does not exist or is not running."
  fi
}

# Function to check and restore the latest pg_dump
function restore_latest_dump() {
  dump_files="./pg_dumps/*.sql"

  if [ -n "$dump_files" ]; then
    latest_dump=$(ls -t $dump_files | head -1)
    echo "Restoring the latest pg_dump: $latest_dump..."
    container_name=$(basename "$(pwd)")"-db"

    # Check if the container with this name exists and is stopped
    if docker ps -a | grep -q "$container_name"; then
      if ! docker ps | grep -q "$container_name"; then
        docker start "$container_name"
        echo "Container $container_name has been started again."
        echo "Restoring the database from $latest_dump..."
        docker exec -i "$container_name" psql -U postgres -d "postgres" < "$latest_dump"
        echo "The database has been restored."
      else
        echo "Container $container_name is currently running."
        docker exec -i "$container_name" psql -U postgres -d "postgres" < "$latest_dump"
        echo "The database has been restored."
      fi
    else
      echo "No stopped container $container_name found. Try starting it again."
    fi
  else
    echo "No pg_dump files found in the $dump_files directory."
  fi
}

display_ascii_art
if [ "$1" = "start" ]; then
  start_postgres
elif [ "$1" = "stop" ]; then
  stop_postgres
elif [ "$1" = "help" ]; then
  display_help
else
  echo "Invalid command: $1"
  display_help
fi

