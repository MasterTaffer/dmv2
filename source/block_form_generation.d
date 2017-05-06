import form;
import gradient;
import std.stdint;

immutable byte[] sinetable =
[
	16 , 0 ,
	14 , 6 ,
	11 , 11 ,
	6 , 14 ,
	0 , 16 ,
	-6 , 14 ,
	-11 , 11 ,
	-14 , 6 ,
	-16 , 0 ,
	-14 , -6 ,
	-11 , -11 ,
	-6 , -14 ,
	0 , -16 ,
	6 , -14 ,
	11 , -11 ,
	14 , -6
];

immutable byte[] angtable =
[
	16 , 0 ,
	17 , 7 ,
	15 , 15 ,
	7 , 17 ,
	0 , 16 ,
	-7 , 17 ,
	-15 , 15 ,
	-17 , 7 ,
	-16 , 0 ,
	-17 , -7 ,
	-15 , -15 ,
	-7 , -17 ,
	0 , -16 ,
	7 , -17 ,
	15 , -15 ,
	17 , -7
];

immutable byte[] angtabledside =
[
	11 , 4 , -11 , 4 ,
	10 , 10 , -14 , 0 ,
	6 , 15 , -15 , -6 ,
	0 , 14 , -10 , -10 ,
	-4 , 11 , -4 , -11 ,
	-10 , 10 , 0 , -14 ,
	-15 , 6 , 6 , -15 ,
	-14 , 0 , 10 , -10 ,
	-11 , -4 , 11 , -4 ,
	-10 , -10 , 14 , 0 ,
	-6 , -15 , 15 , 6 ,
	0 , -14 , 10 , 10 ,
	4 , -11 , 4 , 11 ,
	10 , -10 , 0 , 14 ,
	15 , -6 , -6 , 15 ,
	14 , 0 , -10 , 10 ,
];

pure nothrow @safe @nogc
BlockForm generateBlockForm(Gradient g)
{
	//The following algorithm is quite convoluted
	//and is pretty much just pure arithmetics and
	//lookup table checks
	
	uint64_t form;
	int pow = g.rawPower;
	uint angle = g.rawAngle;
	bool dside = g.darkSide;
	bool dsideblack = false;
	
	int l1dir,l2dir,ld1dir,ld2dir;
	int l1, l2, ld1, ld2;
	
	if (!dside)
	{
		angle *= 2;
		
		l1dir = angtable[angle];
		l2dir = angtable[angle+1];
		int power = pow * 2 - 7;
		l1 = l1dir * power * BlockSize;
		l2 = l2dir * power * BlockSize;
	}
	else
	{
		if (pow % 2)
			pow = 7 - pow / 2;
		else
			pow = pow / 2;
		
		if (pow >= 4)
		{
			angle = (angle+8) & 0xf;
			pow = pow - 4;
			dsideblack = 1;
		}
		
		pow = pow * 2;
		if (pow == 6)
			pow -= 1;
		
		angle *= 4;
		
		l1dir = angtabledside[angle+0];
		l2dir = angtabledside[angle+1];
		ld1dir = angtabledside[angle+2];
		ld2dir = angtabledside[angle+3];
		
		int power = pow * 2 - 7;
		l1 = l1dir * power * BlockSize;
		l2 = l2dir * power * BlockSize;
		ld1 = -ld1dir * power * BlockSize;
		ld2 = -ld2dir * power * BlockSize;
		
		
		//TO SAVE A SINGLE ADD
		ld1 = ld1 - l1;
		ld2 = ld2 - l2;
	}
	
	enum difex = (15 * 7 * 2);
	
	int dify = (- difex * 4) + difex / 2 + l2;
	int basedifx = (- difex * 4) + difex / 2 + l1;
	
	uint64_t form_bit = 1;
	
	foreach (int y; 0 .. BlockSize)
	{
		int difx = basedifx;
		
		foreach (int x; 0 .. BlockSize)
		{
			bool o = false;
			
			int dot = difx * l1dir + dify * l2dir;
			if (dot > 0)
				o = true;
				
			if (dside)
			{
				dot = (difx + ld1) * ld1dir + (dify + ld2) * ld2dir;
				if (dot <= 0)
					o = true;
				if (dsideblack)
					o = !o;
			}
			if (o)
				form = form | form_bit;
			form_bit = form_bit << 1;
			difx += difex;
		}
		dify += difex;
	}
	return BlockForm(form);
}

