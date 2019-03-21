module TermTools;

import std.conv : to;

import Terms;

// enumerates terms recursivly and returns only the unique terms of it
shared(Term)[] enumerateUniqueTermsRec(shared Term term) {
	shared(Term)[] result;

	bool existsInResult(shared Term term) {
		foreach(iTerm; result) {
			if (isSameRec(iTerm, term)) {
				return true;
			}
		}
		return false;
	}
	auto enumeratedSubterms = enumerateTermsRec(term);
	foreach(iTerm; enumeratedSubterms) {
		if (!existsInResult(iTerm)) {
			result ~= iTerm;
		}
	}
	return result;
}

// enumerate terms recursivly
shared(Term)[] enumerateTermsRec(shared Term term) {
	if (cast(shared BinaryTerm)term !is null) {
		auto binary = cast(shared Binary)term; // TODO< cast to binaryTerm and use methods to access children >

		shared(Term)[] enumSubj = enumerateTermsRec(binary.subject);
		shared(Term)[] enumPred = enumerateTermsRec(binary.predicate);
		return [term] ~ enumSubj ~ enumPred;
	}
	else if (cast(shared AtomicTerm)term !is null || cast(shared Interval)term !is null) {
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

	if (a.retType() != b.retType()) {
		return false;
	}

	if (a.retHash() != b.retHash()) {
		return false;
	}


	// fall back to recursive comparision

	char aType = a.retType();
	char bType = b.retType();

	if (aType == 'a' && bType == 'a') {
		auto a2 = cast(shared AtomicTerm)a;
		auto b2 = cast(shared AtomicTerm)b;
		return a2.name == b2.name;
	}
	else if(aType == 'b' && bType == 'b') {
		auto a2 = cast(shared Binary)a;
		auto b2 = cast(shared Binary)b;
		
		if (a2.copula != b2.copula) {
			return false;
		}

		// makes sure that both big hashes are the same - the probability of false positives is extremely low
		return a2.hash0 == b2.hash0 && a2.hash1 == b2.hash1;

		//return true; // makes it way faster
		/* super slow path
		bool isSame = isSameRec(a2.subject, b2.subject) && isSameRec(a2.predicate, b2.predicate);

		if (!isSame) {
			writeln("DBG  isSameRec() failed for");
			writeln("                 termA = " ~convToStrRec(a)~ " w/ hash=" ~to!string(a.retHash()));
			writeln("                 termB = " ~convToStrRec(b)~ " w/ hash=" ~to!string(b.retHash()));
		}

		return isSame;
		 */
	}
	else if(aType == 'i' && bType == 'i') {
		auto a2 = cast(shared Interval)a;
		auto b2 = cast(shared Interval)b;
		return a2.retInterval() == b2.retInterval();
	}

	return false;
}

string convToStrRec(shared Term term) {
	if (cast(shared AtomicTerm)term !is null) {
		return (cast(shared AtomicTerm)term).name;
	}
	else if (cast(shared Binary)term !is null) {
		auto binary = cast(shared Binary)term;
		
		bool isCompound = binary.copula == "&/" || binary.copula == "&|" || binary.copula == "&&" || binary.copula == "||" || binary.copula == "-" || binary.copula == "~";

		if (isCompound) return "(" ~ binary.copula ~ "," ~ convToStrRec(binary.subject) ~ "," ~ convToStrRec(binary.predicate) ~ ")";
		else 		    return "<" ~ convToStrRec(binary.subject) ~ binary.copula ~ convToStrRec(binary.predicate) ~ ">";

	}
	else if (cast(shared Interval)term !is null) {
		long intervalValue = (cast(shared Interval)term).retInterval();
		if (intervalValue >= 0) {
			return "+" ~ to!string(intervalValue);
		}
		else {
			return to!string(intervalValue);
		}
	}
	else {
		// TODO< call function which throws an exception in debug mode >
		throw new Exception("convToStrRec(): unhandled case!");
	}	
}
