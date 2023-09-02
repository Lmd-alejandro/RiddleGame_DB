#!/bin/bash

# PostgreSQL database configuration
db_host="localhost"
db_port="5432"
db_name="RiddleGames_DB"
db_user="postgres"
db_password="tu_contraseña"

# Schema and table names in the database
schema_name="public"
table_player="player"
table_punctuation="punctuation"

echo "Welcome to the Number Guessing Game!"
echo "Try to guess the secret number between 1 and 100."

# Ask for the player's name
read -p "Enter your name: " player_name

# ...

# Get the player's ID from the database or insert a new player
player_id=$(psql -h $db_host -p $db_port -d $db_name -U $db_user -t -c "SELECT player_id FROM $schema_name.$table_player WHERE name = '$player_name';")

if [ -z "$player_id" ]; then
  # Player doesn't exist, insert a new player
  player_id=$(psql -h $db_host -p $db_port -d $db_name -U $db_user -t -c "INSERT INTO $schema_name.$table_player (name) VALUES ('$player_name') RETURNING player_id;")
fi

# ...


attempts=0
guess=0

# Generate a random number between 1 and 100
secret_number=$(( (RANDOM % 100) + 1 ))

while [ $guess -ne $secret_number ]; do
  read -p "Enter your guess: " guess

  # Validate if the input is a number
  if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
    echo "Please enter a valid number."
    continue
  fi

  attempts=$((attempts + 1))

  if [ $guess -lt $secret_number ]; then
    echo "The secret number is higher."
  elif [ $guess -gt $secret_number ]; then
    echo "The secret number is lower."
  fi
done

# Calculate the score based on the number of attempts
if [ $attempts -le 5 ]; then
  score=100
elif [ $attempts -le 10 ]; then
  score=80
elif [ $attempts -le 15 ]; then
  score=60
elif [ $attempts -le 20 ]; then
  score=40
elif [ $attempts -le 25 ]; then
  score=10
else
  score=0
fi

# Record the score in the "Punctuation" table of the database
current_date=$(date +"%Y-%m-%d %H:%M:%S")
psql -h $db_host -p $db_port -d $db_name -U $db_user -c "INSERT INTO $schema_name.$table_punctuation (date, player_id, punctuation) VALUES ('$current_date', $player_id, $score);"

echo "Congratulations, $player_name! You guessed the secret number ($secret_number) in $attempts attempts."
echo "Your score is: $score points."

# Show the top scores
echo "Top Scores:"
psql -h $db_host -p $db_port -d $db_name -U $db_user -c "SELECT $schema_name.$table_player.name, $schema_name.$table_punctuation.punctuation, $schema_name.$table_punctuation.date FROM $schema_name.$table_punctuation JOIN $schema_name.$table_player ON $schema_name.$table_punctuation.player_id = $schema_name.$table_player.player_id ORDER BY $schema_name.$table_punctuation.punctuation ASC LIMIT 10;"
