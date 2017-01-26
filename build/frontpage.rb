#!/usr/bin/env ruby

require 'yaml'
require 'nokogiri'
require 'redcarpet'

# FIXME: This currently does its job, but `mustache` should be re-utilized here
# TODO: Inject actual frontmatter
html = %{
<!DOCTYPE html>
<html lang="en">
  <head>
    <title>dn-m</title>
    <link rel="stylesheet" type="text/css" href="build/css/jazzy.css" />
    <link rel="stylesheet" type="text/css" href="build/css/highlight.css" />
    <meta charset="utf-8">
    <script src="build/js/jquery.min.js" defer></script>
    <script src="build/js/jazzy.js" defer></script>

  </head>
  <body>

    <a title="dn-m"></a>

    <header class="header">
      
      <p class="header-col header-col--primary">
        <a class="header-link" href="index.html">
          dn-m Docs
        </a>
      </p>

      <p class="header-col header-col--secondary">
        <a class="header-link" href="https://github.com/dn-m/">
          <img class="header-icon" src="build/img/gh.png"/>
          View on GitHub
        </a>
      </p>
      
    </header>

    <div class="content-wrapper">
      <nav class="navigation">
        <ul class="nav-groups"></ul>
      </nav>

      <article class="main-content">
        <section class="section">
          <div class="section-content">

            <a href='#dn-m' class='anchor' aria-hidden=true>
              <span class="header-anchor"></span>
            </a>

          </div>
        </section>

      </article>
    </div>
    <section class="footer">
      <p>&copy; 2016 <a class="link" href="https://github.com/dn-m" target="_blank" rel="external">dn-m</a>. All rights reserved.</p>
    </section>
  </body>
</div>
</html>
}

# Expects hash in the form: { String: [String] }
def construct_navigation(table_of_contents, page)
  
  # For each layer of the application, create a category with links
  table_of_contents.each do |category, frameworks|

    # Retrieve the first node
    categories_node = page.css(".nav-groups")[0]

    # Create an HTML node for the category
    category_node = categories_node.add_child '
      <li class="nav-group-name" id="' + category + '"></li>
        <span class="nav-group-name-link">' + category + '</span>
        <ul class="nav-group-tasks"></ul>
      </li>
    '

    # For each framework, add a ul item: a link to the docs
    frameworks.each do |framework|

      link = "https://dn-m.github.io/#{framework}"

      # Create an HTML node for the framework
      category_node.css(".nav-group-tasks")[0].add_child '
        <li class="nav-group-task">
          <a class="nav-group-task-link" href="' + link + '">' + framework + '</a>
        </li>
      '
    end
  end
end

def inject_main_contents(contents, page)
  content_node = page.css(".section-content")[0]
  content_node.add_child contents
end

# Returns internal representation of the table of contents yaml file
def prepare_table_of_contents(file) 
  table_of_contents_yaml = File.read(file)
  table_of_contents = YAML.load(table_of_contents_yaml)
  return table_of_contents
end

# Returns html string representation of a given markdown file
def prepare_main_contents(file)

  options = {
    filter_html: true,
    hard_wrap: true,
    link_attributes: { 
      rel: 'nofollow', 
      target: "_blank" 
    },
    space_after_headers: true,
    fenced_code_blocks: true
  }

  extensions = {
    autolink: true,
    superscript: true,
    disable_indented_code_blocks: true
  }

  renderer = Redcarpet::Render::HTML.new(options)
  markdown = Redcarpet::Markdown.new(renderer, extensions)

  contents_markdown = File.read(file)
  contents_html = markdown.render(contents_markdown)

  return contents_html  
end

# Modify the internal representation of the page
page = Nokogiri::HTML(html)
construct_navigation(prepare_table_of_contents('build/toc.yaml'), page)
inject_main_contents(prepare_main_contents('build/main.md'), page)

# Write to file
File.write('index.html', page.to_html)
