FROM ubuntu:22.04


# Set up system
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y --no-install-recommends \
	build-essential bzip2 ca-certificates curl git gettext libssl-dev locales-all \
	libxslt1.1 liblcms2-2 libldap2-dev libpq5 libsasl2-2 \
	libtinfo-dev libncurses5-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev \
	libncursesw5-dev tk-dev libxmlsec1-dev libffi-dev liblzma-dev adduser lsb-base libxml2-dev \
	libxslt1-dev libpq-dev libsasl2-dev libopenjp2-7-dev libjpeg-turbo8-dev \
	libtiff5-dev libfreetype6-dev liblcms2-dev libwebp-dev openssh-server nano pre-commit \
	python3-dev ssh sudo wget

RUN apt-get install -y --no-install-recommends \
RUN pip install "python-lsp-server[all]"
RUN curl -L https://nixos.org/nix/install | sh -s -- --daemon --yes
RUN useradd -d /home/waft -s /bin/bash waft
RUN usermod --password waft waft
RUN mkdir -p /home/waft/.ssh
RUN chown -R waft:users /home/waft
RUN echo "service ssh start" >> /root/.bashrc
RUN echo "nix-daemon &" >> /root/.bashrc


ADD etc/gitconfig /etc/gitconfig
ADD etc/nvim /etc/xdg/nvim


USER waft
RUN git config --global user.name "Danny de Jong"
RUN git config --global user.email "ddejong@therp.nl"

# Clone all needed customer repositories upon first login
RUN cat > /home/waft/.profile <<PROFILE
#!/bin/bash
function prepare_repo() {
	if [ ! -d "\$1" ]; then
		mkdir "\$1"
		( # Don't create the repo with git clone, it causes issues
			cd "\$1"
			git init
			git remote add origin "\$2"
			git fetch -a
			git checkout -b "\$3" "origin/\$3"
		)
	fi
}

function prepare_gitlab_repo() {
	prepare_repo "\$1" "git@gitlab.therp.nl:\$2/\$1.git" "\$3"
}


# Not sure how to activate the environment variables for Nix in the Dockerfile
nix-env -iA nixpkgs.neovim
nix-env -iA nixpkgs.bash-language-server


prepare_gitlab_repo aectual therp build-12.0-production
prepare_repo bmair-build git@gitlab.therp.nl:sunflowerit/freshfilter.git build-14.0-production
prepare_gitlab_repo freshfilter sunflowerit 14.0
prepare_repo inuka-build git@gitlab.therp.nl:inuka/inuka_custom_modules.git build-16.0-production
prepare_repo inuka git@gitlab.therp.nl:inuka/inuka_custom_modules.git 16.0

alias g="git"
alias vi="nvim"

export LC_ALL="C"
export XDG_CONFIG_HOME="/etc/xdg"
PROFILE

# Set up ssh for the waft user
RUN cat > /home/waft/.ssh/authorized_keys <<KEY
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC39DiDDuJsjexBPfBhHTzNATMjpnjR+gFR5qcfKCogytuD19PiCyESRx2DtPCHKVvmHWNbDeIwHG9LXsspZLoIFijl15JL3t9JC8n0etDALMKoW9VxS6Itq0YwaoiEw5W4QcVc6Oe+dMF/nWiv7tPLf9TT6jkfrZjuBb1O7KL/P/UmGLHU8hhQPu+tv/k+AZaDHZSh9/FdvxZ+ayxBFXCSIDS2mEe4KjKnVunRZHjk6R9WzEJEYSxZhCFHiXkQ6QBCPYHiBxB0opNaFCHIzKLCuVzFL7zjFMpeL025GrJdasLQYe8LAn/Ms2/JqVKVlzFF6SISG/s7FPuaM6fLNhtSqQ8UTvMm3x29+TBvCCp25dDXFmuvhCZttzLgfTG0cRTam3lh/Mj7Oya1xHw7MT5aw1bEiugZMw6d8H+YB3HpKRCqcIm/7XhzK3BYizDHEGs5uLg+mLteMzlHAd2tbKh59KI/m1uBnkGVyOfvO93K2OScIwevgDkSfqY0211KTpc= ddejong@therp.nl
KEY
RUN ssh-keyscan gitlab.therp.nl > /home/waft/.ssh/known_hosts
RUN ssh-keyscan sfithub.com >> /home/waft/.ssh/known_hosts
RUN ssh-keyscan github.com >> /home/waft/.ssh/known_hosts

EXPOSE 22 8069 8072


USER root
CMD [ "/usr/bin/bash" ]
