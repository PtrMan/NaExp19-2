module Sentence;

import std.conv : to;

import TruthValue : TruthValue;
import Stamp : Stamp;
import Terms : Term;
import TermTools;

shared class Sentence {
	shared TruthValue truth; // can be null if question
	shared Term term;
	shared Stamp stamp;
	public immutable char punctation;

	public final shared this(char punctation, shared Term term, shared TruthValue truth, shared Stamp stamp) {
		this.punctation = punctation;
		this.term = term;
		this.truth = truth;
		this.stamp = stamp;
	}
}

bool isQuestion(shared Sentence sentence) { return sentence.punctation == '?'; }
bool isJudgment(shared Sentence sentence) { return sentence.punctation == '.'; }


string convToStr(shared Sentence sentence) {
	string str = convToStrRec(sentence.term) ~ sentence.punctation;
	if (sentence.truth !is null) {
		str ~= " %" ~ to!string(sentence.truth.freq) ~ ";" ~ to!string(sentence.truth.conf) ~ "%";
	}

	if (!sentence.stamp.occurrenceTime.isNull) {
		str ~= " T="~to!string(sentence.stamp.occurrenceTime);
	}

	return str;
}
