FROM  ruby:2.6

ENV DEBIAN_FRONTEND noninteractive

# Install required packages
RUN apt-get update -qq \
    && apt-get install -y locales

# Set timezone
ENV LC_TIME C
ENV TZ Asia/Tokyo

WORKDIR /swimmy

COPY . /swimmy/

# install bundle
RUN gem install bundler -v "2.1.4"
RUN bundle config set path 'vendor/bundle'
RUN bundle install

CMD ["exe/swimmy"]
