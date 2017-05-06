import diff;
import gradient;
import diff;
import std.math;

class DiffDecoder
{
	const int width, height;
	Gradient[] state;
	pure nothrow @safe
	this(int width = 40, int height = 25)
	{
		this.width = width;
		this.height = height;
		this.state.length = width*height;
	}
	
	pure @safe
	void setState(in Gradient[] newState)
	{
		if (newState.length != state.length)
			throw new Exception("Illegal state size");
		state[] = newState[];
	}
	
	pure @safe
	void applyDiffs(in Diff[] diffs)
	{
		if (diffs.length != width*height)
		{
			throw new Exception("Invalid diff array length");
		}
		
		import std.range;
		
		for (int i = 0; i < width*height; i++)
		{
			state[i] = applyDiffToGradient(diffs[i], state[i]);
		}
	}
}