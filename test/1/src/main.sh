
#use MULANG_SOFT_WORKING_DIR
#use MULANG_HARD_WORKING_DIR

echo Hello1 > $MULANG_SOFT_WORKING_DIR/data.txt
echo Hello2 > $MULANG_HARD_WORKING_DIR/data.txt

cat $MULANG_SOFT_WORKING_DIR/data.txt
cat $MULANG_HARD_WORKING_DIR/data.txt


