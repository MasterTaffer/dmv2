import diff;
import gradient;
import std.math;


/// Stateful class used for encoding Gradient frames into Diff frames
class DiffEncoder
{
	
	const int width, height;
	private Gradient[] state;
	pure nothrow @safe
	this(int width = 40, int height = 25)
	{
		this.width = width;
		this.height = height;
		this.state.length = width*height;
	}
	
	/// Sets the current Gradient state of the frame
	pure @safe
	void setState(in Gradient[] newState)
	{
		if (newState.length != state.length)
			throw new Exception("Illegal state size");
		state[] = newState[];
	}
	
	/// Generate differences between current state and the target frame
	/// and applies the differences to the current state
	pure @safe
	Diff[] generateDiffs(in Gradient[] to)
	{
		Diff[] diffs;
		diffs.reserve(state.length);
		if (to.length != width*height)
		{
			throw new Exception("Invalid target gradient array length");
		}
		
		import std.range;
		
		//Calculate approximate frame difference
		int thres = 0;
		foreach (tuple; zip(state, to))
		{
			
			int d1 = tuple[0].rawPower - tuple[1].rawPower;
			int d2 = tuple[0].rawAngle - tuple[1].rawAngle;
			int d3 = (tuple[0].darkSide ^ tuple[1].darkSide) ? 0 : 1;
			if (d2 < -8)
				d2 += 16;
				
			if (d2 > 8)
				d2 -= 16;
				
			if (abs(d2) <= 2)
				d2 = 0;
			if (abs(d1) <= 2)
				d1 = 0;
			if (tuple[0].rawPower == 0 || tuple[0].rawPower == 7)
				d2 = 0;
				
			thres += abs(d1) + abs(d2) + abs(d3)*8;
		}
		auto fineChangesThreshold = width * height / 2;
		bool doFineChanges = false;
		if (thres < fineChangesThreshold)
			doFineChanges = true;
		
		int fineThres = 1;
		if (doFineChanges)
		{
			fineThres = 0;
		}
		
		auto lastDiff = Diff();
		auto lastPureDiff = Diff();
		auto lastBlack = true;
		Diff previous = Diff(0,0,false);
	
		foreach (tuple; zip(state, to))
		{
			auto g1 = tuple[0];
			auto g2 = tuple[1];

			int power = g1.rawPower - g2.rawPower; 
			int angle = g1.rawAngle - g2.rawAngle;
			bool dside = g1.darkSide ^ g2.darkSide;
			
			bool toblack = ((g2.rawPower == 0) || (g2.rawPower == 7))
				&& (g2.darkSide == false);
			
			
			auto powScale = (int x, int fine)
			{
				if (x == 0)
					return x;
				else if (!toblack && abs(x) <= fine)
					return 0;
				else if (x < 0)
					return 8 + x;
				else
					return x;
			};
				
			auto angScale = (int x, int fine, out bool dontCare)
			{
				if (toblack)
				{
					dontCare = true;
					return 0;
				}
				dontCare = false;
				
				if (abs(x) > 6)
					return 3;
				if (x > fine)
				{
					if (abs(x) > 4)
						return 6;
					if (abs(x) > 2)
						return 4;
					return 1;
				}
				else
				if (x < -fine)
				{
					if (abs(x) > 4)
						return 7;
					if (abs(x) > 2)
						return 5;
					return 2;
				}
				return 0;
			};
			
			
			if (angle >= 8)
				angle -= 16;
				
			if (angle <= -8)
				angle += 16;
			
			bool dontCareAngle = false;
			Diff d;
			d.powerMod = powScale(power, 0);
			d.angleMod = angScale(angle, 0, dontCareAngle);
			d.darkSideMod = dside;
			
			if (dontCareAngle)
			if (previous.powerMod == d.powerMod &&
				previous.darkSideMod == d.darkSideMod)
			{
				d = previous;
			}
			
			
			
			diffs ~= [d];
			previous = d;
			
		}
		
		for (int i = 0; i < width*height; i++)
			state[i] = applyDiffToGradient(diffs[i],state[i]);
		
		return diffs;
	}
}
