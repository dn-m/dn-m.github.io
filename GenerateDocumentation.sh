#!/bin/bash

cd ../
cd Frameworks

for i in $( ls ); do
  if [[ -d $i ]]; then
    if ! [[ $i = dependencies ]]; then
      
      cd $i

      VERSION=$(git describe --tags | cut -d - -f -1)
      echo $i: $VERSION

      jazzy \
        --clean \
        --author James Bean \
        --author_url http://jamesbean.info \
        --github_url https://github.com/dn-m/$i \
        --module-version $VERSION \
        --module $i \
        --root-url https://dn-m.github.io \
        --output ../../site/$i \
        --skip-undocumented \
        --hide-documentation-coverage \
        --theme ../../site/dependencies/bean

      cd ../
      
    fi
  fi
done

cd ../
cd site
