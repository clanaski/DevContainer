#echo  "6e6CQR6ICnvLIegoKh6uMUl1nKnnKUZrq5kVJdZcN6oOkb9gNWt9JQQJ99BDACAAAAAAFU20AAASAZDO44OQ" | az devops login --organization https://dev.azure.com/Wellfit-Tech
# az config set extension.use_dynamic_install=yes_without_prompt \
# az devops login --organization https://dev.azure.com/Wellfit-Tech 

## CaskaydiaCove Nerd Font
# Uncomment the below to install the CaskaydiaCove Nerd Font
mkdir $HOME/.local
mkdir $HOME/.local/share
mkdir $HOME/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip
unzip CascadiaCode.zip -d $HOME/.local/share/fonts
rm CascadiaCode.zip

## AZURE FUNCTIONS CORE TOOLS ##
# Uncomment the below to install Azure Functions Core Tools
npm i -g azure-functions-core-tools@4 --unsafe-perm true

## AZURE DEV CLI ##
# Uncomment the below to install Azure Dev CLI
curl -fsSL https://aka.ms/install-azd.sh | bash

## LOGIN TO GIT
git config --global user.name "Christina Lanaski"
git config --global user.email "christina.lanaski@outlook.com"