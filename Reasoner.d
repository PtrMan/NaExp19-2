




// TODO< implement temporal inference in trie processing >

// TODO< metagen: implement basic temporal reasoning rules >


// TODO< trie generation: check for unequality of vars when they appear on both sides >

// TODO< Binary can be a compound-term or something else - we need to overhaul the interface and some of the impl >


// LATER TODO< unification for Q&A >

// TODO< questions from outside invalidate active questions with the same term >

// TODO REFACTOR< implement function which handles the recursive call of some delegate >

// TODO< implement  construction of compounds (class is ProdStar)  ex:   ("*", "A", "B")  >



// TODO< make term immutable >

// TODO ATTENTION< implement activation spreading  by derived results >

// LATER TODO< add rules for detachment to metaGen.py >
// LATER TODO< metaGen.py : generate backward inference rules >
// LATER TODO< add a lot of the missing rules to metaGen.py >
// LATER TODO< add sets to terms and recursive handling >
// LATER TODO< add inference rules for sets to metaGen.py >


// BUG< concept removal: we need to remove the concept from the dict by hash of the name >


// LATER TODO< variable unifier >

// TODO LATER MAYBE< disallow derivations  of the same component if it is set-like     ex: <d|d> >



// LATER TODO< decision making :( >

import std.array;
import std.random;
import std.math : pow;
import std.stdio : writeln;
import std.algorithm.mutation;
import std.algorithm.comparison;
import std.algorithm.sorting : sort;
import std.conv : to;
//import core.sync.mutex;
import core.atomic;
import std.typecons : Nullable;


void main() {
	test0();
	//testQuestionDerivation0();
}

