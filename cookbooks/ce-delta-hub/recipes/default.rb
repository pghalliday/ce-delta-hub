include_recipe "nodejs"
include_recipe "git"
include_recipe "zeromq"

user node[:ce_delta_hub][:user] do
end

git "#{node[:ce_delta_hub][:destination]}" do
  user node[:ce_delta_hub][:user]
  repository node[:ce_delta_hub][:repository]
  destination node[:ce_delta_hub][:destination]
  not_if { ::FileTest.exists?(node[:ce_delta_hub][:destination]) }
end

file "#{node[:ce_delta_hub][:destination]}/config.json" do
  owner node[:ce_delta_hub][:user]
  content <<-EOH
{
  "commission": {
    "account": #{node[:ce_delta_hub][:commission][:account]}
  },
  "ce-front-end": {
    "stream": #{node[:ce_delta_hub][:ce_front_end][:stream]},
    "state": #{node[:ce_delta_hub][:ce_front_end][:state]}
  },
  "ce-engine": {
    "stream": #{node[:ce_delta_hub][:ce_engine][:stream]},
    "state": #{node[:ce_delta_hub][:ce_engine][:state]}
  }
}
  EOH
end

bash "start ce-delta-hub server" do
  code <<-EOH
    su -l #{node[:ce_delta_hub][:user]} -c "cd #{node[:ce_delta_hub][:destination]} && npm install && npm start"
  EOH
end
