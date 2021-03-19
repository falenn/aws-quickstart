# Dockerfile for building Ansible image for Debian 8 (jessie), with as few additional software as possible.
#
# @see https://launchpad.net/~ansible/+archive/ubuntu/ansible
#
# Version  1.0
#


# pull base image
FROM debian:stable

MAINTAINER Curtis Bates <dev@imwiz.com> based on William Yeh <william.pjyeh@gmail.com>


RUN echo "===> Installing python, sudo, and supporting tools..."  && \
    apt-get update -y  &&  apt-get install --fix-missing          && \
    DEBIAN_FRONTEND=noninteractive         \
    apt-get install -y                     \
        python3 python-yaml sudo            \
        curl gcc python3-pip python3-dev libffi-dev libssl-dev  && \
    apt-get -y --purge remove python3-cffi    && \
    \
    \
    echo "===> Installing handy tools (not absolutely required)..."  && \
    apt-get install -y sshpass openssh-client && \
    \
    echo "python version: `python -v`" && \
    ln -s /usr/bin/pip3 /usr/bin/pip && \
    rm -rf /usr/bin/python && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    \
    echo "===> Removing unused APT resources..."                  && \
    apt-get -f -y --auto-remove remove \
                 gcc python3-dev libffi-dev libssl-dev            && \
    apt-get clean                                                 && \
    rm -rf /var/lib/apt/lists/*  /tmp/*
    
RUN echo "==>Installing Ansible and PIP modules===" && \
    pip install --upgrade setuptools         && \
    pip install --upgrade pycrypto           && \
    pip install --upgrade cffi pywinrm       && \
    pip install --upgrade boto               && \
    \
    \
    echo "===> Installing Ansible..."   && \
    pip install ansible                 && \
    \
    \
    pip list && \
    echo "==>Setting up Ansible"                       && \
    echo "===> Adding hosts for convenience..."        && \
    mkdir -p /etc/ansible                              && \
    echo 'localhost' > /etc/ansible/hosts


# default command: display Ansible version
CMD [ "ansible-playbook", "--version" ]
#CMD [ "/bin/sh" ]
