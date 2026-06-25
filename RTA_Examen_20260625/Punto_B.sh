#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Uso: $0 <Usuario_Clave_Origen> <Path_Lista_Usuarios>"
    exit 1
fi
USUARIO_ORIGEN=$1
LISTA_USUARIOS=$2
CLAVE_ENCRIPTADA=$(sudo grep "^${USUARIO_ORIGEN}:" /etc/shadow | cut -d: -f3)
while IFS=, read -r USUARIO GRUPO HOME_DIR || [ -n "$USUARIO" ]; do
    case "$USUARIO" in
        \#*|"") continue ;;
    esac
    USUARIO=$(echo "$USUARIO" | tr -d ' ')
    GRUPO=$(echo "$GRUPO" | tr -d ' ')
    HOME_DIR=$(echo "$HOME_DIR" | tr -d ' ')
    if ! getent group "$GRUPO" > /dev/null; then
        sudo groupadd "$GRUPO"
        echo "Grupo creado: $GRUPO"
    fi
    if ! getent passwd "$USUARIO" > /dev/null; then
        sudo useradd -m -d "$HOME_DIR" -g "$GRUPO" -s /bin/bash "$USUARIO"
        if [ -n "$CLAVE_ENCRIPTADA" ]; then
            sudo usermod -p "$CLAVE_ENCRIPTADA" "$USUARIO"
        fi
        echo "Usuario creado: $USUARIO con Home en $HOME_DIR"
    else
        echo "El usuario $USUARIO ya existe."
    fi
done < "$LISTA_USUARIOS"
