# Pin the Guest OS
OS_IMAGE = "bento/ubuntu-22.04"

# Determine the host OS
HOST_OS = RbConfig::CONFIG['host_os']
puts "The Virtual Machine has been called from #{HOST_OS} OS"

# Function to read the .env file and load variables into ENV
def load_env
  env_file = File.join(File.dirname(__FILE__), '.env')
  
  if File.exist?(env_file)
    File.foreach(env_file) do |line|
      key, value = line.split('=')
      ENV[key] = value.chomp if key && value
    end
  else
    abort("The .env file does not exist in the current directory. Process terminated.")
  end
end

# Load the .env file
load_env

# Check for necessary ENV variables
['AUTH_KEY', 'API_KEY'].each do |var|
  if ENV[var].nil? || ENV[var].empty?
    abort("#{var} not found in the .env file. Process terminated.")
  end
end


disk_name = File.join(Dir.home, "VirtualBox VMs", "Works.vdi")
ephemeral_disk_name = File.join(Dir.home, "VirtualBox VMs", "EphemeralDocker.vdi")


git_username = `git config user.username`.chomp
puts "The Command is being Executed for Git User : #{git_username}"


if git_username.nil? || git_username.to_s.strip.empty?
  raise "Configure git First. I am not able to Identify your git.username"
end

Vagrant.configure("2") do |config|
  
  config.ssh.insert_key = false

  config.vm.define "devbox" do |devbox|
    devbox.vm.box = OS_IMAGE
    devbox.vm.hostname = 'devbox'

    # OS-specific configurations
    disk_base_path = File.join(Dir.home, "VirtualBox VMs")
    if HOST_OS =~ /darwin/i # MacOS
      vboxmanage_path = "/usr/local/bin/VBoxManage"
      network_bridge = "en0: Wi-Fi (AirPort)"
    elsif HOST_OS =~ /mswin|mingw|cygwin/i # Windows
      vboxmanage_path = 'C:\\Program Files\\Oracle\\VirtualBox\\VBoxManage.exe'
      network_bridge = "eth1"
    else
      abort("Unsupported host OS. Only Windows and MacOS are supported.")
    end
    
    devbox.vm.network "public_network", bridge: network_bridge


    # HDD Creation Triggers
    [disk_name, ephemeral_disk_name].each_with_index do |disk, index|
      devbox.trigger.before [:up] do |trigger|
        unless File.exists?(disk)
          trigger.info = "Creating disk: #{disk}"
          if HOST_OS =~ /mswin|mingw|cygwin/i
            command = "& '#{vboxmanage_path}' 'createmedium' 'disk' '--filename' '#{disk}' '--format' 'VDI' '--size' '#{index.zero? ? 5120 : 30720}'"
          else
            command = "#{vboxmanage_path} createmedium disk --filename \"#{disk}\" --format VDI --size #{index.zero? ? 5120 : 30720}"
          end
          trigger.run = {inline: command}
        else
          trigger.info = "#{disk} exists. Moving on!"
        end
      end
    end

  # HDD Detachment Triggers
  [disk_name, ephemeral_disk_name].each_with_index do |disk, index|
    devbox.trigger.before [:halt] do |trigger|
      if File.exists?(".vagrant/machines/devbox/virtualbox/id")
        machineId = File.read(".vagrant/machines/devbox/virtualbox/id").chomp
        trigger.info = "Detaching disk: #{disk}"
        if HOST_OS =~ /mswin|mingw|cygwin/i
          command = "& '#{vboxmanage_path}' 'storageattach' '#{machineId}' '--storagectl' 'SATA Controller' '--port' '#{index + 1}' '--device' '0' '--type' 'hdd' '--medium' 'none'"
        else
          command = "#{vboxmanage_path} storageattach #{machineId} --storagectl 'SATA Controller' --port #{index + 1} --device 0 --type hdd --medium none"
        end
        trigger.run = {inline: command}
      else
        trigger.info = "No VM found to detach disks from."
      end
    end
  end

    # Define the Folders required to be Synchronized between Laptop and Virtual Box VM
    # devbox.vm.synced_folder ".", "/vagrant", disabled: true
    devbox.vm.synced_folder ".", "/BASE", type: "rsync" # This is the folder for configuring the DevBox. It runs as a local ansible playbook
    
    # Define the Ports that we want to forward from our Laptops to the Virtual Box VM
    devbox.vm.network "forwarded_port", guest: 80, host: 80, protocol: "tcp"
    devbox.vm.network "forwarded_port", guest: 443, host: 443, protocol: "tcp"
    devbox.vm.network "forwarded_port", guest: 8080, host: 8080, protocol: "tcp"
    devbox.vm.network "forwarded_port", guest: 8443, host: 8443, protocol: "tcp"
    devbox.vm.network "forwarded_port", guest: 9090, host: 9090, protocol: "tcp"
    devbox.vm.network "forwarded_port", guest: 9443, host: 9443, protocol: "tcp"    
    devbox.vm.network "forwarded_port", guest: 3000, host: 3000, protocol: "tcp"
    devbox.vm.network "forwarded_port", guest: 8081, host: 8081, protocol: "tcp"
    devbox.vm.network "forwarded_port", guest: 1080, host: 1080, protocol: "tcp"    
    devbox.vm.network "forwarded_port", guest: 19090, host: 19090, protocol: "tcp"        
    devbox.vm.network "forwarded_port", guest: 3306, host: 3306, protocol: "tcp"             
    devbox.vm.network "forwarded_port", guest: 16686, host: 16686, protocol: "tcp" 
    devbox.vm.network "forwarded_port", guest: 5432, host: 5432, protocol: "tcp"  # For postgres           
    devbox.vm.network "forwarded_port", guest: 2375, host: 2375, protocol: "tcp" # Port Forwarded for Docker Daemon.      

    devbox.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", 10240]
      v.customize ["modifyvm", :id, "--name", "devbox"]
      v.customize ["modifyvm", :id, "--cpus", 4]
      v.customize ["storageattach", :id, "--storagectl",  "SATA Controller", "--port", "1", "--device", "0", "--type", "hdd", "--medium", "#{disk_name}", "--hotpluggable", "on" ]
      v.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", "2", "--device", "0", "--type", "hdd", "--medium", "#{ephemeral_disk_name}", "--hotpluggable", "on"]
    end
  
  # Define the Provisioning Scripts.
    common = <<-SCRIPT
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -y 
    sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y 
    sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y
    sudo lvextend -l +100%FREE  /dev/ubuntu-vg/ubuntu-lv
    sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
    SCRIPT

    devbox.vm.provision :shell, :inline => common
    
    devbox.vm.provision "ansible_local" do |ansible|
      # ansible.verbose = "vvvvv"
      ansible.install = true
      ansible.install_mode = "pip"
      ansible.version = "6.7.0"
      ansible.provisioning_path = "/BASE"
      # ansible.playbook = "configure-node-setup.yaml"
      ansible.playbook = "99-devbox-configure-node.yaml"
      ansible.galaxy_role_file = "requirements.yml"
      ansible.extra_vars = {
        git_username: "#{git_username.strip}",
        tailscale_domain:"#{ENV['TAILSCALE_DOMAIN'].strip}",
        tailscale_auth_key:"#{ENV['AUTH_KEY'].strip}",
        tailscale_api_key:"#{ENV['API_KEY'].strip}",
        tailnet:"#{ENV['TAILNET'].strip}",
      }
    end 
  end  
end
