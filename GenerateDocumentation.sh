#!/bin/bash

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
        --output $SITE_DIR/$i \
        --skip-undocumented \
        --hide-documentation-coverage \
        --theme $SITE_DIR/dependencies/bean

      cd ../
      
    fi
  fi
done

cd $SITE_DIR
