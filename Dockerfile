FROM ubuntu:24.04

# Install required packages
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive apt install -y unbound tayga iproute2 iptables && \
    mkdir -p /etc/unbound/unbound.conf.d /var/db/tayga

# Copy config files
COPY unbound.conf /etc/unbound/unbound.conf
COPY tayga.conf /etc/tayga.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 53/udp
EXPOSE 53/tcp

CMD ["/start.sh"]