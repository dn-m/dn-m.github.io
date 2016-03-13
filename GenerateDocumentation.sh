#!/bin/bash

SITE_DIR=${PWD}
FRAMEWORKS_DIR="../Frameworks"

cd $FRAMEWORKS_DIR

for i in $( ls ); do
  if [[ -d $i ]]; then

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
        --output ../../$SITE_DIR/$i \
        --skip-undocumented \
        --hide-documentation-coverage \
        --theme ../../$SITE_DIR/dependencies/bean

      cd ../

  fi
done

cd $SITE_DIR

# Clean and build assets for main index
for i in $( ls ); do
  if [[ -d $i ]]; then
    if ! [ $i = dependencies -o $i = build ]; then
      rm -r build # Clean old build directory
      mkdir build # Recreate build directory
      for dir in js css img; do
        cp -R $i/$dir build/$dir # Copy js, css & img assets to build directory
      done
      break
    fi
  fi
done
