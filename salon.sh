#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -A -c"

services=$($PSQL "select * from services;")

echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

while IFS='|' read -r service_id name; do
        echo "$service_id) $name"
done <<< "$services"

allowed_services=("1" "2" "3")
count=0
while [ $count = 0 ];do
  read SERVICE_ID_SELECTED
  if [[ " ${allowed_services[@]} " =~ " $SERVICE_ID_SELECTED " ]]; then
      echo -e "\nWhat is your phone number?\n"
      read CUSTOMER_PHONE
      checkphone=$($PSQL "SELECT COUNT(*) FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      if [ $checkphone -eq 0 ]; then
        echo -e "\nWhat is your name?\n"
        read CUSTOMER_NAME
        $PSQL "INSERT INTO customers (name,phone) VALUES ('$CUSTOMER_NAME','$CUSTOMER_PHONE');"
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
      fi
      num_int=$(expr "$SERVICE_ID_SELECTED" + 0)
      s_from_id=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
      echo -e "\nWhat time would you like your $s_from_id?"
      read SERVICE_TIME
      c_id=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

      $PSQL "INSERT INTO appointments (customer_id,service_id,time) VALUES ('$c_id','$SERVICE_ID_SELECTED','$SERVICE_TIME');"
      echo -e "\nI have put you down for a $s_from_id at $SERVICE_TIME, $CUSTOMER_NAME."
      count=1
  else
      echo "Sorry, $SERVICE_ID_SELECTED is not one of our list of services."
      while IFS='|' read -r service_id name; do
        echo "$service_id) $name"
      done <<< "$services"

  fi
done

