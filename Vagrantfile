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
      apt-get install -y make sqlite jq
      dpkg -i /vagrant/cabby/cabby.deb
    OUT
  end

  config.vm.provision "setup-cabby", type: "shell" do |s|
    s.inline = <<-OUT
      cabby-certs
      /vagrant/scripts/setup-cabby
    OUT
  end

  config.vm.provision "run-cabby", type: "shell" do |s|
    s.inline = <<-OUT
      sudo systemctl enable cabby
      systemctl start cabby
    OUT
  end

  config.vm.provision "restart-cabby", type: "shell", run: "never" do |s|
    s.inline = "systemctl restart cabby"
  end
end
