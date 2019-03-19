// Copyright 2019 Robert Wünsche

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Stamp;

import std.conv : to;
import std.typecons : Nullable;
import std.algorithm.comparison : min;

class Stamp {
	public string convToStr() shared {
		return to!string(evidentialTrail.trail);
	}

	public static shared(Stamp) makeEternal(shared(long[]) trail) {
		return new shared Stamp(Nullable!long.init, new shared EvidentialTrail(trail));
	}

	public static shared(Stamp) makeEvent(long occurrenceTime, shared(long[]) trail) {
		auto occTime = Nullable!long(occurrenceTime);
		return new shared Stamp(occTime, new shared EvidentialTrail(trail));
	}

	private final shared this(Nullable!long occurrenceTime, shared EvidentialTrail evidentialTrail) {
		this.occurrenceTime = occurrenceTime;
		this.evidentialTrail = evidentialTrail;
	}

	public static bool checkOverlap(shared Stamp a, shared Stamp b) {
		// ASK< how to handle timestamp here ? >

		return EvidentialTrail.checkOverlap(a.evidentialTrail, b.evidentialTrail);
	}

	public static bool equals(shared Stamp a, shared Stamp b) {
		// TODO< take occurrenceTime into account >

		return EvidentialTrail.equals(a.evidentialTrail, b.evidentialTrail);
	}

	public static shared(Stamp) merge(shared Stamp a, shared Stamp b) {
		Nullable!long occurrenceTime = Nullable!long.init;
		if (a.occurrenceTime.isNull() && !b.occurrenceTime.isNull()) {
			occurrenceTime = b.occurrenceTime;
		}
		else if (!a.occurrenceTime.isNull() && b.occurrenceTime.isNull()) {
			occurrenceTime = a.occurrenceTime;
		}
		else if(!a.occurrenceTime.isNull() && !b.occurrenceTime.isNull()) {
			occurrenceTime = min(a.occurrenceTime, b.occurrenceTime); // use first occurence time
		}

		return new shared Stamp(occurrenceTime, EvidentialTrail.merge(a.evidentialTrail, b.evidentialTrail));
	}

	public immutable Nullable!long occurrenceTime; // a stamp may have a occurrenceTime
	public EvidentialTrail evidentialTrail;
}


class EvidentialTrail {
	// TODO OPTIMIZATION< allocate non-GC'ed memory >
	public immutable shared(long[]) trail;

	public shared this(shared(long[]) trail) {
		this.trail = trail.idup;
	}
	
	public static bool checkOverlap(shared EvidentialTrail a, shared EvidentialTrail b) {
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

	public static bool equals(shared EvidentialTrail a, shared EvidentialTrail b) {
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

	public static shared(EvidentialTrail) merge(shared EvidentialTrail a, shared EvidentialTrail b) {
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

        return new shared EvidentialTrail(zipped);
	}

	public final shared string convToStr() {
		return to!string(trail);
	}
}
