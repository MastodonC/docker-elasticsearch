FROM mastodonc/basejava

RUN curl -sL https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/2.1.0/elasticsearch-2.1.0.tar.gz | \
    tar -xzf - -C / --transform 's@\([a-z-]*\)-[0-9\.]*@\1@'

RUN useradd -ms /bin/bash elasticsearch

ADD start-elasticsearch.sh /start-elasticsearch

ENV HOME /home/elasticsearch
USER elasticsearch

CMD ["/bin/bash","/start-elasticsearch"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
EXPOSE 9200 9300
