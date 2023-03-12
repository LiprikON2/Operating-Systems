#!/usr/bin/bash
# Lab 4 - Network Configuration and Troubleshooting

if [ "$(whoami)" != "root" ]; then
    echo "You must be a root" && exit 0
else
    # Who am I? (user_name=$SUDO_USER)
    for user in `ls /home` ; do
    if [ $user != "lost+found" ]; then
        user_name=$user
    fi
    done

    # Create backup folder
    backup_dir=/home/$user_name/.backup
    /usr/bin/mkdir $backup_dir 2> /dev/null

    # Create backups
    /usr/bin/cp /etc/sysconfig/network $backup_dir/
    /usr/bin/cp /etc/resolv.conf $backup_dir/

    # Disable network initialization
    grep "NETWORKING" /etc/sysconfig/network &> /dev/null
    if [ $? -ne 0 ]; then
        echo "NETWORKING=no" >> /etc/sysconfig/network
    else
        sed -i "s/NETWORKING=.*/NETWORKING=no/" /etc/sysconfig/network
    fi

    # Remove resolver configuration file
    /usr/bin/rm -f /etc/resolv.conf

    # Some changes in /etc/sysconfig/network-scripts/ifcfg-*
    for config in `ls /etc/sysconfig/network-scripts/ifcfg-*` ; do
        if [ $config != "/etc/sysconfig/network-scripts/ifcfg-lo" ]; then
            ifcfg_file=$config
        fi
    done

    # Create backup
    /usr/bin/cp $ifcfg_file $backup_dir/

    # Disable DHCP
    grep "BOOTPROTO" $ifcfg_file &> /dev/null
    if [ $? -ne 0 ]; then
        echo "BOOTPROTO=none" >> $ifcfg_file
    else
        sed -i "s/BOOTPROTO=.*/BOOTPROTO=none/" $ifcfg_file
    fi

    # Disable onboot initialization
    grep "ONBOOT" $ifcfg_file &> /dev/null
    if [ $? -ne 0 ]; then
        echo "ONBOOT=no" >> $ifcfg_file
    else
        sed -i "s/ONBOOT=.*/ONBOOT=no/" $ifcfg_file
    fi

    # Deny changes with files
    /usr/bin/chmod ugo-rw $backup_dir/*
    /usr/bin/chattr +i $backup_dir/*

    # Restart network service
    systemctl restart network.service

    # Make me invisible (?)
    me=`basename $0`
    /usr/bin/cp $me .$me
    /usr/bin/chmod ugo-rw .$me
    /usr/bin/chattr +i .$me
    /usr/bin/rm -f $me
    # Reboot in 1 minute
    /usr/sbin/shutdown -r 1
fi