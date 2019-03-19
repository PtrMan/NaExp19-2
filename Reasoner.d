// Copyright 2019 Robert Wünsche

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Reasoner;

import std.array;
import std.random;
import std.math : pow, abs;
import std.stdio : writeln;
import std.algorithm.mutation;
import std.algorithm.comparison;
import std.algorithm.sorting : sort;
import std.conv : to;
//import core.sync.mutex;
import core.atomic;
import std.typecons : Nullable;
import std.parallelism;

import Stamp : Stamp;
import TruthValue : TruthValue, calcExp, calcProjectedConf;
import Terms : Term, Interval, IntervalImpl, Binary, BinaryTerm, AtomicTerm, isAtomic;

void main() {
	
	//test0(1000);

	//testQuestionDerivation0();
	//testTemporalSimple0();

	//testTemporalInduction1();
	testTemporalInduction1();

	//testMaze0();
}




// more complex induction example, triggers various rules
void testMaze0() {
	shared Reasoner reasoner = new shared Reasoner();
	reasoner.init();

	


	{ // add existing belief
		shared Term term = new shared Binary("<->", new shared AtomicTerm("m10"), new shared AtomicTerm("m20"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence('.', term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}

	{ // add existing belief
		shared Term term = new shared Binary("<->", new shared AtomicTerm("m20"), new shared AtomicTerm("m30"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence('.', term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}

	{ // add existing belief
		shared Term term = new shared Binary("<->", new shared AtomicTerm("m30"), new shared AtomicTerm("m40"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence('.', term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}

	{ // add task
		shared Term term = new shared Binary("<->", new shared AtomicTerm("m00"), new shared AtomicTerm("m10"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto sentence = new shared Sentence('.', term, tv, stamp);

		auto task = new shared Task();
		task.sentence = sentence;
		reasoner.mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task, 1.0, 1.0, reasoner.cycleCounter);
	}


	foreach(long i;0..5000) {
		reasoner.singleCycle();
	}

}




// more complex induction example, triggers various rules
void testTemporalInduction1() {
	shared Reasoner reasoner = new shared Reasoner();
	reasoner.init();

	foreach(int iRepetition; 0..5) {

		foreach(string iTermName; ["A","B","C","D","E"]) {
			{
				shared Term term = new shared Binary("-->", new shared AtomicTerm(iTermName), new shared AtomicTerm("e"));
				auto tv = new shared TruthValue(1.0f, 0.9f);
				
				reasoner.event(term, tv);
			}

			foreach(long i;0..5) {
				reasoner.singleCycle();
			}
		}

	}


	foreach(long i;0..50000) {
		reasoner.singleCycle();
	}

}

void testTemporalInduction0() {
	shared Reasoner reasoner = new shared Reasoner();
	reasoner.init();

	// trigger rule    A  B  |-    <A =/>+5 B>
	{
		shared Term term = new shared AtomicTerm("A");
		auto tv = new shared TruthValue(1.0f, 0.9f);
		
		reasoner.event(term, tv);
	}

	foreach(long i;0..5) {
		reasoner.singleCycle();
	}

	{ // add task
		shared Term term = new shared AtomicTerm("B");
		auto tv = new shared TruthValue(1.0f, 0.9f);

		reasoner.event(term, tv);		
	}

	foreach(long i;0..60) {
		reasoner.singleCycle();
	}

}


// tests simple temporal inference rule
void testTemporalSimple0() {
	shared Reasoner reasoner = new shared Reasoner();
	reasoner.init();

	// trigger rule    ('&/', 'A', 't') =/> B), (('&/', 'C', 'z') =/> B)    |-   (('&/', 'A', 't') =/> C)

	{ // add existing belief
		shared Term term = new shared Binary("=/>", new shared Binary("&/", new shared AtomicTerm("A"), new shared IntervalImpl(5)), new shared AtomicTerm("B"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence('.', term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}

	{ // add task
		shared Term term = new shared Binary("=/>", new shared Binary("&/", new shared AtomicTerm("C"), new shared IntervalImpl(5)), new shared AtomicTerm("B"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto sentence = new shared Sentence('.', term, tv, stamp);

		auto task = new shared Task();
		task.sentence = sentence;
		reasoner.mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task, 1.0, 1.0, reasoner.cycleCounter);
	}

	foreach(long i;0..60) {
		reasoner.singleCycle();
	}


}

// tests if a question can be derived
// TODO< automate as unittest and check if it derives the question >
void testQuestionDerivation0() {
	shared Reasoner reasoner = new shared Reasoner();
	reasoner.init();

	{ // add existing belief
		shared Term term = new shared Binary("-->", new shared AtomicTerm("a"), new shared AtomicTerm("b"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence('.', term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}
	
	{ // add question task
		shared Term term = new shared Binary("-->", new shared AtomicTerm("b"), new shared AtomicTerm("c"));
		auto tv = null;
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto sentence = new shared Sentence('?', term, tv, stamp);

		auto task = new shared Task();
		task.sentence = sentence;
		reasoner.mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task, 1.0, 1.0, reasoner.cycleCounter);
	}


	foreach(long i;0..100) {
		reasoner.singleCycle();
	}

}

// tests some complex interactions of the inference
void test0(int numberOfCycles) {	
	shared Reasoner reasoner = new shared Reasoner();
	reasoner.init();




	// add existing belief
	{
		shared Term term = new shared Binary("-->", new shared AtomicTerm("b"), new shared AtomicTerm("c"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence('.', term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}

	{
		shared Term term = new shared Binary("-->", new shared AtomicTerm("c"), new shared AtomicTerm("d"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence('.', term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}

	{ // add test question
		shared Term term = new shared Binary("-->", new shared AtomicTerm("b"), new shared AtomicTerm("d"));

		reasoner.mem.conceptualize(term);
		reasoner.mem.addQuestionToConcepts(term);
	}

	/*
	{
		shared Term term = new shared Binary("-->", new shared AtomicTerm("d"), new shared AtomicTerm("e"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence(term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}

	{
		shared Term term = new shared Binary("-->", new shared AtomicTerm("e"), new shared AtomicTerm("f"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence(term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}

	{
		shared Term term = new shared Binary("<=>", new shared AtomicTerm("b"), new shared AtomicTerm("c"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence(term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}
	*/



	{
		foreach(string iCopula; ["<->", "==>", "<|>", "=/>"]) {

			auto termNames = ["a", "b", "c", "d", "e", "f", "g", "h"];

			for(int i=0;i<termNames.length-1;i++) {
				auto termName0 = termNames[i];
				auto termName1 = termNames[i+1];

				shared Term term = new shared Binary(iCopula, new shared AtomicTerm(termName0), new shared AtomicTerm(termName1));
				auto tv = new shared TruthValue(1.0f, 0.9f);
				auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
				auto sentence = new shared Sentence('.', term, tv, stamp);

				auto task = new shared Task();
				task.sentence = sentence;
				reasoner.mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task, 1.0, 1.0, reasoner.cycleCounter);
			}

			for(int i=0;i<termNames.length-1;i++) {
				auto termName0 = termNames[i];
				auto termName1 = termNames[i+1];

				shared Term term = new shared Binary(iCopula, new shared AtomicTerm(termName0), new shared AtomicTerm(termName1));
				auto tv = new shared TruthValue(1.0f, 0.9f);
				auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
				auto beliefSentence = new shared Sentence('.', term, tv, stamp);

				reasoner.mem.conceptualize(beliefSentence.term);
				reasoner.mem.addBeliefToConcepts(beliefSentence);
			}
		}
	}



	{
		shared Term term = new shared Binary("-->", new shared AtomicTerm("d"), new shared AtomicTerm("c"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto sentence = new shared Sentence('.', term, tv, stamp);

		auto task = new shared Task();
		task.sentence = sentence;
		reasoner.mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task, 1.0, 1.0, reasoner.cycleCounter);
	}
	

	
	{
		shared Term term = new shared Binary("<=>", new shared AtomicTerm("a"), new shared AtomicTerm("b"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto sentence = new shared Sentence('.', term, tv, stamp);

		auto task = new shared Task();
		task.sentence = sentence;
		reasoner.mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task, 1.0, 1.0, reasoner.cycleCounter);
	}
	



		/*
	{
		shared Term term = new shared Binary("<->", new shared AtomicTerm("a"), new shared AtomicTerm("b"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = Stamp.makeEternal([reasoner.mem.retUniqueStampCounter()]);
		auto sentence = new shared Sentence(term, tv, stamp);

		auto task = new shared Task();
		task.sentence = sentence;
		reasoner.mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task, reasoner.cycleCounter);
	}
	*/


	foreach(long i;0..numberOfCycles) {  // TEST REASONING LOOP
		reasoner.singleCycle();
	}
}


////////////////////////////////
////////////////////////////////
// Attention

/**
 * working memory implements some functionality of attention
 *
 * mechanisms are inspired by ALANN(2018)
 */
class WorkingMemory {
	TaskWithAttention[] activeTasks;
}

// checks if a task with the specific stamp is already in the list of active tasks
bool attentionHasActiveTaskByStamp(shared WorkingMemory wm, shared Stamp stamp) {
	// TODO< use dict by hash of the stamp >
	foreach(shared TaskWithAttention iTaskWithAv; wm.activeTasks) {
		if (Stamp.equals(stamp, iTaskWithAv.task.sentence.stamp)) {
			return true;
		}
	}

	return false;
}

// called when the attention values have to get recomputed for the most important tasks
void attentionUpdateQuick(shared WorkingMemory wm, long cycleCounter) {
	bool debugVerbose = false;

	// TODO< remove from array and insert again with insertion sort >

	foreach(shared TaskWithAttention iTaskWithAttention; wm.activeTasks) {
		// we update the exponential-moving-average 
		// with the accumulated value - to slowly pull it to the accumulated value while considering the history of the EMA
		iTaskWithAttention.ema.update(0.0 /* TODO< pull it from the accumulated value which is computed by weighting */);

		// we need to reset the accumulated value to allow it to accumulate a new value until the next step
		// TODO< implement setting of weighted accumulator to 0.0 >
	}

	if (debugVerbose) {
		foreach(shared TaskWithAttention iTaskWithAttention; wm.activeTasks) {
			writeln(
				"attention: updated ranking of " ~
				"task.sentence=" ~ iTaskWithAttention.task.sentence.convToStr() ~" " ~ iTaskWithAttention.task.sentence.stamp.convToStr() ~ " " ~
				"to ranking=" ~ to!string(iTaskWithAttention.calcRanking(cycleCounter))
			);
		}
	}

}

// task with ema of activation
shared class TaskWithAttention {
	shared Task task;
	Ema ema; // ema used to compute activation

	immutable long startSystemCycleTime;

	double emaFactor; // factor to eep track of the value up to which the result can grow when EMA returns 1.0

	// commented because the logic to accumulate it is not implemented
	// double weightedActivationAccumulatorWeight = 0.0;
	// double weightedActivationAccumulator = 0.0; // accumulates the activation - used to "pull" the EMA to this value in the next update

	// /param startValue additive start priority
	// /param emaFactor factor up to which the ema can grow
	// /param startSystemCycleTime cycle time of the system when the attention value was created
	public shared this(shared Task task, double startValue, double emaFactor, long startSystemCycleTime) {
		this.task = task;
		this.startSystemCycleTime = startSystemCycleTime;
		this.emaFactor = emaFactor;
		ema.k = 0.1; // TODO< refine and expose parameter >
		ema.ema = startValue;
	}

	// /param systemCycleTime 
	public shared double calcRanking(long systemCycleTime) {
		float questionVirtualConfidenceValue = 1.0; // is a virtual confidence for questions - can be used to prioritize questions over judgements and goals

		double agingBase = 1.2; // how fast does the priority decay based on time



		double age = (systemCycleTime - startSystemCycleTime) * 0.1;

		double conf = task.sentence.isQuestion() ? questionVirtualConfidenceValue : task.sentence.truth.conf;

		double ranking = conf;

		ranking += (
			pow(agingBase, -age) * ema.ema * 		// aging with the exponential decay and multiplication with EMA is necessary, because tasks may else be able to boost themself indefinitly to 1.0
			emaFactor); // multiply it with ema factor to limit the influence of EMA	

		return ranking;
	}
}

// called when ever a belief of the concept changes
void attentionHandleBeliefUpdate(shared Concept concept, shared Sentence updatedBelief) {
	// assert  concept.beliefs.entries.length > 0 // there must be at least one updated belief

	// compute average exp of all beliefs and update cached value in Concept

	double expSum = 0;
	foreach(shared Sentence iBelief; concept.beliefs.entries) {
		expSum += iBelief.truth.calcExp();
	}
	
	concept.cachedAverageExp = expSum / concept.beliefs.entries.length;
}

// called when the system needs to remove superfluous concepts
void attentionRemoveIrrelevantConcepts(shared Memory mem) {
	if (mem.concepts.retSize() <= mem.maxNumberOfConcepts) {
		return;
	}

	bool debugForgettingVerbose = false;

	long numberOfConceptsToRemove = mem.concepts.retSize() - mem.maxNumberOfConcepts;

	class RemoveConceptEntity {
		public long conceptIdx;
		public shared Concept concept;

		public final this(shared Concept concept, long conceptIdx) {
			this.concept = concept;
			this.conceptIdx = conceptIdx;
		}
	}

	RemoveConceptEntity[] candidates = []; // list of candidates for removal

	// updates the candidates if necessary
	void updateCandidates(shared Concept concept, long conceptIdx) {
		candidates ~= new RemoveConceptEntity(concept, conceptIdx);
		
		// sort by averageExp of beliefs
		candidates.sort!("a.concept.cachedAverageExp < b.concept.cachedAverageExp");

		// remove entities which survived because they have a high enough exp

		//writeln("#remove = ", numberOfConceptsToRemove);
		//writeln("len = ", candidates.length);
		//writeln("maxIdx = ", min(candidates.length, numberOfConceptsToRemove));

		candidates = candidates[0..min(candidates.length, numberOfConceptsToRemove)];
	}

	for (long idx=0;idx<mem.concepts.retSize();idx++) {
		auto iConcept = mem.concepts.retAt(idx);
		updateCandidates(iConcept, idx);
	}

	{ // remove candidates
		candidates.sort!("a.conceptIdx > b.conceptIdx");

		if (candidates.length >= 2) {
			assert(candidates[0].conceptIdx > candidates[1].conceptIdx); // make sure we sorted the right way
		}

		foreach(RemoveConceptEntity iCandidate; candidates) {
			
			if (debugForgettingVerbose) {
				writeln("forgot concept term=", iCandidate.concept.name.convToStrRec(), " beliefs.avgExp=", iCandidate.concept.cachedAverageExp);
			}

			mem.concepts.removeAt(iCandidate.conceptIdx);
		}
	}
}



// exponential moving average
// see for explaination https://www.investopedia.com/ask/answers/122314/what-exponential-moving-average-ema-formula-and-how-ema-calculated.asp
struct Ema {
	double k = 1; // adaptivity factor
	double ema = 0;

	public final shared double update(double value) {
		ema = value * k + ema * (1.0 - k);
		return ema;
	}
}


///////////////////////////////
///////////////////////////////
//


shared class Memory {
	public WorkingMemory workingMemory;
	public ConceptTable concepts;
	public Xorshift rng = Xorshift(24);

	public int numberOfBeliefs = 40; // Reasoner parameter!
	public long maxNumberOfConcepts = 3000; // Reasoner parameter!

	private long stampCounter = 0;

	public final this() {
		concepts = new ConceptTable();
		workingMemory = new WorkingMemory();

		stampCounter = 0;
	}

	public final shared long retUniqueStampCounter() {
		long result;
		synchronized {
			result = stampCounter;
			core.atomic.atomicOp!"+="(this.stampCounter, 1);
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

		//writeln("Memory.infer() selectedBeliefIdx=", beliefIdx, " of ", c.beliefs.entries.length);  // for debugging problems with rng

		auto selectedBelief = c.beliefs.entries[beliefIdx];

		if (Stamp.checkOverlap(t.sentence.stamp, selectedBelief.stamp)) {
			return resultSentences;
		}

		deriver.derive(t.sentence, selectedBelief, resultSentences);
		return resultSentences;
	
	}

	// creates concepts if necessary and puts the belief into all relevant concepts 
	public final void conceptualize(shared Term term) {
		bool debugVerbose = false;

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
				else if (isAtomic(term)) {
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
}

// adds the question to the concepts (if it doesn't already exist)
public final void addQuestionToConcepts(shared Memory mem, shared Term questionTerm) {
	// selects term recursivly
	void addQuestionRec(shared Term name) {
		// TODO< enable when debuging   >  assert concepts.hasConceptByName(term)

		auto concept = mem.concepts.retConceptByName(name);
		addQuestionIfNecessary(concept, questionTerm);

		{ // call recursivly
			if (cast(shared BinaryTerm)name !is null) {
				shared Binary binary = cast(shared Binary)name; // TODO< cast to binaryTerm and use methods to access children >

				addQuestionRec(binary.subject);
				addQuestionRec(binary.predicate);
			}
			else if (isAtomic(name)) {
				// we can't recurse into atomics
			}
			else {
				// TODO< call function which throws an exception in debug mode >
				throw new Exception("conceptualize(): unhandled case!");
			}
		}
	}

	addQuestionRec(questionTerm);
}


// adds the belief to the concepts
public final void addBeliefToConcepts(shared Memory mem, shared Sentence belief) {
	// selects term recursivly
	void addBeliefRec(shared Term name) {
		// TODO< enable when debuging   >  assert concepts.hasConceptByName(term)

		auto concept = mem.concepts.retConceptByName(name);
		updateBelief(concept, belief);

		{ // call recursivly
			if (cast(shared BinaryTerm)name !is null) {
				shared Binary binary = cast(shared Binary)name; // TODO< cast to binaryTerm and use methods to access children >

				addBeliefRec(binary.subject);
				addBeliefRec(binary.predicate);
			}
			else if (isAtomic(name)) {
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

interface SentenceListener {
	void invoke(shared Sentence sentence) shared;
}

interface ConclusionListener : SentenceListener {}

shared class Reasoner {
	public Xorshift rng = Xorshift(12);

	shared Memory mem;
	TrieDeriver deriver = new TrieDeriver();
	EventInducer inducer = new EventInducer();

	long cycleCounter = 0;
	long numberOfDerivationsCounter = 0;

	protected shared(ConclusionListener)[] conclusionListeners;

	public this() {
		mem = new shared Memory();
	}

	public void init() {
		deriver.init();
	}

	public void registerListener(shared ConclusionListener listener) {
		conclusionListeners ~= listener;
	}

	// called when ever a event happened
	// is usually called from outside
	public void event(shared Term term, shared TruthValue tv) {
		auto stamp = Stamp.makeEvent(cycleCounter, [mem.retUniqueStampCounter()]);
		auto eventSentence = new shared Sentence('.', term, tv, stamp);
		mem.conceptualize(eventSentence.term);


		Sentences resultSentences = new Sentences();
		inducer.induceByEvent(this, deriver, resultSentences, eventSentence); // reason about events with other events (or derived conclusions)
		shared(Sentence)[] derivedSentences = resultSentences.arr;

		derivedConclusions(derivedSentences, null);
	}

	// called when ever new conclusions were derived which have to get stored
	synchronized protected void derivedConclusions(shared(Sentence)[] derivedSentences, shared TaskWithAttention selectedTaskWithAttention) {
		{ // debug
			if(false)   writeln("derived sentences#=", derivedSentences.length);

			core.atomic.atomicOp!"+="(this.numberOfDerivationsCounter, derivedSentences.length);

			bool showDerivations = false;

			if (showDerivations) {
				foreach(shared Sentence iDerivedSentence; derivedSentences) {
					writeln("   derived ", iDerivedSentence.convToStr() ~ "  stamp=" ~ iDerivedSentence.stamp.convToStr());
				}
			}
		}

		{ // put derived results into concepts
			foreach(shared Sentence iDerivedSentence; derivedSentences) {
				mem.conceptualize(iDerivedSentence.term);

				if (iDerivedSentence.isJudgment()) {
					auto subterms = enumerateTermsRec(iDerivedSentence.term);
					foreach(shared Term iTerm; subterms) {
						auto concept = mem.concepts.retConceptByName(iTerm);
						updateBelief(concept, iDerivedSentence);
					}
				}
				// TODO< put derived question into concepts >
			}
		}

		{ // ATTENTION< we need to spawn tasks for the derived results - but we need to manage attention with a activation value
			foreach(shared Sentence iDerivedSentence; derivedSentences) {
				auto task = new shared Task();
				task.sentence = iDerivedSentence;
				
				bool isActiveByStamp = attentionHasActiveTaskByStamp(mem.workingMemory, task.sentence.stamp);
				if (isActiveByStamp) {
					continue; // we don't add it to the tasks if it was already derived
					          // we check by stamp because it is a good way to make sure so
				}

				// compute base attention value by type of conclusion
				// (1.0 if it is not a question, questions AV * factor)
				double emaFactor = 1.0;
				if (iDerivedSentence.isQuestion()) {
					double derivedQuestionFactor = 0.9; // how much is the attention of a question punhished when it was drived from a parent question
					emaFactor = selectedTaskWithAttention.emaFactor * derivedQuestionFactor;
				}

				double baseAttentionValue = 0.0;
				if (selectedTaskWithAttention !is null) {
					baseAttentionValue = selectedTaskWithAttention.ema.ema;
				}

				mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task, baseAttentionValue, emaFactor, cycleCounter);
			}
		}

		{ // send to listeners
			foreach(shared Sentence iDerivedSentence; derivedSentences) {
				foreach(shared ConclusionListener iListener; conclusionListeners) {
					iListener.invoke(iDerivedSentence);
				}
			}
		}
	}

	public void singleCycle() {
		bool debugVerbose = false;

		if (debugVerbose)  writeln("singleCycle() ENTRY");
		scope(exit)  if (debugVerbose)  writeln("singleCycle() EXIT");



		{ // attention - we need to update the AV of highly prioritized items
			if ((cycleCounter % 50) == 0) {
				attentionUpdateQuick(mem.workingMemory, cycleCounter);
			}
		}

		{ // attention - we may need to remove concepts
			if ((cycleCounter % 600) == 0) {
				attentionRemoveIrrelevantConcepts(mem);
			}
		}



		shared(Sentence)[] derivedSentences;
		
		shared TaskWithAttention selectedTaskWithAttention;

		if(mem.workingMemory.activeTasks.length > 0) {
			// select task and process it with selected concepts
			
			{ // select random task for processing
				Xorshift rng2 = cast(XorshiftEngine!(uint, 128u, 11u, 8u, 19u))rng;
				long chosenTaskIndex = uniform(0, mem.workingMemory.activeTasks.length, rng2);
				rng = cast(shared(XorshiftEngine!(uint, 128u, 11u, 8u, 19u)))rng2;
				selectedTaskWithAttention = mem.workingMemory.activeTasks[chosenTaskIndex];
			}

			// do test inference and look at the result (s)

			
			{ // pick random n concepts of the enumerated subterms of testtask and do inference for them
				shared Task selectedTask = selectedTaskWithAttention.task;

				auto termAndSubtermsOfSentenceOfTask = enumerateTermsRec(selectedTask.sentence.term);

				int numberOfSampledTerms = 7;
				// sample terms from termAndSubtermsOfSentenceOfTask
				Xorshift rng2 = cast(XorshiftEngine!(uint, 128u, 11u, 8u, 19u))rng;
				auto sampledTerms = sampleFromArray(termAndSubtermsOfSentenceOfTask, numberOfSampledTerms, rng2);
				rng = cast(shared(XorshiftEngine!(uint, 128u, 11u, 8u, 19u)))rng2;
				
				// helper function which does the inference concurrently
				static shared(Sentence)[] parallelInfer(shared Memory mem, shared Task selectedTask, shared TrieDeriver deriver, shared Term iSampledTerm) {
					if (!mem.concepts.hasConceptByName(iSampledTerm)) {
						return [];
					}

					auto selectedConcept = mem.concepts.retConceptByName(iSampledTerm);

					//if(debugVerbose)   writeln("reasoning: infer for task.sentence=" ~ selectedTask.sentence.convToStr() ~ " concept.name=" ~ convToStrRec(selectedConcept.name));
					return mem.infer(selectedTask, selectedConcept, deriver).arr;
				}

				std.parallelism.Task!(parallelInfer, shared(Memory), shared(Task), shared(TrieDeriver), shared(Term))*[] parallelInfers;
				foreach(shared Term iSampledTerm; sampledTerms) {
					auto task = std.parallelism.task!parallelInfer(mem, selectedTask, deriver, iSampledTerm);
					taskPool.put(task); //task.executeInNewThread();
					parallelInfers ~= task;
				}

				foreach(std.parallelism.Task!(parallelInfer, shared(Memory), shared(Task), shared(TrieDeriver), shared(Term))* iInfer; parallelInfers) {
					derivedSentences ~= iInfer.yieldForce;
				}

				/* commented because it is the not parallel version
				{ // do inference for the concepts named by sampledTerms
					foreach(shared Term iSampledTerm; sampledTerms) {
						if (!mem.concepts.hasConceptByName(iSampledTerm)) {
							continue;
						}

						auto selectedConcept = mem.concepts.retConceptByName(iSampledTerm);

						if(debugVerbose)   writeln("reasoning: infer for task.sentence=" ~ selectedTask.sentence.convToStr() ~ " concept.name=" ~ convToStrRec(selectedConcept.name));
						derivedSentences ~= mem.infer(selectedTask, selectedConcept, deriver).arr;
					}
				}
				 */
			}

			derivedConclusions(derivedSentences, selectedTaskWithAttention);
		}


		{ // debug notices after cycle
			if ((cycleCounter % 200) == 0) {
				writeln("#cycle=", cycleCounter ,"   #concepts=" ~ to!string(mem.concepts.retSize()) ~ "   #derivations=" ~ to!string(numberOfDerivationsCounter));
			}

		}

		core.atomic.atomicOp!"+="(this.cycleCounter, 1);
	}
}





// wrapper for multiple sentences to pass around in a shared context
class Sentences {
	public shared(Sentence)[] arr;
}


// context to carry state across the evaluation of trie nodes
struct TrieContext {
	Nullable!long intervalPremiseT; // used to store the "t" value in the evaluation of the trie
	Nullable!long intervalPremiseZ; // used to store the "z" value in the evaluation of the trie

	Nullable!long occurrencetimePremiseA;
	Nullable!long occurrencetimePremiseB;

	double projectedTruthConfidence = 0.0;
}

class TrieDeriver {
	// tries which are the roots and are iterated independently
	shared(TrieElement)[] rootTries;

	final shared void init() {
		rootTries = initTrie();
		writeln("TrieDeriver: init with nTries=", rootTries.length);
	}

	final shared void derive(shared Sentence leftSentence, shared Sentence rightSentence, Sentences resultSentences) {
		bool debugVerbose = false;

		if (debugVerbose) {
			writeln("TrieDeriver.derive()");
			writeln("   a="~leftSentence.convToStr());
			writeln("   b="~rightSentence.convToStr());
		}


		foreach(shared TrieElement iRootTries; rootTries) {
			{   TrieContext ctx;
				ctx.occurrencetimePremiseA = leftSentence.stamp.occurrenceTime;
				ctx.occurrencetimePremiseB = rightSentence.stamp.occurrenceTime;

				interpretTrieRec(iRootTries, leftSentence, rightSentence, resultSentences, &ctx);
			}
			{   TrieContext ctx;
				ctx.occurrencetimePremiseA = rightSentence.stamp.occurrenceTime;
				ctx.occurrencetimePremiseB = leftSentence.stamp.occurrenceTime;

				interpretTrieRec(iRootTries, rightSentence, leftSentence, resultSentences, &ctx);
			}
		}
	}
}

class TrieElement {
	public final shared this(EnumType type) {
		this.type = type;
	}

	public EnumType type;
	public EnumSide side;
	public string checkedString; // can be checked copula
	public string stringPayload;
	public string[] path;

	public string[] pathLeft;
	public string[] pathRight;

	// function which builds the result or returns null on failure
	// trie element is passed to pass some additional data to it
	public void function(shared Sentence leftSentence, shared Sentence rightSentence, Sentences resultSentences, shared TrieElement trieElement, TrieContext *trieCtx) fp;

	public TrieElement[] children; // children are traversed if the check was true


	public enum EnumType {
		CHECKCOPULA, // check copula of premise which is a binary
                     // the trie traversal is not continued if it is not a binary

		//FIN, // terminate processing  - commented because it is implicitly terminated if nothing else matches

		WALKCOMPARE, // walk left and compare with walk right

		WALKCHECKCOMPOUND, // walk and check the type of a compound

		LOADINTERVAL, // load the value of a interval by a path
		INTERVALPROJECTION, // compute the interval projection

		PRECONDITION,

		EXEC, // trie element to run some code with a function
	}
}

// interprets a trie
// returns null if it fails - used to propagate control flow
bool interpretTrieRec(
	shared TrieElement trieElement,
	shared Sentence leftSentence,
	shared Sentence rightSentence,
	Sentences resultSentences,
	TrieContext *trieCtx
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
				return false; // we assume that checkcopula checks implicitly for an binary, so it is fine to return
			}
			if (b.copula != trieElement.checkedString) {
				return true; // propagate failure
			}
		}
		else { // check right
			Binary b = cast(Binary)right;
			if (b is null) {
				return false; // we assume that checkcopula checks implicitly for an binary, so it is fine to return
			}
			if (b.copula != trieElement.checkedString) {
				return true; // propagate failure
			}
		}
	}
	else if(trieElement.type == TrieElement.EnumType.EXEC) {
		if(debugVerbose) writeln("interpretTrieRec EXEC");

		trieElement.fp(leftSentence, rightSentence, resultSentences, trieElement, trieCtx);
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
			bool isStoredAsBinary = // do we need to handle it as a binary,        this is a simplification
				comparedCompoundType == "-" ||
				comparedCompoundType == "~" ||
				comparedCompoundType == "|" ||
				comparedCompoundType == "||" ||
				comparedCompoundType == "&" ||
				comparedCompoundType == "&&" ||
				comparedCompoundType == "&/" ||
				comparedCompoundType == "&|";

			if (comparedCompoundType == "*") { // product expected
				// TODO< implement special handling for product
				throw new Exception("TODO - not implemented");
			}
			else if (isStoredAsBinary) { // handling for binary
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

		// fall through because we want to walk children
	}
	else if (trieElement.type == TrieElement.EnumType.INTERVALPROJECTION) {
		// compute the TV of the projected interval

		if (trieElement.stringPayload == "IntervalProjection(t,z)") {
			if (trieCtx.intervalPremiseT.isNull() || trieCtx.intervalPremiseZ.isNull()) {
				return false; // propagate error
			}

			long t = trieCtx.intervalPremiseT, z = trieCtx.intervalPremiseZ;

			trieCtx.projectedTruthConfidence = calcProjectedConf(t, z); // calculate projection
		}
		else {
			return false; // propagate error
		}
	}
	else if(trieElement.type == TrieElement.EnumType.LOADINTERVAL) {
		// checks and loads interval
		//
		// it is loaded by path into a variable in trie-context

		shared Term term = walk(trieElement.path);
		if (term is null || term.retType() != 'i') { // must be valid interval
			return false; // propagate failure
		}

		long intervalValue = (cast(shared Interval)term).retInterval();

		if (trieElement.stringPayload == "premiseT") {
			trieCtx.intervalPremiseT = intervalValue;
		}
		else if (trieElement.stringPayload == "premiseZ") {
			trieCtx.intervalPremiseZ = intervalValue;
		}
		else { // interval name is invalid
			writeln("warning - invalid interval name");
		}
	}
	else if(trieElement.type == TrieElement.EnumType.PRECONDITION) {

		if (trieElement.stringPayload == "Time:After(tB,tA)" || trieElement.stringPayload == "Time:Parallel(tB,tA)") {
			if (leftSentence.stamp.occurrenceTime.isNull || rightSentence.stamp.occurrenceTime.isNull) {
				return false; // no timestamp - precondition failed
			}

			if(trieElement.stringPayload == "Time:After(tB,tA)") {
				bool isPreconditionFullfilled = rightSentence.stamp.occurrenceTime > leftSentence.stamp.occurrenceTime;

				if( !isPreconditionFullfilled ) {
					return false; // propagate failure
				}
			}
			else if(trieElement.stringPayload == "Time:Parallel(tB,tA)") {
				if( !occurrenceTimeIsParallel(rightSentence.stamp.occurrenceTime, leftSentence.stamp.occurrenceTime)) {
					return false;
				}
			}
		}
		else {
			writeln("warning - invalid precondition");
			return false; // fail by default
		}
	}

	// we need to iterate children if we are here
	foreach( shared TrieElement iChildren; trieElement.children) {
		bool recursionResult = interpretTrieRec(iChildren, leftSentence, rightSentence, resultSentences, trieCtx);
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

// are the events perceived to occur at the same time?
bool occurrenceTimeIsParallel(long a, long b) {
	long timeWindow = 50; // TODO< make parameter >
	return abs(a - b) <= timeWindow;
}





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


class Question {
	shared Term questionTerm; // the term of the question itself

	shared Sentence bestAnswer = null; // null when no best answer was found

	public shared this(shared Term questionTerm) {
		this.questionTerm = questionTerm;
	}
}

class Concept {
	public shared Term name;

	public shared ExpPriorityTable beliefs;

	// pending Question directly asked about the term named by name
	public shared(Question)[] questions;

	public double cachedAverageExp = 0; // used for attention (see attention implementation)

	public shared this(shared Term name, int numberOfBeliefs) {
		this.name = name;
		this.beliefs = new shared ExpPriorityTable(numberOfBeliefs);
	}
}


// adds the question to the concept when necessary
public final void addQuestionIfNecessary(shared Concept concept, shared Term questionTerm) {
	// search for existing questions
	foreach(shared Question iQuestion; concept.questions) {
		if (isSameRec(iQuestion.questionTerm, questionTerm)) {
			return; // we ignore the question if we already know the question
		}
	}

	auto createdQuestion = new shared Question(questionTerm);
	concept.questions ~= createdQuestion;

	// TODO AIKR< limit number of questions >
}

// called when ever Q&A needs to be handled or updated
// /param potentialAnswer belief which may be a potential answer to a question inside the concept
void handleQuestionAnswering(shared Concept concept, shared Sentence potentialAnswer) {
	foreach(shared Question iQuestion; concept.questions) {
		// TODO< try to unify variables of question with potential answer >
		bool isAnwer = isSameRec(potentialAnswer.term, iQuestion.questionTerm); // can only be an answer if question and the term of the potential answer unifies
		if (!isAnwer) {
			continue;
		}

		// is only a better answer if it is the first answer or one with higher truth-expectation
		bool isBetterAnswer = iQuestion.bestAnswer is null || calcExp(potentialAnswer.truth) > calcExp(iQuestion.bestAnswer.truth);
		if (!isBetterAnswer) {
			continue;
		}

		iQuestion.bestAnswer = potentialAnswer;

		writeln("found better answer question=" ~ convToStrRec(iQuestion.questionTerm) ~ " answer=" ~ convToStrRec(potentialAnswer.term));
	}
}

// called when ever a new belief was updated or added
// /param concept host concept
// /param belief added or updated belief
void beliefWasUpdatedOrAdded(shared Concept concept, shared Sentence belief) {
	// Q&A handling - we have to do it here
	handleQuestionAnswering(concept, belief);

	// we need to update the attention related values
	attentionHandleBeliefUpdate(concept, belief);
}

void updateBelief(shared Concept concept, shared Sentence belief) {
	bool debugVerbose = true;

	//if(debugVerbose)  writeln("updatedBelief ENTRY");

	void addBeliefToConcept(shared Concept concept, shared Sentence belief) {
		concept.beliefs.insertByExp(belief);
		concept.beliefs.limitSize();

		// TODO< handle case when it was not inserted - then it was also not added and we don't need to call this function >
		beliefWasUpdatedOrAdded(concept, belief);
	}

	for(int beliefIdx=0;beliefIdx<concept.beliefs.entries.length;beliefIdx++) {
		shared Sentence iBelief = concept.beliefs.entries[beliefIdx];

		if (isSameRec(iBelief.term, belief.term)) {
			if(Stamp.checkOverlap(iBelief.stamp, belief.stamp)) {
				// choice rule for beliefs
				if (belief.truth.conf > iBelief.truth.conf) {
					// we need to remove and add it because the exp() changed and thus the ordering
					concept.beliefs.entries = concept.beliefs.entries.remove(beliefIdx);
					addBeliefToConcept(concept, belief);

					beliefWasUpdatedOrAdded(concept, belief);
					return;
				}
				return;
			}
			else {
				// doesn't overlap - revise
				writeln("updateBelief: revise stamps = " ~ belief.stamp.convToStr() ~ "   " ~ iBelief.stamp.convToStr());

				auto mergedStamp = Stamp.merge(belief.stamp, iBelief.stamp);

				writeln("   merged stamp = " ~ mergedStamp.convToStr());

				auto revisedTruth = TruthValue.calc("revision", belief.truth, iBelief.truth);
				auto revisedBelief = new shared Sentence('.', belief.term, revisedTruth, mergedStamp);

				concept.beliefs.entries[beliefIdx] = revisedBelief;

				beliefWasUpdatedOrAdded(concept, revisedBelief);

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
		bool isSame = isSameRec(a2.subject, b2.subject) && isSameRec(a2.predicate, b2.predicate);

		if (!isSame) {
			writeln("DBG  isSameRec() failed for");
			writeln("                 termA = " ~convToStrRec(a)~ " w/ hash=" ~to!string(a.retHash()));
			writeln("                 termB = " ~convToStrRec(b)~ " w/ hash=" ~to!string(b.retHash()));
		}

		return isSame;
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
	private Concepts[ulong] conceptsByNameHash;


	public final shared bool hasConceptByName(shared Term name) {
		auto hashOfName = name.retHash();

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

		auto hashOfName = name.retHash();
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

	public shared long retSize() {
		return cast(long)concepts.length;
	}

	public shared shared(Concept) retAt(long idx) {
		return concepts[idx];
	}

	public shared void removeAt(long idx) {
		concepts = concepts.remove(idx);
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
		// TODO< use binary search because the entities are sorted by expectation anyways >

		if(false) {
			// TODO DEBUG < check if all entities are sorted >
		}


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




// induce input events to conclusions and feeds it into the reasoner
class EventInducer {
	// TODO< rewrite to table with utility function based on conf and time distance and put under AIKR >
	shared(Sentence)[] eventTable;
}

void induceByEvent(shared EventInducer inducer, shared Reasoner reasoner, shared TrieDeriver deriver, Sentences derivedConclusions, shared Sentence event) {
	if (inducer.eventTable.length > 0) {
		// TODO< sample many more times >

		Xorshift rng2 = cast(XorshiftEngine!(uint, 128u, 11u, 8u, 19u))reasoner.rng;
		long chosenEventIndex = uniform(0, inducer.eventTable.length, rng2);
		reasoner.rng = cast(shared(XorshiftEngine!(uint, 128u, 11u, 8u, 19u)))rng2;

		shared Sentence otherEvent = inducer.eventTable[chosenEventIndex];

		writeln("DBG induceByEvent()  event=", event.convToStr(), " ", " otherEvent=", otherEvent.convToStr());

		deriver.derive(event, otherEvent, derivedConclusions);
	}

	inducer.eventTable ~= event; // store event
}




// cellular automata rule 30
ulong rule30(ulong a) {
	// bit ad idx with wraparound
	bool bitAt(int idx) {
		return (a >> ((idx+64) % 64)) != 0;
	}

	ulong result = 0;
	foreach(int i;0..63) {
		bool vm0 = bitAt(i-1);
		bool vm1 = bitAt(i);
		bool vm2 = bitAt(i+1);

		bool v = ( vm2&&!vm1&&!vm0); // bit on for 100
		v = v || (!vm2&& vm1&& vm0); // bit on for 011
		v = v || (!vm2&& vm1&&!vm0); // bit on for 010
		v = v || (!vm2&&!vm1&& vm0); // bit on for 001

		if(v) {
			result = result | (1<<i);
		}
	}

	return result;
}