import std.stdio;
import form;
import imageformats;
import gradient_generator;
import gradient;
import diff;
import diff_encoder;
import dmv2;

enum WhiteThreshold = 32;

BlockForm generateBlockFormFromImage(IFImage input, int x, int y, int w, int h)
{
	if (x < 0 || y < 0 || x >= input.w || y >= input.h)
		throw new Exception("Input coordinates out of bounds");
	if (w < 0 || h < 0 || x + w > input.w || y + h > input.h)
		throw new Exception("Input size out of bounds");
	if (input.c != ColFmt.RGBA)
		throw new Exception("Input image in wrong format");
	
	bool[64] b;
	int index = 0;
	foreach (j; 0..BlockSize)
	{
		foreach (i; 0..BlockSize)
		{
			int px = x + (w * i) / (BlockSize);
			int py = y + (h * j) / (BlockSize);
			
			int pindex = px * 4 + py * 4 * input.w;
			int val = input.pixels[pindex];
			bool o = false;
			if (val > WhiteThreshold)
				o = true;
			
			b[index] = o;
			index++;
		}
	}
	return BlockForm(b);
}

void generateBlockFormsFromImage(IFImage input, int w, int h, ref BlockForm[] forms)
{
	int bw = input.w / w;
	int bh = input.h / h;
	if (input.c != ColFmt.RGBA)
		throw new Exception("Input image in wrong format");
	
	int index = 0;
	forms.length = w*h;
	
	foreach (j; 0..h)
	{
		foreach (i; 0..w)
		{
			import std.stdio;
			forms[index] = generateBlockFormFromImage(
				input, i * bw, j * bh, bw, bh);
			index++;
		}
	}
}

void blockFormsToImage(int w, int h, in BlockForm[] forms, ref ubyte[] buf)
{
	buf.length = w*h*4*64;
	
	int index = 0;
	foreach (by; 0..h)
	{
		foreach (bx; 0..w)
		{
			BlockForm form = forms[index];
			index++;
			
			foreach (j; 0..BlockSize)
			{
				foreach (i; 0..BlockSize)
				{
					int px = BlockSize * bx + i;
					int py = BlockSize * by + j;
					
					bool o = false;
					if (form.rawForm & 1)
						o = true;
					form.rawForm >>= 1;
					
					int pindex = px * 4 + py * 4 * w * BlockSize;
					buf[pindex+3] = 255;
					
					ubyte val = o ? 255 : 0;
					buf[pindex+0] = val;
					buf[pindex+1] = val;
					buf[pindex+2] = val;
					
				}
			}
		}
	}
}



int main(string[] args)
{
	import std.algorithm.iteration;
	import std.algorithm.searching;
	import std.file;

	auto printUsage = { writeln("Usage: dmv2 outputfile imagefolder"); };
	if (args.length != 3)
	{
		printUsage();
		return 1;
	}
	auto outfile = args[1];
	auto ifolder = args[2];

	
	auto inputFrames = dirEntries(ifolder, SpanMode.shallow)
		.filter!(f => f.name.endsWith(".png"));
	
	BlockForm[] forms;
	
	{
		IFImage im = read_image(inputFrames.front, ColFmt.RGBA);
		generateBlockFormsFromImage(im, 40, 25, forms);
	}
	
	GradientGenerator grad = new GradientGenerator();
	DiffEncoder encoder = new DiffEncoder(40,25);
	
	import std.range;
	
	Gradient[] grads;
	auto formsToGrads = 
	{
		import std.parallelism;
		grads.length = forms.length;
		foreach (i, ref form; parallel(forms))
		{
			grads[i] = grad.blockFormToGradient(form);
		}
	};
	
	auto gradsToForms = 
	{
		import std.parallelism;
		forms.length = grads.length;
		foreach (i, ref r_grad; grads)
		{
			forms[i] = grad.gradientToBlockForm(r_grad);
		}
	};
	
	writeln("Generating first frame");
	formsToGrads();
	
	encoder.setState(grads);
	DMV2File dmv2 = new DMV2File();
	dmv2.width = 40;
	dmv2.height = 25;
	dmv2.gframe.length = grads.length;
	dmv2.gframe[] = grads[];
	
	int index = 2;
	foreach (string frame; dropOne(inputFrames))
	{
		writeln("Generating frame ", index);
		IFImage im = read_image(frame, ColFmt.RGBA);
		generateBlockFormsFromImage(im, 40, 25, forms);
		formsToGrads();
		dmv2.dframes ~= [encoder.generateDiffs(grads)];
		index++;
	}
	
	
	auto buf = dmv2.compress();
	writeln("Compressed size: ", buf.length);
	auto f = File(outfile, "wb");
	f.rawWrite(buf);
	return 0;	
}
