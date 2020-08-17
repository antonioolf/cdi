#!/bin/bash

INSTALL_PATH="/usr/local/bin"

install() {
    uninstall
	
    SCRIPT_URL="https://raw.githubusercontent.com/antonioolf/cdi/master/cdi.sh"
    TMP_FILE="$(mktemp)"
    
	if [ ! -d "$INSTALL_PATH" ]; then
		sudo mkdir -p $INSTALL_PATH
	fi

    echo "Downloading CDI..."

    wget  -q --show-progress -O "$TMP_FILE" "$SCRIPT_URL" &&
    sudo mv $TMP_FILE "$INSTALL_PATH/cdi.sh"

    # Add execution permission
    sudo chmod +x "$INSTALL_PATH/cdi.sh"

    # Appends alias for cdi execution in .bashrc file and source it
    echo "alias cdi='. $INSTALL_PATH/cdi.sh'" >> ~/.bashrc
    . ~/.bashrc
}

uninstall() {
    # Deletes cdi script from installation folder
    sudo rm -f "$INSTALL_PATH/cdi.sh"

    echo "Removing older versions of CDI"
    # Remove alias for cdi in in .bashrc
    sed '/alias cdi=/d' -i ~/.bashrc
    . ~/.bashrc
}

install
