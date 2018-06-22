# configure with version "2"
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.box_check_update = true

  config.vm.provider "virtualbox" do |v|
    v.cpus = 2
    v.memory = 2048
  end

  config.vm.network "private_network", ip: "192.168.50.101"
  config.vm.network "forwarded_port", guest: 1234, host: 1234, auto_correct: true

  # avoid 'Innapropriate ioctl for device' messages
  # see vagrant config doc for more info: https://www.vagrantup.com/docs/vagrantfile/ssh_settings.html
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  config.vm.provision "install", type: "shell" do |s|
    s.inline = <<-OUT
      apt-get update
      apt-get install -y sqlite jq
      dpkg -i /vagrant/cabby/cabby_1.0_amd64.deb
    OUT
  end

  config.vm.provision "setup-cabby", type: "shell" do |s|
    s.inline = <<-OUT
      cabby-certs
      CABBY_ENVIRONMENT=production cabby-cli -c /etc/cabby/cabby.json -u test@cabby.com -p test
      systemctl start cabby
    OUT
  end
end
