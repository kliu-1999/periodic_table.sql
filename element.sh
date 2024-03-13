#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
re='^[0-9]+$'

#check for number or letter entered as arguement
if [[ $1 =~ $re ]]
then
  number_selected=$($PSQL "select name,symbol,elements.atomic_number,atomic_mass,melting_point_celsius,boiling_point_celsius from elements full join properties on elements.atomic_number=properties.atomic_number where $1=elements.atomic_number")
  type=$($PSQL "select type from types full join properties on types.type_id = properties.type_id where $1=properties.atomic_number")
else  
  lw_selected=$($PSQL "select name,symbol,elements.atomic_number,atomic_mass,melting_point_celsius,boiling_point_celsius from elements full join properties on elements.atomic_number=properties.atomic_number where '$1'=symbol or '$1'=name")
  a_number=$($PSQL "select atomic_number from elements where '$1'=symbol or '$1'=name")
  type=$($PSQL "select type from types full join properties on types.type_id = properties.type_id where $a_number=properties.atomic_number")
fi

#check for whether arguement is null, an element, or not an element and returns accordingly
if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
elif [ -z $number_selected ] && [ -z $lw_selected ]
then
  echo I could not find that element in the database.
else
  if [[ -z $lw_selected ]]
  then
    echo $number_selected | while IFS='|' read name symbol atomic mass melting boiling 
    do
      echo "The element with atomic number $atomic is $name ($symbol). It's a $type, with a mass of $mass amu. $name has a melting point of $melting celsius and a boiling point of $boiling celsius."
    done
  else
    echo $lw_selected | while IFS='|' read name symbol atomic mass melting boiling 
    do
      echo "The element with atomic number $atomic is $name ($symbol). It's a $type, with a mass of $mass amu. $name has a melting point of $melting celsius and a boiling point of $boiling celsius."
    done
  fi
fi
