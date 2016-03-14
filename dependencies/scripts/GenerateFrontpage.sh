#!/bin/bash

# Declare Utility modules
UTILITY=(ArithmeticTools ArrayTools CopyTools DictionaryTools DirectionTools EnumTools IntervalTools StringTools TreeTools)
# Declare MusicModel modules
MUSICMODEL=(MusicModel Duration Pitch)
MISC=()

misci=0
utilityi=0
musicmodeli=0
for dir in $( ls ); do
  if [[ -d $dir ]]; then
    if [[ ${UTILITY[*]} =~ "$dir" ]]; then
      UTILITY_VERIFIED[utilityi]="$dir"
      ((utilityi++))
    elif [[ ${MUSICMODEL[*]} =~ "$dir" ]]; then
      MUSICMODEL_VERIFIED[musicmodeli]="$dir"
      ((musicmodeli++))
    elif ! [ "$dir" = dependencies -o "$dir" = build ]; then
      MISC[$misci]="$dir"
      ((misci++))
    fi
  fi
done

if [ $utilityi -gt 0 ]; then
  export ${UTILITY_VERIFIED[@]}
fi
if [ $musicmodeli -gt 0 ]; then
  export ${MUSICMODEL_VERIFIED[@]}
fi
if [ $misci -gt 0 ]; then
  export ${MISC[@]}
  export hasMISC=1
  tput setab 3
  tput setaf 0
  echo "You have uncategorised subdirectories:"
  tput sgr0
  for dir in ${MISC[@]}; do
    echo "—— $dir"
  done
fi


if [[ -e main.md ]]; then
  ruby dependencies/scripts/Md2Mo.rb main.md
else
  print_color "Looks like you’re missing main.md! No homepage content for you."
fi
. dependencies/scripts/mo
mo dependencies/templates/index.mo > index.html
