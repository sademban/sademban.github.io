#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "fileutils"
require "pathname"
require "yaml"

ROOT = Pathname.new(__dir__).join("..").expand_path
TRACKER_PATH = ROOT.join("content-ops", "tracker.yml")
SUPPORTED_EVIDENCE_HEADINGS = /^(##)\s+(Basis|Sources|References|Further reading|Evidence)\b/i

def abort_with(message)
  warn "publish_approved_post: #{message}"
  exit 1
end

def parse_date(value)
  return value if value.is_a?(Date)
  return nil if value.nil? || value.to_s.strip.empty?

  Date.parse(value.to_s)
rescue Date::Error
  abort_with("invalid date: #{value.inspect}")
end

def slugify(value)
  value.to_s.downcase.strip
       .gsub(/[^a-z0-9]+/, "-")
       .gsub(/\A-+|-+\z/, "")
end

def split_front_matter(markdown)
  return [{}, markdown] unless markdown.start_with?("---\n")

  _opening, yaml_text, body = markdown.split(/^---\s*$/, 3)
  parsed = YAML.safe_load(yaml_text || "", permitted_classes: [Date, Time], aliases: false) || {}
  [parsed, body.to_s.sub(/\A\n/, "")]
rescue Psych::SyntaxError => e
  abort_with("invalid draft front matter: #{e.message}")
end

def require_tracker!
  abort_with("missing #{TRACKER_PATH.relative_path_from(ROOT)}") unless TRACKER_PATH.file?

  YAML.safe_load(TRACKER_PATH.read, permitted_classes: [Date, Time], aliases: false) || []
rescue Psych::SyntaxError => e
  abort_with("invalid tracker YAML: #{e.message}")
end

def ready?(item, today)
  item["status"].to_s == "approved" &&
    (parse_date(item["publish_after"]) || today) <= today
end

def ensure_supported_by_evidence!(item, body)
  basis = Array(item["basis"]).compact.reject { |entry| entry.to_s.strip.empty? }
  source_urls = Array(item["source_urls"]).compact.reject { |entry| entry.to_s.strip.empty? }
  abort_with("#{item["slug"]} is approved but has no basis or source_urls in tracker") if basis.empty? && source_urls.empty?

  return if body.match?(SUPPORTED_EVIDENCE_HEADINGS)

  abort_with("#{item["slug"]} draft needs a Basis, Sources, References, Further reading, or Evidence section")
end

def ensure_tag_pages!(tags)
  tags.each do |tag|
    slug = slugify(tag)
    next if slug.empty?

    tag_path = ROOT.join("tags", "#{slug}.md")
    next if tag_path.file?

    tag_path.dirname.mkpath
    tag_path.write(<<~MARKDOWN)
      ---
      layout: post_list
      title: #{tag}
      permalink: /tags/#{slug}/
      tag: #{tag}
      show_excerpts: true
      ---
    MARKDOWN
  end
end

today = parse_date(ENV["PUBLISH_DATE"]) || Date.today
items = require_tracker!
abort_with("tracker root must be a YAML list") unless items.is_a?(Array)

candidate = items
            .select { |item| item.is_a?(Hash) && ready?(item, today) }
            .sort_by { |item| [parse_date(item["publish_after"]) || today, item["slug"].to_s] }
            .first

unless candidate
  puts "No approved posts ready for #{today}."
  exit 0
end

slug = slugify(candidate["slug"])
abort_with("approved item is missing slug") if slug.empty?

draft_path = ROOT.join(candidate["draft_path"].to_s.empty? ? "content-ops/drafts/#{slug}.markdown" : candidate["draft_path"].to_s)
abort_with("missing draft: #{draft_path.relative_path_from(ROOT)}") unless draft_path.file?

draft_front_matter, body = split_front_matter(draft_path.read)
abort_with("#{slug} draft is empty") if body.strip.empty?

ensure_supported_by_evidence!(candidate, body)

category = candidate["category"].to_s.empty? ? "blog" : candidate["category"].to_s
tags = Array(candidate["tags"] || draft_front_matter["tags"]).compact
abort_with("#{slug} is missing tags") if tags.empty?

published_dir = ROOT.join("_posts", category, today.strftime("%Y"), today.strftime("%m"))
published_path = published_dir.join("#{today.strftime("%Y-%m-%d")}-#{slug}.markdown")

if published_path.file?
  candidate["status"] = "published"
  candidate["published_at"] ||= today.to_s
  candidate["published_path"] ||= published_path.relative_path_from(ROOT).to_s
  TRACKER_PATH.write(items.to_yaml)
  puts "Already published: #{published_path.relative_path_from(ROOT)}"
  exit 0
end

title = candidate["title"] || draft_front_matter["title"]
description = candidate["description"] || draft_front_matter["description"]
abort_with("#{slug} is missing title") if title.to_s.strip.empty?
abort_with("#{slug} is missing description") if description.to_s.strip.empty?

front_matter = draft_front_matter.merge(
  "layout" => "post",
  "title" => title,
  "description" => description,
  "date" => "#{today} 09:00:00 +0900",
  "author" => candidate["author"] || draft_front_matter["author"] || "sademban",
  "categories" => category,
  "tags" => tags
)

%w[image image_alt image_caption].each do |key|
  front_matter[key] = candidate[key] if candidate[key]
end

if candidate["image_plan"].is_a?(Hash)
  image_plan = candidate["image_plan"]
  front_matter["image"] ||= "/#{image_plan["path"].to_s.sub(%r{\A/+}, "")}" if image_plan["path"]
  front_matter["image_alt"] ||= image_plan["alt"] if image_plan["alt"]
  front_matter["image_caption"] ||= image_plan["caption"] if image_plan["caption"]
end

published_dir.mkpath
published_path.write("#{front_matter.to_yaml}---\n\n#{body.strip}\n")
ensure_tag_pages!(tags)

candidate["status"] = "published"
candidate["published_at"] = today.to_s
candidate["published_path"] = published_path.relative_path_from(ROOT).to_s

TRACKER_PATH.write(items.to_yaml)
puts "Published #{published_path.relative_path_from(ROOT)}"
