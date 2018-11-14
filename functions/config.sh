bold=$(tput bold)
normal=$(tput sgr0)

VBOX_FILE=$1
DB_FILE=$2

# ----------------------- ERRORI ----------------------- #
# Stringa per l'errore nel caso di uso sbagliato
ILLIGAL_ARGS_NUMB_ERR="${bold}ILLIGAL ARGS NUMBER ERROR: ${normal}Il numero degli argomenti è sbagliato."

NEW_MAC_FORMAT_ERR="${bold}MAC FORMAT ERROR:${normal}Il MACAddress inserito non è in un formato esadecimale corretto!
Controllare che la lunghezza della stringa sia di 12 caratteri.
"

MAC_NOT_FOUND_ERR="${bold}MAC NOT FOUND ERROR: ${normal}Il MAC Address inserito non presente nel file '$VBOX_FILE'
"

MAC_FOUND_ERR="${bold}MAC FOUND ERROR:${normal}Il MAC Address inserito e' gia' presente nel file '$DB_FILE'
"


# ----------------------- USAGE ----------------------- #
# Stringa per l'uso
USAGE="
${bold}USAGE:${normal} ./vboxMACman file.vbox MAClist ${normal}

  - \"file.vbox\" è il percorso al file .vbox da caricare
  - \"MAClist\" è il percorso al file dove sono contenuti i mac address già usati.

Per saperne di più digitare 'man ./manual'
"

# Stringa per il menu
MENU="${bold}vboxMACman menu: ${normal}
1. Visualizza MAC ADDRESS presenti nel file vbox
2. Visualizza MAC ADDRESS già utilizzati
3. Modifica MAC ADDRESS
4. Modifica MAC ADDRESS con uno random
5. Echo menu
6. Esci
"

PRESS_Q="${bold}Per uscire dall'opzione inserire 'q' o 'Q'!
${normal}"