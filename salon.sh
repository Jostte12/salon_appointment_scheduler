#!/bin/bash

# Salon appointment scheduler project

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT * FROM services;")
  
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
    
  case $SERVICE_ID_SELECTED in 
    [1-5]) OPTION_MENU ;;
        *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac

}


OPTION_MENU() {

  echo -e "\nWhat's your phone number?"

  read CUSTOMER_PHONE

  NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  CUSTOMER_NAME=$(echo $NAME | sed 's/^ //')
    
  # if couldn' t find a phone number
  if [[ -z $NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    # Enter the name and phone of customer into customers table
    CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');") 
  fi

  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  SERVICE_NAME=$(echo $SERVICE_NAME_SELECTED | sed -E 's/^ *//g')

  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';") 

  # Insert SERVICE_TIME, CUSTOMER_ID, SERVICE_ID_SELECTED into appointments 
  APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

  # Check if appointment is inserted
  if [[ $APPOINTMENT_INSERT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATED at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
    
}

MAIN_MENU
