FROM jenkins:latest

# Configure Jenkins
COPY config/*.xml $JENKINS_HOME/
COPY config/executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy

# Install plugins
RUN /usr/local/bin/install-plugins.sh \
    ant \
    ansible \
    gradle \
    xunit \
    workflow-aggregator \
    docker-workflow \
    build-timeout \
    credentials-binding \
    ssh-agent \
    ssh-slaves \
    timestamper \
    ws-cleanup \
    email-ext \
    github-organization-folder \
    purge-job-history \
    simple-theme-plugin

USER root

# Install Docker from official repo
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -qqy apt-transport-https ca-certificates && \
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 \
        --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo deb https://apt.dockerproject.org/repo debian-jessie main > /etc/apt/sources.list.d/docker.list && \
    apt-get update -qq && \
    apt-get install -qqy docker-engine && \
    usermod -aG docker jenkins && \
    chown -R jenkins:jenkins $JENKINS_HOME/

ENV ANSIBLE_HOME=/opt/ansible

# Install Ansible (+deps) from git repo & cleanup
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -qqy \
        build-essential \
        python-pip python-dev python-yaml \
        libffi-dev libssl-dev \
        libxml2-dev libxslt1-dev zlib1g-dev

# Set the working directory to /app
WORKDIR /jenky

# Copy the current directory contents into the container at /app
ADD . /jenky

# Install any needed packages specified in requirements.txt
RUN pip install -r requirements.txt


USER jenkins


VOLUME ["/var/jenkins_home", "/var/run/docker.sock", "/etc/ansible"]
