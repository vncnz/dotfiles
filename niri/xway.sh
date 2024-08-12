#!/bin/bash

# Verifica se è stato passato un parametro (l'applicazione da eseguire)
if [ -z "$1" ]; then
  echo "Errore: Nessuna applicazione specificata."
  echo "Uso: $0 nome_applicazione"
  exit 1
fi

# Lancia Xwayland
Xwayland :1 &
XWAYLAND_PID=$!

# Imposta il DISPLAY per la sessione Xwayland
export DISPLAY=:1

# Esegui l'applicazione passata come parametro
"$@" &
APP_PID=$!

# Attendi un momento affinché l'applicazione si avvii
sleep 2

# Forza la finestra dell'applicazione in fullscreen dentro Xwayland
wmctrl -r :ACTIVE: -b add,fullscreen -e 0,0,0,1920,1080

# Attendi che l'applicazione termini
wait $APP_PID
APP_EXIT_CODE=$?

# Quando l'applicazione si chiude, termina Xwayland
kill $XWAYLAND_PID

exit $APP_EXIT_CODE
