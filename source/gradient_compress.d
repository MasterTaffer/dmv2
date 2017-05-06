import gradient;
import var_int;


void gradientCompress(in Gradient[] grad, ref ubyte[] buffer)
{
	int lastctype = -1;
	int lastccount = 0;
	size_t dsize = grad.length;
	int i = 0;
	while (i < dsize)
	{
		ubyte c = grad[i].getRawByte();
		i += 1;
		
		if (c != lastctype)
		{
			if (lastctype != -1)
				buffer ~= integerToBytes(lastccount);
			buffer ~= [c];
			lastctype = c;
			lastccount = 1;
		}
		else
		{
			lastccount += 1;
		}
	}		
	buffer ~= integerToBytes(lastccount);
}
