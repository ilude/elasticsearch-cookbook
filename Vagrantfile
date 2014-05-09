# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.berkshelf.enabled = true
  config.omnibus.chef_version = :latest

  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  config.vm.hostname = "elasticsearch-berkshelf"

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  # config.vm.network :private_network, ip: "33.33.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.

  # config.vm.network :public_network

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"] 
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
  end

  #
  # View the documentation for the provider you're using for more
  # information on available options.

  # The path to the Berksfile to use with Vagrant Berkshelf
  # config.berkshelf.berksfile_path = "./Berksfile"

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to exclusively install and copy to Vagrant's shelf.
  # config.berkshelf.only = []

  # An array of symbols representing groups of cookbook described in the Vagrantfile
  # to skip installing and copying to Vagrant's shelf.
  # config.berkshelf.except = []

  #config.vm.provision :shell, :inline => "sudo apt-get -o Acquire::http::Pipeline-Depth=0 update -y"
  # upgrade the chef install that comes on the base box
  
  # Otherwise rvm undoes omnibus.chef_version = :latest
  # config.vm.provision :shell, :inline => "gem install chef --version 11.12.4 --no-rdoc --no-ri --conservative"
  
  config.vm.provision :chef_solo do |chef|
    chef.add_recipe "apt::default"
    chef.add_recipe "elasticsearch::default"
    chef.json = {
      :apt => {:compiletime => true},
      :rvm => {
        :rubies => %w(2.0.0-p353),
        :default_ruby => '2.0.0-p353',
        :user_default_ruby => '2.0.0-p353',
        :global_gems => [
          {:name => 'bundler'},
          {:name => 'chef'},
          {:name => 'rubygems-bundler', 'action'  => 'remove' }
        ],
        :rvmrc => {
          'rvm_project_rvmrc'             => 1,
          'rvm_gemset_create_on_use_flag' => 1,
          'rvm_trust_rvmrcs_flag'         => 1
        },
        :gem_package => {
          :rvm_string => '2.0.0-p353'
        }
      },
      :mysql => {
        :server_root_password => 'rootpass',
        :server_debian_password => 'debpass',
        :server_repl_password => 'replpass'
      }
    }
  end
end
