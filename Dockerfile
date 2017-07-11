# Linux OS
FROM elasticsearch:2.4.1

# REV 140930062017

# Maintainer
MAINTAINER lmangani <lorenzo.mangani@gmail.com>

RUN groupadd -r kibi && useradd -r -m -g kibi kibi

# Setup Packages & Permissions
RUN apt-get update && apt-get -y install git && apt-get clean \
 && wget -O /dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.1.3/dumb-init_1.1.3_amd64 \
 && chmod +x /dumb-init \
 && curl -sL https://deb.nodesource.com/setup_4.x | bash - \
 && apt-get install -y nodejs \
 && /usr/share/elasticsearch/bin/plugin install solutions.siren/siren-join/2.4.1 \
 && npm install phantomjs-prebuilt -g \
 && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
RUN cd /opt && wget https://download.support.siren.solutions/kibi/community?file=kibi-community-standalone-4.6.4-1-linux-x64.zip -O kibi-community-standalone-4.6.4-1-linux-x64.zip \
 && unzip kibi-community-standalone-4.6.4-1-linux-x64.zip \
 && rm -rf kibi-community-standalone-4.6.4-1-linux-x64.zip \
 && mv kibi-community-standalone-4.6.4-1-linux-x64 kibi \
 && chown -R kibi:kibi /opt/kibi \
 && chown -R elasticsearch:elasticsearch /var/lib/elasticsearch/

#RUN cd /tmp \
# && wget https://github.com/dlumbrer/kbn_network/archive/Kibana-4.x.tar.gz \
# && tar zxvf Kibana-4.x.tar.gz && mv kbn_network-Kibana-4.x /opt/kibi/installedPlugins/kbn_network \
# && cd /opt/kibi/installedPlugins/kbn_network && npm install
 
RUN cd /opt/kibi/installedPlugins \
 && git clone -b 4.x https://github.com/sbeyn/kibana-plugin-gauge-sg gauge-sg \
 && git clone -b 4.x https://github.com/sbeyn/kibana-plugin-traffic-sg traffic-sg \
 && git clone -b 4.x  https://github.com/dlumbrer/kbn_network kbn_network && cd kbn_network && npm install && cd .. \
 && chown -R kibi:kibi /opt/kibi

RUN cd /opt/kibi \
 && ./bin/kibi plugin --install sentinl -u https://github.com/sirensolutions/sentinl/releases/download/tag-4.6.4-4/sentinl.zip \
 && ./bin/kibi plugin --install kibana-auth-plugin -u https://github.com/elasticfence/kibana-auth-elasticfence/releases/download/snapshot/kauth-latest.tar.gz \
 && ./bin/kibi plugin --install kibrand -u https://github.com/elasticfence/kibrand/archive/0.4.5.zip \
 && ./bin/kibi plugin --install kibana-time-plugin -u https://github.com/nreese/kibana-time-plugin/archive/4.x.zip \
 && ./bin/kibi plugin --install elastic/timelion \
 && ./bin/kibi plugin --install elastic/sense \
 && chown -R kibi:kibi /opt/kibi \
 && cd /usr/share/elasticsearch \
 && ./bin/plugin install https://raw.githubusercontent.com/elasticfence/elasticsearch-http-user-auth/2.4.1/jar/elasticfence-2.4.1-SNAPSHOT.zip

COPY entrypoint.sh /opt/
RUN chmod 755 /opt/entrypoint.sh
ENV PATH /opt/kibi/kibi/bin:$PATH

# Kibi init files
COPY etc/default/kibi /etc/default/kibi
COPY etc/init.d/kibi /etc/init.d/kibi
RUN chmod +x /etc/init.d/kibi

# Expose Default Port
EXPOSE 5601 5606
EXPOSE 9200
EXPOSE 9300
EXPOSE 8899

# Exec on start
ENTRYPOINT ["/dumb-init", "--"]
CMD ["/opt/entrypoint.sh"]
