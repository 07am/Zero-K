return{
    font="LuaUI/Fonts/ru/FreeSansBoldKOI8R.ttf", 
	-- ��� � (�� �� �) ������ ���� �������� �� `
	-- �=255 , � ��� ����������� ������ � Spring Engine
	-- ���� ����� ����������� � ������ ` ������ ���������� �
	-- All � (not �) must be replaced by ` 
	-- The code of the Symbol � is 255 which is color control code for Spring Engine
	-- This font dispaly � instead of `
	
	-- We must know who we should blame if a translation is sucks.  
    units={
		-- Cloaky Bot Factory (banana_Ai)
		factorycloak={
			description="���������� ��������� �����, ������ 10m/s",
			helptext="����� ������������ �� ���� ������� ���������� ������������� ��� � �������� ��� ������ ����� ��������� ������� �����������, ���������� � EMP ������. �������� �����: ���(Glave), ����(Rocko), ����(Warrior), ����(Zeus) � �����(Hammer).",
		},
		-- Rector (banana_Ai)
		armrectr={
			description="��������� �������� �����-���������, ������ 5 m/s",
			helptext="������ ����ݣ� ��������� ����������� ����� � ������������ ����������� �����������, ��� ��������� ��� ������� � ������, ��������� ������������.",
		},
		-- Glave (banana_Ai, banana_king_ChvaN)
		armpw={
			description="����� �����-������",
			helptext="������� � ��ۣ���, ���� ����� ����������� � ��������� �����������, ��������� � ������� ������� ���� ��������� ����������. ������ ��� ������ �������� �������������� ������� � ������ � �������� ������.",
		},
		-- Scythe (banana_Ai)
		spherepole={
			description="��������� �����-������",
			helptext="������ ������� ���� ���-�� ��������� ���������� ����� � ����, �� ������������ ��������� ����������� ��������� ��� ������������� ����� ������� ���������� � ���������� ���������.",
		},
		
		-- Rocko (banana_Ai)
		armrock={
			description="������� ����� (������ �����)",
			helptext="���� �������� ����������, �������������� � ������� ��������, �� ��� �������������� ���������� ��������. ������ ������ ������������ ���� - ��������� �� � ����� � ����� ����� �� ���������� � ����������� ��������� ���������. ������� � ��Σ������� ����� ����� ��������� ��� ����, ��� ��� ����� ������������� �� �����.",
		},
		-- Warrior (banana_Ai)
		armwar={
			description="����� � �������� ������",
			helptext="�����, ������� �������������� ����ͣ��, �������� ���������� ������ ��������, �� ����� ������� ���أ���� ���� � ����� ������ ������. ������, ��� �� ����� ���������� �� ������������ ��������. ��-�� ����� �������� ����� ���� ����� ���������� ������������� �������.",
		},
		-- Zeus (banana_Ai)
        armzeus={
            description="���������/�������� ������ �����",
            helptext="�������� � ��������� ������ ������ ����� ���� ������ ������� ���������� ���� ��� ������� �����, �� ��� ��� ���� ��� �� ������ ������� � ��� ���� ������������ ������������. ������������� �� ����� ����� ���� ������� ������ �� �������. ",
		},
		-- Hammer (banana_Ai)
		armham={
			description="����� ����������/�������-����� ",
			helptext="����� ���������� ���������� ������, ������������� �� ��������� ����������� ������������ ������� � ����������� �������� �� �������������� ����������. �� ������ �� ��, ��� ����� ���������� ������ ��������� ������, ��� ���� �������� �� �������� � ������ ������� ������.",
		},
		--[[
		-- Sharpshooter
		armsnipe={
			description="Sniper Walker (Skirmish/Anti-Heavy)",
			helptext="The Sharpshooter's energy rifle inflicts heavy damage to a single target. It can fire while cloaked; however its visible round betrays its position. It requires quite a bit of energy to keep cloaked, especially when moving. The best way to locate a Sharpshooter is by sweeping the area with many cheap units.",
		},
		-- Jethro
		armjeth={
			description="Anti-air Bot",
			helptext="Fast and fairly sturdy for its price, the Jethro is good budget mobile anti-air. It can cloak, allowing it to provide unexpected anti-air protection or escape ground forces it's defenseless against.",
		},
		-- Tick 
		armtick={
			description="All-Terrain EMP Crawling Bomb ",
			helptext="The Tick relies on its speed and small size to dodge inaccurate weapons, especially those of assaults and many skirmishers. It can paralyze heavy units or packs of lighter raiders which cannot kill it before it is already in range. Warriors or Glaives can then eliminate the helpless enemies without risk. Counter with defenses or single cheap units to set off a premature detonation. This unit cloaks when otherwise idle.",
		},
		]]--
		-- Eraser (banana_Ai)
		spherecloaker={
			description="�������� ����� � ������������ ����������� � �����",
			helptext="��������� ����ݣ� ����������� �����, ���-�� �������� ����� �� ��������� �������. ����� � ���� ���� ��������� ���� �����������.",
		},
		
		--[[
		-- Shield Bot Factory
		factoryshield={
			description="Produces Tough Robots, Builds at 10 m/s ",
			helptext="The Shield Bot Factory is tough yet flexible. Its units are built to take the pain and dish it back out, without compromising mobility. Clever use of unit combos is well rewarded. Key units: Bandit, Thug, Outlaw, Rogue, Racketeer",
		},
		-- Convict
		cornecro={
			description="Construction/Shield Support bot, Builds at 5 m/s",
			helptext="The Convict is a fairly standard construction bot with a twist: a light shield to defend itself and support allied shieldbots. ",
		},
		-- Bandit
		corak={
			description="Medium-Light Raider Bot",
			helptext="The Bandit outranges and is somewhat tougher than the Glaive, but still not something that you hurl against entrenched forces. Counter with riot units and LLTs.",
		},
		-- Rogue
		corstorm={
			description="Skirmisher Bot (Indirect Fire)",
			helptext="The Rogue's arcing missiles have a low rate of fire, but do a lot of damage, making it very good at dodging in and out of range of enemy units or defense, or in a powerful initial salvo. Counter them by attacking them with fast units, or crawling bombs when massed.",
		},
		-- Thug
		corthud={
			description="Shielded Assault Bot ",
			helptext="Weak on its own, the Thug makes an excellent screen for Outlaws and Rogues. The linking shield gives Thugs strength in numbers, but can be defeated by AoE weapons or focus fire. ",
		},
		-- Outlaw
		cormak={
			description="Riot Bot",
			helptext="The Outlaw emits an electromagnetic disruption pulse in a wide circle around it that damages and slows enemy units. Friendly units are unaffected. ",
		},
		-- Felon
		shieldfelon={
			description="Shielded Skirmisher",
			helptext="The Felon draws energy from its shield, discharging it in accurate bursts. Link it to other shields to increase its rate of fire.",
		},
		]]--
    }
}
