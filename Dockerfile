FROM ruby:2.6.5

COPY SMLoadr-linux-x86.zip .
RUN unzip SMLoadr-linux-x86.zip && \
	rm SMLoadr-linux-x86.zip && \
	chmod +x SMLoadr-linux-x86

RUN gem install bundler
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

CMD ["./app.rb"]

