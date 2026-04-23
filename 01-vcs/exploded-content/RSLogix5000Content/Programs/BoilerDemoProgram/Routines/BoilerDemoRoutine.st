//Init Motors and WaterTank
if (not Init) then
	Init := 1;
	Motors[0].SetSpeed := 100;
	Motors[1].SetSpeed := 120;
	Motors[2].SetSpeed := 140;
	Motors[3].SetSpeed := 160;
	Motors[4].SetSpeed := 180;
	Tank2.SetPoint := 50.0;
	Tank1.SetPoint := 50.0;
	Tank2.Level := 1;
	Tank1.Level := 1;
end_if;

if (TestIncrementTag = 0) then
	Direction := 1;
end_if;
if (TestIncrementTag = 100) then
	Direction := 0;
end_if;
if (TestBoolTag) then
	if (Direction) then 
		TestIncrementTag := TestIncrementTag + 1;
	else
		TestIncrementTag := TestIncrementTag - 1;
	end_if;
end_if;


//Motor Logic
for Count := 0 to 4 do
	if (Motors[Count].CmdOffOn) then
		Motors[Count].Status := 1;
		if (Motors[Count].Speed <= Motors[Count].SetSpeed) then
			Motors[Count].Speed := Motors[Count].Speed + 1;
			Motors[Count].Power := Motors[Count].Power + 0.2;
		end_if;
	else
		Motors[Count].Status := 0;
		if (Motors[Count].Speed >= 0) then
			Motors[Count].Speed := Motors[Count].Speed - 1;
			Motors[Count].Power := Motors[Count].Power - 0.2;
		end_if;
	end_if;
end_for;
