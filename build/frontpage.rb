#!/usr/bin/env ruby

require 'nokogiri'

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

            dn-m: dynamic notation for music

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

page = Nokogiri::HTML(html)

# TODO: Persist this in a YAML file
categories = {
  "Application Layer" => ["dn-m"],
  "Interaction: Graphics" => ["ProgressBar", "ControllerElements", "CompoundController"],
  "Interaction: Control / Audio" => ["Timeline", "OSC", "AudioTools", "AirTurn"],
  "Score View Layer" => ["PlotView", "StaffView"],
  "Score Model Layer" => ["Pitch", "Rhythm", "Dynamics", "Articulations", "EnsembleTools"],
  "Graphics" => ["PathTools", "GraphicsTools"],
  "Input" => ["MusicXML", "Language"],
  "Utility" => ["Collections", "ArithmeticTools", "IntervalTools"]
}

# For each layer of the application, create a category with links
categories.each do |category, frameworks|

  # Retrieve the first node
  categories_node = page.css(".nav-groups")[0]

  # Create an HTML node for the category
  category_node = categories_node.add_child '
    <li class="nav-group-name" id="' + category + '"></li>
      <span class="nav-group-name-link">' + category + '</span>
      <ul class="nav-group-tasks"></ul>
    </li>
  '

  # For each framework, add a UL item: a link to the docs for the given framework
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

File.write('index.html', page.to_html)
