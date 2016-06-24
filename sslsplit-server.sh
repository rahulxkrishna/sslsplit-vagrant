# Adopted from here
# https://blog.heckel.xyz/2013/08/04/use-sslsplit-to-transparently-sniff-tls-ssl-connections/

HOME=/home/vagrant
SSLSPLIT_VERSION=sslsplit-0.5.0
SSLSPLIT_DIR=/home/vagrant/sslsplit

provision() {
    # Install sslsplit
    apt-get update
    apt-get install --assume-yes libssl-dev libevent-dev

    su vagrant
    wget http://mirror.roe.ch/rel/sslsplit/${SSLSPLIT_VERSION}.tar.bz2 -P ${SSLSPLIT_DIR}/versions
    cd ${SSLSPLIT_DIR}/versions
    bunzip2 ${SSLSPLIT_DIR}/versions/${SSLSPLIT_VERSION}.tar.bz2  
    tar xvf ${SSLSPLIT_DIR}/versions/${SSLSPLIT_VERSION}.tar  
    cd ${SSLSPLIT_DIR}/versions/${SSLSPLIT_VERSION}
    make
    mkdir -p ${SSLSPLIT_DIR}
    ln -s ${SSLSPLIT_DIR}/versions/${SSLSPLIT_VERSION}/sslsplit ${SSLSPLIT_DIR}/sslsplit
    mkdir -p /tmp/sslsplit

    # Create private key an self-signed root certificate
    # http://crohr.me/journal/2014/generate-self-signed-ssl-certificate-without-prompt-noninteractive-mode.html
    openssl genrsa -des3 -passout pass:x -out ${SSLSPLIT_DIR}/server.pass.key 2048
    openssl rsa -passin pass:x -in ${SSLSPLIT_DIR}/server.pass.key -out ${SSLSPLIT_DIR}/server.key
    rm ~/sslsplit/server.pass.key
    openssl req -new -key ${SSLSPLIT_DIR}/server.key -out ${SSLSPLIT_DIR}/server.csr \
        -subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=IT Department/CN=example.com"
    openssl x509 -req -days 365 -in ${SSLSPLIT_DIR}/server.csr -signkey ${SSLSPLIT_DIR}/server.key -out ${SSLSPLIT_DIR}/server.crt


    # Enable IP forwarding
    sysctl -w net.ipv4.ip_forward=1
    iptables -t nat -F
    iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
    iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-ports 8443
    iptables -t nat -A PREROUTING -p tcp --dport 587 -j REDIRECT --to-ports 8443
    iptables -t nat -A PREROUTING -p tcp --dport 465 -j REDIRECT --to-ports 8443
    iptables -t nat -A PREROUTING -p tcp --dport 993 -j REDIRECT --to-ports 8443
    iptables -t nat -A PREROUTING -p tcp --dport 5222 -j REDIRECT --to-ports 8080
}


run() {
    # Run sslsplit
    mkdir logdir
    ${SSLSPLIT_DIR}/sslsplit -D -l connections.log -j /tmp/sslsplit/ -S logdir/ -k ${SSLSPLIT_DIR}/server.key -c ${SSLSPLIT_DIR}/server.crt https 0.0.0.0 8443 http 0.0.0.0 8080
}

case "$1" in 
    run)
        run
        ;;
    provision)
        provision
        ;;
        *)
    echo "Invalid option"
        exit 1
    ;;
esac
