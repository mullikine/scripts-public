#!/bin/sh
# by Jakukyo Friel <weakish@gmail.com> under GPL v2.

### Set up a chroot busybox SSH environment

## requires
# wget -- to download pubkey and busybox
# sharutils -- to generate random password

## Config

# Edit them to suit your needs, e.g $Pubkeyurl.  Paticuliarly, I'm using amd64.  If you
# are on a 32-bit x86 system, change $Arch to i586 or i686.


# chroot users' group
readonly Members=members
# chroot directory (should be owned and writable only by root)
readonly Chroot=/chroot

# busybox
readonly Site=http://busybox.net/downloads/binaries
readonly Version=1.16.0
readonly Arch=x86_64
readonly URL=$Site/$Version/busybox-$Arch


## Doc

help() {
cat << END
Set up a chroot busybox SSH environment

Actions

init                       create chroot environment
add USERNAME PUBKEY_URL    add new user and specify url to download pubkey
help                       this help page

Examples:
busyroot add joe http://example.com/id_dsa.pub
END
}

## sshd settings
#
# You should have openssh-sever (>4.8) installed.
# 
# We will use /chroot as the chroot directory.  All users belong to the
# group members will get chrooted.  Edit your /etc/ssh/sshd_config, e.g.:
#
#    Match Group members 
#        ChrootDirectory /chroot
#   


## Set up chroot environment
setup_chroot() {
    # prepare chroot group
    groupadd $Members 

    # build directory tree
    mkdir $Chroot 
    cd $Chroot 
    mkdir -p dev/pts proc etc lib usr/lib var/run var/log \
        home bin usr/bin sbin usr/sbin 

    # copy files
    cp /etc/localtime etc/ 
    cp /etc/nsswitch.conf etc/ 
    cp /etc/resolv.conf etc/ 
    cp /etc/host.conf etc/ 
    cp /etc/hosts etc/ 
    touch var/log/lastlog 
    touch var/run/utmp 
    touch var/log/wtmp 
    
    # create devices
    mknod dev/urandom c 1 9 && chmod 0666 dev/urandom 
    mknod dev/ptmx c 5 2 && chmod 0666 dev/ptmx 
    mknod dev/tty c 5 0 && chmod 0666 dev/tty 
    
    # The new environment needs access to terminals (this is necessary for a user to login) and to proc filesystem.
    mount -o bind /dev/pts dev/pts/ 
    mount -o bind /proc proc/ 

    # busybox
    cd bin
    wget "$URL" 
    mv busybox-$Arch busybox 
    chmod 0755 busybox 
    ln -s busybox sh

    cat <<- END 
You need to manually chroot to link commands to busybox:
chroot  $Chroot /bin/sh 
busybox --install
exit
END
}


## add user

# Generate random password
#
# We disable password login.  So in most cases, password is useless.
# But in rare cases, we may need to enable password login.  Thus we
# made a very long password for security.
# Since Base64 uses [:alnum:] plus [+-] ('=' as suffix), our password length is about as strong as an 256-bit key.
# log(2**256)/log(26*2+10+2) => 42.6666666666667
#
generate_passwd() {
    dd if=/dev/urandom count=1 2>/dev/null |
    uuencode -m - |
    head -n 2 | tail -n 1 | cut -c -43 
}

init_user() {
    local new_comer=$1
    local pubkey_url=$2
    local strong_passwd=`generate_passwd`

    # add user
    useradd -d /home/$new_comer -s /bin/sh -p $strong_passwd \
        -g $Members -m $new_comer 

    # ssh with dsa_pubkey
    cd /home/$new_comer
    wget --no-check-certificate $pubkey_url 
    mkdir .ssh 
    chmod 700 .ssh 
    cat ${pubkey_url##*/} >> .ssh/authorized_keys2
    chmod 600 .ssh/authorized_keys2
    chown -R $new_comer:$Members .ssh

    # copy files to $Chroot
    cd $Chroot
    local pattern="^${new_comer}:x:[0-9]"
    grep $pattern /etc/passwd >> etc/passwd 
    grep $pattern /etc/group >> etc/group 
    grep $pattern /etc/shadow >> etc/shadow 
    mkdir home/$new_comer 
    chown $new_comer:$Members home/$new_comer 

    # report
    echo "Done for $new_comer, whose password is"
    echo $strong_passwd

} 


## main function

case $1 in 
    init)    setup_chroot;;
    add)
        New_comer=$2
        Pubkey_url=$3
        init_user $New_comer $Pubkey_url;;
    *)    help;;
esac

