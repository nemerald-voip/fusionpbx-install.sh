        #make sure the freeswitch directory exists
        mkdir -p /etc/freeswitch/tls

        #make sure the freeswitch certificate directory is empty
        #rm /etc/freeswitch/tls/*

        #combine the certs into all.pem
        cat ~/ssl/__us_nemerald_net.crt > /etc/freeswitch/tls/all.pem
        cat ~/ssl/__us_nemerald_net.ca-bundle >> /etc/freeswitch/tls/all.pem
        cat ~/ssl/us.nemerald.net.privkey >> /etc/freeswitch/tls/all.pem
        #cat /etc/dehydrated/certs/$domain_alias/chain.pem >> /etc/freeswitch/tls/all.pem

        #copy the certificates
        cp ~/ssl/__us_nemerald_net.crt /etc/freeswitch/tls/cert.pem
        cp ~/ssl/__us_nemerald_net.ca-bundle /etc/freeswitch/tls/chain.pem
        cat ~/ssl/__us_nemerald_net.crt > /etc/freeswitch/tls/fullchain.pem
        cat ~/ssl/__us_nemerald_net.ca-bundle >> /etc/freeswitch/tls/fullchain.pem
        cp ~/ssl/us.nemerald.net.privkey /etc/freeswitch/tls/privkey.pem

        #add symbolic links
        ln -s /etc/freeswitch/tls/all.pem /etc/freeswitch/tls/agent.pem
        ln -s /etc/freeswitch/tls/all.pem /etc/freeswitch/tls/tls.pem
        ln -s /etc/freeswitch/tls/all.pem /etc/freeswitch/tls/wss.pem
        ln -s /etc/freeswitch/tls/all.pem /etc/freeswitch/tls/dtls-srtp.pem

        #set the permissions
        chown -R www-data:www-data /etc/freeswitch/tls

        #set the permissions
        chown -R www-data:www-data /etc/freeswitch/tls

        fs_cli -x "reload mod_sofia"
