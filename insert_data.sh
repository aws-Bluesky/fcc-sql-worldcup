#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # remove first line with year, round,...
  if [[ $YEAR != year ]]
  then
    # -----------INSERT INTO TEAMS
    # get winner_id (CHECK EXISTENCE)
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    
    # if not found
    if [[ -z $WINNER_ID ]]
    then
      # insert into teams
      INSERT_WINNER_INTO_TEAMS_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_INTO_TEAMS_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi

      # get new winner_id to use for games (FOREIGN)
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")

    fi
    
    # get opponent_id (CHECK EXISTENCE)
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

    # if not found
    if [[ -z $OPPONENT_ID ]]
    then
      # insert into teams
      INSERT_OPPONENT_INTO_TEAMS_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_INTO_TEAMS_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi

      # get new opponent_id to use for games (FOREIGN)
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

    fi
    
    # ------------INSERT INTO games
    INSERT_INTO_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_INTO_GAMES_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into games, $YEAR $WINNER $OPPONENT
    fi
  fi
done