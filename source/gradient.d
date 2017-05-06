import std.bitmanip;

/**
 * Structure for representing a single "gradient block"
 *
 * Struct Gradient is used during compression and decompression
 * to contain additional hints, while RawGradient is in a format
 * easily convertible to bytes.
 */
struct Gradient
{
	int rawPower;
	int rawAngle;
	bool darkSide;
	
	pure nothrow @nogc @safe
	this(in RawGradient rg)
	{
		rawPower = rg.power;
		rawAngle = rg.angle;
		darkSide = rg.darkSide;
	}
	
	pure nothrow @nogc @safe
	this(in int rawPower, in int rawAngle, in bool darkSide)
	{
		this.rawPower = rawPower;
		this.rawAngle = rawAngle;
		this.darkSide = darkSide;
	}
	
	const pure nothrow @nogc @safe
	ubyte getRawByte()
	{
		RawGradient rg = RawGradient(this);
		return rg.rawData;
	}
}

/// ditto
struct RawGradient
{
	union 
	{
		struct
		{
			mixin(bitfields!(
				uint, "power",    3,
				uint, "angle",    4,
				bool, "darkSide", 1));
		}
		ubyte rawData;
	}
	
	pure nothrow @nogc @safe
	this(in Gradient g)
	{
		power = g.rawPower;
		angle = g.rawAngle;
		darkSide = g.darkSide;
	}
	
	pure nothrow @nogc @safe
	this(in ubyte packedGradient)
	{
		rawData = packedGradient;
	}
}


/// Gradient to RawGradient conversion
pure nothrow @nogc @safe
unittest
{
	Gradient gradient = Gradient(3,7,true);
	RawGradient rg = RawGradient(gradient);
	assert(rg.power == 3);
	assert(rg.angle == 7);
	assert(rg.darkSide == true);
}

/// Raw byte to RawGradient conversion
pure nothrow @nogc @safe
unittest
{
	ubyte rawByte = 0b10011010;
	RawGradient rg = RawGradient(rawByte);
	assert(rg.power == 2);
	assert(rg.angle == 3);
	assert(rg.darkSide == true);

}



/// Gradient to byte conversion conversion
pure nothrow @nogc @safe
unittest
{
	Gradient gradient = Gradient(2,3,true);
	assert(gradient.getRawByte() == 0b10011010);
}


