# Funzione che permette di visualizzare tutti mac address presenti nel file vbox
# passato come primo parametro.
function mac_vbox {
    # $1 si riferisce all'arg della funzione non quello del programma, anche se
    # in questo caso sono uguali
    echo "I MAC address già presenti in '$VBOX_FILE': "

    # Prendo tutti i mac address
    # NB -F serve per usare le regexp e tr per avere l'array (altrimenti me le
    # mette sulla stessa riga e la cosa mi infastidisce). Sort le ordina
    local mac=$( awk -F '["]' '/MACAddress/{print $6}' $VBOX_FILE  | tr -d " " | sort | uniq )

    for addr in $mac; do
        echo "  - $addr"
    done
}

# Funzione che permette di visualizzare i mac address già usati, ovvero quelli
# del file passati come secondo parametro.
function mac_used {
    # $1 è l'args della funzione, non quello del prog principale!
    local database=$( awk -F '[\n]' '{print $1}' $DB_FILE)
    if [[ ! -s $DB_FILE ]]; then
        echo "Il file è vuoto!"
        return
    fi
    echo "MAC Address già presenti in '$DB_FILE':"

    for addr in $database; do
        echo "  - $addr"
    done
}

# Funzione che permette di modificare il mac address di una scheda di rete.
function modify_mac {
    local guard=0
    local to_change
    local new_mac
    local mac=$( awk -F '["]' '/MACAddress/{print $6}' $VBOX_FILE  | tr -d " " | sort | uniq )
    local database=$( awk -F '[\n]' '{print $1}' $DB_FILE)

    echo $PRESS_Q
    # PRINTO LA LISTA VECCHIA
    echo "I MAC address già presenti in '$VBOX_FILE': "
    for addr in $mac; do
        echo "  - $addr"
    done

    # CHIEDO IL MAC DA CAMBIARE E CONTROLLO ESISTENZA
    # Fiche non è presente nel file lo richiedo
    while [[  $guard -eq 0 ]]; do
        echo -n "Inserire il MAC Address da cambiare: "
        read to_change
        to_change=$(echo "$to_change" | tr '[:lower:]' '[:upper:]')
        # se inserisco 'q' o 'Q' allora esco
        if [[ $to_change == 'Q' ]]; then
            return
        fi
        # controllo se l'indirizzo è presente
        for addr in $mac; do
            if [[ $addr == $to_change ]]; then
                guard=1
                break
            fi
        done
        # Se non lo trovo allora printo un messaggio di errore!
        if [[ $guard -eq 0 ]]; then
            echo "$MAC_NOT_FOUND_ERR"
        fi
    done

    # CHIEDO NUOVO MAC E CONTROLLO CORRETTEZZA
    echo -n "Inserire il nuovo MAC Address: "
    read new_mac
    new_mac=$(echo "$new_mac" | tr '[:lower:]' '[:upper:]')
    # se inserisco 'q' o 'Q' allora esco
    if [[ $new_mac == 'Q' ]]; then
        return
    fi
    # finche non è hex corretto lo richiedo
    #until [[ $new_mac == $(grep $new_mac ^[0-9A-F]{12}$) ]]; do # NOT WORK
    until [[ $new_mac == $( grep  -e "^[0-9A-F]\{12\}$" <<< $new_mac ) ]]; do
        echo "$NEW_MAC_FORMAT_ERR"
        echo -n "Reinserire il nuovo MAC Address: "
        read new_mac
        new_mac=$(echo "$new_mac" | tr '[:lower:]' '[:upper:]')
        # se inserisco 'q' o 'Q' allora esco
        if [ $new_mac == 'Q' ]; then
            return
        fi
    done

    # Controllo se è presente sul file
    # NB: guard è già a 1, altrimenti non si esce dal while del controllo sul
    # vecchio mac
    while [[ $guard -eq 1 ]]; do
        # pongo guard a 0 sulla fiducia e la cambio eventualmente
        guard=0
        for addr in $database; do
            if [[ $addr == $new_mac ]]; then
                guard=1
                echo "$MAC_FOUND_ERR"
                echo -n "Inserire il nuovo MAC Address: "
                read new_mac
                break
            fi
        done
    done

    # Sostituisce tutte le occorenze di to_change con new_mac
    sed -ie "s/$to_change/$new_mac/g" $VBOX_FILE
    # Il parametro -i crea un file di backup con una 'e' alla fine del file
    rm $VBOX_FILE"e"
    # Aggiungo il nuovo MAC al db di MAC usati
    printf "\n$new_mac" >> $DB_FILE
}

# Funzione di uscita. Semplicemente stampa "bye bye!" a schermo.
function go_out {
    echo "Bye Bye!"
}

# Funzione per la scelta other, ovvero quando si inserisce un numero maggiore
# di 4 o uguale a 0, oppure quando si inserisce un valore non numerico.
function other {
    echo "Scelta non corretta! non esiste nessuna opzione $choice."
}

# Funzione che chiede all'utente un MAC Address valido (ovvero contenuto nel file DB_FILE)
# e lo sostituisce con uno generato randomicamente. Inoltre quest'ultimo viene aggiunto al
# file DB_FILE contenente tutti i MACAddress già utilizzati.
function random_modify {
    local guard=0
    local new_mac=$(openssl rand -hex 6 | tr '[:lower:]' '[:upper:]')
    local mac=$( awk -F '["]' '/MACAddress/{print $6}' $VBOX_FILE  | tr -d " " | sort | uniq )
    local database=$( awk -F '[\n]' '{print $1}' $DB_FILE)

    echo $PRESS_Q

    # PRINTO LA LISTA VECCHIA
    echo "I MAC address già presenti in '$VBOX_FILE': "
    for addr in $mac; do
        echo "  - $addr"
    done

    # CHIEDO IL MAC DA CAMBIARE E CONTROLLO ESISTENZA
    # Fiche non è presente nel file lo richiedo
    while [[  $guard -eq 0 ]]; do
        echo -n "Inserire il MAC Address da cambiare: "
        read to_change
        to_change=$(echo "$to_change" | tr '[:lower:]' '[:upper:]')
        # se inserisco 'q' o 'Q' allora esco
        if [[ $to_change == 'Q' ]]; then
            return
        fi
        # controllo se l'indirizzo è presente
        for addr in $mac; do
            if [[ $addr == $to_change ]]; then
                guard=1
                break
            fi
        done
        # Se non lo trovo allora printo un messaggio di errore!
        if [[ $guard -eq 0 ]]; then
            echo "$MAC_NOT_FOUND_ERR"
        fi
    done

    # Controllo se è presente sul file
    # NB: guard è già a 1, altrimenti non si esce dal while del controllo sul
    # vecchio mac
    while [[ $guard -eq 1 ]]; do
        # pongo guard a 0 sulla fiducia e la cambio eventualmente
        guard=0
        for addr in $database; do
            if [[ $addr == $new_mac ]]; then
                guard=1
                # genero il numero randomicamente e porto le lettere in maiuscolo.
                new_mac=$(openssl rand -hex 6 | tr '[:lower:]' '[:upper:]')
                break
            fi
        done
    done

    # Sostituisce tutte le occorenze di to_change con new_mac
    sed -ie "s/$to_change/$new_mac/g" $VBOX_FILE
    # Il parametro -i crea un file di backup con una 'e' alla fine del file
    rm $VBOX_FILE"e"
    # Aggiungo il nuovo MAC al db di MAC usati
    printf "\n$new_mac" >> $DB_FILE

    echo "New random MAC: $new_mac"
}
