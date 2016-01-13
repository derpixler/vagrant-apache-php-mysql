# -*- mode: ruby -*-
# vi: set ft=ruby :

dir = Dir.pwd
vagrant_dir = File.expand_path(File.dirname(__FILE__))

Vagrant.configure("2") do |config|

  # Store the current version of Vagrant for use in conditionals when dealing
  # with possible backward compatible issues.
  vagrant_version = Vagrant::VERSION.sub(/^v/, '')

  # Configurations from 1.0.x can be placed in Vagrant 1.1.x specs like the following.
  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--memory", 8042]
  end

  # Forward Agent
  #
  # Enable agent forwarding on vagrant ssh commands. This allows you to use identities
  # established on the host machine inside the guest. See the manual for ssh-add
  config.ssh.forward_agent = true

  # Default Ubuntu Box
  #
  # This box is provided by Vagrant at vagrantup.com and is a nicely sized (290MB)
  # box containing the Ubuntu 12.0.4 Precise 32 bit release. Once this box is downloaded
  # to your host computer, it is cached for future use under the specified box name.
  config.vm.box = "debian/jessie64"

  config.vm.hostname = "playground"

  # Local Machine Hosts
  #
  # If the Vagrant plugin hostsupdater (https://github.com/cogitatio/vagrant-hostsupdater) is
  # installed, the following will automatically configure your local machine's hosts file to
  # be aware of the domains specified below. Watch the provisioning script as you may be
  # required to enter a password for Vagrant to access your hosts file.
  #
  # By default, we'll include the domains setup by VVV through the vvv-hosts file
  # located in the www/ directory.
  #
  # Other domains can be automatically added by including a vvv-hosts file containing
  # individual domains separated by whitespace in subdirectories of www/.
  if defined? VagrantPlugins::HostsUpdater

    # Capture the paths to all vvv-hosts files under the www/ directory.
    paths = []
    Dir.glob(vagrant_dir + '/config/hosts.list').each do |path|
      paths << path
    end

    # Parse through the vvv-hosts files in each of the found paths and put the hosts
    # that are found into a single array.
    hosts = []
    paths.each do |path|
      new_hosts = []
      file_hosts = IO.read(path).split( "\n" )
      file_hosts.each do |line|
        if line[0..0] != "#"
          sameHosts = line.gsub( ' ', '' ).split( "|" )
          if sameHosts.length > 1
            sameHosts.each do |shost|
              new_hosts << shost
            end
          else
            new_hosts << line
          end
        end
      end
      hosts.concat new_hosts
    end

    # Pass the final hosts array to the hostsupdate plugin so it can perform magic.
    config.hostsupdater.aliases = hosts

  end


  # Default Box IP Address
  #
  # This is the IP address that your host will communicate to the guest through. In the
  # case of the default `192.168.50.4` that we've provided, VirtualBox will setup another
  # network adapter on your host machine with the IP `192.168.50.1` as a gateway.
  #
  # If you are already on a network using the 192.168.50.x subnet, this should be changed.
  # If you are running more than one VM through VirtualBox, different subnets should be used
  # for those as well. This includes other Vagrant boxes.
  config.vm.network :private_network, ip: "192.168.56.101"

  # Drive mapping
  #
  # The following config.vm.synced_folder settings will map directories in your Vagrant
  # virtual machine to directories on your local machine. Once these are mapped, any
  # changes made to the files in these directories will affect both the local and virtual
  # machine versions. Think of it as two different ways to access the same file. When the
  # virtual machine is destroyed with `vagrant destroy`, your files will remain in your local
  # environment.

  # /srv/database/
  #
  # If a database directory exists in the same directory as your Vagrantfile,
  # a mapped directory inside the VM will be created that contains these files.
  # This directory is used to maintain default database scripts as well as backed
  # up mysql dumps (SQL files) that are to be imported automatically on vagrant up
  #config.vm.synced_folder "database/", "/srv/database"
  if vagrant_version >= "1.3.0"
    config.vm.synced_folder "database/data/", "/var/lib/mysql", :mount_options => [ "dmode=777", "fmode=777" ]
  else
    config.vm.synced_folder "database/data/", "/var/lib/mysql", :extra => 'dmode=777,fmode=777'
  end

  # /srv/log/
  config.vm.synced_folder "log/", "/srv/log"


  # /srv/www/
  #
  # If a www directory exists in the same directory as your Vagrantfile, a mapped directory
  # inside the VM will be created that acts as the default location for Apache sites. Put all
  # of your project files here that you want to access through the web server
  if vagrant_version >= "1.3.0"
    config.vm.synced_folder "html/", "/srv/html/", :owner => "www-data", :mount_options => [ "dmode=775", "fmode=774" ]
  else
    config.vm.synced_folder "html/", "/srv/html/", :owner => "www-data", :extra => 'dmode=775,fmode=774'
  end

  config.vm.synced_folder "scripts/", "/srv/scripts"
  config.vm.synced_folder "config/", "/srv/config"
  config.vm.synced_folder "config/", "/srv/database"

  # shell scripts
  config.vm.provision :shell, path: "scripts/provision.sh"
  config.vm.provision :shell, path: "scripts/webroute.sh"
  config.vm.provision :shell, path: "scripts/vhosts.sh"
  config.vm.provision :shell, path: "scripts/composer.sh"

  # Prevent stdin: is not a tty error
  # @see http://foo-o-rama.com/vagrant--stdin-is-not-a-tty--fix.html
  config.vm.provision "fix-no-tty", type: "shell" do |s|
      s.privileged = false
      s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end

end
