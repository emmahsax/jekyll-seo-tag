# frozen_string_literal: true

module Jekyll
  class SeoTag
    class Drop < Jekyll::Drops::Drop
      include Jekyll::SeoTag::UrlHelper

      TITLE_SEPARATOR = " | "
      FORMAT_STRING_METHODS = [
        :markdownify, :strip_html, :normalize_whitespace, :escape_once,
      ].freeze
      HOMEPAGE_OR_ABOUT_REGEX = %r!^/(about/)?(index.html?)?$!

      EMPTY_READ_ONLY_HASH = {}.freeze
      private_constant :EMPTY_READ_ONLY_HASH

      def initialize(text, context)
        @obj = EMPTY_READ_ONLY_HASH
        @mutations = {}
        @text = text
        @context = context
      end

      def version
        Jekyll::SeoTag::VERSION
      end

      # Should the `<title>` tag be generated for this page?
      def title?
        return false unless title
        return @display_title if defined?(@display_title)

        @display_title = (@text !~ %r!title=false!i)
      end

      def seo_custom_title?
        site["seo_custom_title"] == true
      end

      def site_title
        @site_title ||= format_string(site["title"] || site["name"])
      end

      def site_tagline
        @site_tagline ||= format_string site["tagline"]
      end

      def site_description
        @site_description ||= format_string site["description"]
      end

      # Page title without site title or description appended
      def page_title
        @page_title ||= format_string(page["title"]) || site_title
      end

      def page_pagination_title
        @page_pagination_title ||= begin
          if page["pagination"]
            title = format_string(page["pagination"]["title"])
            if title == "Blog" || format_string(page["pagination"]["collection"]).nil?
              title
            else
              "Blog – #{title}"
            end
          end
        end
      end

      def page_subtitle_title
        @page_subtitle_title ||= begin
          if page["title"] && page["subtitle"]
            format_string("#{page["title"]} – #{page["subtitle"]}")
          end
        end
      end

      def site_tagline_or_description
        site_tagline || site_description
      end

      # Page title with site title or description appended
      def title
        @title ||= seo_custom_title? ? seo_custom_title : add_page_number(:before, generic_title)
      end

      def generic_title
        if site_title && page_title != site_title
          "#{page_title}#{TITLE_SEPARATOR}#{site_title}"
        elsif site_description && site_title
          "#{site_title}#{TITLE_SEPARATOR}#{site_tagline_or_description}"
        else
          page_title || site_title
        end
      end

      def seo_custom_title
        if site_title
          determine_detailed_title || add_page_number(:after, site_title)
        else
          add_page_number(:after, page_title)
        end
      end

      def determine_detailed_title
        small_title = if format_string(page["title_meta"])
                        format_string(page["title_meta"])
                      elsif page_pagination_title
                        add_page_number(:after, page_pagination_title)
                      elsif page_subtitle_title
                        add_page_number(:after, page_subtitle_title)
                      elsif page_title != site_title
                        add_page_number(:after, page_title)
                      elsif site_description
                        add_page_number(:after, site_tagline_or_description)
                      end

        "#{small_title}#{TITLE_SEPARATOR}#{site_title}"
      end

      def name
        return @name if defined?(@name)

        @name = if seo_name
                  seo_name
                elsif !homepage_or_about?
                  nil
                elsif site_social["name"]
                  format_string site_social["name"]
                elsif site_title
                  site_title
                end
      end

      def description
        @description ||= begin
          value = format_string(page["description"] || page["excerpt"]) || site_description
          snippet(value, description_max_words)
        end
      end

      # A drop representing the page author
      def author
        @author ||= AuthorDrop.new(:page => page, :site => site)
      end

      # A drop representing the JSON-LD output
      def json_ld
        @json_ld ||= JSONLDDrop.new(self)
      end

      # Returns a Drop representing the page's image
      # Returns nil if the image has no path, to preserve backwards compatability
      def image
        @image ||= ImageDrop.new(:page => page, :context => @context)
        @image if @image.path
      end

      def date_modified
        @date_modified ||= begin
          date = page_seo["date_modified"] || page["last_modified_at"].to_liquid || page["date"]
          filters.date_to_xmlschema(date) if date
        end
      end

      def date_published
        @date_published ||= filters.date_to_xmlschema(page["date"]) if page["date"]
      end

      def type
        @type ||= begin
          if page_seo["type"]
            page_seo["type"]
          elsif homepage_or_about?
            "WebSite"
          elsif page["date"]
            "BlogPosting"
          else
            "WebPage"
          end
        end
      end

      def links
        @links ||= begin
          if page_seo["links"]
            page_seo["links"]
          elsif homepage_or_about? && site_social["links"]
            site_social["links"]
          end
        end
      end

      def logo
        @logo ||= begin
          return unless site["logo"]

          if absolute_url? site["logo"]
            filters.uri_escape site["logo"]
          else
            filters.uri_escape filters.absolute_url site["logo"]
          end
        end
      end

      def page_lang
        @page_lang ||= page["lang"] || site["lang"] || "en_US"
      end

      def page_locale
        @page_locale ||= (page["locale"] || site["locale"] || page_lang).tr("-", "_")
      end

      def canonical_url
        @canonical_url ||= begin
          if page["canonical_url"].to_s.empty?
            filters.absolute_url(page["url"]).to_s.gsub(%r!/index\.html$!, "/")
          else
            page["canonical_url"]
          end
        end
      end

      def description_max_words
        @description_max_words ||= page["seo_description_max_words"] || 100
      end

      private

      def filters
        @filters ||= Jekyll::SeoTag::Filters.new(@context)
      end

      def page
        @page ||= @context.registers[:page].to_liquid
      end

      def site
        @site ||= @context.registers[:site].site_payload["site"].to_liquid
      end

      def homepage_or_about?
        page["url"] =~ HOMEPAGE_OR_ABOUT_REGEX
      end

      def add_page_number(placement, title)
        if page_number
          return "#{page_number} #{title}" if placement == :before
          return "#{title} #{page_number}" if placement == :after
        end

        title
      end

      def page_number
        return unless @context["paginator"] && @context["paginator"]["page"]

        current = @context["paginator"]["page"]
        total = @context["paginator"]["total_pages"]
        paginator_message = site["seo_paginator_message"] || (
          if seo_custom_title?
            "(page %<current>s of %<total>s)"
          else
            "Page %<current>s of %<total>s for "
          end
        )

        format(paginator_message, :current => current, :total => total) if current > 1
      end

      attr_reader :context

      def fallback_data
        @fallback_data ||= {}
      end

      def format_string(string)
        string = FORMAT_STRING_METHODS.reduce(string) do |memo, method|
          filters.public_send(method, memo)
        end

        string unless string.empty?
      end

      def snippet(string, max_words)
        return string if string.nil?

        result = string.split(%r!\s+!, max_words + 1)[0...max_words].join(" ")
        result.length < string.length ? result.concat("…") : result
      end

      def seo_name
        @seo_name ||= format_string(page_seo["name"]) if page_seo["name"]
      end

      def page_seo
        @page_seo ||= sub_hash(page, "seo")
      end

      def site_social
        @site_social ||= sub_hash(site, "social")
      end

      # Safely returns a sub hash
      #
      # hash - the parent hash
      # key  - the key in the parent hash
      #
      # Returns the sub hash or an empty hash, if it does not exist
      def sub_hash(hash, key)
        if hash[key].is_a?(Hash)
          hash[key]
        else
          EMPTY_READ_ONLY_HASH
        end
      end
    end
  end
end
