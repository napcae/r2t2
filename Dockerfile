FROM ruby:2.6.5

RUN gem install bundler
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["./app.rb"]

#https://git.fuwafuwa.moe/SMLoadrDev/SMLoadr/releases/download/v1.9.5/SMLoadr-linux-x86_v1.9.5.zip