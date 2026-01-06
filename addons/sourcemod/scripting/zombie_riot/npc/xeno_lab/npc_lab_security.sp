#pragma semicolon 1
#pragma newdecls required

#define LAB_SECURITY_MODEL "models/bots/heavy/bot_heavy.mdl"
#define INFECTION_BLAST_RADIUS 400.0
#define INFECTION_BLAST_DELAY 2.0

static char g_HurtSounds[][] = {
	"vo/mvm/norm/heavy_mvm_painsharp01.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp02.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp03.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp04.mp3",
	"vo/mvm/norm/heavy_mvm_painsharp05.mp3"
};

static char g_DeathSounds[][] = {
	"vo/mvm/norm/heavy_mvm_paincrticialdeath01.mp3"
};

static char g_MeleeAttackSounds[][] = {
	"ui/item_robot_arm_drop.wav"
};

static char g_MeleeHitSounds[][] = {
	"player/taunt_tank_drop.wav"
};

static char g_InfectionChargeSounds[][] = {
	"vo/mvm/norm/heavy_mvm_standonthepoint01.mp3",
	"vo/mvm/norm/heavy_mvm_standonthepoint02.mp3",
	"vo/mvm/norm/heavy_mvm_standonthepoint03.mp3"
};

static char g_PassiveSound[][] = {
	"mvm/giant_heavy/giant_heavy_loop.wav"
};

void LabSecurity_OnMapStart()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Lab Security");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_lab_security");
	strcopy(data.Icon, sizeof(data.Icon), "heavy");
	data.IconCustom = false;
	data.Flags = 0;
	data.Category = Type_Common;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	PrecacheModel(LAB_SECURITY_MODEL);
	PrecacheModel("models/player/heavy.mdl");
	PrecacheModel("models/workshop/player/items/heavy/sf14_heavy_robo_chest/sf14_heavy_robo_chest.mdl");
	
	for(int i = 0; i < sizeof(g_HurtSounds); i++)
		PrecacheSound(g_HurtSounds[i]);
	
	for(int i = 0; i < sizeof(g_DeathSounds); i++)
		PrecacheSound(g_DeathSounds[i]);
	
	for(int i = 0; i < sizeof(g_MeleeAttackSounds); i++)
		PrecacheSound(g_MeleeAttackSounds[i]);
	
	for(int i = 0; i < sizeof(g_MeleeHitSounds); i++)
		PrecacheSound(g_MeleeHitSounds[i]);
	
	for(int i = 0; i < sizeof(g_InfectionChargeSounds); i++)
		PrecacheSound(g_InfectionChargeSounds[i]);
	
	for(int i = 0; i < sizeof(g_PassiveSound); i++)
		PrecacheSound(g_PassiveSound[i]);
	
	PrecacheSound("weapons/cow_mangler_explode.wav");
	PrecacheSound("mvm/giant_heavy/giant_heavy_entrance.wav");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team)
{
	return LabSecurity(vecPos, vecAng, team);
}

