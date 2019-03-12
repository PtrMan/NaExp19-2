// AUTOGEN: initializes and fills tries
void initTrie(TrieElement[] rootTries) {
// (A --> B), (C --> B)   |-   (A --> C)		(Truth:induction)
{
    TrieElement te0 = new TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "-->";
    
    TrieElement te1 = new TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "-->";
    te0.children ~= te1;
    
    TrieElement te2 = new TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    TrieElement teX = new TrieElement();
    teX.type = TrieElement.EnumType.EXEC;
    teX.fp = &derive0;
    te3.children ~= teX;
    
    rootTries ~= te0;
}
// (A --> B), (A --> C)   |-   (B --> C)		(Truth:abduction)
{
    TrieElement te0 = new TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "-->";
    
    TrieElement te1 = new TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "-->";
    te0.children ~= te1;
    
    TrieElement te2 = new TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.subject"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    TrieElement teX = new TrieElement();
    teX.type = TrieElement.EnumType.EXEC;
    teX.fp = &derive1;
    te3.children ~= teX;
    
    rootTries ~= te0;
}
// (A ==> B), (C ==> B)   |-   (A ==> C)		(Truth:induction)
{
    TrieElement te0 = new TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "==>";
    
    TrieElement te1 = new TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "==>";
    te0.children ~= te1;
    
    TrieElement te2 = new TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    TrieElement teX = new TrieElement();
    teX.type = TrieElement.EnumType.EXEC;
    teX.fp = &derive2;
    te3.children ~= teX;
    
    rootTries ~= te0;
}
// (A ==> B), (A ==> C)   |-   (B ==> C)		(Truth:abduction)
{
    TrieElement te0 = new TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "==>";
    
    TrieElement te1 = new TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "==>";
    te0.children ~= te1;
    
    TrieElement te2 = new TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.subject"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    TrieElement teX = new TrieElement();
    teX.type = TrieElement.EnumType.EXEC;
    teX.fp = &derive3;
    te3.children ~= teX;
    
    rootTries ~= te0;
}
// (A =|> B), (C =|> B)   |-   (A =|> C)		(Truth:induction)
{
    TrieElement te0 = new TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "=|>";
    
    TrieElement te1 = new TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "=|>";
    te0.children ~= te1;
    
    TrieElement te2 = new TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    TrieElement teX = new TrieElement();
    teX.type = TrieElement.EnumType.EXEC;
    teX.fp = &derive4;
    te3.children ~= teX;
    
    rootTries ~= te0;
}
// (A =|> B), (A =|> C)   |-   (B =|> C)		(Truth:abduction)
{
    TrieElement te0 = new TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "=|>";
    
    TrieElement te1 = new TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "=|>";
    te0.children ~= te1;
    
    TrieElement te2 = new TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.subject"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    TrieElement teX = new TrieElement();
    teX.type = TrieElement.EnumType.EXEC;
    teX.fp = &derive5;
    te3.children ~= teX;
    
    rootTries ~= te0;
}
}


static void derive0(Sentence aSentence, Sentence bSentence, Sentence[] resultSentences, TrieElement trieElement) {
   Term a = a.term;
   Term b = b.term;
   Binary conclusionTerm = new Binary("-->", a.subject, b.subject);
   // TODO< build stamp >
   TruthValue tv = TruthValue.calc("induction", a.truth, b.truth);
   resultSentences ~= new Sentence(conclusionTerm, tv);
}


static void derive1(Sentence aSentence, Sentence bSentence, Sentence[] resultSentences, TrieElement trieElement) {
   Term a = a.term;
   Term b = b.term;
   Binary conclusionTerm = new Binary("-->", a.predicate, b.predicate);
   // TODO< build stamp >
   TruthValue tv = TruthValue.calc("abduction", a.truth, b.truth);
   resultSentences ~= new Sentence(conclusionTerm, tv);
}


static void derive2(Sentence aSentence, Sentence bSentence, Sentence[] resultSentences, TrieElement trieElement) {
   Term a = a.term;
   Term b = b.term;
   Binary conclusionTerm = new Binary("==>", a.subject, b.subject);
   // TODO< build stamp >
   TruthValue tv = TruthValue.calc("induction", a.truth, b.truth);
   resultSentences ~= new Sentence(conclusionTerm, tv);
}


static void derive3(Sentence aSentence, Sentence bSentence, Sentence[] resultSentences, TrieElement trieElement) {
   Term a = a.term;
   Term b = b.term;
   Binary conclusionTerm = new Binary("==>", a.predicate, b.predicate);
   // TODO< build stamp >
   TruthValue tv = TruthValue.calc("abduction", a.truth, b.truth);
   resultSentences ~= new Sentence(conclusionTerm, tv);
}


static void derive4(Sentence aSentence, Sentence bSentence, Sentence[] resultSentences, TrieElement trieElement) {
   Term a = a.term;
   Term b = b.term;
   Binary conclusionTerm = new Binary("=|>", a.subject, b.subject);
   // TODO< build stamp >
   TruthValue tv = TruthValue.calc("induction", a.truth, b.truth);
   resultSentences ~= new Sentence(conclusionTerm, tv);
}


static void derive5(Sentence aSentence, Sentence bSentence, Sentence[] resultSentences, TrieElement trieElement) {
   Term a = a.term;
   Term b = b.term;
   Binary conclusionTerm = new Binary("=|>", a.predicate, b.predicate);
   // TODO< build stamp >
   TruthValue tv = TruthValue.calc("abduction", a.truth, b.truth);
   resultSentences ~= new Sentence(conclusionTerm, tv);
}



