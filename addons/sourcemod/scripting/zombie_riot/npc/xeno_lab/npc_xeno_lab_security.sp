#pragma semicolon 1
#pragma newdecls required

static char g_DeathSounds[][] =
{
	"mvm/giant_heavy/giant_heavy_explode.wav"
};

static char g_HurtSounds[][] =
{
	"mvm/giant_heavy/giant_heavy_pain01.wav",
	"mvm/giant_heavy/giant_heavy_pain02.wav"
};

static char g_MeleeHitSounds[][] =
{
	"weapons/fists_punch.wav"
};

static char g_MeleeAttackSounds[][] =
{
	"mvm/giant_heavy/giant_heavy_attack01.wav",
	"mvm/giant_heavy/giant_heavy_attack02.wav"
};

static char g_StompSounds[][] =
{
	"mvm/giant_heavy/giant_heavy_step01.wav",
	"mvm/giant_heavy/giant_heavy_step02.wav",
	"mvm/giant_heavy/giant_heavy_step03.wav",
	"mvm/giant_heavy/giant_heavy_step04.wav"
};

static char g_PrepareSlamSound[][] =
{
	"vo/mvm/mght/heavy_mvm_m_incoming01.mp3",
	"vo/mvm/mght/heavy_mvm_m_incoming02.mp3",
	"vo/mvm/mght/heavy_mvm_m_incoming03.mp3",
};

static char g_SlamSound[][] =
{
	"weapons/crossbow/bolt_fly4.wav",
};

#define STOMP_RANGE 350.0
#define STOMP_DAMAGE 450.0
#define STOMP_DELAY 1.5

static float f_RobotStompInfectionImmunity[MAXENTITIES];

void XenoLabSecurity_OnMapStart_NPC()
{
	NPCData data;
	strcopy(data.Name, sizeof(data.Name), "Xeno Lab Security");
	strcopy(data.Plugin, sizeof(data.Plugin), "npc_xeno_lab_security");
	strcopy(data.Icon, sizeof(data.Icon), "heavy_champ");
	data.IconCustom = false;
	data.Flags = MVM_CLASS_FLAG_MINIBOSS;
	data.Category = Type_Raid;
	data.Func = ClotSummon;
	data.Precache = ClotPrecache;
	NPC_Add(data);
}

static void ClotPrecache()
{
	for (int i = 0; i < (sizeof(g_DeathSounds)); i++) { PrecacheSound(g_DeathSounds[i]); }
	for (int i = 0; i < (sizeof(g_HurtSounds)); i++) { PrecacheSound(g_HurtSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeHitSounds)); i++) { PrecacheSound(g_MeleeHitSounds[i]); }
	for (int i = 0; i < (sizeof(g_MeleeAttackSounds)); i++) { PrecacheSound(g_MeleeAttackSounds[i]); }
	for (int i = 0; i < (sizeof(g_StompSounds)); i++) { PrecacheSound(g_StompSounds[i]); }
	for (int i = 0; i < (sizeof(g_PrepareSlamSound)); i++) { PrecacheSound(g_PrepareSlamSound[i]); }
	for (int i = 0; i < (sizeof(g_SlamSound)); i++) { PrecacheSound(g_SlamSound[i]); }
	PrecacheSound("weapons/physcannon/energy_sing_explosion2.wav");
	PrecacheSound("items/powerup_pickup_plague_infected.wav");
	PrecacheSound("mvm/mvm_tank_horn.wav");
	PrecacheModel("models/bots/heavy/bot_heavy.mdl");
	PrecacheModel("models/workshop/player/items/heavy/spr18_tsar_platinum/spr18_tsar_platinum.mdl");
	PrecacheModel("models/workshop/player/items/heavy/sum23_hog_heels/sum23_hog_heels.mdl");
	PrecacheModel("models/player/items/all_class/awes_badge.mdl");
}

static any ClotSummon(int client, float vecPos[3], float vecAng[3], int team, const char[] data)
{
	return XenoLabSecurity(vecPos, vecAng, team, data);
}

