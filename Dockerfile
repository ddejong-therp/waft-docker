FROM ubuntu:24.04


# Set up system
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y --no-install-recommends \
	build-essential ca-certificates git openssh-server ssh sudo curl libssl-dev libxslt1.1 \
	liblcms2-2 libpq5 libldap2 libsasl2-2 bzip2 \
	libtinfo-dev libncurses5-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
	libncursesw5-dev tk-dev libxmlsec1-dev libffi-dev liblzma-dev adduser lsb-base libxml2-dev \
	libxslt1-dev libpq-dev libldap2-dev libsasl2-dev libopenjp2-7-dev libjpeg-turbo8-dev \
	libtiff5-dev libfreetype6-dev liblcms2-dev libwebp-dev
RUN useradd -d /home/waft -s /bin/bash waft
RUN usermod --password waft waft
RUN mkdir -p /home/waft/.ssh
RUN chown -R waft:users /home/waft
RUN echo "service ssh start" >> /root/.bashrc


USER waft
RUN git config --global user.name "Danny de Jong"
RUN git config --global user.email "ddejong@therp.nl"

# Clone all needed customer repositories upon first login
RUN cat > /home/waft/.profile <<PROFILE
#!/bin/bash
function prepare_repo() {
	if [ ! -d "\$1" ]; then
		git clone -b "\$3" "\$2" "\$1"
	fi
}

function prepare_gitlab_repo() {
	prepare_repo "\$1" "git@gitlab.therp.nl:\$2/\$1.git" "\$3"
}


prepare_gitlab_repo aectual therp build-12.0-production
prepare_gitlab_repo freshfilter sunflowerit build-14.0-production
prepare_repo inuka git@gitlab.therp.nl:inuka/inuka_custom_modules.git build-16.0-production
PROFILE

# Set up ssh for the waft user
RUN cat > /home/waft/.ssh/authorized_keys <<KEY
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC39DiDDuJsjexBPfBhHTzNATMjpnjR+gFR5qcfKCogytuD19PiCyESRx2DtPCHKVvmHWNbDeIwHG9LXsspZLoIFijl15JL3t9JC8n0etDALMKoW9VxS6Itq0YwaoiEw5W4QcVc6Oe+dMF/nWiv7tPLf9TT6jkfrZjuBb1O7KL/P/UmGLHU8hhQPu+tv/k+AZaDHZSh9/FdvxZ+ayxBFXCSIDS2mEe4KjKnVunRZHjk6R9WzEJEYSxZhCFHiXkQ6QBCPYHiBxB0opNaFCHIzKLCuVzFL7zjFMpeL025GrJdasLQYe8LAn/Ms2/JqVKVlzFF6SISG/s7FPuaM6fLNhtSqQ8UTvMm3x29+TBvCCp25dDXFmuvhCZttzLgfTG0cRTam3lh/Mj7Oya1xHw7MT5aw1bEiugZMw6d8H+YB3HpKRCqcIm/7XhzK3BYizDHEGs5uLg+mLteMzlHAd2tbKh59KI/m1uBnkGVyOfvO93K2OScIwevgDkSfqY0211KTpc= ddejong@therp.nl
KEY
RUN ssh-keyscan gitlab.therp.nl > /home/waft/.ssh/known_hosts

EXPOSE 22 8069 8072


USER root
CMD [ "/usr/bin/bash" ]
