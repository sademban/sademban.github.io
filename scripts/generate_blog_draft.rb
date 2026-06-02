#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "fileutils"
require "json"
require "net/http"
require "pathname"
require "time"
require "uri"
require "yaml"

ROOT = Pathname.new(__dir__).join("..").expand_path
TRACKER_PATH = ROOT.join("content-ops", "tracker.yml")
INSTRUCTIONS_PATH = ROOT.join("content-ops", "instructions.md")

SECRET_PATTERNS = [
  /-----BEGIN [A-Z ]*PRIVATE KEY-----/,
  /\bAKIA[0-9A-Z]{16}\b/,
  /\b(?:OPENAI_API_KEY|API_KEY|TOKEN|SECRET|PASSWORD|PASSWD)\s*[:=]\s*["']?[^"'\s<][^"'\s]*/i,
  /\bAuthorization:\s*Bearer\s+[A-Za-z0-9._\-]+/i,
  /\bsk-[A-Za-z0-9_\-]{20,}\b/
].freeze

def abort_with(message)
  warn "generate_blog_draft: #{message}"
  exit 1
end

def load_tracker
  abort_with("missing #{TRACKER_PATH.relative_path_from(ROOT)}") unless TRACKER_PATH.file?

  YAML.safe_load(TRACKER_PATH.read, permitted_classes: [Date, Time], aliases: false) || []
rescue Psych::SyntaxError => e
  abort_with("invalid tracker YAML: #{e.message}")
end

def slugify(value)
  value.to_s.downcase.strip
       .gsub(/[^a-z0-9]+/, "-")
       .gsub(/\A-+|-+\z/, "")
end

def parse_output_text(response)
  return response["output_text"] if response["output_text"].is_a?(String) && !response["output_text"].empty?

  Array(response["output"]).flat_map do |item|
    Array(item["content"]).filter_map do |content|
      content["text"] if content.is_a?(Hash) && content["type"].to_s.include?("text")
    end
  end.join("\n")
end

def redact_check!(label, text)
  SECRET_PATTERNS.each do |pattern|
    abort_with("#{label} appears to contain sensitive data matching #{pattern.inspect}; redact before drafting") if text.match?(pattern)
  end
end

def front_matter_for(item)
  front_matter = {
    "layout" => "post",
    "title" => item["title"],
    "description" => item["description"],
    "date" => Date.today.strftime("%Y-%m-%d 09:00:00 +0900"),
    "author" => item["author"] || "sademban",
    "categories" => item["category"] || "blog",
    "tags" => Array(item["tags"])
  }

  if item["image_plan"].is_a?(Hash)
    image_plan = item["image_plan"]
    front_matter["image"] = "/#{image_plan["path"].to_s.sub(%r{\A/+}, "")}" if image_plan["path"]
    front_matter["image_alt"] = image_plan["alt"] if image_plan["alt"]
    front_matter["image_caption"] = image_plan["caption"] if image_plan["caption"]
  end

  front_matter
end

def scaffold_body(item, research)
  sources = Array(item["source_urls"]).map { |url| "- #{url}" }.join("\n")
  basis = Array(item["basis"]).map { |entry| "- #{entry}" }.join("\n")

  <<~MARKDOWN
    ## Problem

    Explain the practical problem this post solves.

    ## Short Answer

    Summarize the useful takeaway in one or two paragraphs.

    ## Steps

    Turn the research packet into concrete commands, configs, or checks.

    ## Verification

    Show how to prove the result worked.

    ## Common Mistakes

    List the mistakes that cause confusion or bad outcomes.

    ## Evidence

    Basis from tracker:

    #{basis.empty? ? "- Add verified basis before approval." : basis}

    Sources from tracker:

    #{sources.empty? ? "- Add source URLs before approval." : sources}

    Research packet summary:

    ```text
    #{research.strip[0, 4000]}
    ```
  MARKDOWN
end

