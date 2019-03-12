// TODO< implement WALKCHECKCOPULA which walks and checks the copula >




// LATER TODO< variable unifier >
// LATER TODO< sets >

// LATER TODO< decision making :( >

public enum EnumSide {
	LEFT,
	RIGHT
}

class TrieElement {
	public this(EnumType type) {
		this.type = type;
	}

	public EnumType type;
	public EnumSide side;
	public string checkedString; // can be checked copula

	public string[] pathLeft;
	public string[] pathRight;

	// function which builds the result or returns null on failure
	// trie element is passed to pass some additional data to it
	public Term function(Sentence leftSentence, Sentence rightSentence, Sentence[] resultSentences, TrieElement trieElement) fp;

	public TrieElement[] children; // children are traversed if the check was true


	public enum EnumType {
		CHECKCOPULA, // check copula of premise
		//FIN, // terminate processing  - commented because it is implicitly terminated if nothing else matches

		WALKCOMPARE, // walk left and compare with walk right

		EXEC, // trie element to run some code with a function
	}
}

/* commented because outdated
TrieElement buildTestTrie() {
	TrieElement[] rootTries;

	{
		TrieElement te0 = new TrieElement();
		te0.type = TrieElement.EnumType.CHECKCOPULA;
		te0.side = EnumSide.LEFT;
		te0.checkedString = "==>";

		TrieElement te1 = new TrieElement();
		te1.type = TrieElement.EnumType.CHECKCOPULA;
		te1.side = EnumSide.RIGHT;
		te1.checkedString = "==>";
		te0.children ~= te1;

		TrieElement teX = new TrieElement();
		teX.type = TrieElement.EnumType.EXEC;
		teX.fp = &infer0;
		te1.children ~= teX;

		rootTries ~= te0;
	}

	return rootTries[0];
}
*/

// interprets a trie
// returns null if it fails - used to propagate control flow
Term interpretTrieRec(TrieElement trieElement, Term leftSentence, Term rightSentence, Sentence[] resultSentences) {
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
		if (trieElement.side == EnumSide.LEFT) {
			Binary b = cast(Binary)left;
			if (b is null) {
				throw new Exception("");
			}
			if (b.copula != trieElement.checkedString) {
				return null; // propagate failure
			}
		}
		else { // check right
			Binary b = cast(Binary)right;
			if (b is null) {
				throw new Exception("");
			}
			if (b.copula != trieElement.checkedString) {
				return null; // propagate failure
			}
		}
	}
	else if(trieElement.type == TrieElement.EnumType.EXEC) {
		Term execResult = trieElement.fp(leftSentence, rightSentence, resultSentences, trieElement);
		if (execResult !is null) {
			return execResult;
		}
	}
	else if(trieElement.type == TrieElement.EnumType.WALKCOMPARE) {
		Term leftElement = walk(trieElement.pathLeft);
		Term rightElement = walk(trieElement.pathRight);

		if (leftElement is null || rightElement is null || !isSame(leftElement, rightElement)) {
			return null; // abort if walk failed or if the walked elements don't match up
		}
	}

	// we need to iterate children if we are here
	foreach( TrieElement iChildren; trieElement.children) {
		Term recursionResult = interpretTrieRec(iChildren, leftSentence, rightSentence, resultSentences);
		if (recursionResult !is null) {
			return recursionResult;
		}
	}

	return null; // propagate failure
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
	public this(string name) {
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
	public this(string copula, Term subject, Term predicate) {
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

class TruthValue {
	public float freq;
	public double conf;

	public static TruthValue calc(string function_, TruthValue a, TruthValue b) {
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
		// TODO< implement other truth functions >

		throw new Exception("not implemented!");
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

struct Stamp {
	public long[] trail;
	
	public static bool checkOverlap(ref Stamp a, ref Stamp b) {
		// TODO< optimize >

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
}

class Sentence {
	TruthValue truth;
	Term term;

	Stamp stamp;

	public this(Term term, TruthValue truth) {
		this.term = term;
		this.truth = truth;
	}
}

struct Concept {
	public Term name;

	public Sentence[] beliefs;
}

class Task {
	public Sentence sentence;
}

bool isSame(Term a, Term b) {
	return a.retHash() == b.retHash();


	// TODO< real compare >
}

class Memory {
	Concept[] concepts;

	public final Sentence[] infer(Task t, Concept c) {
		Sentence[] resultSentences;

		// TODO< pick random belief and try to do inference >

		if (cast(Binary)t.sentence.term && cast(Binary)c.beliefs[0]) {
			Binary sentenceTerm = cast(Binary)t.sentence.term;
			Binary conceptNameTerm = cast(Binary)c.beliefs[0].term;

			if (Stamp.checkOverlap(t.sentence.stamp, c.beliefs[0].stamp)) {
				return resultSentences;
			}

			return inferBinaryBinary(sentenceTerm, conceptNameTerm);
		}

		return resultSentences;
	}
}

// inference of binary and binary
// TODO< autogenerate code >
Sentence[] inferBinaryBinary(Binary a, Binary b) {
	Sentence[] result;
	inferBinaryBinarySingleSide(a, b, result);
	inferBinaryBinarySingleSide(b, a, result);
	return result;
}

void inferBinaryBinarySingleSide(Binary a, Binary b, Sentence[] resultSentences) {
	/* hand crafted code
	// A =/> B   B =/> C |- A =/> C
	if (a.copula == "=/>" && b.copula == "=/>" && isSame(a.predicate, b.subject) ) {
		// TODO< check for no overlap! >
		if (true) {
			Binary conclusionTerm = new Binary("=/>", a.subject, b.predicate);

			// TODO< build and append conclusion sentence >
			resultSentences ~= new Sentence(conclusionTerm, new TruthValue());
		}
	}
	 */






}

// TODO< inference cycle >

