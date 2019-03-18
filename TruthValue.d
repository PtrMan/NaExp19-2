module TruthValue;

import std.stdio;
import std.math : pow, abs;
import std.conv : to;

// TODO< convert to struct >
class TruthValue {
	public immutable float freq;
	public immutable double conf;

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

double calcProjectedConf(long timeA, long timeB) {
	long diff = abs(timeA - timeB);

	writeln("calcProj diff = " ~to!string(diff));

	return pow(2.0, -diff * 0.003);
}
