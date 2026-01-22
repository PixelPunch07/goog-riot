#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] =
{
	"mvm/giant_heavy/giant_heavy_explode.wav"
};

static char g_HurtSounds[][] =
{
	"mvm/giant_heavy/giant_heavy_pain.wav"
};

static char g_IdleSounds[][] =
{
	"mvm/giant_heavy/giant_heavy_entrance.wav"
};

static char g_MeleeHitSounds[][] =
{
	"weapons/metal_gloves_hit_flesh1.wav",
	"weapons/metal_gloves_hit_flesh2.wav",
	"weapons/metal_gloves_hit_flesh3.wav",
	"weapons/metal_gloves_hit_flesh4.wav"
};

static char g_MeleeAttackSounds[][] =
{
	"vo/heavy_specialcompleted01.mp3",
	"vo/heavy_specialcompleted02.mp3"
};

static char g_AngerSounds[][] =
{
	"mvm/giant_heavy/giant_heavy_gunwindup.wav"
};

static char g_SecurityAlertSounds[][] =
{
	"ambient/alarms/klaxon1.wav"
};

#define SECURITY_MODEL "models/bots/heavy/bot_heavy.mdl"
#define SECURITY_INFECTION_RANGE 250.0  // Bigger than Calmaticus's 150.0
#define SECURITY_CIRCLE_DELAY 1.0

float SecurityInfectionDelay()
{
	return SECURITY_CIRCLE_DELAY;
}

void XenoLabSecurity_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Xeno Lab Security");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_xeno_lab_security");
	strcopy(data.Icon, sizeof(data.Icon), "heavy_giant");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS|MVM_CLASS_FLAG_ALWAYSCRIT;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds)); i++) { PrecacheSound(g_DeathSounds[i]); }
	for (int i = 0; i < (sizeof(g_HurtSounds)); i++) { PrecacheSound(g_HurtSounds[i]); }
	for (int i = 0; i < (sizeof(g_IdleSounds)); i++) { PrecacheSound(g_IdleSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_AngerSounds)); i++) { PrecacheSound(g_AngerSounds[i]); }
	for (int i = 0; i < (sizeof(g_SecurityAlertSounds)); i++) { PrecacheSound(g_SecurityAlertSounds[i]); }
	
	PrecacheModel(SECURITY_MODEL);
	PrecacheSound("weapons/cow_mangler_explode.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return XenoLabSecurity(vecPos, vecAng, team, data);
}

