#
# Ruby Dockerfile
#
# https://github.com/dockerfile/ruby
#

# Pull base image.
FROM ubuntu

# Install Ruby.
RUN \
  apt-get update && \
  apt-get install -y ruby ruby-dev ruby-bundler && \
  rm -rf /var/lib/apt/lists/*

RUN gem install dashing

RUN apt-get update && apt-get install -y \
    git \
    zlib1g-dev \
    libxml2-dev \
    python \
    build-essential \
    make \
    gcc \
    python-dev \
    nodejs \
    locales

ENV release_stage=production
ENV workdir /srv/dashboard

WORKDIR $workdir
ADD . $workdir

RUN bundle install

EXPOSE 5111

CMD ["dashing", "start", "-p 5111"]

