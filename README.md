## Docker project: mattcahill/ubuntu-foreman

This image was put together for training and demo purposes.  If intending any real use of this image, then you
should seriously consider persistent volumes for all critical data and configuration.

Tested with foreman 1.9.

The container simply automates instructions at - http://theforeman.org/manuals/1.9/index.html#2.Quickstart

### To use it:

    docker run --restart=always -d -P --name=ubuntu-foreman -h hostname.example.com mattcahill/ubuntu-foreman

(Optional option --restart=always ensures the container is restarted in the event of failure or restart of the parent server/docker daemon.)

### Monitor the foreman install log, as it completes the installation:

    docker logs -f ubuntu-foreman

(the awk bit just gets the container id, and only really works if you are running just one container, its just a quick start guide)

### Get the https port for browser access:

Once finished, find out which local port is assigned to the docker's https/443:

    docker port ubuntu-foreman 443

### Enter the container with a shell:

    docker exec -ti ubuntu-foreman bash
