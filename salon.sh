#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Welcome to my Salon ~~~~~\n"
echo -e "\nHow can I help you?\n"

MAIN_MENU()
{
  if [[ $1 ]]
  then
        echo -e "\n$1" 
  fi

  DISPLAY=$($PSQL "SELECT * FROM services ORDER BY service_id")

  if [[ -z $DISPLAY ]]
  then 
        echo "There is no services available right now!"
  else
        echo -e "$DISPLAY" | while read SERVICE_ID BAR SERVICE_NAME
        do 
            echo "$SERVICE_ID) $SERVICE_NAME"
        done

        read SERVICE_ID_SELECTED 
        if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
        then 
              MAIN_MENU "Please enter a valid number"
        else
              VALID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
              
              if [[ -z $VALID ]]
              then 
                    MAIN_MENU "This service is not available.Please choose an available service"
              else
                    echo -e "\nWhat is your phone number?"
                    read CUSTOMER_PHONE
                    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

                    if [[ -z $CUSTOMER_NAME ]]
                    then
                          echo -e "\nThere is no record exists with the given phone number.Please enter your name"
                          read CUSTOMER_NAME
                          INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
                          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
                          FORMAT_SERVICE=$(echo $SERVICE_NAME | sed 's/ //g')
                          FORMAT_CUSTOMER=$(echo $CUSTOMER_NAME | sed 's/ //g')

                          echo -e "\nWhat time would you like to be served $FORMAT_SERVICE, $FORMAT_CUSTOMER?"
                          read SERVICE_TIME

                          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone ='$CUSTOMER_PHONE'")
                          INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
                          echo -e "\nI have put you down for a $FORMAT_SERVICE at $SERVICE_TIME, $FORMAT_CUSTOMER."
                    else
                          SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
                          FORMAT_SERVICE=$(echo $SERVICE_NAME | sed 's/ //g')
                          FORMAT_CUSTOMER=$(echo $CUSTOMER_NAME | sed 's/ //g')

                          echo -e "\nWhat time would you like to be served $FORMAT_SERVICE, $FORMAT_CUSTOMER?"
                          read SERVICE_TIME

                          CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone ='$CUSTOMER_PHONE'")
                          INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
                          echo -e "\nI have put you down for a $FORMAT_SERVICE at $SERVICE_TIME, $FORMAT_CUSTOMER."
                    fi
              fi
        fi

  fi
}

MAIN_MENU