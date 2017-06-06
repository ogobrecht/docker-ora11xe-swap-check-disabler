# HOW TO BUILD THIS IMAGE AND GET AN ORA11XE INSTALL FILE WITHOUT SWAP SPACE CHECK
# --------------------------------------------------------------------------------
# 1. Put the downloaded file oracle-xe-11.2.0-1.0.x86_64.rpm.zip in the same
#    directory as this Dockerfile
# 2. Build the image: Run command `docker build --tag=ora11xe-swap-ckeck-disabler .`
#    in the directory where the Dockerfile is
# 3. Have fun with the following screencast :-)
# 4. Run the image: `docker run -it --name temp ora11xe-swap-ckeck-disabler`
#    (will show top command, without running program container is stopped immediately)
# 5. In a second terminal copy back the modified install file:
#    `docker cp temp:/install/oracle-xe-11.2.0-1.0.x86_64.rpm.zip.swap-check-disabled <path/to/your/local/target/dir>`
# 6. Stop the temp container: `docker stop temp`
# 7. Delete the temp container: `docker container rm temp`
# 8. Delete the image, if you want to save space: `docker rmi ora11xe-swap-ckeck-disabler`

# Pull base image (the same like for the Oracle docker files)
FROM oraclelinux:7-slim

LABEL maintainer="Ottmar Gobrecht" \
      url="github.com/ogobrecht/docker-ora11xe-swap-check-disabler" \
      description="Because of license restrictions every one has to download \
      his/her own Oracle DB install files. The 11gXE has often problems to be \
      installed in docker containers because of failing swap space checks. \
      This Dockerfile tries to automate the creation of an install file with \
      deactivated swap space check."

ENV INSTALL_FILE_ZIP="oracle-xe-11.2.0-1.0.x86_64.rpm.zip" \
    INSTALL_FILE_RPM="oracle-xe-11.2.0-1.0.x86_64.rpm" \
    INSTALL_FILE_NEW="oracle-xe-11.2.0-1.0.x86_64.rpm.zip.swap-check-disabled" \
    PREINSTALL_SCRIPTLET="rpm-preinstall-scriptlet.sh" \
    WORK_DIR="$HOME/install"

COPY $INSTALL_FILE_ZIP $PREINSTALL_SCRIPTLET $WORK_DIR/

# 1. Add the optional yum repo (needed for ruby-devel)
# 2. Install needed yum packages
# 3. Install the magic ruby package: https://github.com/jordansissel/fpm
# 4. Change directory and unzip the install file
# 5. Replace the preinstall scriptlet with our modified version (see scriptlet line 195 - 210)
# 6. Zip the new install file to $HOME (the Oracle Dockerfile need it compressed)
# 7. Cleanup files
RUN yum-config-manager --enable ol7_optional_latest && \
    yum -y install procps-ng unzip ruby ruby-devel gcc make rpm-build && \
    gem install --no-ri --no-rdoc fpm && \
    cd $WORK_DIR && \
    unzip $INSTALL_FILE_ZIP && \
    fpm -s rpm -t rpm -f --before-install $PREINSTALL_SCRIPTLET Disk1/$INSTALL_FILE_RPM && \
    \cp -f $INSTALL_FILE_RPM Disk1/$INSTALL_FILE_RPM && \
    zip -r $INSTALL_FILE_NEW Disk1 && \
    rm $INSTALL_FILE_ZIP && \
    rm $INSTALL_FILE_RPM && \
    rm -rf Disk1

ENTRYPOINT exec top
