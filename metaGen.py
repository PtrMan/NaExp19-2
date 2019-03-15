
# Non-Axiomatic Logic generation

# TODO< swizzle subject and predicate  when the copula is symetric >
# TODO< implement sets >

# helper
def isPlaceholder(string):
    return len(string) == 1 and string.istitle()

emitExecCode = True # do we emit executable code?

staticFunctionCounter = 0

# used to accumulate all static functions for the derivation
derivationFunctionsSrc = ""

def gen(premiseA, premiseB, conclusion, truthTuple, desire):
    # unpack truthTuple into truth and 
    (truth, intervalProjection) = truthTuple

    (premiseASubj, premiseACopula, premiseAPred) = premiseA
    (premiseBSubj, premiseBCopula, premiseBPred) = premiseB
    (conclusionSubj, conclusionCopula, conclusionPred) = conclusion

    def escape(str_):
        return str_.replace("\\", "\\\\")

    # converts a path to a 
    def convertPathToDSrc(path):
        asStringList = []
        for iPathElement in path:
            if isinstance(iPathElement, str):
                asStringList.append('"'+iPathElement+'"')
            else:
                asStringList.append('"' + str(iPathElement) + '"')
        return "[" + ",".join(asStringList) + "]"


    # need to figure out which terms are the same on both sides
    #
    #
    samePremiseTerms = [] # contains tuple of the paths of the terms which have to be the same
                          # can be multiple

    pathsPremiseA = {}
    if not isinstance(premiseASubj, tuple):
        pathsPremiseA[premiseASubj] = ["a.subject"]
    else:
        pathsPremiseA[premiseASubj[1]] = ["a.subject", 0]
        pathsPremiseA[premiseASubj[2]] = ["a.subject", 1]

    if not isinstance(premiseAPred, tuple):
        pathsPremiseA[premiseAPred] = ["a.predicate"]
    else:
        pathsPremiseA[premiseAPred[1]] = ["a.predicate", 0]
        pathsPremiseA[premiseAPred[2]] = ["a.predicate", 1]


    if not isinstance(premiseBSubj, tuple):
        checkedName = premiseBSubj
        if checkedName in pathsPremiseA:
            samePremiseTerms.append( (pathsPremiseA[checkedName], ["b.subject"]) )
    else:
        checkedName = premiseBSubj[1]
        if checkedName in pathsPremiseA:
            samePremiseTerms.append( (pathsPremiseA[checkedName], ["b.subject", 0]) )

        checkedName = premiseBSubj[2]
        if checkedName in pathsPremiseA:
            samePremiseTerms.append( (pathsPremiseA[checkedName], ["b.subject", 1]) )

    if not isinstance(premiseBPred, tuple):
        checkedName = premiseBPred
        if checkedName in pathsPremiseA:
            samePremiseTerms.append( (pathsPremiseA[checkedName], ["b.predicate"]) )
    else:
        checkedName = premiseBPred[1]
        if checkedName in pathsPremiseA:
            samePremiseTerms.append( (pathsPremiseA[checkedName], ["b.predicate", 0]) )

        checkedName = premiseBPred[2]
        if checkedName in pathsPremiseA:
            samePremiseTerms.append( (pathsPremiseA[checkedName], ["b.predicate", 1]) )


    
    pathsPremiseB = {}
    if not isinstance(premiseBSubj, tuple):
        pathsPremiseB[premiseBSubj] = ["b.subject"]
    else:
        if True: #isPlaceholder(premiseBSubj[0]):
            pathsPremiseB[premiseBSubj[1]] = ["b.subject", 0]
            pathsPremiseB[premiseBSubj[2]] = ["b.subject", 1]
        else:
            # special handling for compounds

            # NOT COMMENTED< because it will be useful for products and images and other compounds >

            pathsPremiseB[premiseBSubj[1]] = ["b.subject", "idx0"] # index indicates array access
            pathsPremiseB[premiseBSubj[2]] = ["b.subject", "idx1"] # index indicates array access

    if not isinstance(premiseBPred, tuple):
        pathsPremiseB[premiseBPred] = ["b.predicate"]
    else:
        if True: #isPlaceholder(premiseBPred[0]):
            pathsPremiseB[premiseBPred[1]] = ["b.predicate", 0]
            pathsPremiseB[premiseBPred[2]] = ["b.predicate", 1]
        else:
            # special handling for compounds

            # NOT COMMENTED< because it will be useful for products and images and other compounds >

            pathsPremiseB[premiseBPred[1]] = ["b.predicate", "idx0"] # index indicates array access
            pathsPremiseB[premiseBPred[2]] = ["b.predicate", "idx1"] # index indicates array access




    def retCode(obj):

        def retCodeOfVar(name):
            resList = None

            if name in pathsPremiseA:
                resList = pathsPremiseA[name]
            elif name in pathsPremiseB:
                resList = pathsPremiseB[name]
            else:
                raise Exception("couldn't find name " + name)

            if len(resList) == 1:
                if resList[0][0] == 'a' or resList[0][0] == 'b':
                    code = "(" + "cast(Binary)"+resList[0][0] + ")" + resList[0][1:]

                return code
            elif len(resList) == 2:
                code = None
                if resList[0][0] == 'a' or resList[0][0] == 'b':
                    code = "(" + "cast(Binary)"+resList[0][0] + ")" + resList[0][1:]


                if resList[1] == 0:
                    code = "(cast(Binary)("+ code +"))" + ".subject"
                elif resList[1] == 1:
                    code = "(cast(Binary)("+ code +"))" + ".predicate"
                #if resList[1] == "idx0": # special handling for compound access
                #    code += ".TODO[0]"
                #elif resList[1] == "idx1":
                #    code += ".TODO[1]" # special handling for compound access
                else:
                    raise Exception("not implemented!")

                return code
            else:
                raise Exception("unexpected length!")


        if isinstance(obj, tuple):
            (a, b, c) = obj

            if isPlaceholder(a):
                # normal handling for statement

                (name0, nameCopula, name1) = obj # structure of conclusion term is encoded as tuple

                codeName0 = retCodeOfVar(name0)
                codeName1 = retCodeOfVar(name1)
                
                return "new shared Binary(\"" + nameCopula + "\"," + codeName0 + "," + codeName1 + ")"
            else:
                # special handling for compound

                (compoundType, name0, name1) = obj

                codeName0 = retCodeOfVar(name0)
                codeName1 = retCodeOfVar(name1)
                
                if compoundType == "*":
                    raise TODO() # generation for the code of products is not implemented!
                elif compoundType in ["|", "||", "&", "&&", "-", "~"]: # fall back to generation of binary
                    return "new shared Binary(\"" + compoundType + "\"," + codeName0 + "," + codeName1 + ")" 
                else:
                    raise Exception() # not implemented or internal error

                raise TODO()
                # TODO< code return handling >
        else:
            return retCodeOfVar(obj)




    conclusionSubjCode = retCode(conclusionSubj)
    conclusionPredCode = retCode(conclusionPred)


    # TODO< print desire >
    print "// ("+str(premiseASubj)+" "+premiseACopula+" "+str(premiseAPred)+"), ("+str(premiseBSubj)+" "+premiseBCopula+" "+str(premiseBPred)+")   |-   ("+str(conclusionSubj)+" "+conclusionCopula+" "+str(conclusionPred)+")\t\t(Truth:"+truth+intervalProjection+")"
    
    global emitExecCode
    if not emitExecCode:
        return # if we don't emit the code and just the inference rules with comments

    # TODO< implement truth computation for time delta with projection >

    # build trie
    

    # TODO< check embedded copula by walking >

    global staticFunctionCounter
    global derivationFunctionsSrc

    
    print "{"
    print "    shared TrieElement te0 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);"
    print "    te0.side = EnumSide.LEFT;"
    print "    te0.checkedString = \""+escape(premiseACopula)+"\";"
    print "    "
    print "    shared TrieElement te1 = new shared TrieElement(TrieElement.EnumType.CHECKCOPULA);"
    print "    te1.side = EnumSide.RIGHT;"
    print "    te1.checkedString = \""+escape(premiseBCopula)+"\";"
    print "    te0.children ~= te1;"
    print "    "

    teCounter = 2

    if not isPlaceholder(premiseA[0]):
        raise NotImplemented()
        """ commented because not used by rules and thus not tested
        comparedCompoundType = premiseA[0][0]

        print "    shared TrieElement te"+str(teCounter)+" = new shared TrieElement(TrieElement.EnumType.WALKCHECKCOMPOUND);"
        

        print "    te"+str(teCounter)+".pathLeft = [\"a.subject\"];" # print python list to D list
        print "    te"+str(teCounter)+".pathRight = [];"
        print "    te"+str(teCounter)+".checkedString = \"" + comparedCompoundType + "\";"
        
        print "    te"+str(teCounter-1)+".children ~= te"+str(teCounter)+";"
        print "    "

        teCounter+=1
        """

    if not isPlaceholder(premiseA[2]):
        raise NotImplemented()
        """
        comparedCompoundType = premiseA[2][0]

        print "    shared TrieElement te"+str(teCounter)+" = new shared TrieElement(TrieElement.EnumType.WALKCHECKCOMPOUND);"
        

        print "    te"+str(teCounter)+".pathLeft = [\"a.predicate\"];" # print python list to D list
        print "    te"+str(teCounter)+".pathRight = [];"
        print "    te"+str(teCounter)+".checkedString = \"" + comparedCompoundType + "\";"
        
        print "    te"+str(teCounter-1)+".children ~= te"+str(teCounter)+";"
        print "    "

        teCounter+=1
        """
    

    if not isPlaceholder(premiseB[0]):
        comparedCompoundType = premiseB[0][0]

        print "    shared TrieElement te"+str(teCounter)+" = new shared TrieElement(TrieElement.EnumType.WALKCHECKCOMPOUND);"
        

        print "    te"+str(teCounter)+".pathLeft = [];" # print python list to D list
        print "    te"+str(teCounter)+".pathRight = [\"b.subject\"];"
        print "    te"+str(teCounter)+".checkedString = \"" + comparedCompoundType + "\";"
        
        print "    te"+str(teCounter-1)+".children ~= te"+str(teCounter)+";"
        print "    "

        teCounter+=1

    if not isPlaceholder(premiseB[2]):
        comparedCompoundType = premiseB[2][0]

        print "    shared TrieElement te"+str(teCounter)+" = new shared TrieElement(TrieElement.EnumType.WALKCHECKCOMPOUND);"
        

        print "    te"+str(teCounter)+".pathLeft = [];" # print python list to D list
        print "    te"+str(teCounter)+".pathRight = [\"b.predicate\"];"
        print "    te"+str(teCounter)+".checkedString = \"" + comparedCompoundType + "\";"
        
        print "    te"+str(teCounter-1)+".children ~= te"+str(teCounter)+";"
        print "    "

        teCounter+=1
    


    for iSamePremiseTerms in samePremiseTerms: # need to iterate because there can be multiple terms which have to be the same
        print "    shared TrieElement te"+str(teCounter)+" = new shared TrieElement(TrieElement.EnumType.WALKCOMPARE);"
        print "    te"+str(teCounter)+".pathLeft = "+ convertPathToDSrc( iSamePremiseTerms[0] ) +";" # print python list to D list
        print "    te"+str(teCounter)+".pathRight = "+ convertPathToDSrc( iSamePremiseTerms[1] ) +";" # print python list to D list
        print "    te"+str(teCounter-1)+".children ~= te"+str(teCounter)+";"
        print "    "
        teCounter+=1
    
    print "    shared TrieElement teX = new shared TrieElement(TrieElement.EnumType.EXEC);"
    print "    teX.fp = &derive"+str(staticFunctionCounter)+";"
    print "    te"+str(teCounter-1)+".children ~= teX;"
    print "    "
    print "    rootTries ~= te0;"
    print "}"
    print "\n"

    teCounter+=1



    derivationFunctionsSrc+= "static void derive"+str(staticFunctionCounter)+"(shared Sentence aSentence, shared Sentence bSentence, Sentences resultSentences, shared TrieElement trieElement) {\n"
    derivationFunctionsSrc+= "   auto a = aSentence.term;\n"
    derivationFunctionsSrc+= "   auto b = bSentence.term;\n"
    derivationFunctionsSrc+= "   \n"
    derivationFunctionsSrc+= "   auto conclusionSubj = "+conclusionSubjCode+";\n"
    derivationFunctionsSrc+= "   auto conclusionPred = "+conclusionPredCode+";\n"

    # TODO< do allow it the conclusion copula is not a real copula >
    derivationFunctionsSrc+= "   if(!isSameRec(conclusionSubj, conclusionPred)) { // conclusion with same subject and predicate are forbidden by NAL\n"    

    derivationFunctionsSrc+= "      shared Binary conclusionTerm = new shared Binary(\""+escape(conclusionCopula)+"\", conclusionSubj, conclusionPred);\n"

    derivationFunctionsSrc+= "      auto stamp = Stamp.merge(aSentence.stamp, bSentence.stamp);\n"
    derivationFunctionsSrc+= "      auto tv = TruthValue.calc(\""+truth+"\", aSentence.truth, bSentence.truth);\n"
    derivationFunctionsSrc+= "      resultSentences.arr ~= new shared Sentence(conclusionTerm, tv, stamp);\n"
    derivationFunctionsSrc+= "   }\n"
    derivationFunctionsSrc+= "}\n"
    derivationFunctionsSrc+= "\n"
    derivationFunctionsSrc+= "\n"


    staticFunctionCounter+=1

    

