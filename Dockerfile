FROM ruby:2.7.3
RUN apt-get update && apt-get install -y \
    locales \
    locales-all \
    libopus-dev \
    ffmpeg \
    libopus0 \
    libsodium-dev
WORKDIR /app
COPY Gemfile /app/
ENV LANG ja_JP.UTF-8
RUN bundle install --path vendor/bundle
COPY discord-voicebot.rb /app/
CMD ["bundle", "exec", "ruby", "discord-voicebot.rb"]