methodmap XenoLabSecurity < CClotBody
{
	public void PlayIdleSound()
	{
		if(this.m_flNextIdleSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_IdleSounds[GetRandomInt(0, sizeof(g_IdleSounds) - 1)], this.index, SNDCHAN_VOICE, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextIdleSound = GetGameTime(this.index) + GetRandomFloat(12.0, 24.0);
	}
	
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
			
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + GetRandomFloat(0.6, 1.6);
	}
	
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayAngerSound()
	{
		EmitSoundToAll(g_AngerSounds[GetRandomInt(0, sizeof(g_AngerSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlaySecurityAlertSound()
	{
		EmitSoundToAll(g_SecurityAlertSounds[GetRandomInt(0, sizeof(g_SecurityAlertSounds) - 1)], this.index, SNDCHAN_AUTO, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, BOSS_ZOMBIE_VOLUME);
	}
	
	public XenoLabSecurity(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		XenoLabSecurity npc = view_as<XenoLabSecurity>(CClotBody(vecPos, vecAng, SECURITY_MODEL, "1.75", "50000", ally, false, true, true, true));
		
		i_NpcWeight[npc.index] = 4;
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
		if(iActivity > 0) npc.StartActivity(iActivity);
		
		func_NPCDeath[npc.index] = XenoLabSecurity_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = XenoLabSecurity_OnTakeDamage;
		func_NPCThink[npc.index] = XenoLabSecurity_ClotThink;
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;
		
		// Raid boss setup (from Speechless cause im a little dumb...)
		bool final = StrContains(data, "xenotime") != -1;
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
		}
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 300.0;  // 5 minute timer
			RaidAllowsBuildings = true;
			RaidModeScaling = MultiGlobalHealth;
			if(RaidModeScaling == 1.0)
				RaidModeScaling = 0.0;
			else
				RaidModeScaling *= 2.0;  // Harder scaling
		}
		
		npc.m_iHealthBar = 1;
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bThisNpcIsABoss = true;
		
		// Security protocol activation messages
		if(i_RaidGrantExtra[npc.index] == 1)
		{
			CPrintToChatAll("{red}[XENO LAB SECURITY PROTOCOL ACTIVATED]");
			CPrintToChatAll("{crimson}Xeno Lab Security{default}: INTRUDERS DETECTED. INITIATING CONTAINMENT PROCEDURES.");
		}
		
		npc.m_flSpeed = 200.0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flNextRangedAttack = 0.0;
		npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 10.0;  // First infection circle
		
		npc.m_flMeleeArmor = 1.1;
		npc.m_flRangedArmor = 0.85;
		
		// Robot cosmetics (no minigun)
		npc.m_iWearable1 = npc.EquipItem("head", "models/workshop/player/items/heavy/robo_heavy_chief/robo_heavy_chief.mdl");
		
		SetEntityRenderColor(npc.index, 50, 200, 50, 255);
		SetEntityRenderColor(npc.m_iWearable1, 50, 200, 50, 255);
		
		npc.PlaySecurityAlertSound();
		npc.StartPathing();
		
		return npc;
	}
}

public void XenoLabSecurity_ClotThink(int iNPC)
{
	XenoLabSecurity npc = view_as<XenoLabSecurity>(iNPC);
	
	if(npc.m_flNextDelayTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextDelayTime = GetGameTime(npc.index) + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	if(RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		CPrintToChatAll("{crimson}Xeno Lab Security{default}: CONTAINMENT SUCCESSFUL. ALL INTRUDERS ELIMINATED.");
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		return;
	}
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.m_blPlayHurtAnimation = false;
		npc.PlayHurtSound();
	}
	
	if(npc.m_flNextThinkTime > GetGameTime(npc.index))
	{
		return;
	}
	
	npc.m_flNextThinkTime = GetGameTime(npc.index) + 0.1;
	
	// Infection circle ability with animation
	if(npc.m_flNextRangedSpecialAttack < GetGameTime(npc.index))
	{
		if(npc.m_flDoingAnimation == 0.0)
		{
			// Start animation
			npc.SetActivity("taunt_soviet_strongarm_end");
			npc.m_flDoingAnimation = GetGameTime(npc.index) + 2.5;
			npc.StopPathing();
			npc.m_bisWalking = false;
			npc.m_flSpeed = 0.0;
			npc.PlayAngerSound();
		}
		else if(npc.m_flDoingAnimation < GetGameTime(npc.index))
		{
			// Animation finished, trigger infection and resume
			npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + 12.0;
			npc.m_flDoingAnimation = 0.0;
			Security_DoInfectionCircle(npc.index);
			npc.m_flSpeed = 200.0;
			npc.m_bisWalking = true;
			int iActivity = npc.LookupActivity("ACT_MP_RUN_MELEE");
			if(iActivity > 0) npc.StartActivity(iActivity);
			npc.StartPathing();
		}
		else
		{
			// Still animating, don't do anything else
			return;
		}
	}
	
	if(npc.m_flGetClosestTargetTime < GetGameTime(npc.index))
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = GetGameTime(npc.index) + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
			npc.SetGoalVector(vPredictedPos);
		}
		else
		{
			npc.SetGoalEntity(npc.m_iTarget);
		}
		
		Security_SelfDefense(npc, GetGameTime(npc.index), npc.m_iTarget, flDistanceToTarget);
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
	
	npc.PlayIdleSound();
}

public Action XenoLabSecurity_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	XenoLabSecurity npc = view_as<XenoLabSecurity>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void XenoLabSecurity_NPCDeath(int entity)
{
	XenoLabSecurity npc = view_as<XenoLabSecurity>(entity);
	
	if(!npc.m_bGib)
	{
		npc.PlayDeathSound();
	}
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	
	if(i_RaidGrantExtra[npc.index] == 1)
	{
		CPrintToChatAll("{crimson}Xeno Lab Security{default}: CRITICAL SYSTEM FAILURE... CONTAINMENT... BREACH...");
	}
}

void Security_SelfDefense(XenoLabSecurity npc, float gameTime, int target, float distance)
{
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			Handle swingTrace;
			float VecEnemy[3]; WorldSpaceCenter(npc.m_iTarget, VecEnemy);
			npc.FaceTowards(VecEnemy, 15000.0);
			
			if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
			{
				target = TR_GetEntityIndex(swingTrace);
				float vecHit[3];
				TR_GetEndPosition(vecHit, swingTrace);
				
				if(IsValidEnemy(npc.index, target))
				{
					float damageDealt = 350.0;
					if(ShouldNpcDealBonusDamage(target))
						damageDealt *= 5.0;
					
					float DamageDoExtra = MultiGlobalHealth;
					if(DamageDoExtra != 1.0)
						DamageDoExtra *= 2.0;
					
					damageDealt *= DamageDoExtra;
					
					SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
					npc.PlayMeleeHitSound();
				}
			}
			delete swingTrace;
		}
	}
	
	if(gameTime > npc.m_flNextMeleeAttack)
	{
		if(distance < (GIANT_ENEMY_MELEE_RANGE_FLOAT_SQUARED))
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.PlayMeleeSound();
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				
				npc.m_flAttackHappens = gameTime + 0.4;
				npc.m_flDoingAnimation = gameTime + 0.4;
				npc.m_flNextMeleeAttack = gameTime + 1.2;
			}
		}
	}
	
}

