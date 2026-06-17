---
layout: default
title: Tags
permalink: /tags/
---

{%- assign sorted_tags = site.tags | sort -%}
{%- assign visible_posts = site.posts | where_exp: "post", "post.noindex != true" -%}
{%- assign visible_posts = visible_posts | where_exp: "post", "post.hidden != true" -%}
{%- assign visible_posts = visible_posts | where_exp: "post", "post.published != false" -%}
{%- assign total_posts = visible_posts | size -%}
{%- assign visible_tag_count = 0 -%}
{%- for tag in sorted_tags -%}
  {%- assign tag_posts = tag[1] | where_exp: "post", "post.noindex != true" -%}
  {%- assign tag_posts = tag_posts | where_exp: "post", "post.hidden != true" -%}
  {%- assign tag_posts = tag_posts | where_exp: "post", "post.published != false" -%}
  {%- if tag_posts.size > 0 -%}
    {%- assign visible_tag_count = visible_tag_count | plus: 1 -%}
  {%- endif -%}
{%- endfor -%}

<section class="tags-archive">
  <header class="tags-header">
    <h1>Explore Topics</h1>
    <p>{{ total_posts }} {% if total_posts == 1 %}post{% else %}posts{% endif %} across {{ visible_tag_count }} {% if visible_tag_count == 1 %}tag{% else %}tags{% endif %}.</p>
  </header>

  {%- if sorted_tags and sorted_tags != empty -%}
    <table class="tags-table">
      <thead>
        <tr>
          <th>Tag</th>
          <th>Posts</th>
          <th>Latest Entry</th>
        </tr>
      </thead>
      <tbody>
      {%- for tag in sorted_tags -%}
        {%- assign tag_name_raw = tag[0] -%}
        {%- assign tag_name = tag_name_raw | arrayify | join: ' ' -%}
        {%- assign posts = tag[1] | where_exp: "post", "post.noindex != true" -%}
        {%- assign posts = posts | where_exp: "post", "post.hidden != true" -%}
        {%- assign posts = posts | where_exp: "post", "post.published != false" | sort: "date" | reverse -%}
        {%- assign post_count = posts | size -%}
        {%- if post_count == 0 -%}
          {%- continue -%}
        {%- endif -%}
        {%- assign latest_post = posts[0] -%}
        {%- assign tag_slug = tag_name | slugify -%}
        <tr>
          <td><a href="{{ '/tags/' | append: tag_slug | append: '/' | relative_url }}">{{ tag_name }}</a></td>
          <td>{{ post_count }}</td>
          <td>
            {%- if latest_post -%}
              <span class="tag-detail__date">{{ latest_post.date | date: "%b %d, %Y" }}</span>
              <a href="{{ latest_post.url | relative_url }}">{{ latest_post.title }}</a>
            {%- else -%}
              —
            {%- endif -%}
          </td>
        </tr>
      {%- endfor -%}
      </tbody>
    </table>
  {%- else -%}
    <p class="empty-archive">No tags to show yet.</p>
  {%- endif -%}
</section>
