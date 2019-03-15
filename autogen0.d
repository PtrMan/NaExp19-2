// AUTOGEN: initializes and fills tries
shared(TrieElement)[] initTrie() {
   shared(TrieElement)[] rootTries;
// (A --> B), (B --> C)   |-   (A --> C)		(Truth:deduction)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "-->";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "-->";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive0;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A --> B), (C --> B)   |-   (A --> C)		(Truth:induction)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "-->";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "-->";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive1;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A --> B), (A --> C)   |-   (B --> C)		(Truth:abduction)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "-->";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "-->";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.subject"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive2;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A <-> B), (B <-> C)   |-   (A <-> C)		(Truth:resemblance)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "<->";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<->";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive3;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A --> B), (C <-> B)   |-   (A --> C)		(Truth:analogy)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "-->";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<->";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive4;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A --> B), (C <-> A)   |-   (C <-> B)		(Truth:analogy)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "-->";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<->";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.subject"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive5;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A --> B), (C <-> B)   |-   (A <-> C)		(Truth:comparison)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "-->";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<->";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive6;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A --> B), (A <-> C)   |-   (C <-> B)		(Truth:comparison)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "-->";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<->";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.subject"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive7;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A ==> B), (B ==> C)   |-   (A ==> C)		(Truth:deduction)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "==>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "==>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive8;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A ==> B), (C ==> B)   |-   (A ==> C)		(Truth:induction)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "==>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "==>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive9;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A ==> B), (A ==> C)   |-   (B ==> C)		(Truth:abduction)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "==>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "==>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.subject"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive10;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A <=> B), (B <=> C)   |-   (A <=> C)		(Truth:resemblance)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "<=>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<=>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive11;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A ==> B), (C <=> B)   |-   (A ==> C)		(Truth:analogy)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "==>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<=>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive12;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A ==> B), (C <=> A)   |-   (C <=> B)		(Truth:analogy)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "==>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<=>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.subject"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive13;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A ==> B), (C <=> B)   |-   (A <=> C)		(Truth:comparison)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "==>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<=>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive14;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A ==> B), (A <=> C)   |-   (C <=> B)		(Truth:comparison)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "==>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<=>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.subject"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive15;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A =|> B), (B =|> C)   |-   (A =|> C)		(Truth:deduction)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "=|>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "=|>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive16;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A =|> B), (C =|> B)   |-   (A =|> C)		(Truth:induction)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "=|>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "=|>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive17;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A =|> B), (A =|> C)   |-   (B =|> C)		(Truth:abduction)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "=|>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "=|>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.subject"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive18;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A <|> B), (B <|> C)   |-   (A <|> C)		(Truth:resemblance)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "<|>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<|>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive19;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A =|> B), (C <|> B)   |-   (A =|> C)		(Truth:analogy)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "=|>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<|>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive20;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A =|> B), (C <|> A)   |-   (C <|> B)		(Truth:analogy)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "=|>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<|>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.subject"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive21;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A =|> B), (C <|> B)   |-   (A <|> C)		(Truth:comparison)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "=|>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<|>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.predicate"];
    te2.pathRight = ["b.predicate"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive22;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


// (A =|> B), (A <|> C)   |-   (C <|> B)		(Truth:comparison)
{
    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te0.side = EnumSide.LEFT;
    te0.checkedString = "=|>";
    
    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);
    te1.side = EnumSide.RIGHT;
    te1.checkedString = "<|>";
    te0.children ~= te1;
    
    shared TrieElement te2 = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);
    te2.pathLeft = ["a.subject"];
    te2.pathRight = ["b.subject"];
    te1.children ~= te2;
    
    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);
    teX.fp = &derive23;
    te2.children ~= teX;
    
    rootTries ~= te0;
}


  return rootTries;
}


static void derive0(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("-->", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("deduction", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive1(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).subject;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("-->", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("induction", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive2(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).predicate;
   auto conclusionPred = (cast(Binary)b).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("-->", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("abduction", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive3(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("<->", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("resemblance", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive4(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).subject;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("-->", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("analogy", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive5(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)b).subject;
   auto conclusionPred = (cast(Binary)a).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("<->", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("analogy", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive6(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).subject;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("<->", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("comparison", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive7(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)b).predicate;
   auto conclusionPred = (cast(Binary)a).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("<->", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("comparison", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive8(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("==>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("deduction", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive9(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).subject;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("==>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("induction", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive10(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).predicate;
   auto conclusionPred = (cast(Binary)b).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("==>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("abduction", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive11(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("<=>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("resemblance", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive12(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).subject;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("==>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("analogy", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive13(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)b).subject;
   auto conclusionPred = (cast(Binary)a).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("<=>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("analogy", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive14(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).subject;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("<=>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("comparison", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive15(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)b).predicate;
   auto conclusionPred = (cast(Binary)a).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("<=>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("comparison", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive16(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("=|>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("deduction", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive17(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).subject;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("=|>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("induction", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive18(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).predicate;
   auto conclusionPred = (cast(Binary)b).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("=|>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("abduction", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive19(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("<|>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("resemblance", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive20(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).subject;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("=|>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("analogy", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive21(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)b).subject;
   auto conclusionPred = (cast(Binary)a).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("<|>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("analogy", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive22(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)a).subject;
   auto conclusionPred = (cast(Binary)b).subject;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("<|>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("comparison", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}


static void derive23(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {
   auto a = aSentence.term;
   auto b = bSentence.term;
   
   auto conclusionSubj = (cast(Binary)b).predicate;
   auto conclusionPred = (cast(Binary)a).predicate;
   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL
      shared Binary conclusionTerm = new shared Binary("<|>", conclusionSubj, conclusionPred);
      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);
      auto tv = TruthValue.calc("comparison", aSentence.truth, bSentence.truth);
      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);
   }
}



