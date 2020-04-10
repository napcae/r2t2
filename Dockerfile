FROM ruby:2.7.1-alpine3.11

COPY vendor/SMLoadr/SMLoadr-linux-x64 .

RUN apk add --update build-base

RUN gem install bundler 
RUN gem install unf_ext -v '0.0.7.6' --source 'https://rubygems.org/'
RUN bundle config

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN mkdir tmp
RUN rm vendor/SMLoadr/SMLoadr-linux-x64.zip

CMD ["./app.rb"]

