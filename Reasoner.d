// TODO< implement WALKCHECKCOPULA which walks and checks the copula >



// TODO< add table for beliefs of concept! >
// call it ExpPriorityTable because it takes only the expectation into account for ranking >

// TODO< implement basic reasoning loop >

// TODO< lock stamp counter and increment >

// TODO< fall back to normal comparision if all hashes succeed >

// LATER TODO< variable unifier >
// LATER TODO< sets >

// LATER TODO< decision making :( >

import std.random;
import std.stdio;
import std.algorithm.comparison;

void main() {	
	Reasoner reasoner = new Reasoner();
	reasoner.init();

	// TODO< implement reasoning loop >

	Task testTask = new Task();

	{
		Term term = new Binary("-->", new AtomicTerm("a"), new AtomicTerm("b"));
		auto tv = new TruthValue(1.0f, 0.9f);
		auto stamp = new Stamp([reasoner.mem.stampCounter++]);
		auto sentence = new Sentence(term, tv, stamp);
		testTask.sentence = sentence;

		reasoner.mem.conceptualize(sentence);
	}
	
	Term testConceptName = new Binary("-->", new AtomicTerm("b"), new AtomicTerm("c"));
	Concept testConcept = new Concept(testConceptName);

	{
		Term term = new Binary("-->", new AtomicTerm("b"), new AtomicTerm("c"));
		auto tv = new TruthValue(1.0f, 0.9f);
		auto stamp = new Stamp([reasoner.mem.stampCounter++]);
		Sentence beliefSentence = new Sentence(term, tv, stamp);
		testConcept.beliefs ~= beliefSentence;

		reasoner.mem.conceptualize(beliefSentence);
	}

	writeln("test derivation");

	// do test inference and look at the result (s)
	Sentence[] derivedSentences = reasoner.mem.infer(testTask, testConcept, reasoner.deriver);

	writeln("derived sentences#=", derivedSentences.length);

	// TODO< conceptualize derived sentences ! >
}




public enum EnumSide {
	LEFT,
	RIGHT
}

class TrieElement {
	public final this(EnumType type) {
		this.type = type;
	}

	public EnumType type;
	public EnumSide side;
	public string checkedString; // can be checked copula

	public string[] pathLeft;
	public string[] pathRight;

	// function which builds the result or returns null on failure
	// trie element is passed to pass some additional data to it
	public void function(Sentence leftSentence, Sentence rightSentence, ref Sentence[] resultSentences, TrieElement trieElement) fp;

	public TrieElement[] children; // children are traversed if the check was true


	public enum EnumType {
		CHECKCOPULA, // check copula of premise
		//FIN, // terminate processing  - commented because it is implicitly terminated if nothing else matches

		WALKCOMPARE, // walk left and compare with walk right

		EXEC, // trie element to run some code with a function
	}
}

// interprets a trie
// returns null if it fails - used to propagate control flow
bool interpretTrieRec(TrieElement trieElement, Sentence leftSentence, Sentence rightSentence, ref Sentence[] resultSentences) {
	bool debugVerbose = false;

	if (debugVerbose) writeln("interpretTrieRec ENTRY");

	Term left = leftSentence.term;
	Term right = rightSentence.term;

	Term walk(string[] path) {
		Term walkToBinarySubject(Term root) {
			return cast(Binary)root !is null ? (cast(Binary)root).subject : null;
		}

		Term walkToBinaryPredicate(Term root) {
			return cast(Binary)root !is null ? (cast(Binary)root).predicate : null;
		}

		Term current = null;

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
		if(debugVerbose) writeln("interpretTrieRec checkcopula");

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
		if(debugVerbose) writeln("interpretTrieRec exec");

		/*commented because it doesn't return anything   Term execResult = */trieElement.fp(leftSentence, rightSentence, resultSentences, trieElement);
		/*if (execResult !is null) {
			return execResult;
		} commented because it doesn't return anything*/
	}
	else if(trieElement.type == TrieElement.EnumType.WALKCOMPARE) {
		if(debugVerbose) writeln("interpretTrieRec walkCompare");

		Term leftElement = walk(trieElement.pathLeft);
		Term rightElement = walk(trieElement.pathRight);

		if (leftElement is null || rightElement is null || !isSame(leftElement, rightElement)) {
			return true; // abort if walk failed or if the walked elements don't match up
		}
	}

	// we need to iterate children if we are here
	foreach( TrieElement iChildren; trieElement.children) {
		bool recursionResult = interpretTrieRec(iChildren, leftSentence, rightSentence, resultSentences);
		if (recursionResult ) {
			//return recursionResult;
		}
	}

	return true;
}