// tests if a question can be derived
// TODO< automate as unittest and check if it derives the question >
void testQuestionDerivation0() {
	shared Reasoner reasoner = new shared Reasoner();
	reasoner.init();

	{ // add existing belief
		shared Term term = new shared Binary("-->", new shared AtomicTerm("a"), new shared AtomicTerm("b"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence('.', term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}
	
	{ // add question task
		shared Term term = new shared Binary("-->", new shared AtomicTerm("b"), new shared AtomicTerm("c"));
		auto tv = null;
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
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
void test0() {	
	shared Reasoner reasoner = new shared Reasoner();
	reasoner.init();




	// add existing belief
	{
		shared Term term = new shared Binary("-->", new shared AtomicTerm("b"), new shared AtomicTerm("c"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
		auto beliefSentence = new shared Sentence('.', term, tv, stamp);

		reasoner.mem.conceptualize(beliefSentence.term);
		reasoner.mem.addBeliefToConcepts(beliefSentence);
	}

	{
		shared Term term = new shared Binary("-->", new shared AtomicTerm("c"), new shared AtomicTerm("d"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
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
	*/



	{
		foreach(string iCopula; ["<->", "==>", "<|>", "=/>"]) {

			auto termNames = ["a", "b", "c", "d", "e", "f", "g", "h"];

			for(int i=0;i<termNames.length-1;i++) {
				auto termName0 = termNames[i];
				auto termName1 = termNames[i+1];

				shared Term term = new shared Binary(iCopula, new shared AtomicTerm(termName0), new shared AtomicTerm(termName1));
				auto tv = new shared TruthValue(1.0f, 0.9f);
				auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
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
				auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
				auto beliefSentence = new shared Sentence('.', term, tv, stamp);

				reasoner.mem.conceptualize(beliefSentence.term);
				reasoner.mem.addBeliefToConcepts(beliefSentence);
			}
		}
	}



	{
		shared Term term = new shared Binary("-->", new shared AtomicTerm("d"), new shared AtomicTerm("c"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
		auto sentence = new shared Sentence('.', term, tv, stamp);

		auto task = new shared Task();
		task.sentence = sentence;
		reasoner.mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task, 1.0, 1.0, reasoner.cycleCounter);
	}
	

	
	{
		shared Term term = new shared Binary("<=>", new shared AtomicTerm("a"), new shared AtomicTerm("b"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
		auto sentence = new shared Sentence('.', term, tv, stamp);

		auto task = new shared Task();
		task.sentence = sentence;
		reasoner.mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task, 1.0, 1.0, reasoner.cycleCounter);
	}
	



		/*
	{
		shared Term term = new shared Binary("<->", new shared AtomicTerm("a"), new shared AtomicTerm("b"));
		auto tv = new shared TruthValue(1.0f, 0.9f);
		auto stamp = new shared Stamp([reasoner.mem.retUniqueStampCounter()]);
		auto sentence = new shared Sentence(term, tv, stamp);

		auto task = new shared Task();
		task.sentence = sentence;
		reasoner.mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task, reasoner.cycleCounter);
	}
	*/


	foreach(long i;0..1000) {  // TEST REASONING LOOP
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
	// TODO< remove from array and insert again with insertion sort >

	foreach(shared TaskWithAttention iTaskWithAttention; wm.activeTasks) {
		// we update the exponential-moving-average 
		// with the accumulated value - to slowly pull it to the accumulated value while considering the history of the EMA
		iTaskWithAttention.ema.update(0.0 /* TODO< pull it from the accumulated value which is computed by weighting */);

		// we need to reset the accumulated value to allow it to accumulate a new value until the next step
		// TODO< implement setting of weighted accumulator to 0.0 >
	}

	// debug
	foreach(shared TaskWithAttention iTaskWithAttention; wm.activeTasks) {
		writeln(
			"attention: updated ranking of " ~
			"task.sentence=" ~ iTaskWithAttention.task.sentence.convToStr() ~" " ~ to!string(iTaskWithAttention.task.sentence.stamp.trail) ~ " " ~
			"to ranking=" ~ to!string(iTaskWithAttention.calcRanking(cycleCounter))
		);
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
			writeln("forgot concept term=", iCandidate.concept.name.convToStrRec(), " beliefs.avgExp=", iCandidate.concept.cachedAverageExp);

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

	public int numberOfBeliefs = 100; // Reasoner parameter!
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
			else if (cast(shared AtomicTerm)name !is null) {
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

shared class Reasoner {
	public Xorshift rng = Xorshift(12);

	shared Memory mem;
	TrieDeriver deriver = new TrieDeriver();

	long cycleCounter = 0;
	long numberOfDerivationsCounter = 0;

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

		{ // select task and process it with selected concepts
			
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
			}
		}

		{ // debug
			if(true)   writeln("derived sentences#=", derivedSentences.length);

			core.atomic.atomicOp!"+="(this.numberOfDerivationsCounter, derivedSentences.length);

			bool showDerivations = true;

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

				double baseAttentionValue = selectedTaskWithAttention.ema.ema;

				mem.workingMemory.activeTasks ~= new shared TaskWithAttention(task, baseAttentionValue, emaFactor, cycleCounter);
			}
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
	Nullable!long intervalResultT; // used to store the "t" value in the evaluation of the trie
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
			{   TrieContext ctx;
				interpretTrieRec(iRootTries, leftSentence, rightSentence, resultSentences, &ctx);
			}
			{   TrieContext ctx;
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
		CHECKCOPULA, // check copula of premise
		//FIN, // terminate processing  - commented because it is implicitly terminated if nothing else matches

		WALKCOMPARE, // walk left and compare with walk right

		WALKCHECKCOMPOUND, // walk and check the type of a compound

		LOADINTERVAL, // load the value of a interval by a path
		INTERVALPROJECTION, // compute the interval projection

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
		// TODO< implement interval projection >
		writeln("TODO - INTERVALPROJECTION !");
	}
	else if(trieElement.type == TrieElement.EnumType.LOADINTERVAL) {
		// TODO< implement loading of interval by path >
		writeln("TODO - LOADINTERVAL !");
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




interface Term {
	// a : atomic
	// b : binary with copula
	// S : set
	// i : interval
	char retType();

	// same terms have to have the same hash
	shared long retHash();
}

interface Interval : Term {
	long retInterval(); // return the value of the interval
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

	public immutable string name;

    private immutable long cachedHash;
}

class IntervalImpl : Interval {
	public shared this(long value) {
		this.value = value;
	}

	public long retInterval() {return value;}

	public char retType() {return 'i';}

	public shared long retHash() {
		long hash = value;
        hash = hash << 3 || hash >> (64-3); // rotate
        hash ^= 0x34052AAB34052AAB;
        return hash;
    }

	private immutable long value;
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
		else if(function_ == "union") {
			double f = or(f1, f2);
        	double c = and(c1, c2);
			return new shared TruthValue(cast(float)f, c);
		}
		else if(function_ == "intersection") {
			double f = and(f1, f2);
        	double c = and(c1, c2);
			return new shared TruthValue(f, c);
		}
		else if("decomposePNP") {
			// see https://github.com/jarradh/narjure/blob/master/src/nal/truth_value.clj#L94-L99
			double f2n = not(f2),
			       f = and(f1, f2n),
			       c = and(f, c1, c2);
			return new shared TruthValue(f, c);
		}
		else if("decomposeNNN") {
			// see https://github.com/jarradh/narjure/blob/master/src/nal/truth_value.clj#L101-L108
			double f1n = not(f1),
			       f2n = not(f2),
			       fn = and(f1n, f2n),
			       f = not(fn),
			       c = and(fn, c1, c2);
			return new shared TruthValue(f, c);
		}
		else if("decomposeNPP") {
			// see https://github.com/jarradh/narjure/blob/master/src/nal/truth_value.clj#L87-L92
			double f1n = not(f1),
			       f = and(f1n, f2),
			       c = and(f, c1, c2);
			return new shared TruthValue(f, c);
		}
		else if("decomposePNN") {
			// see https://github.com/jarradh/narjure/blob/master/src/nal/truth_value.clj#L79-L85
			double f2n = not(f2),
			       fn = and(f1, f2n),
			       f = not(fn),
			       c = and(fn, c1, c2);
			return new shared TruthValue(f, c);
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
	private static double not(double v) {
		return 1.0-v;
	}
}

double calcExp(shared TruthValue tv) {
	return (tv.freq - 0.5) * /*strength*/tv.conf + /*offset to map to (0;1)*/0.5;
}

class Stamp {
	// TODO OPTIMIZATION< allocate non-GC'ed memory >
	public immutable shared(long[]) trail;

	public shared this(shared(long[]) trail) {
		this.trail = trail.idup;
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

	public static bool equals(shared Stamp a, shared Stamp b) {
		if (a.trail.length != b.trail.length) {
			return false;
		}

		foreach(long idx; 0..a.trail.length) {
			if (a.trail[idx] != b.trail[idx]) {
				return false;
			}
		}
		return true;
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
				writeln("updateBelief: revise stamps = " ~ to!string(belief.stamp.trail) ~ "   " ~ to!string(iBelief.stamp.trail));

				auto mergedStamp = Stamp.merge(belief.stamp, iBelief.stamp);

				writeln("   merged stamp = " ~ to!string(mergedStamp.trail));

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
