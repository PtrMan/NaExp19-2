// TODO< refactor < put functions to update belief of single concept to public function        of concept> >
// TODO< refactor < put functions to query if a belief exists to public function               of concept > >





// TODO< implement truth value for union, intersection and decomposition >

// TODO< implement WALKCHECKCOMPOUND which walks and checks the copula >


// LATER TODO< basic Q&A >
// LATER TODO< basic attention mechanism >

// TODO< implement  construction of compounds (class is ProdStar)  ex:   ("A",cop,(junc,"B", "C"))  >


// LATER TODO< add rules for products to metaGen.py >


// LATER TODO< add rules for detachment to metaGen.py >
// LATER TODO< metaGen.py : generate backward inference rules >
// LATER TODO< add a lot of the missing rules to metaGen.py >
// LATER TODO< sets >
// LATER TODO< add inference rules for sets to metaGen.py >


// LATER TODO< variable unifier >
// LATER TODO< backward inference >



// LATER TODO< decision making :( >

import std.array;
import std.random;
import std.stdio;
import std.algorithm.mutation;
import std.algorithm.comparison;
import std.conv;
import core.sync.mutex;
import core.atomic;

void main() {	
	shared Reasoner reasoner = new shared Reasoner();
	reasoner.init();




	// add existing belief
	{
		shared Term term = new shared Binary("-->", new shared AtomicTerm("b"), new shared AtomicTerm("c"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence(term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}

	{
		shared Term term = new shared Binary("-->", new shared AtomicTerm("c"), new shared AtomicTerm("d"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence(term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}

	{
		shared Term term = new shared Binary("-->", new shared AtomicTerm("d"), new shared AtomicTerm("e"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence(term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}

	{
		shared Term term = new shared Binary("-->", new shared AtomicTerm("e"), new shared AtomicTerm("f"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence(term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}

	{
		shared Term term = new shared Binary("<=>", new shared AtomicTerm("b"), new shared AtomicTerm("c"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence(term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}

	// TODO< implement reasoning loop >


	foreach(long i;0..10) {  // TEST REASONING LOOP



	
	{
		shared Term term = new shared Binary("<->", new shared AtomicTerm("a"), new shared AtomicTerm("b"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
		auto sentence = new shared Sentence(term, tv, stamp);

		auto task = new shared Task();
		task.sentence = sentence;
		reasoner.mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task);
	}



	{
		shared Term term = new shared Binary("-->", new shared AtomicTerm("d"), new shared AtomicTerm("c"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
		auto sentence = new shared Sentence(term, tv, stamp);

		auto task = new shared Task();
		task.sentence = sentence;
		reasoner.mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task);
	}
	

	
	{
		shared Term term = new shared Binary("<=>", new shared AtomicTerm("a"), new shared AtomicTerm("b"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
		auto sentence = new shared Sentence(term, tv, stamp);

		auto task = new shared Task();
		task.sentence = sentence;
		reasoner.mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task);
	}
	



	reasoner.singleCycle();


	} // TEST REASONING LOOP
}

/**
 * working memory implements some functionality of attention
 *
 * mechanisms are inspired by ALANN(2018)
 */
class WorkingMemory {
	// 
	// TODO< add prioritization based on EXP() and activation(which is calculated with exponentially moving average) >
	TaskWithAttention[] activeTasks;
}

// task with ema of activation
shared class TaskWithAttention {
	shared Task task;
	Ema ema; // ema used to compute activation

	public final shared this(shared Task task) {
		this.task = task;
		ema.k = 0.1; // TODO< refine and expose parameter >
	}

	public final double calcRanking() {
		// TODO< refine formula >
		return ema.ema + task.sentence.truth.calcExp();
	}
}

// exponential moving average
// see for explaination https://www.investopedia.com/ask/answers/122314/what-exponential-moving-average-ema-formula-and-how-ema-calculated.asp
struct Ema {
	double k = 1; // adaptivity factor
	double ema = 0;

	public final double update(double value) {
		ema = value * k + ema * (1.0 - k);
		return ema;
	}
}


shared class Memory {
	public WorkingMemory workingMemory;
	public ConceptTable concepts;
	public Xorshift rng = Xorshift(24);

	public int numberOfBeliefs = 100; // Reasoner parameter!

	private long stampCounter = 0;

	public final this() {
		concepts = new ConceptTable();
		workingMemory = new WorkingMemory();

		stampCounter = 0;
	}

	public final shared long retUniqueStampCounter() {
		long result;
		synchronized {
			result = stampCounter++;
		}
		return result;
	}

	public final Sentences infer(shared Task t, shared Concept c, shared TrieDeriver deriver) {
		Sentences resultSentences = new Sentences();

		// pick random belief and try to do inference

		if (c.beliefs.entries.length == 0) {
			return resultSentences; // can't select a belief to do inference
		}

		Xorshift rng2 = cast(XorshiftEngine!(uint, 128u, 11u, 8u, 19u))rng;
		long beliefIdx = uniform(0, cast(int)c.beliefs.entries.length, rng2);
		rng = cast(shared(XorshiftEngine!(uint, 128u, 11u, 8u, 19u)))rng2;

		writeln("Memory.infer() selectedBeliefIdx=", beliefIdx, " of ", c.beliefs.entries.length);

		auto selectedBelief = c.beliefs.entries[beliefIdx];

		if (Stamp.checkOverlap(t.sentence.stamp, selectedBelief.stamp)) {
			return resultSentences;
		}

		deriver.derive(t.sentence, selectedBelief, resultSentences);
		return resultSentences;
	
	}

	// creates concepts if necessary and puts the belief into all relevant concepts 
	public final void conceptualize(shared Term term) {
		bool debugVerbose = true;

		// conceptualizes by selected term recursivly
		void conceptualizeByTermRec(shared Term term) {
			if(debugVerbose)   writeln("conceptualize: called for term=" ~ convToStrRec(term));

			if(!concepts.hasConceptByName(term)) {
				// create concept and insert into table

				if(debugVerbose)   writeln("conceptualize: created concept for term=" ~ convToStrRec(term));

				auto createdConcept = new shared Concept(term, numberOfBeliefs);
				concepts.insertConcept(createdConcept);
			}

			if(debugVerbose)   writeln("conceptualize: call recursivly");

			{ // call recursivly
				if (cast(shared BinaryTerm)term !is null) {
					auto binary = cast(shared Binary)term; // TODO< cast to binaryTerm and use methods to access children >

					conceptualizeByTermRec(binary.subject);
					conceptualizeByTermRec(binary.predicate);
				}
				else if (cast(shared AtomicTerm)term !is null) {
					// we can't recurse into atomics
				}
				else {
					// TODO< call function which throws an exception in debug mode >
					throw new Exception("conceptualize(): unhandled case!");
				}
			}
		}

		conceptualizeByTermRec(term);
	}

	// adds the belief to the concepts
	public final void addBeliefToConcepts(shared Sentence belief) {
		// selects term recursivly
		void addBeliefRec(shared Term name) {
			// TODO< enable when debuging   >  assert concepts.hasConceptByName(term)

			auto concept = concepts.retConceptByName(name);
			updateBelief(concept, belief);

			{ // call recursivly
				if (cast(shared BinaryTerm)name !is null) {
					shared Binary binary = cast(shared Binary)name; // TODO< cast to binaryTerm and use methods to access children >

					addBeliefRec(binary.subject);
					addBeliefRec(binary.predicate);
				}
				else if (cast(shared AtomicTerm)name !is null) {
					// we can't recurse into atomics
				}
				else {
					// TODO< call function which throws an exception in debug mode >
					throw new Exception("conceptualize(): unhandled case!");
				}
			}
		}

		addBeliefRec(belief.term);
	}
}

shared class Reasoner {
	public Xorshift rng = Xorshift(12);

	shared Memory mem;
	TrieDeriver deriver = new TrieDeriver();

	public this() {
		mem = new shared Memory();
	}

	public void init() {
		deriver.init();
	}

	public void singleCycle() {
		bool debugVerbose = true;

		if (debugVerbose)  writeln("singleCycle() ENTRY");
		scope(exit)  if (debugVerbose)  writeln("singleCycle() EXIT");

		shared(Sentence)[] derivedSentences;
		
		{ // select task and process it with selected concepts
			shared Task selectedTask;
			{ // select random task for processing
				Xorshift rng2 = cast(XorshiftEngine!(uint, 128u, 11u, 8u, 19u))rng;
				long chosenTaskIndex = uniform(0, mem.workingMemory.activeTasks.length, rng2);
				rng = cast(shared(XorshiftEngine!(uint, 128u, 11u, 8u, 19u)))rng2;
				selectedTask = mem.workingMemory.activeTasks[chosenTaskIndex].task;
			}

			// do test inference and look at the result (s)

			
			{ // pick random n concepts of the enumerated subterms of testtask and do inference for them
				auto termAndSubtermsOfSentenceOfTask = enumerateTermsRec(selectedTask.sentence.term);

				int numberOfSampledTerms = 5;
				// sample terms from termAndSubtermsOfSentenceOfTask
				Xorshift rng2 = cast(XorshiftEngine!(uint, 128u, 11u, 8u, 19u))rng;
				auto sampledTerms = sampleFromArray(termAndSubtermsOfSentenceOfTask, numberOfSampledTerms, rng2);
				rng = cast(shared(XorshiftEngine!(uint, 128u, 11u, 8u, 19u)))rng2;
				
				{ // do inference for the concepts named by sampledTerms
					foreach(shared Term iSampledTerm; sampledTerms) {
						if (!mem.concepts.hasConceptByName(iSampledTerm)) {
							continue;
						}

						auto selectedConcept = mem.concepts.retConceptByName(iSampledTerm);

						if(debugVerbose)   writeln("reasoning: infer for taskTerm=" ~ convToStrRec(selectedTask.sentence.term) ~ " concept.name=" ~ convToStrRec(selectedConcept.name));
						derivedSentences ~= mem.infer(selectedTask, selectedConcept, deriver).arr;
					}
				}
			}
		}

		{ // debug
			if(false)   writeln("derived sentences#=", derivedSentences.length);

			foreach(shared Sentence iDerivedSentence; derivedSentences) {
				// TODO< convert Sentence to string and print >
				writeln("   derived ", convToStrRec(iDerivedSentence.term) ~ "  stamp=" ~ iDerivedSentence.stamp.convToStr());
			}
		}

		{ // put derived results into concepts
			foreach(shared Sentence iDerivedSentence; derivedSentences) {
				mem.conceptualize(iDerivedSentence.term);

				// WORKAROUND< for now we just add it to the beliefs >
				// TODO< must be done for every term and subterm of iDerivedSentence.term >
				auto concept = mem.concepts.retConceptByName(iDerivedSentence.term);
				updateBelief(concept, iDerivedSentence);
			}
		}

		{ // TODO ATTENTION< we need to spawn tasks for the derived results - but we need to manage attention with a activation value >
			// WORKAROUND< we just add the conclusions as tasks >
			foreach(shared Sentence iDerivedSentence; derivedSentences) {
				auto task = new shared Task();
				task.sentence = iDerivedSentence;

				// TODO< don't add if it is known by stamp !!! >

				mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task);
			}
		}
	}
}



class TrieDeriver {
	// tries which are the roots and are iterated independently
	shared(TrieElement)[] rootTries;

	final shared void init() {
		rootTries = initTrie();
		writeln("TrieDeriver: init with nTries=", rootTries.length);
	}

	final shared void derive(shared Sentence leftSentence, shared Sentence rightSentence, Sentences resultSentences) {
		foreach(shared TrieElement iRootTries; rootTries) {
			interpretTrieRec(iRootTries, leftSentence, rightSentence, resultSentences);
			interpretTrieRec(iRootTries, rightSentence, leftSentence, resultSentences);
		}
	}
}

// wrapper for multiple sentences to pass around in a shared context
class Sentences {
	public shared(Sentence)[] arr;
}

class TrieElement {
	public final shared this(EnumType type) {
		this.type = type;
	}

	public EnumType type;
	public EnumSide side;
	public string checkedString; // can be checked copula

	public string[] pathLeft;
	public string[] pathRight;

	// function which builds the result or returns null on failure
	// trie element is passed to pass some additional data to it
	public void function(shared Sentence leftSentence, shared Sentence rightSentence, Sentences resultSentences, shared TrieElement trieElement) fp;

	public TrieElement[] children; // children are traversed if the check was true


	public enum EnumType {
		CHECKCOPULA, // check copula of premise
		//FIN, // terminate processing  - commented because it is implicitly terminated if nothing else matches

		WALKCOMPARE, // walk left and compare with walk right

		WALKCHECKCOMPOUND, // walk and check the type of a compound

		EXEC, // trie element to run some code with a function
	}
}

// interprets a trie
// returns null if it fails - used to propagate control flow
bool interpretTrieRec(
	shared TrieElement trieElement,
	shared Sentence leftSentence,
	shared Sentence rightSentence,
	Sentences resultSentences
) {
	bool debugVerbose = false;

	if (debugVerbose) writeln("interpretTrieRec ENTRY");

	shared Term left = leftSentence.term;
	shared Term right = rightSentence.term;

	// returns null if it didn't find it
	// TODO< refactor to recursive function which cuts down the path >
	shared(Term) walk(shared(string[]) path) {
		shared(Term) walkToBinarySubject(shared Term root) {
			return cast(shared Binary)root !is null ? (cast(shared Binary)root).subject : null;
		}

		shared(Term) walkToBinaryPredicate(shared Term root) {
			return cast(shared Binary)root !is null ? (cast(shared Binary)root).predicate : null;
		}

		shared Term current = null;

		foreach(string iPath; path) {
			if (iPath == "a.subject") {
				current = walkToBinarySubject(left);
			}
			else if (iPath == "a.predicate") {
				current = walkToBinaryPredicate(left);
			}
			else if (iPath == "b.subject") {
				current = walkToBinarySubject(right);
			}
			else if (iPath == "b.predicate") {
				current = walkToBinaryPredicate(right);
			}
			
			// path in Binary
			else if (iPath == "0") {
				current = walkToBinarySubject(current);
			}
			else if (iPath == "1") {
				current = walkToBinaryPredicate(current);
			}
		}

		return current;
	}


	if (trieElement.type == TrieElement.EnumType.CHECKCOPULA) {
		if(debugVerbose) writeln("interpretTrieRec CHECKCOPULA");

		if (trieElement.side == EnumSide.LEFT) {
			Binary b = cast(Binary)left;
			if (b is null) {
				throw new Exception("");
			}
			if (b.copula != trieElement.checkedString) {
				return true; // propagate failure
			}
		}
		else { // check right
			Binary b = cast(Binary)right;
			if (b is null) {
				throw new Exception("");
			}
			if (b.copula != trieElement.checkedString) {
				return true; // propagate failure
			}
		}
	}
	else if(trieElement.type == TrieElement.EnumType.EXEC) {
		if(debugVerbose) writeln("interpretTrieRec EXEC");

		trieElement.fp(leftSentence, rightSentence, resultSentences, trieElement);
	}
	else if(trieElement.type == TrieElement.EnumType.WALKCOMPARE) {
		if(debugVerbose) writeln("interpretTrieRec WALKCOMPARE");

		auto leftElement = walk(trieElement.pathLeft);
		auto rightElement = walk(trieElement.pathRight);

		if (leftElement is null || rightElement is null || !isSameRec(leftElement, rightElement)) {
			return true; // abort if walk failed or if the walked elements don't match up
		}
	}
	else if(trieElement.type == TrieElement.EnumType.WALKCHECKCOMPOUND) {
		if(debugVerbose) writeln("interpretTrieRec WALKCHECKCOMPOUND");

		// function which checks if the expected compound term or binary term is present
		bool checkCompoundOrBinary(shared Term term, string comparedCompoundType) {
			if (comparedCompoundType == "*") { // product expected
				// TODO< implement special handling for product
				throw new Exception("TODO - not implemented");
			}
			else if (comparedCompoundType == "-" || comparedCompoundType == "~" || comparedCompoundType == "|" || comparedCompoundType == "||" || comparedCompoundType == "&" || comparedCompoundType == "&&") { // handling for binary
				// must be binary
				auto binary = cast(shared Binary)term;
				if (binary is null) { // must be binary
					return false; // return failure because it found a not expected term
				}

				if (binary.copula != comparedCompoundType) { // binary must be of expected type
					return false;
				}

				return true;
			}
			else { // not implemented case
				throw new Exception("debug - ignorable internal error (checkCompoundOrBinary) for compound/binary=" ~ comparedCompoundType); // either not implemented or 

				return false; // we must return because it did not match
			}
		}

		if (trieElement.pathLeft.length == 0) { // walk right
			auto path = trieElement.pathRight;
			auto walkedTerm = walk(path);

			if (walkedTerm is null) { // doesn't the expected term exist?
				return false; // return failure if so
			}

			string comparedCompoundType = trieElement.checkedString;

			if (!checkCompoundOrBinary(walkedTerm, comparedCompoundType)) {
				return false; // propage failure
			}
			
			// fall through because we want to walk children
		}
		else if(trieElement.pathRight.length == 0) { // walk left
			auto path = trieElement.pathLeft;
			auto walkedTerm = walk(path);

			if (walkedTerm is null) { // doesn't the expected term exist?
				return false; // return failure if so
			}

			string comparedCompoundType = trieElement.checkedString;

			if (!checkCompoundOrBinary(walkedTerm, comparedCompoundType)) {
				return false; // propage failure
			}
			
			// fall through because we want to walk children
		}
		else {} // ignore

		throw new Exception("TODO - not implemented");
	}

	// we need to iterate children if we are here
	foreach( shared TrieElement iChildren; trieElement.children) {
		bool recursionResult = interpretTrieRec(iChildren, leftSentence, rightSentence, resultSentences);
		if (recursionResult ) {
			//return recursionResult;
		}
	}

	return true;
}

public enum EnumSide {
	LEFT,
	RIGHT
}




interface Term {
	// a : atomic
	// b : binary with copula
	// S : set
	char retType();

	// same terms have to have the same hash
	shared long retHash();
}



/* commented because not used
interface Indexable {
	Term retAt(int idx);
	int retSize();	
}

interface CompoundTerm : Term, Indexable {
}
 */

/* commented because not used
interface SetTerm : Term, Indexable {
	// '['
	// '{'
	char retSetType();
}
 */

long calcHash(string str) {	
	long hash = 17;
    foreach(char ic; str) {
        hash *= ic;
        hash += 17;
    }
    return hash;
}

class AtomicTerm : Term {
	public shared final this(string name) {
		this.name = name;
        cachedHash = calcHash(name);
	}

    public shared long retHash() {
        return cachedHash;
    }

	public char retType() {return 'a';}

	public string name;

    private long cachedHash;
}

interface BinaryTerm : Term {
	// TODO< methods >
}

class Binary : BinaryTerm {
	public shared final this(string copula, shared Term subject, shared Term predicate) {
		this.copula = copula;
		this.subject = subject;
		this.predicate = predicate;
	}

	public char retType() {return 'b';}

    public shared long retHash() {
    	// TODO OPTIMIZATION< cache hash >

        long hash = subject.retHash();
        hash = hash << 3 || hash >> (64-3); // rotate
        hash ^= 0x34052AAB34052AAB;

        hash ^= predicate.retHash();
        hash = hash << 3 || hash >> (64-3); // rotate
        hash ^= 0x34052AAB34052AAB;
        
        hash ^= calcHash(copula);

        return hash;
    }

	public string copula;
	public shared Term subject;
	public shared Term predicate;
}

// TODO< convert to struct >
class TruthValue {
	public float freq;
	public double conf;

	public final shared this(float freq, double conf) {
		this.freq = freq;
		this.conf = conf;
	}

	public static shared(TruthValue) calc(string function_, shared TruthValue a, shared TruthValue b) {
		float horizon = 1.0f;

		double f1 = a.freq;
		double c1 = a.conf;
		double f2 = b.freq;
		double c2 = b.conf;

		if (function_ == "analogy") {
        	double f = and(f1, f2);
        	double c = and(c1, c2, f2);
			return new shared TruthValue(cast(float)f, c);
		}
		else if(function_ == "resemblance") {
			double f = and(f1, f2);
        	double c = and(c1, c2, or(f1, f2));
			return new shared TruthValue(cast(float)f, c);
		}
		else if(function_ == "induction") {
			return abduction(b, a, horizon);
		}
		else if(function_ == "abduction") {
			return abduction(a, b, horizon);
		}
		else if(function_ == "deduction") {
			double f = and(f1, f2);
        	double c = and(c1, c2, f);
			return new shared TruthValue(cast(float)f, c);
		}
		else if(function_ == "resemblance") {
			double f = and(f1, f2);
        	double c = and(c1, c2, or(f1, f2));
			return new shared TruthValue(cast(float)f, c);
		}
		else if(function_ == "comparison") {
			double f0 = or(f1, f2);
        	double f = (f0 == 0.0) ? 0.0 : (and(f1, f2) / f0);
        	double w = and(f0, c1, c2);
        	double c = w2c(w, horizon);
			return new shared TruthValue(cast(float)f, c);
		}
		else if(function_ == "revision") {
			double w1 = c2w(a.conf, horizon);
        	double w2 = c2w(b.conf, horizon);
        	double w = w1 + w2;
        	double f = (w1 * f1 + w2 * f2) / w;
			double c = w2c(w, horizon);
			return new shared TruthValue(cast(float)f, c);
		}
		// TODO< implement other truth functions >

		throw new Exception("Unimplemented truth function name=" ~ function_);
	}

	private static shared(TruthValue) abduction(shared TruthValue a, shared TruthValue b, double horizon) {
		double f1 = a.freq;
		double c1 = a.conf;
		double f2 = b.freq;
		double c2 = b.conf;

		double w = and(f2, c1, c2);
        double c = w2c(w, horizon);
		return new shared TruthValue(cast(float)f1, c);
	}

	private static double w2c(double w, double horizon) {
		return w / (w + horizon);
	}
	private static double c2w(double c, double horizon) {
		return horizon * c / (1.0 - c);
	}

	private static double or(double a, double b) {
		return (1.0-a)*(1.0-b);
	}
	private static double and(double a, double b) {
		return a*b;
	}
	private static double and(double a, double b, double c) {
		return a*b*c;
	}
}

double calcExp(shared TruthValue tv) {
	return (tv.freq - 0.5) * /*strength*/tv.conf + /*offset to map to (0;1)*/0.5;
}

class Stamp {
	// TODO OPTIMIZATION< allocate non-GC'ed memory >
	public shared(long[]) trail;

	public shared this(shared(long[]) trail) {
		this.trail = trail;
	}
	
	public static bool checkOverlap(shared Stamp a, shared Stamp b) {
		// TODO OPTIMIZATION< optimize for runtime >

		bool[long] inA;
		foreach(long ia; a.trail) {
			inA[ia] = true;
		}

		foreach(long ib; b.trail) {
			if (ib in inA) {
				return true;
			}
		}
		return false;
	}

	public static shared(Stamp) merge(shared Stamp a, shared Stamp b) {
		shared(long[]) zipped = [];

        int ia = 0, ib = 0;
        foreach(ulong i; 0..min(a.trail.length, b.trail.length)) {
        	zipped ~= ( (i % 2) == 0 ? a.trail[ia] : b.trail[ib] ); // append trail in lockstep

        	if ((i % 2) == 0) { ia++; }
            else              { ib++; }
        }

        // append remaining part of either stamp
        zipped ~= (a.trail[ia..$] ~ b.trail[ib..$]);

        // limit length
        zipped = zipped[0..min(zipped.length, 100)]; // TODO< make parameter >

        return new shared Stamp(zipped);
	}

	public final shared string convToStr() {
		return to!string(trail);
	}
}

shared class Sentence {
	shared TruthValue truth;
	shared Term term;
	shared Stamp stamp;

	public final shared this(shared Term term, shared TruthValue truth, shared Stamp stamp) {
		this.term = term;
		this.truth = truth;
		this.stamp = stamp;
	}
}

class Concept {
	public shared Term name;

	public shared ExpPriorityTable beliefs;

	public final shared this(shared Term name, int numberOfBeliefs) {
		this.name = name;
		this.beliefs = new shared ExpPriorityTable(numberOfBeliefs);
	}
}

void updateBelief(shared Concept concept, shared Sentence belief) {
	bool debugVerbose = true;

	if(debugVerbose)  writeln("updatedBelief ENTRY");

	void addBeliefToConcept(shared Concept concept, shared Sentence belief) {
		concept.beliefs.insertByExp(belief);
		concept.beliefs.limitSize();
	}

	for(int beliefIdx=0;beliefIdx<concept.beliefs.entries.length;beliefIdx++) {
		shared Sentence iBelief = concept.beliefs.entries[beliefIdx];

		if (isSameRec(iBelief.term, belief.term)) {
			if(Stamp.checkOverlap(iBelief.stamp, belief.stamp)) {
				// choice rule for beliefs
				if (belief.truth.conf > iBelief.truth.conf) {
					// BUG TODO< remove at index and add belief to the table
					concept.beliefs.entries[beliefIdx] = belief;
					return;
				}
				return;
			}
			else {
				// doesn't overlap - revise
				writeln("updateBelief: revise stamps = " ~ to!string(belief.stamp.trail) ~ "   " ~ to!string(iBelief.stamp.trail));

				auto mergedStamp = Stamp.merge(belief.stamp, iBelief.stamp);

				writeln("   merged stamp = " ~ to!string(mergedStamp.trail));

				auto revisedTruth = TruthValue.calc("revision", belief.truth, iBelief.truth);
				auto revisedSentence = new shared Sentence(belief.term, revisedTruth, mergedStamp);

				concept.beliefs.entries[beliefIdx] = revisedSentence;

				return;
			}
		}
	}

	// doesn't exist - add it
	addBeliefToConcept(concept, belief);
}

class Task {
	public shared Sentence sentence;
}




//////////////////////////
//////////////////////////
// term helpers

// enumerate terms recursivly
shared(Term[]) enumerateTermsRec(shared Term term) {
	if (cast(shared BinaryTerm)term !is null) {
		auto binary = cast(shared Binary)term; // TODO< cast to binaryTerm and use methods to access children >

		shared(Term[]) enumSubj = enumerateTermsRec(binary.subject);
		shared(Term[]) enumPred = enumerateTermsRec(binary.predicate);
		return [term] ~ enumSubj ~ enumPred;
	}
	else if (cast(shared AtomicTerm)term !is null) {
		// we can't recurse into atomics
		return [term];
	}
	else {
		// TODO< call function which throws an exception in debug mode >
		throw new Exception("enumerateTermsRec(): unhandled case!");
	}
}

bool isSameRec(shared Term a, shared Term b) {
	if (a == b) {
		return true;
	}

	if( a.retHash() != b.retHash() ) {
		return false;
	}

	// fall back to recursive comparision

	if (cast(shared AtomicTerm)a !is null && cast(shared AtomicTerm)b !is null) {
		auto a2 = cast(shared AtomicTerm)a;
		auto b2 = cast(shared AtomicTerm)b;
		return a2.name == b2.name;
	}
	else if(cast(shared Binary)a !is null && cast(shared Binary)b !is null) {
		auto a2 = cast(shared Binary)a;
		auto b2 = cast(shared Binary)b;
		
		if (a2.copula != b2.copula) {
			return false;
		}
		return isSameRec(a2.subject, b2.subject) && isSameRec(a2.predicate, b2.predicate);
	}

	return false;
}

string convToStrRec(shared Term term) {
	if (cast(shared AtomicTerm)term) {
		return (cast(shared AtomicTerm)term).name;
	}
	else if (cast(shared Binary)term) {
		auto binary = cast(shared Binary)term;
		return "<" ~ convToStrRec(binary.subject) ~ binary.copula ~ convToStrRec(binary.predicate) ~ ">";
	}
	else {
		// TODO< call function which throws an exception in debug mode >
		throw new Exception("convToStrRec(): unhandled case!");
	}	
}

//////////////////////////
//////////////////////////
// memory management





private class Concepts {
	public shared(Concept)[] arr;

	public shared this(shared(Concept)[] arr) {
		this.arr = arr;
	}
}

// TODO< put under AIKR with a strategy similar to ALANN >
// a table is like a bag in Open-NARS, just with different policies for prioritization and attention
class ConceptTable {
	private shared(Concept)[] concepts;

	// concepts by hashes of names
	private Concepts[long] conceptsByNameHash;


	public final shared bool hasConceptByName(shared Term name) {
		long hashOfName = name.retHash();

		if ((hashOfName in conceptsByNameHash) is null) {
			return false;
		}

		auto listOfPotentialConcepts = conceptsByNameHash[hashOfName].arr;
		foreach(shared Concept iConcept; listOfPotentialConcepts) {
			if (isSameRec(iConcept.name, name)) {
				return true;
			}
		}

		return false;
	}

	public shared final shared(Concept) retConceptByName(shared Term name) {
		// TODO< must be ensure >
		assert(hasConceptByName(name));

		long hashOfName = name.retHash();
		auto listOfPotentialConcepts = conceptsByNameHash[hashOfName].arr;
		foreach(shared Concept iConcept; listOfPotentialConcepts) {
			if (isSameRec(iConcept.name, name)) {
				return iConcept;
			}
		}

		return null; // should never happen		
	}

	// does not check if the concept already exists!
	public shared final void insertConcept(shared Concept concept) {
		concepts ~= concept;

		if (concept.name.retHash() in conceptsByNameHash) {
			conceptsByNameHash[concept.name.retHash()].arr ~= concept;
		}
		else {
			conceptsByNameHash[concept.name.retHash()] = new shared Concepts([concept]);
		}
	}
}

// ExpPriorityTable because it takes only the expectation into account for ranking
class ExpPriorityTable {
	// sorted by expectation
	public shared(Sentence)[] entries;

	public int maxSize; // maximal size

	public final shared this(int maxSize) {
		this.maxSize = maxSize;
	}

	// doesn't limit size!
	public shared void insertByExp(shared Sentence inserted) {
		for(int idx=0;idx<entries.length;idx++) {
			auto iElement = entries[idx];
			if(iElement.truth.calcExp() < inserted.truth.calcExp()) {
				auto arr = cast(Sentence[])entries; // HACK< needs some casting because the standard library doesn't define insertInPlace for shared Sentences ! >
				arr.insertInPlace(idx, cast(Sentence)inserted);
				entries = cast(shared(Sentence)[])arr;
				return;
			}
		}

		entries ~= inserted;
	}

	public shared void limitSize() {
		entries = entries[0..min(entries.length, maxSize)];
	}
}

////////////////////////////////
////////////////////////////////
// helpers

shared(Term[]) sampleFromArray(shared(Term[]) arr, int numberOfSamples, ref Xorshift rng) {
	shared(Term[]) sampledResult;

	auto remainingTerms = arr[0..$];

	foreach(int iSample;0..numberOfSamples) {
		if (remainingTerms.length == 0) {
			break;
		}

		long chosenIdx = uniform(0, remainingTerms.length, rng);
		auto sampledTerm = remainingTerms[chosenIdx];
		remainingTerms = remainingTerms.remove(chosenIdx);
		sampledResult ~= sampledTerm;
	}
	return sampledResult;
}
