#! /bin/bash

# make script case insensitive 
shopt -s nocasematch

printf "%s\n" 'Searching for Updates...'

# function to print 64 equals symbols
divider() {
    printf "%s\n" '================================================================'
}

# defines the default behaviour of the yes_no_question function
yes_no_question() {
    printf "%s\n" 'Do you wish to continue? [Yes/No]'
}



# test if homebrew is installed
if command -v brew &> /dev/null
then 
    # update homebrew to get updates for homebrew packages
    brew update &> /dev/null

    brew_outdated=$(brew outdated)

    # test if there are outdated Homebrew packages
    if [[ $brew_outdated != "" ]]
    then
        do_brew_outdated () {
            printf "%s\n" 'Upgrading Homebrew Packages...'
            brew upgrade
            printf "%s\n" 'Upgraded Homebrew Packages'
        }
        show_brew_upgrades () {
            printf "%s\n\n" 'Available Homebrew Package Upgrades:'
            printf "%s\n" "$brew_outdated"
            divider
        }
    else
        do_brew_outdated () {
            :
        }
        show_brew_upgrades () {
            printf "%s\n" 'All Homebrew packages are already upgraded'
            divider
        }
    fi
else
    do_brew_outdated () {
        :
    }
    show_brew_upgrades () {
        :
    }
fi



# test if mas-cli is installed
if command -v mas &> /dev/null
then 
    mas_outdated=$(mas outdated)

    # test if there are outdated Mac App Store app's
    if [[ $mas_outdated != "" ]]
    then 
        do_mas_outdated() {
            printf "%s\n" 'Updating App Store Apps...'
            mas upgrade
            printf "%s\n" 'Updated App Store Apps'
        }
        show_mas_updates() {
            printf "%s\n\n" 'Available App Store Updates:'
            # use awk to not display the first 5 lines of output from softwareupdate -l (they are not necessary to display)
            printf "%s\n" "$mas_outdated" | awk '{$1=""; print $0}'
            divider
        }
    else 
        do_mas_outdated() {
            :
        }
        show_mas_updates() {
            printf "%s\n" 'All App Store apps are already updated'
            divider
        }
    fi
else
    do_mas_outdated() {
        :
    }
    show_mas_updates() {
        :
    }
fi



# test if softwareupdate installed (comes bundled with MacOS so also tests if the script is running on a mac)
if command -v softwareupdate &> /dev/null
then 
    macos_updates_function () {
    macos_updates=$(softwareupdate -l)
    # use awk to not display the first 5 lines of output from softwareupdate -l (they are not necessary to display)
    show_awk_macos_updates=$(printf "%s\n" "$macos_updates" | awk 'NR>=5')
    # grep $macos_updates for any entries mentioning 'restart'
    restart_yes_no=$(grep -o restart <<< "$macos_updates")
    }

    # softwareupdate -l has an annoying output when there are no updates available that dosen't go away when sent to /dev/null, however this works
    macos_updates_function &> /dev/null

    #test if an update requires a restart and if so then mupdate has --restart
    if [[ $restart_yes_no == restart ]]
    then 
        yes_no_question_restart() {
        printf "%s\n" 'One or more of the updates available require a restart. Do you wish to restart? [Yes/No]'
        }
        mupdate() {
            sudo softwareupdate -i -a --verbose --restart
        }
    else
        mupdate() {
            softwareupdate -i -a --verbose
        }
    fi



    # tests if there are any MacOS system updates available
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
            divider
        }
    else
        do_macos_updates() {
            :
        }
        show_mac_updates() {
            printf "%s\n" 'MacOS System is already updated'
            divider
        }
    fi
else
    do_macos_updates() {
        :
    }
    show_mac_updates() {
        :
    }
fi


# tests if pip3 is installed
if command -v pip3 &> /dev/null
then
    pip3_outdated=$(pip3 list --outdated)

    # some code from the internet, used to upgrade all installed pip3 packages
    pip3update() {
        pip3 list -o | cut -f1 -d' ' | tr " " "\n" | awk '{if(NR>=3)print}' | cut -d' ' -f1 | xargs -n1 pip3 install -U 
    }

    # test if there are outdated pip3 packages
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
            divider
        }
    else
        do_pip3_outdated () {
            :
        }
        show_pip3_updates () {
            printf "%s\n" 'All pip3 packages are already upgraded'
            divider
        }
    fi
else
    do_pip3_outdated () {
        :
    }
    show_pip3_updates () {
        :
    }
fi


# displays to the user the state of updates on the system
divider
show_mac_updates
show_mas_updates
show_pip3_updates
show_brew_upgrades



# stores the output of all the commands used to list availible updates
ask_question=$(printf "%s\n" "$brew_outdated" "$mas_outdated" "$show_awk_macos_updates" "$pip3_outdated")


# tests if there are any updates
if  [[ $ask_question != "" ]]
then
    #asks the user if they wish to proceed
    yes_no_question
    read YESNO

    # tests the users response
    if [[ $YESNO == y* ]]
    then 

        yes_no_question_restart
        read restartyesno

        if [[ $restartyesno == y* ]] 
        then
            # tests if an update requires a restart
            if [[ $restart_yes_no == restart ]] 
            then
                # clear cached sudo Password
                sudo -k
                printf "%s\n" "Please enter your [Password]"
                # ask user for password
                sudo -v
                # keepalive cached password
                while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
            fi
        else
            mupdate() {
            softwareupdate -i -a --verbose
            }
        fi

        #does the updating and upgrading
        do_brew_outdated
        do_pip3_outdated
        do_mas_outdated
        do_macos_updates
        sudo -k
        printf "%s\n" 'Your system is up to date'
    else 
        printf "%s\n" 'Update Terminated'
    fi
else
    exit
fi
