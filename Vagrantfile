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
end
