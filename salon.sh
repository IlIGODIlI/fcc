#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only --quiet -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

# Display services
echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")" |
while IFS='|' read SERVICE_ID SERVICE_NAME
do
    echo "$SERVICE_ID) $SERVICE_NAME"
done

# Ask for service
echo -e "\nHow can I help you?"
read SERVICE_ID_SELECTED

# Check whether service exists
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

while [[ -z "$SERVICE_NAME" ]]
do
    echo -e "\nI could not find that service. What would you like today?"
    
    echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")" |
    while IFS='|' read SERVICE_ID SERVICE
    do
        echo "$SERVICE_ID) $SERVICE"
    done

    read SERVICE_ID_SELECTED

    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
done

# Get customer phone
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if customer already exists
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

# If customer doesn't exist, create them
if [[ -z "$CUSTOMER_ID" ]]
then
    echo -e "\nI don't have a record for that phone number. What's your name?"
    read CUSTOMER_NAME

    CUSTOMER_ID=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME') RETURNING customer_id;")
else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID;")
fi

# Get appointment time
echo -e "\nWhat time would you like your appointment?"
read SERVICE_TIME

# Create appointment
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Confirmation
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
