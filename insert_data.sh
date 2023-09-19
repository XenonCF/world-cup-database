#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo "$($PSQL "truncate table games, teams")"

while IFS="," read -r winner opponent
do  
  if [[ $($PSQL "select count(name) from teams where name='$winner'") == 0 ]]
  then
    echo "$($PSQL "insert into teams(name) values('$winner')")"
  fi
  if [[ $($PSQL "select count(name) from teams where name='$opponent'") == 0 ]]
  then
    echo "$($PSQL "insert into teams(name) values('$opponent')")"
  fi
done < <(cut -d "," -f3,4 games.csv | tail -n +2)

while IFS="," read -r year round winner opponent winner_goals opponent_goals
do

  winner_id=$($PSQL "select team_id from teams where name='$winner'")
  opponent_id=$($PSQL "select team_id from teams where name='$opponent'")
  
  echo "$($PSQL "insert into games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) values($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)")"
done < <(tail -n +2 games.csv)