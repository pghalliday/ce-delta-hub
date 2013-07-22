default[:ce_delta_hub][:repository] = "https://github.com/pghalliday/ce-delta-hub.git"
default[:ce_delta_hub][:destination] = "/opt/ce-delta-hub"
default[:ce_delta_hub][:user] = "ce-delta-hub"
default[:ce_delta_hub][:commission][:account] = "commission"
default[:ce_delta_hub][:ce_front_end][:stream] = "5000"
default[:ce_delta_hub][:ce_front_end][:state] = "5001"
default[:ce_delta_hub][:ce_engine][:stream] = "5002"
default[:ce_delta_hub][:ce_engine][:state] = "5003"

# dependency defaults
default[:nodejs][:install_method] = "package"
default[:git][:version] = "1.8.3"
default[:zeromq][:version] = "3.2.3"
default[:zeromq][:url] = "http://download.zeromq.org"
