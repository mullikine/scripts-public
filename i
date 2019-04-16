#!/bin/bash
export TTY

# Internet and netwrok scripts

is_tty() {
    # If stout is a tty
    [[ -t 1 ]]
}

pager() {
    if is_tty; then
        xc -i -
    else
        cat
    fi
}

vc_opt="$1"
shift
case "$vc_opt" in
    getip) {
        ip="$(timeout 5 dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')"

        # Sometimes the google nameserver is not available
        test -z "$ip" && ip="$(getip.rkt)"
        test -z "$ip" && ip="$(curl ifconfig.me 2>/dev/null)"
        echo "$ip" | xct
    }
    ;;

    4|4l) {
        # gateway-interface could be: wlp3s0
        # local_ip="$(sudo ifconfig 2>&1 | awk-apply-to-record -k -r '\n\n' 'sed -z -n /'$(i gateway-interface)'/p | nl' | scrape 'inet addr[^ ]+' | cut -d : -f 2)"

        local_ip="$(sudo ifconfig 2>&1 | awk-apply-to-record -k -r '\n\n' 'ugrep '$(i gateway-interface)' | nl' | scrape 'inet addr: *[^ ]+' | cut -d : -f 2)"
        echo "$local_ip" | xct
    }
    ;;

    6|6l) {
        # gateway-interface could be: wlp3s0
        local_ip="$(sudo ifconfig 2>&1 | awk-apply-to-record -k -r '\n\n' 'ugrep '$(i gateway-interface)' | nl' | scrape 'inet6 addr: *[^ ]+' | s lf)"
        echo "$local_ip" | xct
    }
    ;;
    

    gwi|gateway-interface) {
        netstat -rn | grep "^0.0.0.0" | s lf | xct
    }
    ;;

    gw|gateway) {
        gateway_ip="$(netstat -rn | grep "^0.0.0.0" | s field 2 | grep -v 0.0.0.0 | head -n 1)"

        echo "$gateway_ip" | xct

        #if is_tty; then
        #    ff "$gateway_ip"
        #fi
    }
    ;;

    list-computers) {
        arp-scan --localnet
        arp -a
    }
    ;;

    get-dns) {
        nmcli dev show | grep DNS | s field 2 | s chomp | xc -i
    }
    ;;

    dhcp-start) {
        sudo dhclient -v
    }
    ;;

    dhcp-restart) {
        sudo dhclient -r
    }
    ;;

    restart-wifi) {
        sudo ifconfig wlp3s0 down
        sleep 1
        sudo ifconfig wlp3s0 up
    }
    ;;

    scan) {
        sudo iwlist wlp3s0 scan|less
    }
    ;;

    port2pid) {
        port="$1"
        lsof -i :$port | sed 1d | s field 2
    }
    ;;

    port2name) {
        i port2pid 8008 | xa ps -ef -q | sed 1d | rev | s field 1 | rev
    }
    ;;

    portapps) {
        nmap -sT localhost | while read line; do
            lit "$line"
            if lit "$line" | grep -q -P '^[0-9]'; then
                port="$(lit "$line" | mcut -d / -f 1)"
                i port2pid "$port" | sed 1d | s indent 1
            fi
        done | less -S
        # Annotate with what's on the port
    }
    ;;

    *)
esac
