FROM ruby:2.5-alpine

RUN apk update && apk add build-base nodejs postgresql-dev
# Will fail without next package
RUN apk add tzdata

RUN mkdir /app
WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN gem install bundler
RUN bundle install --binstubs

COPY . .

ENTRYPOINT ["ruby", "contrib/docker/entry.rb"]
CMD ["puma", "-C", "config/puma.rb", "-e", "production"]
