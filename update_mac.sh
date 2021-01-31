#! /bin/bash

shopt -s nocasematch
printf "%s\n" 'Searching for Updates...'
brew update &> /dev/null
macos_updates=$(softwareupdate -l)
brew_outdated=$(brew outdated)
mas_outdated=$(mas outdated)
restart_yes_no=$(grep -o restart <<< "$macos_updates")
show_awk_macos_updates=$(printf "%s\n" "$macos_updates" | awk 'NR>=5')
devider() {
    printf "%s\n" '================================================================'
}




if [[ $restart_yes_no == restart ]]
then 
    yes_no_question() {
    printf "%s\n" 'One or more of the updates available require a restart. Do you wish to continue? [Yes/No]'
    }
    mupdate() {
        sudo softwareupdate -i -a --verbose --restart
    }
else
    yes_no_question() {
        printf "%s\n" 'Do you wish to continue? [Yes/No]'
    }
    mupdate() {
        softwareupdate -i -a --verbose
    }
fi


if [[ $brew_outdated != "" ]]
then
    brew_update () {
        printf "%s\n" 'Upgrading Homebrew Packages...'
        brew update
        brew upgrade
        printf "%s\n" 'Upgraded Homebrew Packages'
    }
    show_upgrades () {
        printf "%s\n\n" 'Available Homebrew Package Upgrades:'
        printf "%s\n" "$brew_outdated"
    }
else
    brew_update () {
        :
    }
    show_upgrades () {
        printf "%s\n" 'All Homebrew packages are already upgraded'
    }
fi


if [[ $mas_outdated != "" ]]
then 
    mas_outdated2() {
        printf "%s\n" 'Updating App Store Apps...'
        mas upgrade
        printf "%s\n" 'Updated App Store Apps'
    }
    show_mas_updates() {
        printf "%s\n\n" 'Available App Store Updates:'
        printf "%s\n" "$mas_outdated" | awk '{$1=""; print $0}'
    }
else 
    mas_outdated2() {
        :
    }
    show_mas_updates() {
        printf "%s\n" 'All App Store apps are already updated'
    }
fi


if [[ $show_awk_macos_updates != "" ]]
then
    macos_updates2() {
        printf "%s\n" 'Updating MacOS System...'
        mupdate
        printf "%s\n" 'Updated MacOS'
    }
    show_mac_updates() {
        printf "%s\n\n" 'Available MacOS System Updates:'
        printf "s\n" "$show_awk_macos_updates"
    }
else
    macos_updates2() {
        :
    }
    show_mac_updates() {
        printf "%s\n" 'MacOS System is already updated'
    }
fi




devider
show_mac_updates
devider
show_upgrades
devider
show_mas_updates
devider




yes_no_question
read YESNO
if [[ $YESNO == y* ]]
then 
    brew_update
    mas_outdated2
    macos_updates2
    printf "%s\n" 'Your system is up to date'
else 
    printf "%s\n" 'Update Terminated'
fi