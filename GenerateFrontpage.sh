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
fi

. dependencies/mo
mo index.mo > index.html