interface Term {
	// a : atomic
	// b : binary with copula
	// S : set
	char retType();

	// same terms have to have the same hash
	long retHash();
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


class AtomicTerm : Term {
	public final this(string name) {
		this.name = name;

        cachedHash = 17;
        foreach(char ic; name) {
            cachedHash *= ic;
            cachedHash += 17;
        }
	}

    public long retHash() {
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
	public final this(string copula, Term subject, Term predicate) {
		this.copula = copula;
		this.subject = subject;
		this.predicate = predicate;
	}

	public char retType() {return 'b';}

    public long retHash() {
        return 0; // TODO
    }

	public string copula;
	public Term subject;
	public Term predicate;
}

// TODO< convert to struct >
class TruthValue {
	public float freq;
	public double conf;

	public final this(float freq, double conf) {
		this.freq = freq;
		this.conf = conf;
	}

	public static TruthValue calc(string function_, TruthValue a, TruthValue b) {
		float horizon = 1.0f;

		double f1 = a.freq;
		double c1 = a.conf;
		double f2 = b.freq;
		double c2 = b.conf;

		if (function_ == "analogy") {
        	double f = and(f1, f2);
        	double c = and(c1, c2, f2);
			return new TruthValue(cast(float)f, c);
		}
		else if(function_ == "resemblance") {
			double f = and(f1, f2);
        	double c = and(c1, c2, or(f1, f2));
			return new TruthValue(cast(float)f, c);
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
			return new TruthValue(cast(float)f, c);
		}
		else if(function_ == "resemblance") {
			double f = and(f1, f2);
        	double c = and(c1, c2, or(f1, f2));
			return new TruthValue(cast(float)f, c);
		}
		else if(function_ == "comparison") {
			double f0 = or(f1, f2);
        	double f = (f0 == 0.0) ? 0.0 : (and(f1, f2) / f0);
        	double w = and(f0, c1, c2);
        	double c = w2c(w, horizon);
			return new TruthValue(cast(float)f, c);
		}
		// TODO< implement other truth functions >

		throw new Exception("Unimplemented truth function name=" ~ function_);
	}

	private static TruthValue abduction(TruthValue a, TruthValue b, double horizon) {
		double f1 = a.freq;
		double c1 = a.conf;
		double f2 = b.freq;
		double c2 = b.conf;

		double w = and(f2, c1, c2);
        double c = w2c(w, horizon);
		return new TruthValue(cast(float)f1, c);
	}

