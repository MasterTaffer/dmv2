import std.typecons;
import gradient;
import form;
import block_form_generation;

class GradientGenerator
{
	Tuple!(BlockForm, Gradient)[256] possibleForms; 
	pure nothrow @nogc @safe
	this()
	{
		generateAllPossibleForms();
	}
	
	pure nothrow @nogc @safe
	private void generateAllPossibleForms()
	{
		foreach (uint i; 0..256)
		{
			ubyte c = cast(ubyte) i;
			Gradient g = Gradient(RawGradient(c));
			BlockForm f = generateBlockForm(g);
			possibleForms[i] = tuple(f, g);
		}
	}
	
	const pure nothrow @nogc @safe
	Gradient blockFormToGradient(in BlockForm form) 
	{
		int closestAmount = 9999;
		Gradient closest = Gradient(); 
		foreach (pair; possibleForms)
		{
			int diff = form.compare(pair[0]);
			if (diff < closestAmount)
			{
				closestAmount = diff;
				closest = pair[1];
			}
		}
		return closest;
	}
	
	const pure nothrow @nogc @safe
	BlockForm gradientToBlockForm(in Gradient grad) 
	{
		return possibleForms[grad.getRawByte()][0];
	}
	
}