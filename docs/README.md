## About Jekyll SEO Tag

A Jekyll plugin to add metadata tags for search engines and social networks to better index and display your site's content.

[![Build Status](https://travis-ci.com/emmahsax/jekyll-seo-tag.svg?branch=main)](https://travis-ci.com/emmahsax/jekyll-seo-tag)

## Archival Notice

This repository has been archived and designated as read-only. From GitHub's documentation:

> This will make the emmahsax/jekyll-seo-tag repository, issues, pull requests, labels, milestones, projects, wiki, releases, commits, tags, branches, reactions and comments read-only and disable any future comments. The repository can still be forked.

For a similar GitHub Action that is _not_ archived, please visit the source of this project: https://github.com/jekyll/jekyll-seo-tag.

To unarchive this repository at any time, please reach out to me at https://emmasax.com/contact-me/.

## What it does

Jekyll SEO Tag adds the following meta tags to your site:

* Page title, with site title or description appended
* Page description
* Canonical URL
* Next and previous URLs on paginated pages
* [JSON-LD Site and post metadata](https://developers.google.com/search/docs/guides/intro-structured-data) for richer indexing
* [Open Graph](https://ogp.me/) title, description, site title, and URL (for Facebook, LinkedIn, etc.)
* [Twitter Summary Card](https://dev.twitter.com/cards/overview) metadata

While you could theoretically add the necessary metadata tags yourself, Jekyll SEO Tag provides a battle-tested template of crowdsourced best-practices.

## What it doesn't do

Jekyll SEO tag is designed to output machine-readable metadata for search engines and social networks to index and display. If you're looking for something to analyze your Jekyll site's structure and content (e.g., more traditional SEO optimization), take a look at [The Jekyll SEO Gem](https://github.com/pmarsceill/jekyll-seo-gem).

Jekyll SEO tag isn't designed to accommodate every possible use case. It should work for most site out of the box and without a laundry list of configuration options that serve only to confuse most users.

## Documentation

For more information, see:

* [Installation](installation.md)
* [Usage](usage.md)
* [Advanced usage](advanced-usage.md)
