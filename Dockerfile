FROM ruby:2.6.5

COPY SMLoadr-linux-x64 .

RUN gem install bundler
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .
RUN rm SMLoadr-linux-x64.zip

CMD ["./app.rb"]

