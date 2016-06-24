Vagrant.configure(2) do |config|

  config.vm.define "sslsplit-server" do |ss|
    ss.vm.box = "ubuntu/trusty64"
    ss.vm.hostname = "sslsplit-server"
    ss.vm.network 'private_network', ip: '10.10.10.100'
    ss.vm.provision "shell" do |s|
        s.path="sslsplit-server.sh"
        s.args="provision"
    end
    ss.vm.provider "virtualbox" do |vb|
        vb.name = "sslsplit-server"
        vb.memory = 4096
        vb.cpus = 4
    end
  end

  config.vm.define "sslsplit-client" do |sc|
    sc.vm.box = "ubuntu/trusty64"
    sc.vm.hostname = "sslsplit-client"
    sc.vm.network 'private_network', ip: '10.10.10.101'
    sc.vm.provision "shell" do |s|
        s.path="sslsplit-client.sh"
        s.args="provision"
    end
    sc.vm.provider "virtualbox" do |vb|
        vb.name = "sslsplit-client"
        vb.memory = 4096
        vb.cpus = 4
        vb.gui = true
    end
  end
end
