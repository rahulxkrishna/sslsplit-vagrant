provision() {
    sudo apt-get update
    sudo apt-get --assume-yes install xfce4
    sudo apt-get --assume-yes install firefox
    sudo apt-get --assume-yes install chromium-browser
}

proxy() {
    sudo route add default gw 10.10.10.100 eth1
}

noproxy() {
    sudo route del default gw 10.10.10.100 eth1
}

run() {
    echo "Pass"
}

case "$1" in 
    run)
        run
        ;;
    proxy)
        proxy
        ;;
    noproxy)
        noproxy
        ;;
    provision)
        provision
        ;;
        *)
    echo "Invalid option"
        exit 1
    ;;
esac
