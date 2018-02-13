FROM debian:stable-slim
MAINTAINER niku

ENV LANG=C.UTF-8

RUN mkdir /app
COPY . /app
WORKDIR /app

RUN DEPS="git ruby ruby-bundler rake ruby-rugged ruby-nokogiri ruby-rouge" && \
    apt-get update -qq && \
    apt-get install --no-install-recommends --no-install-suggests -y $DEPS && \
    bundle install --jobs 4

ENTRYPOINT ["bundle", "exec"]
CMD [ "irb" ]
