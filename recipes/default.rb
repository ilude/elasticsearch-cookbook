elasticsearch = "elasticsearch-#{node.elasticsearch[:version]}"

include_recipe "elasticsearch::curl"
include_recipe "elasticsearch::java"

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

unless(::Dir.exists?("#{node[:elasticsearch][:working_dir]}/bin/elasticsearch"))

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
    code  "tar -xf /tmp/elasticsearch-#{node[:elasticsearch][:version]}.tar"
  end

  bash "copy elasticsearch" do
    user  "root"
    cwd   "/tmp"
    code  "cp -r elasticsearch-#{node[:elasticsearch][:version]} #{node[:elasticsearch][:working_dir]}"
    not_if{ Dir.exists?(node[:elasticsearch][:working_dir]) }
  end

  service 'elasticsearch' do
    provider Chef::Provider::Service::Upstart
    action [:enable, :stop]
    only_if { File.exists?('/etc/init/elasticsearch.conf') }
  end

  bash "remove old elasticsearch dir" do
    user  "root"
    code  "rm -r /opt/elasticsearch"
    only_if{ Dir.exists?("/opt/elasticsearch") }
  end

  bash "install elasticsearch" do
    user  "root"
    code  "ln -s #{node[:elasticsearch][:working_dir]} #{node[:elasticsearch][:install_dir]}"
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

  service 'elasticsearch' do
    provider Chef::Provider::Service::Upstart
    action [:enable, :start]
  end
end