// NaExp19-2 by Robert Wünsche
//
// To the extent possible under law, the person who associated CC0 with
// NaExp19-2 has waived all copyright and related or neighboring rights
// to NaExp19-2.
//
// You should have received a copy of the CC0 legalcode along with this
// work.  If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

module Terms;

import std.conv : to;
import std.digest.sha : sha1Of;

interface Term {
	// a : atomic
	// b : binary with copula
	// S : set
	// i : interval
	// v : variable
	char retType() shared;

	// same terms have to have the same hash
	ulong retHash() shared;
}

interface Interval : Term {
	shared long retInterval(); // return the value of the interval
}

interface BinaryTerm : Term {
	// TODO< methods >
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

ulong calcHash(string str) {	
	ulong hash = 17;
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

    public ulong retHash() shared {
        return cachedHash;
    }

	public char retType() shared {return 'a';}

	public immutable string name;

    private immutable ulong cachedHash;
}

bool isAtomic(shared(Term) term) {
	return cast(shared AtomicTerm)term !is null || cast(shared Interval)term !is null;
}

class IntervalImpl : Interval {
	public shared this(long value) {
		this.value = value;
	}

	public long retInterval() shared {return value;}

	public char retType() shared {return 'i';}

	public ulong retHash() shared  {
		ubyte[20] hash1 = sha1Of(to!string(value));
		ulong hash = *(cast(ulong*)&hash1);

		return hash;
    }

	private immutable long value;
}


class Binary : BinaryTerm {
	public shared final this(string copula, shared Term subject, shared Term predicate) {
		this.copula = copula;
		this.subject = subject;
		this.predicate = predicate;

		/*
		ulong hash = subject.retHash();
        hash = (hash << 3) | (hash >> (64-3)); // rotate
        hash ^= 0x34052AAB34052AAB;

        hash ^= predicate.retHash();
        hash = (hash << 3) | (hash >> (64-3)); // rotate
        hash ^= 0x34052AAB34052AAB;
        
        hash ^= calcHash(copula);
        */

        ubyte[20] hash0 = sha1Of(to!string(to!string(subject.retHash()) ~ copula ~ to!string(predicate.retHash())));
        ubyte[20] hash1 = sha1Of(to!string("1" ~ to!string(subject.retHash()) ~ copula ~ to!string(predicate.retHash())));

		ulong hash = *(cast(ulong*)&hash0);

		cachedHash = hash;

		this.hash0 = hash0.idup;
		this.hash1 = hash1.idup;
	}

	public char retType() shared {return 'b';}

    public ulong retHash() shared {
        return cachedHash;
    }

	public immutable string copula;
	public shared Term subject; // TODO< make immutable >
	public shared Term predicate; // TODO< make immutable >

	public immutable ubyte[20] hash0;
	public immutable ubyte[20] hash1;

	private immutable ulong cachedHash;
}

interface Variable : Term {
	public @property string name() shared;
	public @property string type() shared;
}

class VariableImpl : Variable {
	public this(string name, string type) {
		this.protectedName = name;
		this.protectedType = type;
	}

	public @property string name() shared {
		return protectedName;
	}

	public @property string type() shared {
		return protectedType;
	}

	public char retType() shared {return 'v';}

    public ulong retHash() shared {
        return calcHash(name) ^ calcHash(type);
    }

	protected immutable string protectedName;
	protected immutable string protectedType;
}