methodmap XenoLabSecurity < CClotBody
{
	property bool m_bNextAttackIsStomp
	{
		public get()
		{
			return view_as<bool>(i_TimesSummoned[this.index]);
		}
		public set(bool value)
		{
			i_TimesSummoned[this.index] = view_as<int>(value);
		}
	}
	
	public void PlayHurtSound()
	{
		if(this.m_flNextHurtSound > GetGameTime(this.index))
			return;
		
		EmitSoundToAll(g_HurtSounds[GetRandomInt(0, sizeof(g_HurtSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
		this.m_flNextHurtSound = GetGameTime(this.index) + 0.4;
	}
	
	public void PlayDeathSound()
	{
		EmitSoundToAll(g_DeathSounds[GetRandomInt(0, sizeof(g_DeathSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeSound()
	{
		EmitSoundToAll(g_MeleeAttackSounds[GetRandomInt(0, sizeof(g_MeleeAttackSounds) - 1)], this.index, SNDCHAN_VOICE, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayStompSound()
	{
		EmitSoundToAll(g_StompSounds[GetRandomInt(0, sizeof(g_StompSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayMeleeHitSound()
	{
		EmitSoundToAll(g_MeleeHitSounds[GetRandomInt(0, sizeof(g_MeleeHitSounds) - 1)], this.index, SNDCHAN_STATIC, NORMAL_ZOMBIE_SOUNDLEVEL, _, NORMAL_ZOMBIE_VOLUME);
	}
	
	public void PlayPrepareSlamSound()
	{
		int Sound = GetRandomInt(0, sizeof(g_PrepareSlamSound) - 1);
		EmitSoundToAll("mvm/mvm_tank_horn.wav", _, SNDCHAN_STATIC, 80, _, 0.65, 90);
		EmitSoundToAll(g_PrepareSlamSound[Sound], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, 90, BOSS_ZOMBIE_VOLUME);
	}
	
	public void PlaySlamSound()
	{
		int pitch = GetRandomInt(70, 80);
		EmitSoundToAll(g_SlamSound[GetRandomInt(0, sizeof(g_SlamSound) - 1)], this.index, SNDCHAN_STATIC, RAIDBOSS_ZOMBIE_SOUNDLEVEL, _, 0.7, pitch);
	}

	public XenoLabSecurity(float vecPos[3], float vecAng[3], int ally, const char[] data)
	{
		// Use player heavy model as base (like Vincent) for proper animations
		XenoLabSecurity npc = view_as<XenoLabSecurity>(CClotBody(vecPos, vecAng, "models/player/heavy.mdl", "1.55", "50000", ally, false));
		
		i_NpcWeight[npc.index] = 4;
		
		FormatEx(c_HeadPlaceAttachmentGibName[npc.index], sizeof(c_HeadPlaceAttachmentGibName[]), "head");
		
		npc.SetActivity("ACT_MP_RUN_MELEE");
		
		func_NPCDeath[npc.index] = XenoLabSecurity_NPCDeath;
		func_NPCOnTakeDamage[npc.index] = XenoLabSecurity_OnTakeDamage;
		func_NPCThink[npc.index] = XenoLabSecurity_ClotThink;

		npc.m_flNextMeleeAttack = 0.0;
		npc.m_flAttackHappens = 0.0;
		npc.m_bNextAttackIsStomp = false;
		
		npc.m_iBleedType = BLEEDTYPE_METAL;
		npc.m_iStepNoiseType = STEPSOUND_GIANT;	
		npc.m_iNpcStepVariation = STEPTYPE_ROBOT;

		npc.m_iTarget = 0;
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_flSpeed = 200.0;
		
		// Raid Boss Setup
		bool final = StrContains(data, "survival") != -1;
		if(final)
		{
			i_RaidGrantExtra[npc.index] = 1;
		}
		
		if(!IsValidEntity(RaidBossActive))
		{
			RaidBossActive = EntIndexToEntRef(npc.index);
			RaidModeTime = GetGameTime(npc.index) + 200.0;
			RaidAllowsBuildings = true;
			RaidModeScaling = MultiGlobalHealth;
			if(RaidModeScaling == 1.0)
				RaidModeScaling = 0.0;
			else
				RaidModeScaling *= 1.5;
		}
		
		b_thisNpcIsARaid[npc.index] = true;
		npc.m_bThisNpcIsABoss = true;
		npc.m_iHealthBar = 1;
		
		// Spawn message
		for(int client_check = 1; client_check <= MaxClients; client_check++)
		{
			if(IsClientInGame(client_check) && !IsFakeClient(client_check))
			{
				LookAtTarget(client_check, npc.index);
				SetGlobalTransTarget(client_check);
				ShowGameText(client_check, "item_armor", 1, "%t", "Xeno Lab Security Arrived");
			}
		}
		
		CPrintToChatAll("{green}Xeno Lab Security{default}: LAB PROTOCOL ACTIVE. EXTERMINATE ABNORMALITY.");
		
		// Make base model invisible (like Vincent)
		SetEntityRenderColor(npc.index, .a = 0);
		SetEntityRenderMode(npc.index, RENDER_TRANSCOLOR);
		
		// Equip bot heavy model as wearable
		int skin = 1;
		npc.m_iWearable1 = npc.EquipItem("head", "models/bots/heavy/bot_heavy.mdl", _, skin);
		
		// Apply green color to bot model
		int red = 0;
		int green = 255;
		int blue = 0;
		SetEntityRenderMode(npc.m_iWearable1, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable1, red, green, blue, 255);
		
		// Equip cosmetics on top
		npc.m_iWearable2 = npc.EquipItem("head", "models/workshop/player/items/heavy/spr18_tsar_platinum/spr18_tsar_platinum.mdl", _, skin);
		npc.m_iWearable3 = npc.EquipItem("head", "models/workshop/player/items/heavy/sum23_hog_heels/sum23_hog_heels.mdl", _, skin);
		npc.m_iWearable4 = npc.EquipItem("head", "models/player/items/all_class/awes_badge.mdl", _, skin);
		
		// Apply green color to all cosmetics
		SetEntityRenderMode(npc.m_iWearable2, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable2, red, green, blue, 255);
		SetEntityRenderMode(npc.m_iWearable3, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable3, red, green, blue, 255);
		SetEntityRenderMode(npc.m_iWearable4, RENDER_TRANSCOLOR);
		SetEntityRenderColor(npc.m_iWearable4, red, green, blue, 255);
		
		npc.StartPathing();
		
		return npc;
	}
}

public void XenoLabSecurity_ClotThink(int iNPC)
{
	XenoLabSecurity npc = view_as<XenoLabSecurity>(iNPC);
	float gameTime = GetGameTime(npc.index);
	
	// Raid mode time check
	if(RaidModeTime < GetGameTime())
	{
		ForcePlayerLoss();
		RaidBossActive = INVALID_ENT_REFERENCE;
		CPrintToChatAll("{green}Xeno Lab Security's lab protocol has been completed...");
		func_NPCThink[npc.index] = INVALID_FUNCTION;
		return;
	}
	
	if(npc.m_flNextDelayTime > gameTime)
		return;
	
	npc.m_flNextDelayTime = gameTime + DEFAULT_UPDATE_DELAY_FLOAT;
	npc.Update();
	
	// Update health bar for raid
	if(IsValidEntity(EntRefToEntIndex(RaidBossActive)) && RaidBossActive != EntIndexToEntRef(npc.index))
	{
		for(int EnemyLoop; EnemyLoop <= MaxClients; EnemyLoop++)
		{
			if(IsValidClient(EnemyLoop))
			{
				Calculate_And_Display_hp(EnemyLoop, npc.index, 0.0, false);	
			}	
		}
	}
	else if(EntRefToEntIndex(RaidBossActive) != npc.index && !IsEntityAlive(EntRefToEntIndex(RaidBossActive)))
	{	
		RaidBossActive = EntIndexToEntRef(npc.index);
	}

	if(npc.m_blPlayHurtAnimation)
	{
		npc.AddGesture("ACT_MP_GESTURE_FLINCH_CHEST", false);
		npc.PlayHurtSound();
		npc.m_blPlayHurtAnimation = false;
	}
	
	if(npc.m_flNextThinkTime > gameTime)
		return;
	
	npc.m_flNextThinkTime = gameTime + 0.1;

	// Handle stomp attack animation and damage
	if(npc.m_flAttackHappens)
	{
		if(npc.m_flAttackHappens < gameTime)
		{
			npc.m_flAttackHappens = 0.0;
			
			if(npc.m_iChanged_WalkCycle == 2) // Stomp attack
			{
				// Deal damage
				XenoLabSecurity_StompDamage(npc.index);
				
				// Return to normal movement
				npc.m_bisWalking = true;
				npc.m_flSpeed = 200.0;
				npc.SetActivity("ACT_MP_RUN_MELEE");
				npc.m_iChanged_WalkCycle = 0;
				npc.StartPathing();
			}
			else // Normal melee
			{
				Handle swingTrace;
				if(npc.DoSwingTrace(swingTrace, npc.m_iTarget))
				{
					int target = TR_GetEntityIndex(swingTrace);	
					
					float vecHit[3];
					TR_GetEndPosition(vecHit, swingTrace);
					
					if(IsValidEnemy(npc.index, target))
					{
						float damageDealt = 65.0;
						
						SDKHooks_TakeDamage(target, npc.index, npc.index, damageDealt, DMG_CLUB, -1, _, vecHit);
						npc.PlayMeleeHitSound();
					} 
				}
				delete swingTrace;
			}
		}
	}

	if(npc.m_flGetClosestTargetTime < gameTime)
	{
		npc.m_iTarget = GetClosestTarget(npc.index);
		npc.m_flGetClosestTargetTime = gameTime + GetRandomRetargetTime();
	}
	
	if(IsValidEnemy(npc.index, npc.m_iTarget))
	{
		float vecTarget[3]; WorldSpaceCenter(npc.m_iTarget, vecTarget);
		float VecSelfNpc[3]; WorldSpaceCenter(npc.index, VecSelfNpc);
		float flDistanceToTarget = GetVectorDistance(vecTarget, VecSelfNpc, true);
		
		// Predict their position
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

		if(npc.m_flDoingAnimation > gameTime)
		{
			// Currently doing an animation
			return;
		}

		if(flDistanceToTarget < (NORMAL_ENEMY_MELEE_RANGE_FLOAT_SQUARED * 1.25))
		{
			int Enemy_I_See;
			Enemy_I_See = Can_I_See_Enemy(npc.index, npc.m_iTarget);

			if(IsValidEnemy(npc.index, Enemy_I_See))
			{
				npc.m_iTarget = Enemy_I_See;

				if(npc.m_flNextMeleeAttack < gameTime)
				{
					// Alternate between stomp and normal melee
					if(npc.m_bNextAttackIsStomp)
					{
						// STOMP ATTACK
						npc.m_bNextAttackIsStomp = false;
						npc.m_flNextMeleeAttack = gameTime + 4.0;
						npc.m_flAttackHappens = gameTime + STOMP_DELAY;
						npc.m_flDoingAnimation = gameTime + STOMP_DELAY + 0.5;
						
						// Use sequence like Vincent does for proper animation
						npc.AddActivityViaSequence("taunt_soviet_strongarm_end");
						npc.SetCycle(0.05);
						npc.SetPlaybackRate(0.5);
						npc.m_iChanged_WalkCycle = 2;
						npc.m_bisWalking = false;
						npc.m_flSpeed = 0.0;
						npc.StopPathing();
						
						npc.PlayPrepareSlamSound();
						npc.PlayStompSound();
						
						// Summon warning circle
						float myPos[3];
						GetEntPropVector(npc.index, Prop_Data, "m_vecAbsOrigin", myPos);
						myPos[2] += 10.0;
						
						spawnRing_Vectors(myPos, STOMP_RANGE * 2.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 255, 0, 200, 1, STOMP_DELAY, 6.0, 0.1, 1);
						spawnRing_Vectors(myPos, 0.0, 0.0, 0.0, 5.0, "materials/sprites/laserbeam.vmt", 0, 255, 0, 200, 1, STOMP_DELAY, 6.0, 0.1, 1, STOMP_RANGE * 2.0);
					}
					else
					{
						// NORMAL MELEE
						npc.m_bNextAttackIsStomp = true;
						npc.m_flNextMeleeAttack = gameTime + 1.0;
						npc.m_flAttackHappens = gameTime + 0.4;
						npc.m_flDoingAnimation = gameTime + 0.8;
						
						npc.AddGesture("ACT_MP_ATTACK_STAND_MELEE");
						npc.PlayMeleeSound();
					}
				}
			}
		}
	}
	else
	{
		npc.m_flGetClosestTargetTime = 0.0;
		npc.m_iTarget = GetClosestTarget(npc.index);
	}
}

void XenoLabSecurity_StompDamage(int entity)
{
	float myPos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", myPos);
	myPos[2] += 10.0;
	
	// Visual effects
	int particle = ParticleEffectAt(myPos, "green_wof_sparks", 1.0);
	float ang[3];
	ang[0] = -90.0;
	TeleportEntity(particle, NULL_VECTOR, ang, NULL_VECTOR);
	
	EmitSoundToAll("weapons/physcannon/energy_sing_explosion2.wav", 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, myPos);
	
	XenoLabSecurity npc = view_as<XenoLabSecurity>(entity);
	npc.PlaySlamSound();
	
	// Calculate scaled damage
	float damage = STOMP_DAMAGE;
	float DamageDoExtra = MultiGlobalHealth;
	if(DamageDoExtra != 1.0)
	{
		DamageDoExtra *= 1.5;
	}
	damage *= DamageDoExtra;
	
	// Deal damage with infection effect
	Explode_Logic_Custom(damage, entity, entity, -1, myPos, STOMP_RANGE, _, _, true, _, _, 1.0, RobotStompInfection);
}

public Action XenoLabSecurity_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	XenoLabSecurity npc = view_as<XenoLabSecurity>(victim);
		
	if(attacker <= 0)
		return Plugin_Continue;
	
	if (npc.m_flHeadshotCooldown < GetGameTime(npc.index))
	{
		npc.m_flHeadshotCooldown = GetGameTime(npc.index) + DEFAULT_HURTDELAY;
		npc.m_blPlayHurtAnimation = true;
	}
	
	return Plugin_Changed;
}

public void XenoLabSecurity_NPCDeath(int entity)
{
	XenoLabSecurity npc = view_as<XenoLabSecurity>(entity);
	
	if(!npc.m_bDissapearOnDeath)
	{
		npc.PlayDeathSound();
	}
	
	// Handle raid boss death
	if(i_RaidGrantExtra[npc.index] == 1 && GameRules_GetRoundState() == RoundState_ZombieRiot)
	{
		for(int client_repat = 1; client_repat <= MaxClients; client_repat++)
		{
			if(IsClientInGame(client_repat) && GetClientTeam(client_repat) == 2 && TeutonType[client_repat] != TEUTON_WAITING)
			{
				Items_GiveNamedItem(client_repat, "Infected Circuit Board");
				CPrintToChat(client_repat, "{default}You destroyed the Xeno Security and gained: {green}''Infected Circuit Board''{default}!");
			}
		}
	}
	
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
	if(IsValidEntity(npc.m_iWearable6))
		RemoveEntity(npc.m_iWearable6);
}

void RobotStompInfection(int entity, int victim, float damage, int weapon)
{
	if(f_RobotStompInfectionImmunity[victim] < GetGameTime())
	{
		// Only infect players, not NPCs
		if(IsValidClient(victim) && !IsInvuln(victim))
		{
			f_RobotStompInfectionImmunity[victim] = GetGameTime() + 15.0;
			
			float HudY = -1.0;
			float HudX = -1.0;
			SetHudTextParams(HudX, HudY, 3.0, 50, 255, 50, 255);
			ShowHudText(victim, -1, "You have been infected by the Security's Protocol!");
			
			ClientCommand(victim, "playgamesound items/powerup_pickup_plague_infected.wav");
			
			// Apply infection: deal damage over time using TF2_Ignite for consistent damage
			TF2_IgnitePlayer(victim, victim);
			
			// Alternative: Use direct damage over time with a timer
			DataPack pack;
			CreateDataTimer(1.0, Timer_InfectionDamage, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
			pack.WriteCell(GetClientUserId(victim)); // Use userid instead of entity index
			pack.WriteCell(EntIndexToEntRef(entity));
			pack.WriteCell(15); // 15 ticks
			pack.WriteFloat(150.0); // 150 damage per tick
		}
	}
}

public Action Timer_InfectionDamage(Handle timer, DataPack pack)
{
	pack.Reset();
	int userid = pack.ReadCell();
	int victim = GetClientOfUserId(userid);
	
	if(victim == 0 || !IsClientInGame(victim) || !IsPlayerAlive(victim))
		return Plugin_Stop;
	
	int attackerRef = pack.ReadCell();
	int attacker = EntRefToEntIndex(attackerRef);
	
	if(attacker == INVALID_ENT_REFERENCE)
		attacker = 0;
	
	int ticksRemaining = pack.ReadCell();
	float damagePerTick = pack.ReadFloat();
	
	// Deal damage
	SDKHooks_TakeDamage(victim, attacker, attacker, damagePerTick, DMG_PREVENT_PHYSICS_FORCE, -1);
	
	// Show visual effect
	float victimPos[3];
	GetClientAbsOrigin(victim, victimPos);
	victimPos[2] += 50.0;
	TE_Particle("env_sawblood", victimPos, NULL_VECTOR, NULL_VECTOR, _, _, _, _, _, _, _, _, _, _, 0.0);
	
	ticksRemaining--;
	
	if(ticksRemaining <= 0)
		return Plugin_Stop;
	
	// Update pack for next iteration
	pack.Reset();
	pack.WriteCell(userid);
	pack.WriteCell(attackerRef);
	pack.WriteCell(ticksRemaining);
	pack.WriteFloat(damagePerTick);
	
	return Plugin_Continue;
}