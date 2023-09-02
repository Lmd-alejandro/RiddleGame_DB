#!/bin/bash

# Solicitar datos al usuario
read -p "What is your name: " name

# Variables de conexión a la base de datos
DB_USER="postgres"
DB_NAME="RiddleGames_DB"

# Consulta SQL para insertar los datos
insert_query="INSERT INTO public.player (name) VALUES ('$name');"

# Ejecutar la consulta SQL usando psql
psql -U $DB_USER -d $DB_NAME -c "$insert_query"

