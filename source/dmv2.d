import gradient;
import diff;

class DMV2File
{
	int width;
	int height;
	Gradient[] gframe;
	Diff[][] dframes;
	
	ubyte[] compress()
	{
		import gradient_compress;
		import diff_compress;
		ubyte[] buffer;
		gradientCompress(gframe, buffer);
		foreach (dframe; dframes)
			diffCompress(dframe, buffer);
		return buffer;
	}
}



