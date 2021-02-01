#! /bin/bash

#make script case insensitive 
shopt -s nocasematch
printf "%s\n" 'Searching for Updates...'
#update homebrew to get updates for Homebrew packages
brew update &> /dev/null
#list available MacOS updates
macos_updates=$(softwareupdate -l)
#list outdated Homebrew packages
brew_outdated=$(brew outdated)
#list outdated Mac App Store Apps 
mas_outdated=$(mas outdated)
#grep $macos_updates for any entries mentioning 'restart'
restart_yes_no=$(grep -o restart <<< "$macos_updates")
#use awk to not display the first 5 lines of output from softwareupdate -l (they are not necessary to display)
show_awk_macos_updates=$(printf "%s\n" "$macos_updates" | awk 'NR>=5')
#stores the output of all the commands used to list availible updates
ask_question=$(printf "%s\n" "$brew_outdated" "$mas_outdated" "$show_awk_macos_updates")

#function to print 64 equals symbols
divider() {
    printf "%s\n" '================================================================'
}

#test if an update requires a restart and if so then mupdate has --restart flag and yes_no_question alerts the user about the restart
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

#test if there are outdated Homebrew packages and if so brew_update will update homebrew and its packages and show_upgrades will display the relavent updates else brew_update will do nothing and show_upgrades will print that all packages are up to date
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

#test if there are outdated Mac App Store app's and if so mas_outdated2 will update them and show_mas_updates will display the relavent updates else mas_outdated2 will do nothing and show_mas_updates will print that all app's are up to date
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

#tests if there are any MacOS system updates available and if so macos_updates2 will will run mupdate (function defined above) and show_mac_updates will display the relavent updates else macos_updates2 will do nothing and show_mac_updates will print that all the system up to date
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



#where some of the functions containing printf come together
#displays to the user the state of updates on the system
divider
show_mac_updates
divider
show_upgrades
divider
show_mas_updates
divider



#where the rest of the functions defined above come together
#tests if there are any updates and if so presents the question else it exits
if  [[ $ask_question != "" ]]
then
    #asks the user if they wwish to proceed
    yes_no_question
    read YESNO

    if [[ $YESNO == y* ]]
    then 
        #runs the functions containing the commands to do the updates 
        brew_update
        mas_outdated2
        macos_updates2
        printf "%s\n" 'Your system is up to date'
    else 
        printf "%s\n" 'Update Terminated'
    fi
fi