	private static double w2c(double w, double horizon) {
		return w / (w + horizon);
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

class Stamp {
	// TODO OPTIMIZATION< allocate non-GC'ed memory >
	public long[] trail;

	public this(long[] trail) {
		this.trail = trail;
	}
	
	public static bool checkOverlap(Stamp a, Stamp b) {
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

	public static Stamp merge(Stamp a, Stamp b) {
		long[] zipped = [];

        int ia = 0, ib = 0;
        foreach(ulong i; 0..min(a.trail.length, b.trail.length)) {
        	zipped ~= ( (i % 2) == 0 ? a.trail[ia] : b.trail[ib] ); // append trail in lockstep

        	if ((i % 2) == 0) { ia++; }
            else {              ib++; }
        }

        // append remaining part of either stamp
        zipped ~= a.trail[ia..$];
        zipped ~= b.trail[ib..$];

        // limit length
        zipped = zipped[0..min(zipped.length, 100)]; // TODO< make parameter >

        return new Stamp(zipped);
	}
}

class Sentence {
	TruthValue truth;
	Term term;
	Stamp stamp;

	public final this(Term term, TruthValue truth, Stamp stamp) {
		this.term = term;
		this.truth = truth;
		this.stamp = stamp;
	}
}

class Concept {
	public Term name;

	public Sentence[] beliefs;

	public final this(Term name) {
		this.name = name;
	}
}

class Task {
	public Sentence sentence;
}

bool isSame(Term a, Term b) {
	if (a == b) {
		return true;
	}

	return a.retHash() == b.retHash();

	// TODO< real compare >
}

class Memory {
	public ConceptTable concepts;
	public Xorshift rng = Xorshift(1);

	public shared long stampCounter = 0; // counter used for the creation of stamps

	// commented because not used
	//Task[] activeTasks; // TODO< refine with some table which takes the priority and exp() into account

	public final this() {
		concepts = new ConceptTable();
	}

	public final Sentence[] infer(Task t, Concept c, TrieDeriver deriver) {
		Sentence[] resultSentences;

		// pick random belief and try to do inference

		if (c.beliefs.length == 0) {
			return resultSentences; // can't select a belief to do inference
		}

		long beliefIdx = uniform(0, c.beliefs.length, rng);
		auto selectedBelief = c.beliefs[beliefIdx];

		if (Stamp.checkOverlap(t.sentence.stamp, selectedBelief.stamp)) {
			return resultSentences;
		}

		deriver.derive(t.sentence, selectedBelief, resultSentences);
		return resultSentences;
	
	}

	// creates concepts if necessary and puts the belief into all relevant concepts 
	public final void conceptualize(Sentence belief) {
		// conceptualizes by selected term recursivly
		void conceptualizeByTermRec(Term term) {
			if(!concepts.hasConceptByName(term)) {
				// create concept and insert into table

				Concept createdConcept = new Concept(term);
				concepts.insertConcept(createdConcept);
			}

			{ // add belief
				Concept concept = concepts.retConceptByName(term);
				concept.beliefs ~= belief;
			}

			{ // call recursivly
				if (cast(BinaryTerm)term !is null) {
					Binary binary = cast(Binary)term; // TODO< cast to binaryTerm and use methods to access children >

					conceptualizeByTermRec(binary.subject);
					conceptualizeByTermRec(binary.predicate);
				}
				else if (cast(AtomicTerm)term !is null) {
					// we can't recurse into atomics
				}
				else {
					// TODO< call function which throws an exception in debug mode >
					throw new Exception("conceptualize(): unhandled case!");
				}
			}
		}

		conceptualizeByTermRec(belief.term);
	}
}

class TrieDeriver {
	// tries which are the roots and are iterated independently
	TrieElement[] rootTries;

	final void init() {
		rootTries = [];
		initTrie(rootTries);
		writeln("TrieDeriver: init with nTries=", rootTries.length);
	}

	final void derive(Sentence leftSentence, Sentence rightSentence, ref Sentence[] resultSentences) {
		foreach(TrieElement iRootTries; rootTries) {
			interpretTrieRec(iRootTries, leftSentence, rightSentence, resultSentences);
			interpretTrieRec(iRootTries, rightSentence, leftSentence, resultSentences);
		}
	}
}

class Reasoner {
	Memory mem = new Memory();
	TrieDeriver deriver = new TrieDeriver();

	final void init() {
		deriver.init();
	}
}

//////////////////////////
// memory management



// TODO< put under AIKR with a strategy similar to ALANN >

// a table is like a bag in Open-NARS, just with different policies for prioritization and attention
class ConceptTable {
	private Concept[] concepts;

	// concepts by hashes of names
	private Concept[][long] conceptsByNameHash;

	public final bool hasConceptByName(Term name) {
		long hashOfName = name.retHash();

		if (!(hashOfName in conceptsByNameHash)) {
			return false;
		}

		auto listOfPotentialConcepts = conceptsByNameHash[hashOfName];
		foreach(Concept iConcept; listOfPotentialConcepts) {
			if (isSame(iConcept.name, name)) {
				return true;
			}
		}

		return false;
	}

	public final Concept retConceptByName(Term name) {
		// TODO< must be ensure >
		assert(hasConceptByName(name));

		long hashOfName = name.retHash();
		auto listOfPotentialConcepts = conceptsByNameHash[hashOfName];
		foreach(Concept iConcept; listOfPotentialConcepts) {
			if (isSame(iConcept.name, name)) {
				return iConcept;
			}
		}

		return null; // should never happen		
	}

	// does not check if the concept already exists!
	public final void insertConcept(Concept concept) {
		concepts ~= concept;

		if (concept.name.retHash() in conceptsByNameHash) {
			conceptsByNameHash[concept.name.retHash()] ~= concept;
		}
		else {
			conceptsByNameHash[concept.name.retHash()] = [concept];
		}
	}
}
