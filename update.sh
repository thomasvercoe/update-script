#! /bin/bash

# make script case insensitive 
shopt -s nocasematch
printf "%s\n" 'Searching for Updates...'
# update homebrew to get updates for Homebrew packages
brew update &> /dev/null
# list available MacOS updates
macos_updates=$(softwareupdate -l)
# list outdated Homebrew packages
brew_outdated=$(brew outdated)
# list outdated Mac App Store Apps 
mas_outdated=$(mas outdated)
# list outdated python packages
pip3_outdated=$(pip3 list --outdated)
# grep $macos_updates for any entries mentioning 'restart'
restart_yes_no=$(grep -o restart <<< "$macos_updates")
# use awk to not display the first 5 lines of output from softwareupdate -l (they are not necessary to display)
show_awk_macos_updates=$(printf "%s\n" "$macos_updates" | awk 'NR>=5')
# stores the output of all the commands used to list availible updates
ask_question=$(printf "%s\n" "$brew_outdated" "$mas_outdated" "$show_awk_macos_updates")


# function to print 64 equals symbols
divider() {
    printf "%s\n" '================================================================'
}

pip3update() {
    pip3 list -o | cut -f1 -d' ' | tr " " "\n" | awk '{if(NR>=3)print}' | cut -d' ' -f1 | xargs -n1 pip3 install -U 
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

# test if there are outdated Homebrew packages and if so do_brew_outdated will update homebrew and its packages and show_upgrades will display
# the relavent updates else do_brew_outdated will do nothing and show_upgrades will print that all packages are up to date
if [[ $brew_outdated != "" ]]
then
    do_brew_outdated () {
        printf "%s\n" 'Upgrading Homebrew Packages...'
        brew update &> /dev/null
        brew upgrade
        printf "%s\n" 'Upgraded Homebrew Packages'
    }
    show_upgrades () {
        printf "%s\n\n" 'Available Homebrew Package Upgrades:'
        printf "%s\n" "$brew_outdated"
    }
else
    do_brew_outdated () {
        :
    }
    show_upgrades () {
        printf "%s\n" 'All Homebrew packages are already upgraded'
    }
fi

# test if there are outdated Mac App Store app's and if so do_mas_outdated will update them and show_mas_updates will display
# the relavent updates else do_mas_outdated will do nothing and show_mas_updates will print that all app's are up to date
if [[ $mas_outdated != "" ]]
then 
    do_mas_outdated() {
        printf "%s\n" 'Updating App Store Apps...'
        mas upgrade
        printf "%s\n" 'Updated App Store Apps'
    }
    show_mas_updates() {
        printf "%s\n\n" 'Available App Store Updates:'
        printf "%s\n" "$mas_outdated" | awk '{$1=""; print $0}'
    }
else 
    do_mas_outdated() {
        :
    }
    show_mas_updates() {
        printf "%s\n" 'All App Store apps are already updated'
    }
fi

# tests if there are any MacOS system updates available and if so do_macos_updates will will run mupdate (function defined above)
# and show_mac_updates will display the relavent updates else do_macos_updates will do nothing and show_mac_updates will print that
# all the system up to date
if [[ $show_awk_macos_updates != "" ]]
then
    do_macos_updates() {
        printf "%s\n" 'Updating MacOS System...'
        mupdate
        printf "%s\n" 'Updated MacOS'
    }
    show_mac_updates() {
        printf "%s\n\n" 'Available MacOS System Updates:'
        printf "%s\n" "$show_awk_macos_updates"
    }
else
    do_macos_updates() {
        :
    }
    show_mac_updates() {
        printf "%s\n" 'MacOS System is already updated'
    }
fi


# test if there are outdated pip packages and if so do_pip3_outdated will update pip3 packages and show_pip3_updates will display
# the relavent updates else do_pip3_outdated will do nothing and show_pip3_updates will print that all packages are up to date
if [[ $pip3_outdated != "" ]]
then
    do_pip3_outdated () {
        printf "%s\n" 'Upgrading pip3 Packages...'
        pip3update
        printf "%s\n" 'Upgraded pip3 Packages'
    }
    show_pip3_updates () {
        printf "%s\n\n" 'Available pip3 Package Upgrades:'
        printf "%s\n" "$pip3_outdated"
    }
else
    do_pip3_outdated () {
        :
    }
    show_pip3_updates () {
        printf "%s\n" 'All pip3 packages are already upgraded'
    }
fi




# where some of the functions containing printf come together
# displays to the user the state of updates on the system
divider
show_mac_updates
divider
show_mas_updates
divider
show_pip3_updates
divider
show_upgrades
divider



# where the rest of the functions defined above come together
# tests if there are any updates and if so presents the question else it exits
if  [[ $ask_question != "" ]]
then
    #asks the user if they wwish to proceed
    yes_no_question
    read YESNO

    if [[ $YESNO == y* ]]
    then 
        #runs the functions containing the commands to do the updates 
        do_brew_outdated
        do_mas_outdated
        do_macos_updates
        do_pip3_outdated
        printf "%s\n" 'Your system is up to date'
    else 
        printf "%s\n" 'Update Terminated'
    fi
fi