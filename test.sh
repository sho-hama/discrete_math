#!/bin/zsh

TEST_SCRIPT="highway_advertisement.rb"

RANDOM_TEST_CASE_GENERATOR="script.pl"
MAX_LOOP=$1
DISTANCE=$2
ADV_POINT=$3
MAX_PREF=10

INPUT_FILE="in.txt"
OUTPUT_FILE="out.txt"

WIN_ALGORITHM1=0
WIN_ALGORITHM2=0
DROW=0

tmp1=0
tmp2=0

echo "Running Test Script ... "
echo "テスト回数: $MAX_LOOP 回"
for i in `seq 1 $MAX_LOOP`;
do
    perl $RANDOM_TEST_CASE_GENERATOR $DISTANCE $MAX_PREF $ADV_POINT
    ruby $TEST_SCRIPT < $INPUT_FILE 1> $OUTPUT_FILE 2>/dev/null
    RES_ALGORITHM1=`sed -n 1p $OUTPUT_FILE`
    RATE_ALGORITHM1=`sed -n 2p $OUTPUT_FILE`
    RES_ALGORITHM2=`sed -n 3p $OUTPUT_FILE`
    RATE_ALGORITHM2=`sed -n 4p $OUTPUT_FILE`
    tmp1=$((RATE_ALGORITHM1 + tmp1))
    tmp2=$((RATE_ALGORITHM2 + tmp2))

    if [ $RES_ALGORITHM1 -gt $RES_ALGORITHM2 ] ; then
        WIN_ALGORITHM1=$((WIN_ALGORITHM1 + 1))
    elif [ $RES_ALGORITHM2 -gt $RES_ALGORITHM1 ] ; then
        WIN_ALGORITHM2=$((WIN_ALGORITHM2 + 1))
    else
        DROW=$((DROW + 1))
    fi
done
RATE_ALGORITHM1_AVG=`echo "scale=3; $tmp1/$MAX_LOOP" | bc`
RATE_ALGORITHM2_AVG=`echo "scale=3; $tmp2/$MAX_LOOP" | bc`
echo " "
echo "~~~~~~~~~~~ REPORT ~~~~~~~~~~~"
echo "距離: $DISTANCE"
echo "広告設置可能ポイント: $ADV_POINT"
echo "テスト回数: $MAX_LOOP 回"
echo "アルゴリズム1 "
echo "$WIN_ALGORITHM1 勝, スコア到達率 $RATE_ALGORITHM1_AVG"
echo "アルゴリズム2 "
echo "$WIN_ALGORITHM2 勝, スコア到達率 $RATE_ALGORITHM2_AVG"
echo "引き分け $DROW 回"
echo "~~~~~~~~~ END REPORT ~~~~~~~~~"
