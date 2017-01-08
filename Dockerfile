FROM jenkins:2.19.4

# jenkins Docker image defaults to uid/gid of 1000/1000. This prevents us from mounting ssh keys or forwarding ssh-agent.
# allow us to set uid&gid as build args so we can inherit them from the host user
ARG user=jenkins
ARG group=jenkins
ARG olduid=1000
ARG oldgid=1000
ARG uid
ARG gid
ENV JENKINS_HOME /var/lib/jenkins
ENV COPY_REFERENCE_FILE_LOG $JENKINS_HOME/copy_reference_file.log
USER root
RUN usermod -u $uid $user
RUN usermod -d /var/lib/jenkins $user
RUN groupmod -g $gid $group
RUN usermod -g $gid $group
RUN find / -path /proc -prune -o -group $oldgid -print | xargs chgrp -hv $group
RUN find / -path /proc -prune -o -user $olduid -print | xargs chown -hv $user
RUN cp -R /var/jenkins_home /var/lib/jenkins

# necessary to enable ssh-agent forwarding
ADD ssh_config /var/lib/jenkins/.ssh/config
RUN chmod -R go-rwx /var/lib/jenkins/.ssh/

# enable agent-to-master security
RUN mkdir -p /var/lib/jenkins/secrets/
RUN echo false > /var/lib/jenkins/secrets/slave-to-master-security-kill-switch

RUN chown -R $user:$group /var/lib/jenkins
VOLUME /var/lib/jenkins
USER $user

COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY groovy/ /usr/share/jenkins/ref/init.groovy.d/
RUN ssh-agent
