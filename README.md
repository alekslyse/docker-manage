# docker-manage

REMEMBER: THIS SCRIPT DESTROY ALL CONTAINERS ON YOUR DOCKER BEFORE READDING. IF YOU DONT WANT THAT REMOVE IT IN THE CODE. I TAKE NO RESPONSIBILITY.

A small bash script to handle docker containers. Its quite handy when you have one folder named docker-compose / compose or whatever you want, then have one sub directory for each docker-compmpose.yml - this script first delete all old images from the docker system (assumes all is started through the compose files. NO NOT USE IF NOT), then jump into each folder, check for anything to pull, then start. It tries to start it a few times as sometimes it dont start on the first try). If its any port or IP conflict it try to figure out what is stopping it.

It got some parameters like log state and operation mode (one just for testing etc). 

In general a very basic script that is half-working. It does the following

1. Check for a docker-compose.yml in all sub folders
2. Stop all existing docker images (it assumes you want to redo all of them)
3. start one by one, catching conflicts
4. showing some logs

TODO:
1. more control over what is being done
2. Better conflict checks
3. Start and stop order
4. Relationships/dependancies
5. Exclude and/or explicit Include folders, in directory or config file
6. Save some stats so it can show approx time to run


A very handy script if you want to start/stop a big docker-compose library.

WARNING: This can destroy everything you have. backup first, I take no responsibility.