# each copula-type of form [AsymCop,SymCop,[ConjunctiveCops,DisjunctiveCop,MinusCops]]
CopulaTypes = [
    ["-->","<->",[["&"],"|",["-","~"]]],
    ["==>","<=>",[["&&"],"||",None]], #
    #["=/>(t)","</>(t)",[["&/(t)","&|"],"||",None]], ##
    ["=|>","<|>",[["&/","&|"],"||",None]], #
    #["=\>(t)",None ,[["&/","&|"],"||",None]] ##
]

# generate code for already implemented conversions?
genCodeComplex = False

print "// AUTOGEN: initializes and fills tries"
print "shared(TrieElement)[] initTrie() {"
print "   shared(TrieElement)[] rootTries;"

for [copAsym,copSym,[ConjCops,DisjCop,MinusCops]] in CopulaTypes:
    (bFOL, OmitForHOL, ival, copAsymZ) = (copAsym == "-->", lambda str: str if bFOL else "", lambda str,t: str.replace("t",t), copAsym.replace("t","z"))
    
    # TODO< implement inference generation function to generate code which accepts only one argument >
    #print "(A "+copAsym+" B)\t\t\t\t\t|-\t(B "+ival(copAsym,"-t")+" A)\t\t(Truth:Conversion)"
    
    if False:
        #print "(A "+copAsym+" B),\t(B "+copAsymZ+" C)\t\t\t|-\t(A "+ival(copAsym,"t+z")+" C)\t\t(Truth:deduction"+OmitForHOL(", Desire:Strong")+")"
        gen(("A",copAsym,"B"), ("B",copAsymZ,"C"), ("A",ival(copAsym,"t+z"),"C"),    ("deduction", ""), OmitForHOL("strong"))
    
    copAsymHasTimeOffset = "/" in copAsym or "\\" in copAsym
    IntervalProjection = "WithIntervalProjection(t,z)" if copAsymHasTimeOffset else ""
    
    if False: # block
        gen(("A", copAsym, "B"),   ("C", copAsymZ, "B"),    ("A", copAsym, "C"),   ("induction", IntervalProjection), OmitForHOL("weak"))
        
    if False: # block
        gen(("A", copAsym, "B"),   ("A", copAsymZ, "C"),  ("B", copAsym, "C"), ("abduction", IntervalProjection), OmitForHOL("strong"))


    if copSym != None:
        copSymZ = copSym.replace("t","z")
        
        if False:
            #print "(A "+copSym+" B),\t(B "+copSymZ+" C)\t\t\t|-\t(A "+ival(copSym,"t+z")+" C)\t\t(Truth:resemblance"+OmitForHOL(", Desire:Strong")+")"
            gen(("A",copSym,"B"),("B",copSymZ,"C"),  ("A",ival(copSym,"t+z"),"C"),  ("resemblance", ""), OmitForHOL("strong"))

        if False:
            #print "(A "+copAsym+" B),\t(C "+copSymZ+" B)\t\t\t|-\t(A "+copAsym+" C)\t\t(Truth:analogy"+IntervalProjection+OmitForHOL(", Desire:Strong")+")"
            gen(("A",copAsym,"B"),("C",copSymZ,"B"),  ("A",copAsym,"C"),   ("analogy", IntervalProjection), OmitForHOL("strong"))

        if False:
            #print "(A "+copAsym+" B),\t(C "+copSymZ+" A)\t\t\t|-\t(C "+ival(copSym,"t+z")+" B)\t\t(Truth:analogy"+OmitForHOL(", Desire:Strong")+")"
            gen(("A",copAsym,"B"),("C",copSymZ,"A"),   ("C",ival(copSym,"t+z"),"B"),  ("analogy", ""), OmitForHOL("strong"))
        
        if False:
            #print "(A "+copAsym+" B),\t(C "+copSymZ+" B)\t\t\t|-\t(A "+copSym+" C)\t\t(Truth:comparison"+IntervalProjection+OmitForHOL(", Desire:Weak")+")"
            gen(("A", copAsym, "B"),  ("C", copSymZ, "B"),   ("A",copSym,"C"), ("comparison", IntervalProjection), OmitForHOL("weak"))

        if False:
            #print "(A "+copAsym+" B),\t(A "+copSymZ+" C)\t\t\t|-\t(C "+copSym+" B)\t\t(Truth:comparison"+IntervalProjection+OmitForHOL(", Desire:Weak")+")"
            gen(("A", copAsym, "B"),  ("A",copSymZ,"C"), ("C",copSym,"B"), ("comparison", IntervalProjection), OmitForHOL("weak"))
    
    if not bFOL:
        isBackward = copSym == None
        for ConjCop in ConjCops:
            predRel = "(Time:After(tB,tA))   " if copAsymHasTimeOffset else ("(Time:Parallel(tB,tA))" if "|" in copAsym else "                      ")
            predConj = "(Time:After(tB,tA))   " if "/" in ConjCop or "\\" in ConjCop else ("(Time:Parallel(tB,tA))" if "|" in copAsym else "                      ")
            forwardRel = "tB-tA" if "Time:After" in predRel else "       "
            forwardConj = "tB-tA" if "Time:After" in predConj else "       "

            #if not isBackward:
            #    print "A, \t\tB\t"+predRel+"\t|-\t(A "+copAsym.replace("t",forwardRel)+ "B)\t\t(Truth:Induction, Variables:Introduce$#)"
            #    print "A,\t\tB\t"+predConj+"\t|-\t("+ConjCop.replace("t",forwardConj)+" A B)\t\t(Truth:Intersection, Variables:Introduce#)"
            #    print "A\t\tB\t"+predRel+"\t|-\t(B "+copSym.replace("t",forwardRel)+"A)\t\t(Truth:Comparison, Variables:Introduce$#)"
            #else:
            #    print "A, \t\tB\t"+predRel+"\t|-\t(B "+copAsym+"(tA-tB) A)\t(Truth:Induction, Variables:Introduce$#)"
            #print "("+ConjCop+" A B)\t\t\t\t\t|-\tA\t\t\t(Truth:Deduction, Desire:Induction)"
        
        (tParam, tParam2) = (", Time:-t" if isBackward else ", Time:+t", ", Time:+t" if isBackward else ", Time:-t")
        #print "A,\t\t(A "+copAsym+" B)\t\t\t|-\tB\t\t\t(Truth:Deduction, Desire:Induction, Variables:Unify$#"+(tParam if copAsymHasTimeOffset else "")+")"
        #print "B,\t\t(A "+copAsym+" B)\t\t\t|-\tA\t\t\t(Truth:Abduction, Desire:Deduction, Variables:Unify$#"+(tParam2 if copAsymHasTimeOffset else "")+")"
        #if copSym != None:
        #    print "B,\t\t(A "+copSym+" B)\t\t\t|-\tA\t\t\t(Truth:Analogy, Desire:Strong, Variables:Unify$#)"
    
    for cop in [copAsym,copSym]:
        if cop == None:
            continue

        copZ = cop.replace("t","z")
        if MinusCops != None:
            if True:
                gen(("A",cop,"B"),("C",copZ,"B"),   ((MinusCops[1],"A","C"),cop,"B"),    ("difference", ""), "")
                gen(("A",cop,"B"),("A",copZ,"C"),   ("B",cop,(MinusCops[0],"A","C")),    ("difference", ""), "")
            
            if False:
                gen(("S",cop,"M"),((MinusCops[1],"S","P"),copZ,"B"),   ("P",cop,"M"),   ("decomposePNP", ""), "")
                gen(("S",cop,"M"),((MinusCops[1],"P","S"),copZ,"B"),   ("P",cop,"M"),   ("decomposeNNN", ""), "")
                gen(("M",cop,"S"),("M",copZ,(MinusCops[0],"S","P")),   ("M",cop,"P"),   ("decomposePNP", ""), "")            
                gen(("M",cop,"S"),("M",copZ,(MinusCops[0],"P","S")),    ("M",cop,"P"),  ("decomposeNNN", ""), "")
            


    for cop in [copAsym,copSym]:
        if cop == None:
            continue

        for ConjCop in ConjCops:
            for [junc,[TruthSet1,TruthSet2],[TruthDecomp1,TruthDecomp2]] in [[ConjCop,["union","intersection"],["decomposeNPP","decomposePNN"]],
                                                                             [DisjCop,["intersection","union"],["decomposePNN","decomposeNPP"]]]:
                if junc != None:
                    pass
                    if junc == ConjCop:
                        pass
                        # commented because it only consumes a single premise on the left side! - we haven't implemented this case
                        #print "A,\t\t((" + junc + " A C) "+copZ+" B)\t\t|-\t(C "+ copZ + " B)\t\t(Truth:Deduction"+(tParam.replace("-","+") if copAsymHasTimeOffset else "")+")"

                    if genCodeComplex:
                        #print "(A "+cop+" B),\t(C "+copZ+" B)\t\t\t|-\t((" + junc + " A C) "+ cop + " B) \t" + TruthSet1 + IntervalProjection+")"
                        gen(("A",cop,"B"),("C",copZ,"B"),   ((junc,"A", "C"), cop, "B"),  (TruthSet1, IntervalProjection), "")

                    if genCodeComplex:
                        #print "(A "+cop+" B),\t(A "+copZ+" C)\t\t\t|-\t(A "+ cop + " (" + junc + " B C)) \t"  + TruthSet2 + IntervalProjection+")"
                        gen(("A",cop,"B"),("A",copZ,"C"),   ("A",cop,(junc,"B", "C")),  (TruthSet2, IntervalProjection), "")

                    if False:
                        gen(("S",cop,"M"),((junc,"S", "L"),copZ,"M"),    ("L",cop,"M"),   (TruthDecomp1, IntervalProjection), "")
                    
                    if False:
                        gen(("M",cop,"S"),("M",copZ,(junc,"S","L")),     ("M",cop,"L"),   (TruthDecomp2, IntervalProjection), "")

print "  return rootTries;"
print "}"
print ""
print ""

print derivationFunctionsSrc

