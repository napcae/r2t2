FROM ruby:2.6.5-alpine

COPY SMLoadr-linux-x86 .
RUN chmod +x SMLoadr-linux-x86

RUN apk update && apk add --update-cache build-base
RUN gem install bundler
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install
RUN apk del build-base && rm -rf /var/cache/apk/*

COPY . .

CMD ["./app.rb"]

