# docker-manage
A small bash script to handle docker containers

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
