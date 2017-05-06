import diff;
import var_int;
	
void diffCompress(in Diff[] diff, ref ubyte[] buffer)
{
	int lastctype = -1;
	int lastccount = 0;
	size_t dsize = diff.length;
	int i = 0;
	
	ubyte xrepeatmask = 0x80;
	while (i < dsize)
	{
		Diff d = diff[i];
		ubyte val = d.rawData; 
		ubyte xamount = 0;
		int i2 = i + 1;
		while (i2 < dsize)
		{
			int cmpres = compareDiffValues(d,diff[i2]);
			i2 += 1;
			if (cmpres)
				xamount += 1;
			else
				break;
		}
		
		i += 1;
		
		if (xamount > 0)
		{
			i += xamount;
			val += xrepeatmask;
		}
		
		buffer ~= [val];
		if (xamount > 0)
		{
			buffer ~= integerToBytes(xamount);
		}
	}
}
