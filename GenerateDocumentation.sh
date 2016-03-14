#!/bin/bash

print_color () { tput setab 7; tput setaf 0; echo "$1"; tput sgr0; }

build_docs () {
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

  . $SITE_DIR/HandleDependencies.sh $i $SITE_DIR
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

# Make hashstash accessible in environment
hasStash=0
stashprefix="HASHSTASH__"
stashindex=0
STASHEDHASHES=()
if [[ -f "hashstash" ]]; then
  hasStash=1
  # Read hashstash line by line
  while IFS="=" read -r -a array; do
    ((${#array[@]} >= 1)) || continue # ignore blank lines
    # Store each key as a prefixed (HASHSTASH__) variable
    printf -v "$stashprefix${array[@]:0:1}" %s ${array[@]:1}
    # Create an array of all stashed hashes
    STASHEDHASHES[$stashindex]="$stashprefix${array[@]:0:1}"
    ((stashindex++)) # increment index
  done < hashstash # <-- defines which file is read in
  # At this point we have a series of variables in the form
  # `HASHSTASH__ModuleName` and an array `STASHEDHASHES` of those variable names
fi

cd $FRAMEWORKS_DIR

newindex=0
NEWHASHES=()
for i in $( ls ); do
  if [[ -d $i ]]; then

      cd $i

      print_color "~~~ $i ~~~"

      VERSION=$(git describe --tags | cut -d - -f -1)
      HASHKEY=$stashprefix$i
      HASH=$(git log -n 1 --pretty=format:"%H")

      if [[ -n $VERSION ]]; then
        print_color "Version: $VERSION"
      else
        print_color "Version: undefined"
      fi

      if [[ $hasStash == 1 ]]; then
        if [ -n "${!HASHKEY}" ]; then
          # A hash has been stashed for this module, check for matches
          if [[ $HASH = ${!HASHKEY} ]]; then
            # The current hash and the stashed hash match
            print_color "$i has not changed, skipping..."
          else
            # The current hash and the stashed hash don’t match, proceed
            build_docs
          fi
        else
          # There is no stashed hash, proceed
          build_docs
        fi
      else
        # There is no hashstash file
        build_docs
      fi

      # Save new hash value for stashing
      printf -v "$i" %s $HASH
      # Create an array of all stashed hash keys
      NEWHASHES[$newindex]="$i"
      ((newindex++)) # increment index

      cd ../

  fi
done

cd $SITE_DIR

# Clean old hashstash
if [[ -f "hashstash" ]]; then
  rm hashstash
fi
# Write new hashes to hashstash
for i in "${NEWHASHES[@]}"
do
  echo "$i=${!i}" >> hashstash
done

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
