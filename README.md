[![Build Status](https://secure.travis-ci.org/jduckett01/duck_map.png?branch=master)](http://travis-ci.org/jduckett01/duck_map)

# Duck Map

**Homepage**:       [http://jeffduckett.com](http://jeffduckett.com)

**Git**:            [http://github.com/jduckett01/duck_map](http://github.com/jduckett01/duck_map)

**Documentation**:  [http://rubydoc.info/github/jduckett01/duck_map/frames](http://rubydoc.info/github/jduckett01/duck_map/frames)

**Author**:       Jeff Duckett

**Copyright**:    2013

**License**:      MIT License

## Synopsis

Duck Map is a Rails 4.x compliant gem providing support for dynamically generating sitemaps and meta tags in HTML page headers.

## Full Guide

<span class="note">For an in depth discussion see: {file:GUIDE.md Full guide (GUIDE.md)}</span>

## Feature List
- Sitemaps are baked into the standard Rails Routing Code base and are defined directly in config/routes.rb.
- Default sitemap at the root of the application named: /sitemap.xml
- No code needed.  Default sitemap.xml content is based on standard Rails controller actions: edit, index, new and show.
- Designed to grab volitale elements such as last modified date directly from a model.
- Automagically finds the first model on a controller and uses model attributes in sitemap and page headers.
- Support for namespaces.
- Support for nested resources.
- Define as many sitemaps as you need.
- Ability to sychronize static last modified dates directly from the rails view files or a .git repository.
- Meta tags for HTML page headers such as title, last modified, canonical url, etc. that match data contained in sitemap.
- Generate static sitemap files with compression.
- Define global attributes and values and fine tune them down to the controller/model levels.

## Quick Start

Follow these steps to create a Rails app with a sitemap.

    # open a shell and navigate to a work directory.
    # create a Rails app
    rails new test.com --skip-bundle

    # add the following to your Rails app test.com/Gemfile
    gem 'duck_map'

    # depending on your Rails version, you may have to add the following lines as well.
    gem 'execjs'
    gem 'therubyracer'

    # make sure you have all the gems, etc.
    bundle install

    # create a controller
    rails g controller home

    # create a route in config/routes.rb
    root :to => 'home#index'

    # start the server
    rails s

    # view the sitemap
    http://localhost:3000/sitemap.xml

    # if you view the HTML source of: http://localhost:3000/sitemap.xml
    # you should see something similar to the following:
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      <url>
        <loc>http://localhost:3000/</loc>
        <lastmod>2011-10-27T13:02:15+00:00</lastmod>
        <changefreq>monthly</changefreq>
        <priority>0.5</priority>
      </url>
    </urlset>

## Demo applications
You can find articles and demo apps at: http://jeffduckett.com/blogs.html

## Why use the name Duck Map?
Having "Duck" built into the name?  This stems from a habit I picked up years ago back in the days when I was doing DBase and Clipper programming for DOS.
I picked up the idea from one of my favorite authors at the time (Rick Spence - or at least I think it was Rick).  Anyway, the idea is to basically sign
your code by incorporating your initials into library names or method calls.  That way, you know the origin of a piece of code at a glance.  The downside
is that you definitely own it and can't blame it on that guy that keeps beating you to the good doughnuts.  I hate that guy!!
The second reason is that there was a pretty good chance I wouldn't run into naming conflicts.

## Copyright
Copyright (c) 2013 Jeff Duckett. See license for details.
