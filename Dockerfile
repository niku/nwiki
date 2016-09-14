FROM ruby
MAINTAINER niku

RUN mkdir /myapp
COPY . /myapp
WORKDIR /myapp

RUN BUILD_DEPS="cmake" && \
    apt-get update -qq && \
    apt-get install --no-install-recommends --no-install-suggests -y $BUILD_DEPS && \
    bundle install --path --jobs 4 && \
    apt-get purge -y --auto-remove $BUILD_DEPS && \
    apt-get clean && \
    rm -rf \
       /var/cache/apt/archives/* \
       /var/lib/apt/lists/*

ENTRYPOINT ["bundle", "exec"]
CMD [ "irb" ]
