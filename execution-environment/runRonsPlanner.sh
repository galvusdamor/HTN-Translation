#!/bin/bash

maxTime=1800
# slice=5

./pandaPIparser -R $1 $2 d.hpdl p.hpdl
./htntranslate -s d.hpdl p.hpdl &> analysis.log

minBound=1
maxBound=10000
bStep=1

if grep -q "min progression bound:" analysis.log
then
  line=$(grep -i "min progression bound: " analysis.log)
  minBound=$(sed 's/Problem .* min progression bound: //' <<< "$line")
fi

if [ "$minBound" -gt "1000" ]
then
  minBound=1
fi

if grep -q "max progression bound:" analysis.log
then
  line=$(grep -i "max progression bound: " analysis.log)
  maxBound=$(sed 's/Problem .* max progression bound: //' <<< "$line")
fi

echo "using the following parameters:"
echo "min bound:  $minBound"
echo "max bound:  $maxBound"
# echo "step size:  $bStep"
# echo "full time:  $maxTime"
# echo "time slice: $slice"

echo
echo "starting..."
bound=$minBound
timeL=$maxTime # set time here!
while true
do
  echo
  echo "using bound: $bound"
  echo
  ./htntranslate -t ordered -i "$bound" d.hpdl p.hpdl -p .ron
  /home/dh/Dokumente/versioniert/Source-Code/FastDownward/fast-downward.py d.ron p.ron --evaluator 'hff=ff()' --search "iterated([ehc(hff, preferred=[hff]),lazy_greedy([hff], preferred=[hff])], continue_on_fail=true, continue_on_solve=false, max_time=$timeL)"
  status=$?
  if [ "$status" -eq "0" ]
  then
    exit 0
  fi
  let bound=$bound+$bStep
  # let timeL=$timeL+$slice
done
