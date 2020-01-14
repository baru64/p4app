FROM p4lang/p4c:latest
MAINTAINER Seth Fowler <seth@barefootnetworks.com>
MAINTAINER Robert Soule <robert.soule@barefootnetworks.com>

# Install dependencies and some useful tools.
ENV NET_TOOLS iputils-arping \
              iputils-ping \
              iputils-tracepath \
              iptables \
              net-tools \
              nmap \
              python-ipaddr \
              python-scapy \
              tcpdump \
              traceroute \
              tshark \
	      curl
ENV MININET_DEPS automake \
                 build-essential \
                 cgroup-bin \
                 ethtool \
                 gcc \
                 help2man \
                 iperf \
                 iproute \
                 libtool \
                 make \
                 pkg-config \
                 psmisc \
                 socat \
                 ssh \
                 sudo \
                 telnet \
                 pep8 \
                 pyflakes \
                 pylint \
                 python-pexpect \
                 python-setuptools

# Ignore questions when installing with apt-get:
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends $NET_TOOLS $MININET_DEPS

# Collector dependencies
RUN apt-get install -y python3-pip
RUN pip3 install prometheus_client
RUN pip install prometheus_client

# eBPF dependencies
RUN apt-get install -y apt-transport-https ca-certificates
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4052245BD4284CDD
RUN echo "deb https://repo.iovisor.org/apt/$(lsb_release -cs) $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/iovisor.list
RUN apt-get update
RUN apt-get install -y bcc-tools libbcc-examples linux-headers-$(uname -r)

# Fix to get tcpdump working
RUN mv /usr/sbin/tcpdump /usr/bin/tcpdump

# Install mininet.
COPY docker/third-party/mininet /third-party/mininet
WORKDIR /third-party/mininet
RUN cp util/m /usr/local/bin/m
RUN make install && \
    rm -rf /third-party/mininet

# Install the scripts we use to run and test P4 apps.
COPY docker/scripts /scripts
WORKDIR /scripts
RUN chmod u+x send.py receive.py

ENTRYPOINT ["./p4apprunner.py"]
