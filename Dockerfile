FROM ruby:2.7.3

WORKDIR /app

RUN gem install bundler

CMD exec bin/start.sh