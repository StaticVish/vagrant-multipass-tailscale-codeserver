# Developer Environment

This is an attempt to setup a common developer environment across the machines. 
This works on Vagrant and Virtual Box
* Uninstall WSL and Docker Desktop from your Laptops
* Remove unnessary softwares
* Ensure Virtualization is Enabled.
* Once you install Vagrant and VirtualBox Clone this Repo
* issue `vagrant up` in the root directory 

This will 
* spin a ubuntu server
* Install Docker , Docker Build Kit and Docker compose plugin 
* Install SDKMAN from sdkman.io for managing various java version 
* Install NVM and boot strtap 20 LTS

On Popular demand for MacOS
1) Install Multipass - Follow the Guide from https://multipass.run/docs/installing-on-macos
2) Below command will run multipass - `multipass --verbose launch 22.04 --name devbox --cpus 2 --memory 8G --disk 75G --bridged --cloud-init multipass-cloud-init.yaml`
3) The above command will Create a Bridge Network, Launch Ubuntu 22.04 [LTS] with a 2 CPU and 8G Memory. The customization is run from cloud-init.
4) The below is executed one by one 

```
multipass exec devbox -- git config --global user.username bonda1980 -- ## Change your Username It cannot be Bonda

multipass mount . devbox:/Works/developer-environment/

multipass exec devbox -- bash "/Works/developer-environment/run_multipass_setup.sh"

```
This setup will 
1) Bring up a Develop Machine with the basic nessary softwares
2) Install Caddy and Code Server
3) Install Tailscale and configure Tailscale VPN
4) Generate SSL Certificates for the Tailscale VPN 
5) Setup Caddy with SSL and make the code server available over Tailscale. 

This setup frees the developer in you and can code from anywhere in the world with or without a Laptop.

See the Env Sample File on how to set it up.

From
Visveswaran Vaidyanathan[@StaticVish]`
