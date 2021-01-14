FROM ruby:2.7.2-alpine3.12

MAINTAINER Andrew Kane <andrew@chartkick.com>

RUN apk add --update ruby-dev build-base \
  libxml2-dev libxslt-dev pcre-dev libffi-dev \
  postgresql-dev git gcompat

ENV INSTALL_PATH /app

RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

# https://github.com/grpc/grpc/issues/24116
# install gems first for Docker caching
RUN gem install -v 3.14.0 google-protobuf --platform ruby -- --with-cflags=-D__va_copy=va_copy && \
    find /usr/local/bundle/gems/google-protobuf-3.14.0 -name "*.o" -type f -delete && \
    find /usr/local/bundle/gems/google-protobuf-3.14.0/ext -name "*.a" -type f -delete && \
    find /usr/local/bundle/gems/google-protobuf-3.14.0/ext -name "*.so" -type f -delete
RUN gem install -v 1.34.0 grpc --platform ruby -- --with-cflags=-D__va_copy=va_copy && \
    find /usr/local/bundle/gems/grpc-1.34.0 -name "*.o" -type f -delete && \
    find /usr/local/bundle/gems/grpc-1.34.0/src/ruby/ext -name "*.a" -type f -delete && \
    find /usr/local/bundle/gems/grpc-1.34.0/src/ruby/ext -name "*.so" -type f -delete
RUN bundle config --local build.google-protobuf --with-cflags=-D__va_copy=va_copy
RUN bundle config --local build.grpc --with-cflags=-D__va_copy=va_copy
RUN bundle config --local force_ruby_platform true

COPY Gemfile Gemfile.lock ./

RUN bundle install --binstubs

COPY . .

RUN bundle exec rake RAILS_ENV=production DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname SECRET_TOKEN=dummytoken assets:precompile

ENV PORT 8080

EXPOSE 8080

CMD puma -C /app/config/puma.rb
