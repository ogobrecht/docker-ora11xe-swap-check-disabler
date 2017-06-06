# docker-ora11xe-swap-check-disabler

Many people have problems to install Oracle 11XE in a Docker environment because the install file checks the available swap space in the container. In a container environment this fails often - see [here](https://github.com/oracle/docker-images/issues/294#issuecomment-301465754) or [here](https://www.elastichosts.com/blog/oracle-database-installation-on-a-container-running-centos/), because the swap space is optimized for the entire stack and not controlled from within the operating system of the container.

We have to disable the swap space check in the installation file. I wrote an [blog post about this](https://ogobrecht.github.io/posts/2017-03-21-pitfalls-with-oracle-11g-xe-and-docker-on-mac-os). The problem is here, that you need a Linux based system to do the necessary steps. Under Windows you have no chance. I came up with the idea to do simply all the steps in a Docker container under the same Linux (oraclelinux:7-slim) which is later on needed with the [official Oracle Docker file](https://github.com/oracle/docker-images/blob/master/OracleDatabase/dockerfiles/11.2.0.2/Dockerfile.xe) for an XE instance :-)

For license reasons everyone has to download his/her own copy of the install file from [Oracle OTN](http://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html).

If you are interested in the details - I already extracted the rpm scriptlets for you with this command: `rpm --scripts -qp oracle-xe-11.2.0-1.0.x86_64.rpm > scripts.txt`. I divided then this file into the four scriptlets shipped with this repo. The relevant one is `rpm-preinstall-scriptlet.sh` - see lines 195-210 with the commented block for the swap space check.

1. Clone or download this repository
1. Put the downloaded file oracle-xe-11.2.0-1.0.x86_64.rpm.zip in the same directory as the Dockerfile
1. Open a command shell and go into the directory with the Dockerfile
1. Build the image: Run command `docker build --tag=ora11xe-swap-ckeck-disabler .`
1. Have fun with the following screencast :-)
1. Run the image: `docker run -it --name temp ora11xe-swap-ckeck-disabler` (will show top command, without running a program the container is stopped immediately)
1. In a second command shell copy back the modified install file: `docker cp temp:/install/oracle-xe-11.2.0-1.0.x86_64.rpm.zip.swap-check-disabled <path/to/your/local/target/dir>`
1. Stop the temp container: `docker stop temp`
1. Delete the temp container: `docker container rm temp`
1. Delete the image, if you want to save space: `docker rmi ora11xe-swap-ckeck-disabler`
1. Make a backup of your modified install file for later use, rename it to the original zip file name and have fun with the installation :-)
