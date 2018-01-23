############################################################
# Dockerfile that creates a container for running Foreman (nightly) on phusion/baseimage
# (which is just a modified version of Ubuntu)
#
# Recommended build command:
#
#   docker build -t foreman /path/to/Dockerfile/dir/.
#
# Recommended run command:
#
#   docker run -t --hostname="foreman.company.com" --name=foreman -p 8443:443 -p 8080:80 foreman
#
# That will expose Foreman on ports 8443 and 8080 with the given hostname (use your own).
############################################################

FROM phusion/baseimage
MAINTAINER Dan McDougall <daniel.mcdougall@liftoffsoftware.com>

# Ensures apt doesn't ask us silly questions:
ENV DEBIAN_FRONTEND noninteractive

# Add the Foreman repos
RUN echo "deb http://deb.theforeman.org/ xenial nightly" > /etc/apt/sources.list.d/foreman.list
RUN echo "deb http://deb.theforeman.org/ plugins nightly" >> /etc/apt/sources.list.d/foreman.lis
RUN curl http://deb.theforeman.org/pubkey.gpg | apt-key add -
RUN curl http://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb -o puppet-release-xenial.deb
RUN dpkg -i puppet-release-xenial.deb
RUN apt-get update --fix-missing && apt-get -y upgrade && \
    apt-get -y install git puppet-agent apache2 build-essential ruby ruby-dev rake \
    bundler postgresql-9.5 postgresql-client-9.5 python \
    postgresql-server-dev-9.5 libxml2-dev libxslt1-dev libvirt-dev \
    foreman-installer foreman-cli foreman-postgresql
RUN apt-get -y clean
RUN ln -s /opt/puppetlabs/bin/facter /usr/bin/
RUN ln -s /opt/puppetlabs/bin/puppet /usr/bin/
RUN curl http://deb.theforeman.org/pool/plugins/nightly/p/puppet-agent-oauth/puppet-agent-oauth_0.5.1-2_all.deb -o puppet-agent-oauth_0.5.1-2_all.deb
RUN dpkg -i puppet-agent-oauth_0.5.1-2_all.deb


# Copy our first_run.sh script into the container:
COPY first_run.sh /usr/local/bin/first_run.sh
RUN chmod 755 /usr/local/bin/first_run.sh
# Also copy our installer script
COPY install_foreman.sh /opt/install_foreman.sh
RUN chmod 755 /opt/install_foreman.sh

# Perform the installation
RUN bash /opt/install_foreman.sh
RUN rm -f /opt/install_foreman.sh # Don't need it anymore

# Expose our HTTP/HTTPS ports:
EXPOSE 80
EXPOSE 443

# Our 'first run' script which takes care of resetting the DB the first time
# the image runs with subsequent runs being left alone:
CMD ["/usr/local/bin/first_run.sh"]