def build_prompt(item, instructions, research)
  <<~PROMPT
    Write a practical tech blog draft for this Jekyll site.

    Non-negotiable rules:
    - Use only the tracker metadata and research packet below.
    - Do not invent benchmarks, commands, version details, outages, popularity claims, or security claims.
    - If evidence is missing, say what needs verification instead of filling the gap.
    - Do not include secrets, tokens, private infrastructure details, customer data, or unredacted logs.
    - Write useful, direct prose for developers.
    - Include an "## Evidence" or "## Sources" section.
    - Output markdown body only. Do not output YAML front matter.

    Site instruction set:
    #{instructions}

    Tracker item:
    #{item.to_yaml}

    Research packet:
    #{research}
  PROMPT
end

def generate_with_openai(prompt)
  api_key = ENV["OPENAI_API_KEY"].to_s
  abort_with("OPENAI_API_KEY is not set; set DRAFT_MODE=scaffold to create an outline without AI") if api_key.empty?

  uri = URI("https://api.openai.com/v1/responses")
  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "Bearer #{api_key}"
  request["Content-Type"] = "application/json"
  request.body = {
    model: ENV.fetch("OPENAI_MODEL", "gpt-5"),
    instructions: "You are a careful technical editor. Write only from provided evidence.",
    input: prompt
  }.to_json

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 180) do |http|
    http.request(request)
  end

  unless response.is_a?(Net::HTTPSuccess)
    abort_with("OpenAI API request failed: HTTP #{response.code} #{response.body[0, 500]}")
  end

  text = parse_output_text(JSON.parse(response.body))
  abort_with("OpenAI API returned no draft text") if text.strip.empty?

  text
rescue JSON::ParserError => e
  abort_with("could not parse OpenAI response JSON: #{e.message}")
end

items = load_tracker
abort_with("tracker root must be a YAML list") unless items.is_a?(Array)

requested_slug = ARGV[0] || ENV["BLOG_SLUG"]
candidate = if requested_slug
              items.find { |item| item.is_a?(Hash) && slugify(item["slug"]) == slugify(requested_slug) }
            else
              items.find { |item| item.is_a?(Hash) && item["status"].to_s == "research" }
            end

unless candidate
  abort_with("no matching tracker item found") if requested_slug

  puts "No research-ready tracker item found."
  exit 0
end
abort_with("#{candidate["slug"]} must have status: research before drafting") unless candidate["status"].to_s == "research"

slug = slugify(candidate["slug"])
research_path = ROOT.join(candidate["research_path"].to_s.empty? ? "content-ops/research/#{slug}.md" : candidate["research_path"].to_s)
draft_path = ROOT.join(candidate["draft_path"].to_s.empty? ? "content-ops/drafts/#{slug}.markdown" : candidate["draft_path"].to_s)

abort_with("missing research packet: #{research_path.relative_path_from(ROOT)}") unless research_path.file?
abort_with("draft already exists: #{draft_path.relative_path_from(ROOT)}") if draft_path.file?

instructions = INSTRUCTIONS_PATH.file? ? INSTRUCTIONS_PATH.read : ""
research = research_path.read
abort_with("research packet is empty: #{research_path.relative_path_from(ROOT)}") if research.strip.empty?

redact_check!("research packet", research)
redact_check!("tracker item", candidate.to_yaml)

body = if ENV["DRAFT_MODE"].to_s == "scaffold"
         scaffold_body(candidate, research)
       else
         generate_with_openai(build_prompt(candidate, instructions, research))
       end

redact_check!("generated draft", body)

draft_path.dirname.mkpath
draft_path.write("#{front_matter_for(candidate).to_yaml}---\n\n#{body.strip}\n")

candidate["status"] = "drafted"
candidate["drafted_at"] = Time.now.utc.iso8601
candidate["draft_path"] = draft_path.relative_path_from(ROOT).to_s
TRACKER_PATH.write(items.to_yaml)

puts "Drafted #{draft_path.relative_path_from(ROOT)}"
