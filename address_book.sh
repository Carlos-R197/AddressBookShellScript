#!bin/sh

FILE=book.txt

add_user()
{
    NAME=$1
    SURNAME=$2
    EMAIL=$3
    PHONE=$4

    echo -en "Do you want to add this user to the registry? (y/n) "
    read CONFIRM_OPTION
    case $CONFIRM_OPTION in
        y)
            echo "${NAME},${SURNAME},${EMAIL},${PHONE}" >> book.txt
            WRITE_RESULT=$?
            if [ $WRITE_RESULT -eq "0" ]; then
                echo "The user has been added successfully."
            else
                echo "The writing operation has failed, try again."
                return 1
            fi 
            ;;
        N)
            ;;
        *)
            ;;
    esac
}

search_user()
{
    grep -i -n $1 $FILE
}

search_user_by_surname()
{
    SURNAME=$1
    # Print file, get rid of everything except surnames and find the typed surname along the list
    cat $FILE | cut --delimiter , --fields 2 | grep --ignore-case --line-number $SURNAME
}

edit_record() 
{
    SEARCH_PATTERN=$1

    echo -en "Type the new name, surname, phone and email: "
    read NAME SURNAME PHONE EMAIL
    LINE=`grep -i -n $SEARCH_PATTERN $FILE | cut -d : -f 1`
    sed "${LINE}d" $FILE | tee $FILE
    echo "$NAME $SURNAME $PHONE $EMAIL" >> $FILE
}

ask_for_confirmation()
{
    OPERATION=$1
    while :
    do
        echo -en "Do you want to ${OPERATION} this record? (y/n) "
        read OPTION
        case $OPTION in
            [Yy]*)
                return 0
                ;;
            [Nn]*)
                return 1
                ;;
            *)
                echo "Invalid input."
                ;;
        esac
        echo
    done
}

# Main body

while : 
do
    # Menu
    echo "Type 1 if you want to add an address."
    echo "Type 2 if you want to search for existing addresses."
    echo "Type 3 if you want to search by surname."
    echo "Type 4 if you want to remove an existing record."
    echo "Type 5 if you want to edit an existing record."
    echo "Type 6 is you want to list all the addresses."
    echo "Type q if you want to exit the program."
    read SELECTED_OPTION
    case $SELECTED_OPTION in
        1)      
            echo -en "Type name, surname, email and phone leaving a space for each: "
            read NAME SURNAME EMAIL PHONE
            add_user $NAME $SURNAME $EMAIL $PHONE       
            ;;
        2)
            echo -en "Type the name of the user you are looking for: "
            read NAME
            search_user $NAME
            ;;
        3)
            echo -en "Type the surname of the user you are looking for: "
            read SURNAME
            search_user_by_surname $SURNAME
            ;;
        4)
            echo -en "Type the data of the user you are looking for: "
            read INPUT
            search_user $INPUT
            COUNT_RESULTS=`grep -i -c $INPUT $FILE`
            if [ $COUNT_RESULTS -eq "1" ]; then
                ask_for_confirmation "delete"
                STATUS=$?
                if [ $STATUS -eq "0" ]; then
                    LINE=`grep --ignore-case --line-number $INPUT $FILE | cut --delimiter : --fields 1`
                    sed "${LINE}d" $FILE | tee $FILE  
                fi
            elif [ $COUNT_RESULTS -gt "1" ]; then
                echo "Too many records to proceed with a delete."
            else
                echo "No record corresponding to this data was found."
            fi
            ;;
        5)
            echo -en "Type the data of the user you are looking for: "
            read INPUT
            search_user $INPUT
            COUNT_RESULTS=`grep -i -c $INPUT $FILE`
            if [ $COUNT_RESULTS -eq "1" ]; then
                ask_for_confirmation "edit"
                STATUS=$?
                if [ $STATUS -eq "0" ]; then
                    edit_record $INPUT
                fi
            elif [ $COUNT_RESULTS -gt "1" ]; then
                echo "Too many records to proceed with an edit."
            else
                echo "No record corresponding to this data was found."
            fi
            ;;
        6)
            cat $FILE
            ;;
        q)
            echo "Exiting . . ."
            break
            ;;
    esac
    echo
done 