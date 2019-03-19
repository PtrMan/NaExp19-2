Non-Axiomatic Logic based reasoner experimental system

* first in providing a useable Rule-compiler
* first in providing a OSS implementation of a native system based on NAL

# How to build

* change path to D compiler in build.sh
* run build.sh

# How to run

* execute ./Reasoner

# Non-Axiomatic Logic

# Origins

* Experience-grounded semantics like in [(Open)NARS](https://github.com/opennars/opennars)

* logic is based on NAL
* logic is implemented with a [Rule-compiler](https://groups.google.com/forum/#!topic/open-nars/bMp0jKUZNK8). It translates the rules to Trie-nodes which can be interpreted fast for each derivation.

* timespan between events is computed as a exponential decay like in [ANSNA](https://github.com/patham9/ANSNA) - this emerges naturally if timesteps are interpreted as terms in a similarity derivation <a<->b> <b<->c> | <a<->c>

## Control system
It borrows some control strategy principles from [ALANN2018](https://github.com/opennars/ALANN2018) , especially:
* using the truth (confidence) as a proxy for long term usefulness of items
* derivations are treated as if they were items

NaExp19-2 has no explicit "firing threshold". Task-items are sorted by their importance with an "utility function" which considers the mid-term importance as an activation and the long-term importance as the confidence. It has a given budget of Task inferences with different horizons in that sorted list. Task-based competition influences at which point a task is less important than other tasks.
An extreme form of loosing the competition is forgetting because the utility was to low when items were removed to keep the system under AIKR.

# Project goals

* proof of concept of meta-rule language compiler and trie deriver
* experiment of custom attention system

## maintainable code
* codebase is relativly small compared to its feature set and optimization. This is only possible because of the rule-generation(less lines of code for inference) and choice of language(s).
* control strategy is very compactly encoded and easy to change
* Zero dependencies (except standard library)

## memory efficiency
* Stamps are not excessivly copied, evidential trails are shared if possible.
* Terms can reference each other recursivly, they are only copied if necessary

## native speed
* No VM, JIT or language which compiles down to bytecode

# implemented featureset

* a lot of rules for NAL1 - NAL8 are already implemented
* implementation of attention system should be sufficient enough for small scale experiments