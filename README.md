About
-----
This docker image runs your own anki sync server.
The most basic command to run the image is :
```bash 
docker run \
	-v /host/storage/server:/anki/server \
	-v /host/storage/data:/anki/data \
	-p 27701:27701 \
	-d \
	--restart=unless-stopped \
	anki-server
```

Configuration 
-------------
The image can be configured by passing environment variables to the docker-run command.
Supported environment variables :

- `ANKI_SERVER_URL` : git repository of Anki sync server
- `ANKI_SERVER_VCS_SRC` : set to "branch" or "tag" to checkout the corresponding branch or tag
- `ANKI_SERVER_BRANCH` : branch to checkout
- `ANKI_SERVER_TAG` : tag to checkout

The image also stores anki data into `/anki/data`, and the server git code in `/anki/server`.
If you want to preserve this data across restarts, you need to mount folders from your host into the container.
I suggest you do this for both, server repository and your data, as this shortens the time 
it takes to restart the docker container.

### First run

### Adding a user
Currently there is no way to add a user to the server over the web that I am aware of, 
so I suggest you run the script in `server` folder and create an account for yourself :
```bash 
$ /path/to/server/code/ankiserverctl.py adduser myusername
```
and then enter your passsword when prompted.
Copy the auth.db into your data folder before starting the container.
You don't have to have Anki or Anki-sync-server installed for this to work, 
it is simplest to create the authentication database on your personal computer 
and copy the file over to the server.

### Configuring Anki Sync Server
In order for the image to work, Anki sync server must listen on all interfaces.
See the included [configuration](production.ini) for details.
If you start this image without a `production.ini` file in your data folder, 
a suitable configuration file will be copied into your data folder on first run.

Sync to custom server
---------------------
See https://github.com/dsnopek/anki-sync-server for instructions on how to configure AnkiDesktop 
and AnkiDroid. 

### Secure sync
As AnkiDroid currently [does not verify the TLS certificate](https://github.com/dsnopek/anki-sync-server) 
I didn't find it useful to use a web-server proxy. Instead I added a special user to my server, 
that is used only for forwarding ports.
This way I can have a fully secure sync through ssh proxy, on AnkiDroid and AnkiDesktop.

#### Setting up ssh forwarding
Create an file in `/bin/catshell` with the following contents 
```bash 
#!/bin/bash
cat 
```
and make it executable.

Then add a new user to the system and make it user `/bin/catshell` for its shell. 
As this is a fake shell, the user will not be able to do anything on your system, 
except forward ports.
We need a shell that just hangs, so that *ConnectBot* will not disconnect and we can 
use port forwarding on android. If you know a way of just using 
a standard fake shell (like `/bin/false` or `/bin/true`), please let me know.

Add a user with :
```bash
$ sudo adduser --shell /bin/catshell proxyuser
```
and configure sshd by adding the following 
```
Match User sshproxy
    AllowTcpForwarding yes
    # X11Forwarding no
    # PermitTunnel no
    # GatewayPorts no
    # AllowAgentForwarding no
    # PermitOpen <local ip address:port>
    ForceCommand echo 'This account can only be used for port forwarding'
```
to the end of `/etc/ssh/sshd_config`, uncommenting any other options 
if you are using them in your `sshd_config`.

#### Using with AnkiDesktop
Set AnkiDesktop to sync to `localhost:27701` forward the port over ssh before
starting AnkiDesktop with
```bash
$ ssh -L 127.0.0.1:27701:<docker interface ip>:27701 sshproxy@your.host
```

#### Using with AnkiDroid
Download and install [ConnectBot](https://f-droid.org/repository/browse/?fdfilter=connectbot&fdid=org.connectbot) from f-droid.
Set it up to forward a local port over ssh and run it before starting AnkiDroid. 
You can add a desktop shortcut for this command.


License
-------
The scripts in this image are licensed under the MIT license.
AnkiDesktop, AnkiDroid and Anki sync server are provided under their respective software licenses.

