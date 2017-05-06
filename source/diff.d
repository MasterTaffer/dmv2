import std.bitmanip;
import gradient;

/**
 * Structure for representing a single "difference"
 * between "gradient blocks"
 */
struct Diff
{
	union 
	{
		struct
		{
			mixin(bitfields!(
				uint, "powerMod",    3,
				uint, "angleMod",    3,
				bool, "darkSideMod", 1,
				bool, "repeatBit", 	 1));
		}
		ubyte rawData;
	}
	
	
	pure nothrow @nogc @safe
	this(uint power, uint angle, bool darkSide)
	{
		powerMod = power;
		angleMod = angle;
		darkSideMod = darkSide;
	}
}


pure nothrow @nogc @safe
bool compareDiffValues(in Diff from, in Diff to)
{
	if (from.powerMod != to.powerMod)
		return false;
	if (from.angleMod != to.angleMod)
		return false;
	if (from.darkSideMod != to.darkSideMod)
		return false;
	return true;
}

pure nothrow @nogc @safe
Gradient applyDiffToGradient(in Diff diff, in Gradient gradient)
{
	auto powerOp = (int grad, int diff) => ((grad - diff) + 8) % 8;
	
	auto angleOp = (int grad, int diff)
	{
		int intermed = grad;
		//TODO, Don't care value
		if (diff == 3)
			intermed = grad + 8;
		else if (diff == 1)
			intermed = grad - 1;
		else if (diff == 2)
			intermed = grad + 1;
		else if (diff == 4)
			intermed = grad - 3;
		else if (diff == 5)
			intermed = grad + 3;
		else if (diff == 6)
			intermed = grad - 5;
		else if (diff == 7)
			intermed = grad + 5;
		if (intermed < 0)
			intermed += 16;
		if (intermed > 15)
			intermed -= 16;
		return intermed;
	};
	
	Gradient ret;
	
	ret.rawPower = powerOp(gradient.rawPower , diff.powerMod);
	assert(ret.rawPower >= 0);
	assert(ret.rawPower < 8);
	
	ret.rawAngle = angleOp(gradient.rawAngle , diff.angleMod);
	assert(ret.rawAngle >= 0);
	assert(ret.rawAngle < 16);
	
	ret.darkSide = gradient.darkSide ^ diff.darkSideMod;
	
	return ret;
}

unittest
{
	Gradient g = Gradient(3,12,false);
	Diff d1 = Diff(1, 5, true);
	Gradient result;
	result = applyDiffToGradient(d1,g);
	assert(result.rawPower == 2);
	assert(result.rawAngle == 15);
	assert(result.darkSide == true);
	
	Diff d2 = Diff(7, 7, false);
	result = applyDiffToGradient(d2,g);
	assert(result.rawPower == 4);
	assert(result.rawAngle == 1);
	assert(result.darkSide == false);
}

