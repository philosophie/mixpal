FROM ruby:2.7.1

WORKDIR /workspace

COPY . .
RUN bundle install
