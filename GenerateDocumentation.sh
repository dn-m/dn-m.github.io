#!/bin/bash

print_color () { tput setab 7; tput setaf 0; echo "$1"; tput sgr0; }

run_jazzy () {
  jazzy \
    --clean \
    --author James Bean \
    --author_url http://jamesbean.info \
    --github_url https://github.com/dn-m/$i \
    --module-version $VERSION \
    --module $i \
    --root-url https://dn-m.github.io \
    --output $SITE_DIR/$i \
    --skip-undocumented \
    --hide-documentation-coverage \
    --theme $SITE_DIR/dependencies/bean
}

WORK_DIR=${PWD}
if [ $2 ]; then
  SITE_DIR=$2
else
  SITE_DIR=$WORK_DIR
fi
if [ $1 ]; then
  FRAMEWORKS_DIR=$1
else
  FRAMEWORKS_DIR="../Frameworks"
fi

cd $FRAMEWORKS_DIR

for i in $( ls ); do
  if [[ -d $i ]]; then

      cd $i

      print_color "~~~ $i ~~~"

      VERSION=$(git describe --tags | cut -d - -f -1)
      print_color "Version: $VERSION"
        run_jazzy

      cd ../

  fi
done

cd $SITE_DIR

# Clean and build assets for main index
for i in $( ls ); do
  if [[ -d $i ]]; then
    if ! [ $i = dependencies -o $i = build ]; then
      if [ -d "build" ]; then
        rm -r build # Clean old build directory
      fi
      mkdir build # Recreate build directory
      for dir in js css img; do
        cp -R $i/$dir build/$dir # Copy js, css & img assets to build directory
      done
      break
    fi
  fi
done

# Generate main index
./GenerateFrontpage.sh
