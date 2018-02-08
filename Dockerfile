FROM jekyll/jekyll:latest
ADD Gemfile /srv/jekyll/Gemfile
ADD Gemfile.lock /srv/jekyll/Gemfile.lock
WORKDIR /srv/jekyll
RUN bundle install
