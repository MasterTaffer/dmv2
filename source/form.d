import std.stdint;
import gradient;
import std.typecons;

enum BlockSize = 8;

struct BlockForm
{
	uint64_t rawForm;
	
	this(T)(T list)
	{
		rawForm = 0;
		int iterations = 0;
		uint64_t bitIndex = 1;
		foreach (i; list)
		{
			if (i)
				rawForm = rawForm | bitIndex;
			bitIndex = bitIndex << 1;
			iterations++;
		}
		if (iterations != 64)
		{
			throw new Exception("Illegal list size (not exactly 64)");
		}
	}
	
	pure nothrow @safe @nogc
	this(uint64_t rdata)
	{
		this.rawForm = rdata;
	}
	
	const pure nothrow @safe @nogc
	int compare(in BlockForm bf)
	{
		int sets = 0;
		uint64_t diff = rawForm ^ bf.rawForm;
		foreach (i; 0 .. 64)
		{
			if (diff & 1)
				sets++;
			diff = diff >> 1;
		}
		return sets;
	}
}

unittest
{
	import std.bitmanip;
	uint64_t[] testdata = [0xC2028B5D7C893FBA];
	
	auto ba = BitArray(testdata, 64);
	auto bf = BlockForm(ba);

	assert(bf.rawForm == testdata[0]);
}

pure nothrow @safe
unittest
{
	import std.exception;
	
	int[] testdata = [0,4,3,3,4,6,6,1];
	
	BlockForm bf;
	
	assertThrown!Exception(bf = BlockForm(testdata));
}

pure nothrow @safe  @nogc
unittest
{
	auto bf1 = BlockForm(0xC2028B5D7C893FBA);
	auto bf2 = BlockForm(0x9646BC8C986C6A92);

	assert(bf1.compare(bf2) == bf2.compare(bf1));
	assert(bf1.compare(bf2) == 29);
	
	
	auto bf3 = BlockForm(0x0);
	auto bf4 = BlockForm(0xFFFFFFFFFFFFFFFF);

	assert(bf3.compare(bf4) == 64);
	
	auto bf5 = BlockForm(0x1234);
	auto bf6 = BlockForm(0x1234);

	assert(bf5.compare(bf6) == 0);
}


