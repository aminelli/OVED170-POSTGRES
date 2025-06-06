FROM postgres:17

RUN apt-get update \
    && apt-get install -y \
    net-tools \
    nano \
    htop \
    iputils-ping \
    psmisc \
    vim \
    sudo \
    less \
    emacs-nox \
    procps



RUN echo "Ofima Postgres" > /etc/motd

RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/motd' >> /etc/bash.bashrc
COPY motd /etc/motd




