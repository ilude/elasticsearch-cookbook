elasticsearch = "elasticsearch-#{node.elasticsearch[:version]}"

include_recipe "apt"
include_recipe "build-essential"
include_recipe "ruby_build"
include_recipe "sysstat"
include_recipe "rvm::vagrant"
include_recipe "rvm::system"
include_recipe "rvm::user"
include_recipe "rvm::gem_package"
include_recipe "elasticsearch::curl"
include_recipe "elasticsearch::java"

node.set["bluepill"]["bin"] = "/usr/local/rvm/gems/ruby-#{node[:rvm][:default_ruby]}/bin/bluepill"

include_recipe "bluepill"

group node[:elasticsearch][:user] do
  action :create
  system true
end

user node[:elasticsearch][:user] do
  comment "ElasticSearch User"
  system  true
  gid     node.elasticsearch[:user]
  shell   "/bin/false"
end

# FIX: Work around the fact that Chef creates the directory even for `manage_home: false`
bash "remove the elasticsearch user home" do
  user    'root'
  code    "rm -rf  #{node[:elasticsearch][:dir]}/elasticsearch"
  only_if "test -d #{node[:elasticsearch][:dir]}/elasticsearch"
end

remote_file "/tmp/elasticsearch-#{node[:elasticsearch][:version]}.tar.gz" do
  source    "http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{node[:elasticsearch][:version]}.tar.gz"
  mode      "0644"
  not_if{ File.exists? "/tmp/elasticsearch-#{node[:elasticsearch][:version]}.tar" }
end

bash "gunzip elasticsearch" do
  user  "root"
  cwd   "/tmp"
  code  %(gunzip elasticsearch-#{node[:elasticsearch][:version]}.tar.gz)
  not_if{ File.exists? "/tmp/elasticsearch-#{node[:elasticsearch][:version]}.tar" }
end

bash "extract elasticsearch" do
  user  "root"
  cwd   "/tmp"
  code  <<-EOH
  tar -xf /tmp/elasticsearch-#{node[:elasticsearch][:version]}.tar
  mv elasticsearch-#{node[:elasticsearch][:version]} elasticsearch
  cp -r elasticsearch #{node[:elasticsearch][:dir]}
  EOH
  not_if{ File.exists?(File.join(node[:elasticsearch][:install_dir], "bin/elasticsearch")) }
end

template "elasticsearch.conf" do
  path "/etc/init/elasticsearch.conf"
  source "elasticsearch.conf.erb"
  owner "root"
  group "root"
  mode "0644"
end

# Create ES directories
#
%W[ #{node[:elasticsearch][:config_dir]} #{node[:elasticsearch][:data_dir]} #{node[:elasticsearch][:log_dir]} #{node[:elasticsearch][:pid_path]} ].each do |path|
  directory path do
    owner node[:elasticsearch][:user] 
    group node[:elasticsearch][:user]
    mode 0755
    recursive true
    action :create
    not_if{ File.directory?(path) }
  end
end

template "elasticsearch.yml" do
  path   "#{node[:elasticsearch][:config_dir]}/elasticsearch.yml"
  source "elasticsearch.yml.erb"
  owner node[:elasticsearch][:user] 
  group node[:elasticsearch][:user] 
  mode 0755
end

template "/etc/bluepill/elasticsearch.pill" do
  source "elasticsearch.pill.erb"
end

class BluepillOverride
  def self.provider
    Class.new(Chef::Provider::BluepillService) do
      def shell_out!(*args)
        args.each do |command|
          rvm_shell "#{command}" do
            code command
          end
        end
      end
    end
  end
end

bluepill_service "elasticsearch" do
  provider BluepillOverride.provider
  action [:load, :start]
end