#define MAX_SECURITY_TARGETS 64

void Security_DoInfectionCircle(int entity)
{
	float Security_Loc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Security_Loc);
	Security_Loc[2] += 45.0;
	
	// Create large warning circles (bigger than Calmaticus)
	spawnRing_Vectors(Security_Loc, SECURITY_INFECTION_RANGE * 4.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 50, 255, 50, 200, 1, SecurityInfectionDelay(), 6.0, 8.0, 1, 1.0);
	spawnRing_Vectors(Security_Loc, SECURITY_INFECTION_RANGE * 3.0, 0.0, 0.0, 10.0, "materials/sprites/laserbeam.vmt", 100, 255, 100, 200, 1, SecurityInfectionDelay(), 6.0, 8.0, 1, 1.0);
	
	float Security_Ang[3];
	Security_Ang = {-90.0, 0.0, 0.0};
	int particle = ParticleEffectAt(Security_Loc, "green_steam_plume", SecurityInfectionDelay());
	TeleportEntity(particle, NULL_VECTOR, Security_Ang, NULL_VECTOR);
	
	DataPack pack;
	CreateDataTimer(SecurityInfectionDelay(), Security_DoInfectionCircleInternal, pack, TIMER_FLAG_NO_MAPCHANGE);
	pack.WriteCell(EntIndexToEntRef(entity));
}

public Action Security_DoInfectionCircleInternal(Handle timer, DataPack pack)
{
	pack.Reset();
	int entity = EntRefToEntIndex(pack.ReadCell());
	
	if(!IsValidEntity(entity))
		return Plugin_Stop;
	
	float Security_Loc[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", Security_Loc);
	Security_Loc[2] += 10.0;
	
	// Damage all enemies in range
	Explode_Logic_Custom(400.0, entity, entity, -1, Security_Loc, SECURITY_INFECTION_RANGE * 3.5, _, _, true, _, _, 1.0, SecurityHitInfection);
	
	int particle = ParticleEffectAt(Security_Loc, "green_wof_sparks", 1.5);
	float Ang[3];
	Ang[0] = -90.0;
	TeleportEntity(particle, NULL_VECTOR, Ang, NULL_VECTOR);
	
	EmitSoundToAll("weapons/cow_mangler_explode.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, Security_Loc);
	
	return Plugin_Stop;
}

void SecurityHitInfection(int entity, int victim, float damage, int weapon)
{
	if(IsValidClient(victim) && !IsInvuln(victim))
	{
		float HudY = -1.0;
		float HudX = -1.0;
		SetHudTextParams(HudX, HudY, 3.0, 50, 255, 50, 255);
		ShowHudText(victim, -1, "You have been infected by Xeno Security!");
		ClientCommand(victim, "playgamesound items/cart_explode.wav");
		
		// Apply damage over time
		int InfectionCount = 10;
		StartBleedingTimer(victim, entity, 100.0, InfectionCount, -1, DMG_SLASH, 0, 1);
		
		// Slow effect
		TF2_StunPlayer(victim, 2.0, 0.5, TF_STUNFLAG_SLOWDOWN);
	}
}
