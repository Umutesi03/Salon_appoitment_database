#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

# Function to display available services
display_services() {
  echo "Welcome to My Salon, how can I help you?"
  echo ""
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  if [[ -z $AVAILABLE_SERVICES ]]; 
  then
    echo "Sorry, we don't have any services available right now."
  else
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME; do
      echo "$SERVICE_ID) $NAME"
    done
  fi
}

# Main Menu
MAIN_MENU() {
  display_services
  echo -e "\nWhich service would you like to book?"
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; 
  then
    echo -e "\nI could not find that service. What would you like today?"
    display_services
    MAIN_MENU
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    
    if [[ -z $SERVICE_NAME ]]; 
    then
      echo -e "\nI could not find that service. What would you like today?"
      display_services
      MAIN_MENU
    else
      # Get customer phone number
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      
      if [[ -z $CUSTOMER_NAME ]]; then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi
      
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      
      echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      
      INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      
      echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      
      EXIT
    fi
  fi
}

# Exit function
EXIT() {
  echo -e "\nThank you for stopping in.\n"
}

# Run the main menu
MAIN_MENU
