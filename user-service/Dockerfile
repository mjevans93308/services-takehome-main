FROM ruby:3.1.2

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler:2.3.22
RUN bundle install

COPY . .

EXPOSE 8000
