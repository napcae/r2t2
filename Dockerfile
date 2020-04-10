# can't use -alpine3.11 because SMLoadr is statically linked against glibc
# node runtime is too big as well, defaulting to ruby image
FROM ruby:2.7.1

COPY vendor/SMLoadr/SMLoadr-linux-x64 .

RUN gem install bundler 
#RUN gem install unf_ext -v '0.0.7.6' --source 'https://rubygems.org/'
RUN bundle config

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN mkdir tmp
RUN rm vendor/SMLoadr/SMLoadr-linux-x64.zip

CMD ["./app.rb"]

