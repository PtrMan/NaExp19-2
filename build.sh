

python2 metaGen.py > autogen0.d

cat Reasoner.d autogen0.d > tempBuild000.d

dmd tempBuild000.d

#rm autogen0.d

rm tempBuild000.d tempBuild000.o



# rename
mv tempBuild000 Reasoner