# MobileCPPTutorials.com

MobileCPPTutorials.com began in August 2015 as a WordPress site with tutorials
on how to build cross-platform iPhone and Android apps utilizing Dropbox's
Djinni tool. It quickly became apparent that the tools and development
environment involved were involved were evolving too fast for me alone to keep
up with. Therefore, MobileCPPTutorials.com version 2.0 has been reinvented as a
collaborative GitHub-hosted site that the community can submit updates to, or
even add additional tutorials.

## Contributing

### Environment Setup

#### Docker

Install Docker and `docker-compose`, then

```
docker-compose up --build
```

#### Local machine

This project utilizes Jekyll for local viewing as described in
[Setting up your GitHub Pages site locally with Jekyll](https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll/).
Below is a summary of steps involved to get this up and running...

Make sure you have ruby installed:

`$ ruby --version`

Install Bundler:

`$ gem install bundler`

Clone this repository to your local workspace:

`$ git clone git@github.com:spanndemic/mobilecpptutorials.com.git`

Install Jekyll dependencies via Bundler:

`$ bundle install`

Start a local Jekyll server instance:

`bundle exec jekyll serve`

Preview your changes to the site via [http://localhost:4000](http://localhost:4000)
