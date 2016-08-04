# -*- mode: ruby -*-
# coding: utf-8
# vi: set ft=ruby :

require 'json';

##
# JSON configuration file
#
# you can either use the default settings in ./vagrant.dist.json
# or copy it to ./vagrant.json to adapt the config to your local needs
#
local_config_file = File.expand_path '../vagrant.json'
config_file = File.expand_path '../vagrant.dist.json'
fallback_config_file = File.expand_path './vagrant.dist.json'
presets = {}

if File.exists?( local_config_file )
	presets = JSON.parse( File.read local_config_file )
elsif File.exists?( config_file )
	presets = JSON.parse( File.read config_file )
else
	presets = JSON.parse( File.read fallback_config_file )
end

# Store the current version of Vagrant for use in conditionals when dealing
# with possible backward compatible issues.
vagrant_version = Vagrant::VERSION.sub(/^v/, '')

# All Vagrant configuration is done below. The '2' in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

	config.vm.box = presets[ 'box' ]

	##
	# Port forwarding
	# in vagrant.dist.json the ports are given as { "host_port": "guest_port" }
    #
	presets[ 'network' ][ 'forwarded_port' ].each do | host_port, guest_port |
		config.vm.network 'forwarded_port', guest: guest_port, host: host_port
	end

	##
	# Create a private network, which allows host-only access to the machine
	# using a specific IP.
	#
	config.vm.network 'private_network', ip: presets[ 'network' ][ 'private_network' ][ 'ip' ]

	##
	# Create a public network, which generally matched to bridged network.
	# Bridged networks make the machine appear as another physical device on
	# your network.
	# config.vm.network 'public_network'

	##
	# Synced folders
	#
	# in vagrant.dist.json shared folders are given as { "host_folder": "guest_folder" }
	#
	if ! presets[ 'synced_folder' ].nil?
		presets[ 'synced_folder' ].each do | host_folder, guest_folder |
			config.vm.synced_folder host_folder, guest_folder, type: "nfs"
		end
	end

	##
	# SSH Forwarding
	#
	# note: your ssh client should allow forwarding [~/.ssh/config]:
	#
	# Host *
	#     ForwardAgent yes
	#
	config.ssh.forward_agent = true

	##
	# Provisioning
	#

	##
	# share files
	# in vagrant.dist.json shared files are given as { "host_file": "guest_file" }
	#
	# for example, you might want to sync your ""~/.bash_aliases" to ""/home/vagrant/aliases"
	#
	if ! presets[ 'provision' ][ 'file' ].nil?
		presets[ 'provision' ][ 'file' ].each do | host_file, guest_file |
			config.vm.provision 'file', source: host_file, destination: guest_file
		end
	end

	##
	# shell scripts
	#
	# Shell script paths are given as a simple array in vagrant.dist.json
	#
	if ! presets[ 'provision' ][ 'shell_script' ].nil?
		presets[ 'provision' ][ 'shell_script' ].each do | shell_script |
			config.vm.provision 'shell', path: shell_script
		end
	end

  # /srv/database/
  #
  # If a database directory exists in the same directory as your Vagrantfile,
  # a mapped directory inside the VM will be created that contains these files.
  # This directory is used to maintain default database scripts as well as backed
  # up mysql dumps (SQL files) that are to be imported automatically on vagrant up
  #config.vm.synced_folder "database/", "/srv/database"

 # if ! presets[ 'database_sync' ].nil?
 #
 #     presets[ 'database_sync' ].each do | folder, database |
 #
 #       database_folder = "database/data/" + database
 #
 #       source = File.expand_path folder + '/' + database
 #       destiation =  File.expand_path "./database/data/"
 #
 #       unless File.directory?( database_folder )
 #         FileUtils.cp_r( source, destiation )
 #       end
 #
 #       config.vm.synced_folder folder + '/' + database + "/", "/var/lib/mysql/" +  database , :nfs => { :mount_options =>  ["dmode=777","fmode=777"] }
 #
 #     end
 #
 # end

  if vagrant_version >= "1.3.0"
    config.vm.synced_folder "database/data/", "/var/lib/mysql", :nfs => { :mount_options =>  ["dmode=777","fmode=777"] }
  else
    config.vm.synced_folder "database/data/", "/var/lib/mysql", :extra => 'dmode=777,fmode=777'
  end

   ##
   # Trigger software updater after vagrant up
   #
   #config.trigger.after [:up], :stdout => true, :force => true do
   #  run_remote 'bash /vagrant/provisioning/apt-update.sh'
   #end

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

   if ! presets[ 'network' ][ 'private_network' ][ 'host' ].nil?
     config.vm.hostname = presets[ 'network' ][ 'private_network' ][ 'host' ]
   end

   if ! presets[ 'network' ][ 'private_network' ][ 'alias' ].nil?
     config.hostsupdater.aliases = presets[ 'network' ][ 'private_network' ][ 'alias' ]
   end

end
