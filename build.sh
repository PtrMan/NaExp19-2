

python2 metaGen.py > autogen0.d

cat Reasoner.d autogen0.d > tempBuild000.d

dmd tempBuild000.d Stamp.d TruthValue.d Terms.d TermTools.d Sentence.d
#dmd -O -profile tempBuild000.d Stamp.d TruthValue.d Terms.d TermTools.d Sentence.d
#~/dir/programs/ldc2-1.15.0-beta1-linux-x86_64/bin/ldc2 -O tempBuild000.d Stamp.d TruthValue.d Terms.d TermTools.d Sentence.d

#rm autogen0.d

#rm tempBuild000.d
rm tempBuild000.o



# rename
mv tempBuild000 Reasoner