methodmap LabSecurity < CClotBody
{
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 80);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90);
	}
	
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME, 90);
	}
	
	public void PlayInfectionChargeSound()
	{
		EmitSoundToAll(g_InfectionChargeSounds[GetRandomInt(0, sizeof(g_InfectionChargeSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayPassiveSound()
	{
		EmitSoundToAll(g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)], this.index, SNDCHAN_STATIC, 90, _, 0.8, 100);
	}
	
	public void StopPassiveSound()
	{
		StopSound(this.index, SNDCHAN_STATIC, g_PassiveSound[GetRandomInt(0, sizeof(g_PassiveSound) - 1)]);
	}
	
	public LabSecurity(float vecPos[3], float vecAng[3], int ally)
	{
		LabSecurity npc = view_as<LabSecurity>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.0", "500", ally));
		
		i_NpcWeight[npc.index] = 2;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_SECONDARY");
		
		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flNextRangedAttack = 0.0; // Used for infection blast cooldown
		npc.m_flNextRangedSpecialAttack = 0.0; // Used for infection blast timer
		
		func_NPCDeath[npc.index] = LabSecurity_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = LabSecurity_OnTakeDamage;
		func_NPCThink[npc.index] = LabSecurity_ClotThink;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_NORMAL;
		npc.m_iNpcStepVariation = STEPTYPE_NORMAL;
		
		// Apply robot skin
		int skin = 1;
		SetEntProp(npc.index, Prop_Send, "m_nSkin", skin);
		SetEntProp(npc.index, Prop_Send, "m_bUseClassAnimations", 1);
		
		// Make player model invisible and use robot model as wearable (Vincent's method)
		SetEntityRenderColor(npc.index, .a = 0);
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		
		npc.m_iWearable1 = npc.EquipItem("head", LAB_SECURITY_MODEL, _, skin);
		
		// Orange glow particle effect
		if(IsValidEntity(npc.m_iWearable1))
		{
			TE_SetupParticleEffect("utaunt_iconicoutline_orange_glow", PATTACH_ABSORIGIN_FOLLOW, npc.m_iWearable1);
			TE_WriteNum("m_bControlPoint1", npc.m_iWearable1);	
			TE_SendToAll();
		}
		
		// Robot chest cosmetic
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/heavy/sf14_heavy_robo_chest/sf14_heavy_robo_chest.mdl", _, skin);
		
		// Team glow with green tint for infection theme
		npc.m_iTeamGlow = TF2_CreateGlow(npc.index);
		npc.m_bTeamGlowDefault = false;
		SetVariantColor(view_as<int>({100, 255, 100, 200}));
		AcceptEntityInput(npc.m_iTeamGlow, "SetGlowColor");
		
		// Play passive loop sound
		npc.PlayPassiveSound();
		
		npc.m_flSpeed = 200.0;
		npc.StartPathing();
		
		// Spawn entrance sound
		EmitSoundToAll("mvm/giant_heavy/giant_heavy_entrance.wav", _, _, _, _, 0.8, 100);
		
		return npc;
	}
}

public void LabSecurity_ClotThink(int iNPC)
{
	LabSecurity npc = view_as<LabSecurity>(iNPC);
	
	float gameTime = GetGameTime(npc.index);
	
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	
	npc.Update();
	
	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;
	
	// Check if infection blast is charging
	if(npc.m_flNextRangedSpecialAttack > 0.0)
	{
		// Currently charging infection blast
		if(npc.m_flNextRangedSpecialAttack <= gameTime)
		{
			// Time to explode!
			LabSecurity_InfectionBlast(npc.index);
			npc.m_flNextRangedSpecialAttack = 0.0;
			npc.m_flNextRangedAttack = gameTime + 15.0; // 15 second cooldown
		}
		return; // Don't do anything else while charging
	}
	
	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + 1.0;
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; 
		WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; 
		WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		// Predict their position
		if(flDistanceToTarget < npc.GetLeadRadius())
		{
			float vPredictedPos[3];
			PredictSubjectPosition(npc, npc.m_iTarget, _, _, vPredictedPos);
			NPC_SetGoalVector(npc.index, vPredictedPos);
		}
		else
		{
			NPC_SetGoalEntity(npc.index, npc.m_iTarget);
		}
		
		npc.StartPathing();
		
		// Check if we should trigger infection blast
		if(npc.m_flNextRangedAttack < gameTime && flDistanceToTarget < (INFECTION_BLAST_RADIUS * INFECTION_BLAST_RADIUS))
		{
			// Start infection blast charge
			LabSecurity_StartInfectionBlast(npc.index);
		}
		// Normal melee attack
		else if(flDistanceToTarget < NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED && npc.m_flNextMeleeAttack < gameTime)
		{
			int Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);
			
			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;
				npc.m_flNextMeleeAttack = gameTime + 0.8;
				npc.m_flAttackHappens = gameTime + 0.4;
				npc.m_flDoingAnimation = gameTime + 0.8;
				
				npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
				npc.PlayMeleeSound();
			}
		}
		
		// Handle melee attack damage
		if(npc.m_flAttackHappens)
		{
			if(npc.m_flAttackHappens < gameTime)
			{
				npc.m_flAttackHappens = 0.0;
				
				Handle swingTrace;
				npc.FaceTowards(vecTarget, 20000.0);
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget, _, _, _, 1))
				{
					int target = TR_GetEntityIndex(swingTrace);
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(IsValidEnemy(npc.index, target))
					{
						float damage = 35.0;
						
						SDKHooks_TakeDamage(target, npc.index, npc.index, damage, DMG_CLUB, -1, _, vecHit);
						npc.PlayMeleeHitSound();
					}
				}
				delete swingTrace;
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

void LabSecurity_StartInfectionBlast(int entity)
{
	LabSecurity npc = view_as<LabSecurity>(entity);
	
	float npcPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", npcPos);
	npcPos[2] += 10.0;
	
	// Set charge timer
	npc.m_flNextRangedSpecialAttack = GetGameTime(npc.index) + INFECTION_BLAST_DELAY;
	
	// Stop moving while charging
	npc.m_flSpeed = 0.0;
	npc.StopPathing();
	
	// Visual warning rings
	spawnRing_Vectors(npcPos, INFECTION_BLAST_RADIUS * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 255, 0, 200, 1, INFECTION_BLAST_DELAY, 5.0, 0.0, 1, 1.0);
	
	// Green steam warning effect
	float angles[3] = {-90.0, 0.0, 0.0};
	int particle = ParticleEffectAt(npcPos, "green_steam_plume", INFECTION_BLAST_DELAY);
	TeleportEntity(particle, NULL_VECTOR, angles, NULL_VECTOR);
	
	// Play charge sound
	npc.PlayInfectionChargeSound();
}

void LabSecurity_InfectionBlast(int entity)
{
	LabSecurity npc = view_as<LabSecurity>(entity);
	
	float npcPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", npcPos);
	npcPos[2] += 10.0;
	
	// Explosion visual effect
	int particle = ParticleEffectAt(npcPos, "green_wof_sparks", 1.0);
	float angles[3] = {-90.0, 0.0, 0.0};
	TeleportEntity(particle, NULL_VECTOR, angles, NULL_VECTOR);
	
	// Explosion sound
	EmitSoundToAll("weapons/cow_mangler_explode.wav", entity, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, npcPos);
	
	// Deal damage in radius
	float damage = 75.0;
	Explode_Logic_Custom(damage, entity, entity, -1, npcPos, INFECTION_BLAST_RADIUS, _, _, true, _, _, 1.0, LabSecurity_InfectionHit);
	
	// Resume movement
	npc.m_flSpeed = 200.0;
	npc.StartPathing();
}

void LabSecurity_InfectionHit(int entity, int victim, float damage, int weapon)
{
	// Apply infection debuff to players
	if(IsValidClient(victim) && !IsInvuln(victim))
	{
		// Short infection - 5 ticks over 5 seconds
		TF2_AddCondition(victim, TFCond_Gas, 3.0);
		StartBleedingTimer(victim, entity, 50.0, 5, -1, DMG_TRUEDAMAGE, 0, 1);
		
		// Visual feedback
		ClientCommand(victim, "playgamesound items/powerup_pickup_plague_infected.wav");
	}
}

public Action LabSecurity_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	LabSecurity npc = view_as<LabSecurity>(victim);
	
	if(attacker <= 0)
		return Plugin_Continue;
	
	if(npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

void LabSecurity_NPCDeath(int entity)
{
	LabSecurity npc = view_as<LabSecurity>(entity);
	
	if(!npc.m_bDissapearOnDeath)
		npc.PlayDeathSound();
	
	npc.StopPassiveSound();
	
	if(IsValidEntity(npc.m_iWearable1))
		RemoveEntity(npc.m_iWearable1);
	if(IsValidEntity(npc.m_iWearable2))
		RemoveEntity(npc.m_iWearable2);
	if(IsValidEntity(npc.m_iWearable3))
		RemoveEntity(npc.m_iWearable3);
	if(IsValidEntity(npc.m_iWearable4))
		RemoveEntity(npc.m_iWearable4);
	if(IsValidEntity(npc.m_iWearable5))
		RemoveEntity(npc.m_iWearable5);
	if(IsValidEntity(npc.m_iTeamGlow))
		RemoveEntity(npc.m_iTeamGlow);
}