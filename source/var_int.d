import std.stdint;

uint64_t bytesToInteger(in ubyte[] bytes, out int read_count, int index = 0)
{
	int r = 0;
	int shl = 0;
	int count = 0;
	while (true)
	{
		if (bytes.length <= index)
			throw new Exception("Out of data while reading variable integer");
		int d = bytes[index];
		count += 1;
		r += (d & 0x7F) << shl;
		if (d < 128)
		{
			read_count = count;
			return r;
		}
		shl += 7;
		index += 1;
	}
}
unittest
{
	ubyte[] buffer = [11,0b10101010,0b11001100,0b00001000];
	int readCount = 0;
	uint64_t integer = bytesToInteger(buffer,readCount,1);
	assert(readCount == 3);
	assert(integer == 0b000100010011000101010);
}
unittest
{
	import std.exception;
	ubyte[] buffer = [0xFF,0xFF,0xFF];
	int readCount = 0;
	assertThrown!(Exception)(bytesToInteger(buffer,readCount,1));
}

ubyte[] integerToBytes(uint64_t integer)
{
	ubyte[] ls;
	while (true)
	{
		ubyte r = integer % 128;
		
		if (integer >= 128)
			ls ~= [cast(ubyte)(r + 0x80)];
		else
		{
			ls ~= [cast(ubyte)(r)];
			break;
		}
		
		integer = integer / 128;
	}
	return ls;
}
unittest
{
	uint64_t integer = 0b000100010011000101010;
	ubyte[] buf = integerToBytes(integer);
	assert(buf.length == 3);
	assert(buf[0] == 0b10101010 && buf[1] == 0b11001100 && buf[2] == 0b00001000);
}


