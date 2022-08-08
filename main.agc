
// Project: Dangerous Skies
// Created: 22-07-31

// FONTS USED: 
//	Avenir, 
//	Lucida Grande
// SOUNDS USED: 
//	https://freesound.org/people/Mozfoo/sounds/440163/
//	https://freesound.org/people/AENHS/sounds/607049/
//	https://freesound.org/people/Mozfoo/sounds/458377/

// TODO: Add missile sound when close to plane
#renderer "Basic"

#insert "resolutions.agc"

SetClearColor(150, 230, 220)
SetErrorMode(2)
SetGenerateMipmaps(0)
SetOrientationAllowed(1, 1, 1, 1)
//SetPhysicsDebugOn()
SetPrintColor(255, 0, 0, 255)
SetRandomSeed(GetUnixTime())
SetScissor(0, 0, 0, 0)
SetSyncRate(60, 0)
SetVirtualResolution(100, 100)
SetWindowAllowResize(1)
//SetWindowSize(FindResolutionWidth("Samsung S9") * 0.3, FindResolutionHeight("Samsung S9") * 0.3, 0)
//SetWindowSize(FindResolutionHeight("Samsung S9") * 0.3, FindResolutionWidth("Samsung S9") * 0.3, 0)
SetWindowSize(800, 600, 0)
SetWindowTitle("Text Only Game Jam")
UseNewDefaultFonts(1)

Sync()

// TYPES
type typeExplosion
	sprite as integer[20]
	tween as integer[20]
endtype
type typeGame
	bestScore as integer
	bestTime as integer
	lastMissileTime# as float
	playedCount as integer
	playing as integer
	score as integer
	time as integer
	timeStarted# as float
endtype
type typeMissile
	launchedTime# as float
	markerCircle as integer
	markerPointer as integer
	sound as integer
	soundInstance as integer
	speed# as float
	sprite as integer
	trail as integer[]
	turn# as float
	tween as integer[]
endtype
type typePlane
	sound as integer
	speed# as float
	sprite as integer
	turn# as float
endtype
type typeUI
	bestTimeText as integer
	playButton as integer
	timeText as integer
endtype

// IMAGES
imgClouds as integer[20]
for i = 1 to 20
	imgClouds[i] = LoadImage("Cloud" + AddLeadingZeros(str(random(1, 20)), 2) + ".png")
next
global imgExplosion as integer : imgExplosion = LoadImage("Explosion.png") //: SetImageMagFilter(imgExplosion, 0) : SetImageMinFilter(imgExplosion, 0)
imgMarkerCircle = LoadImage("MarkerCircle.png") //: SetImageMagFilter(imgMarkerCircle, 0) : SetImageMinFilter(imgMarkerCircle, 0)
imgMarkerPointer = LoadImage("MarkerPointer.png") //: SetImageMagFilter(imgMarkerPointer, 0) : SetImageMinFilter(imgMarkerPointer, 0)
imgMissile = LoadImage("Missile.png") //: SetImageMagFilter(imgMissile, 0) : SetImageMinFilter(imgMissile, 0)
imgMissileTrail = LoadImage("MissileTrail.png") //: SetImageMagFilter(imgMissileTrail, 0) : SetImageMinFilter(imgMissileTrail, 0)
imgPlane1 = LoadImage("Plane01.png") : SetImageMagFilter(imgPlane1, 1) : SetImageMinFilter(imgPlane1, 1)
imgPlane2 = LoadImage("Plane02.png") : SetImageMagFilter(imgPlane2, 1) : SetImageMinFilter(imgPlane2, 1)
imgPlayButton = LoadImage("PlayButton.png") //: SetImageMagFilter(imgPlayButton, 0) : SetImageMinFilter(imgPlayButton, 0)

// GLOBALS
global blankExplosion as typeExplosion
global blankMissile as typeMissile
global clouds as integer[100]
global explosion as typeExplosion[0]
global explosionSound as integer : explosionSound = LoadSoundOgg("Explosion.ogg")
global game as typeGame
global missile as typeMissile[0]
global missileSound as integer : missileSound = LoadSound("Missile.wav")
global plane as typePlane
global ui as typeUI

// CREATE CLOUDS
for i = 1 to 50
	clouds[i] = CreateSprite(imgClouds[random(1, 20)])
	SetSpriteSize(clouds[i], random(20, 50), -1)
	SetSpritePositionByOffset(clouds[i], -200 + random(0, 400), -200 + random(0, 400))
	SetSpriteAngle(clouds[i], random(0, 360))
next

// CREATE PLANE
plane.sound = LoadSound("Plane.wav")
plane.speed# = 0.6
plane.sprite = CreateSprite(0)
plane.turn# = 3.1
SetSpriteSize(plane.sprite, 11, -1)
SetSpriteImage(plane.sprite, imgPlane1)
SetSpritePositionByOffset(plane.sprite, 50, 50)
//SetSpriteColor(plane.sprite, 220, 50, 50, 255)
SetSpriteColor(plane.sprite, 148, 9, 13, 255)
SetSpriteShape(plane.sprite, 3)
SetSpriteGroup(plane.sprite, 1)
AddSpriteAnimationFrame(plane.sprite, imgPlane1)
AddSpriteAnimationFrame(plane.sprite, imgPlane2)
PlaySprite(plane.sprite, 20)
PlaySound(plane.sound, 5, 1)

// CREATE UI
ui.timeText = CreateText("00:00")
SetTextSize(ui.timeText, 8)
SetTextColor(ui.timeText, 0, 0, 0, 255)
SetTextAlignment(ui.timeText, 1)
SetTextPosition(ui.timeText, 50, 0)
FixTextToScreen(ui.timeText, 1)
ui.bestTimeText = CreateText("BEST" + chr(10) + "00:00")
SetTextSize(ui.bestTimeText, 5)
SetTextColor(ui.bestTimeText, 0, 0, 0, 255)
SetTextAlignment(ui.bestTimeText, 1)
SetTextPosition(ui.bestTimeText, 50, 25 - (GetTextTotalHeight(ui.bestTimeText) / 2))
FixTextToScreen(ui.bestTimeText, 1)
ui.playButton = CreateSprite(imgPlayButton)
//SetSpriteSize(ui.playButton, 30, -1)
SetSpriteSize(ui.playButton, 10, -1)
SetSpriteColor(ui.playButton, 0, 0, 0, 255)
SetSpritePositionByOffset(ui.playButton, 50, 75)
FixSpriteToScreen(ui.playButton, 1)

SetViewZoomMode(1)
SetViewZoom(1)

game.bestTime = val(LoadSharedVariable("bestTime", "0"))
game.playing = 0
game.playedCount = 0

do	
	if (GetRawKeyPressed(13))
		StartGame()
	endif
	
	// BUTTON TOUCHES
	if (GetPointerPressed() = 1)
		spriteHit = GetSpriteHit(ScreenToWorldX(GetPointerX()), ScreenToWorldY(GetPointerY()))
	else
		if (GetPointerState() = 1)
			
		endif
		if (GetPointerReleased() = 1)
			if (spriteHit > 0)
				if (spriteHit = GetSpriteHit(ScreenToWorldX(GetPointerX()), ScreenToWorldY(GetPointerY())))
					if (spriteHit = ui.playButton and game.playing = 0)
						StartGame()
					endif
				else
					spriteHit = 0
				endif
			endif
		endif
	endif
	
	// SKY
	if (game.playing = 1 or game.playedCount = 0)
		SetViewOffset(GetViewOffsetX() + (plane.speed# * sin(GetSpriteAngle(plane.sprite))), GetViewOffsetY() - (plane.speed# * cos(GetSpriteAngle(plane.sprite))))
	endif
	
	// UI - TIME TEXT
	if (game.playing = 1)
		game.time = (timer() - game.timeStarted#)
		timeSS = mod(game.time, 60)
		timeMM = game.time / 60
		SetTextString(ui.timeText, AddLeadingZeros(str(timeMM), 2) + ":" + AddLeadingZeros(str(timeSS), 2))
		SetTextColorAlpha(ui.bestTimeText, 0)
	else
		timeSS = mod(game.time, 60)
		timeMM = game.time / 60
		SetTextString(ui.timeText, AddLeadingZeros(str(timeMM), 2) + ":" + AddLeadingZeros(str(timeSS), 2))
		bestTimeSS = mod(game.bestTime, 60)
		bestTimeMM = game.bestTime / 60
		SetTextString(ui.bestTimeText, "BEST" + chr(10) + AddLeadingZeros(str(bestTimeMM), 2) + ":" + AddLeadingZeros(str(bestTimeSS), 2))
		SetTextColorAlpha(ui.bestTimeText, 255)
	endif
	
	// UI - PLAY BUTTON
	if (game.playing = 0)
		SetSpriteVisible(ui.playButton, 1)
		if (GetSpriteHit(ScreenToWorldX(GetPointerX()), ScreenToWorldY(GetPointerY())) = ui.playButton)
			SetSpriteColor(ui.playButton, 255, 0, 0, 255)
		else
			SetSpriteColor(ui.playButton, 0, 0, 0, 255)
		endif
	else
		SetSpriteVisible(ui.playButton, 0)
	endif
	
	// CLOUDS
	for i = 1 to 50
		if (GetSpriteInScreen(clouds[i])) then continue
		repositionCloud = 0
		newX# = GetSpriteXByOffset(clouds[i])
		newY# = GetSpriteYByOffset(clouds[i])
		if (GetSpriteXByOffset(clouds[i]) - GetSpriteXByOffset(plane.sprite) < -200)
			newX# = GetSpriteXByOffset(clouds[i]) + 400
			repositionCloud = 1
		elseif (GetSpriteXByOffset(clouds[i]) - GetSpriteXByOffset(plane.sprite) > 200)
			newX# = GetSpriteXByOffset(clouds[i]) - 400
			repositionCloud = 1
		endif
		if (GetSpriteYByOffset(clouds[i]) - GetSpriteYByOffset(plane.sprite) < -200)
			newY# = GetSpriteYByOffset(clouds[i]) + 400
			repositionCloud = 1
		elseif (GetSpriteYByOffset(clouds[i]) - GetSpriteYByOffset(plane.sprite) > 200)
			newY# = GetSpriteYByOffset(clouds[i]) - 400
			repositionCloud = 1
		endif
		if (repositionCloud = 1)
			SetSpriteImage(clouds[i], imgClouds[random(1, 20)])
			SetSpriteSize(clouds[i], random(20, 50), -1)
			SetSpritePositionByOffset(clouds[i], newX#, newY#)
			SetSpriteAngle(clouds[i], random(0, 360))
		endif
	next

	// MISSILES
	if (game.playing = 1)
		baseTimeBetweenEachLaunch# = 7
		level = floor((timer() - game.timeStarted#) / 10.0)
		timeBetweenEachLaunch# = baseTimeBetweenEachLaunch# - ((level * 0.1) ^ 2)
		if (timeBetweenEachLaunch# < 3) then timeBetweenEachLaunch# = 3
		if (game.lastMissileTime# = 0 or timer() > game.lastMissileTime# + timeBetweenEachLaunch#)
			missile.insert(blankMissile, 0)
			missile[0].launchedTime# = timer()
			missile[0].markerCircle = CreateSprite(imgMarkerCircle)
			SetSpriteSize(missile[0].markerCircle, 5, -1)
			SetSpriteColor(missile[0].markerCircle, 255, 0, 0, 255)
			missile[0].markerPointer = CreateSprite(imgMarkerPointer)
			SetSpriteSize(missile[0].markerPointer, 5, -1)
			SetSpriteColor(missile[0].markerPointer, 255, 0, 0, 255)
			missile[0].sound = LoadSound("Missile.wav")
			missile[0].soundInstance = PlaySound(missile[0].sound, 0, 1)
			missile[0].speed# = 1.0
			missile[0].sprite = CreateSprite(imgMissile)
			missile[0].trail.length = 0
			missile[0].turn# = 1.9
			missile[0].tween.length = 0
			SetSpriteSize(missile[0].sprite, 2.4, -1)
			SetSpriteColor(missile[0].sprite, 0, 0, 0, 255)
			randomPosition = random(1, 4)
			if (randomPosition = 1)
				SetSpritePositionByOffset(missile[0].sprite, GetViewOffsetX() + random(5, 95), GetViewOffsetY() - 100)
			elseif (randomPosition = 2)
				SetSpritePositionByOffset(missile[0].sprite, GetViewOffsetX() + 200, GetViewOffsetY() + random(5, 95))
			elseif (randomPosition = 3)
				SetSpritePositionByOffset(missile[0].sprite, GetViewOffsetX() + random(5, 95), GetViewOffsetY() + 200)
			elseif (randomPosition = 4)
				SetSpritePositionByOffset(missile[0].sprite, GetViewOffsetX() - 100, GetViewOffsetY() + random(5, 95))
			endif
			SetSpriteAngle(missile[0].sprite, 5)
			SetSpriteShape(missile[0].sprite, 3)
			SetSpriteGroup(missile[0].sprite, 2)
			game.lastMissileTime# = timer()
		endif
	endif
	for i = 0 to missile.length - 1
		if (GetSpriteExists(missile[i].sprite))
			missile[i].trail.insert(0, 0)
			missile[i].trail[0] = CreateSprite(imgMissileTrail)
			SetSpriteSize(missile[i].trail[0], 1, -1)
			SetSpriteDepth(missile[i].trail[0], 100)
			SetSpritePositionByOffset(missile[i].trail[0], GetSpriteXByOffset(missile[i].sprite), GetSpriteYByOffset(missile[i].sprite))
			SetSpriteAngle(missile[i].trail[0], GetSpriteAngle(missile[i].sprite))
			if (missile[i].trail.length >= 101)
				DeleteSprite(missile[i].trail[100])
				missile[i].trail.length = 100
			endif
			missile[i].tween.insert(0, 0)
			missile[i].tween[0] = CreateTweenSprite(2.0)
			SetTweenSpriteAlpha(missile[i].tween[0], 255, 0, TweenLinear())
			PlayTweenSprite(missile[i].tween[0], missile[i].trail[0], 0)
			if (missile[i].tween.length >= 101)
				DeleteTween(missile[i].tween[100])
				missile[i].tween.length = 100
			endif
			
			if (game.playing = 1)
				newAngle# = ATanFull(GetSpriteXByOffset(missile[i].sprite) - GetSpriteXByOffset(plane.sprite), GetSpriteYByOffset(missile[i].sprite) - GetSpriteYByOffset(plane.sprite)) + 180
				if (newAngle# > 360) then newAngle# = newAngle# - 360
				if (newAngle# < GetSpriteAngle(missile[i].sprite))
					if (GetSpriteAngle(missile[i].sprite) - newAngle# < 180)
						newAngle# = GetSpriteAngle(missile[i].sprite) - missile[i].turn#
					else
						newAngle# = GetSpriteAngle(missile[i].sprite) + missile[i].turn#
					endif
				elseif (newAngle# > GetSpriteAngle(missile[i].sprite))
					if (newAngle# - GetSpriteAngle(missile[i].sprite) < 180)
						newAngle# = GetSpriteAngle(missile[i].sprite) + missile[i].turn#
					else
						newAngle# = GetSpriteAngle(missile[i].sprite) - missile[i].turn#
					endif
				endif
				if (newAngle# > 360) then newAngle# = newAngle# - 360
				SetSpriteAngle(missile[i].sprite, newAngle#)
			endif
			SetSpritePositionByOffset(missile[i].sprite, GetSpriteXByOffset(missile[i].sprite) + (missile[i].speed# * sin(GetSpriteAngle(missile[i].sprite))), GetSpriteYByOffset(missile[i].sprite) - (missile[i].speed# * cos(GetSpriteAngle(missile[i].sprite))))
			
			if (GetSpriteInScreen(missile[i].sprite) = 0)
				SetSpriteColorAlpha(missile[i].markerCircle, 255)
				SetSpriteColorAlpha(missile[i].markerPointer, 255)
				markerX# = GetSpriteXByOffset(missile[i].sprite)
				markerY# = GetSpriteYByOffset(missile[i].sprite)
				if (GetSpriteXByOffset(missile[i].sprite) < GetSpriteXByOffset(plane.sprite) - 50 + GetScreenBoundsLeft()) then markerX# = GetSpriteXByOffset(plane.sprite) - 50 + GetScreenBoundsLeft() + (GetSpriteWidth(missile[i].markerCircle) / 2)
				if (GetSpriteXByOffset(missile[i].sprite) > GetSpriteXByOffset(plane.sprite) + 50 - GetScreenBoundsLeft()) then markerX# = GetSpriteXByOffset(plane.sprite) + 50 - GetScreenBoundsLeft() - (GetSpriteWidth(missile[i].markerCircle) / 2)
				if (GetSpriteYByOffset(missile[i].sprite) < GetSpriteYByOffset(plane.sprite) - 50 + GetScreenBoundsTop()) then markerY# = GetSpriteYByOffset(plane.sprite) - 50 + GetScreenBoundsTop() + (GetSpriteHeight(missile[i].markerCircle) / 2)
				if (GetSpriteYByOffset(missile[i].sprite) > GetSpriteYByOffset(plane.sprite) + 50 - GetScreenBoundsTop()) then markerY# = GetSpriteYByOffset(plane.sprite) + 50 - GetScreenBoundsTop() - (GetSpriteHeight(missile[i].markerCircle) / 2)
				SetSpritePositionByOffset(missile[i].markerCircle, markerX#, markerY#)
				SetSpritePositionByOffset(missile[i].markerPointer, markerX#, markerY#)
				SetSpriteAngle(missile[i].markerPointer, ATanFull(GetSpriteXByOffset(missile[i].markerCircle) - GetSpriteXByOffset(missile[i].sprite), GetSpriteYByOffset(missile[i].markerCircle) - GetSpriteYByOffset(missile[i].sprite)) + 180)
			else
				SetSpriteColorAlpha(missile[i].markerCircle, 0)
				SetSpriteColorAlpha(missile[i].markerPointer, 0)
			endif
			
			if ((game.playing = 1 and timer() > missile[i].launchedTime# + 16.0 and GetSpriteInScreen(missile[i].sprite)) or (game.playing = 0 and GetSpriteInScreen(missile[i].sprite) = 0))
				StopSoundInstance(missile[i].soundInstance)
				StopSound(missile[i].sound)
				DeleteSound(missile[i].sound)
				DeleteSprite(missile[i].sprite)
				DeleteSprite(missile[i].markerCircle)
				DeleteSprite(missile[i].markerPointer)
			endif
		else
			deletedTweenCount = 0
			for j = 0 to missile[i].tween.length - 1
				if (GetSpriteExists(missile[i].trail[j]) and GetTweenExists(missile[i].tween[j]))
					if (GetTweenSpritePlaying(missile[i].tween[j], missile[i].trail[j]) = 0)
						inc deletedTweenCount
					endif
				endif
			next
			if (deletedTweenCount = missile[i].tween.length)
				missile.remove(i)
			endif
		endif
	next
	
	// PLANE
	if (game.playing = 1 or game.playedCount = 0)
		SetSpritePositionByOffset(plane.sprite, GetSpriteXByOffset(plane.sprite) + (plane.speed# * sin(GetSpriteAngle(plane.sprite))), GetSpriteYByOffset(plane.sprite) - (plane.speed# * cos(GetSpriteAngle(plane.sprite))))
	endif
	
	// PLANE CONTROL WITH TOUCH
	if (game.playing = 1 and GetPointerState())
		joystickAngle# = ATan2(ScreenToWorldX(GetPointerX()) - GetSpriteXByOffset(plane.sprite), ScreenToWorldY(GetPointerY()) - GetSpriteYByOffset(plane.sprite)) + 180
		joystickAngle# = abs(mod(joystickAngle# - 360, 360))
		if (abs(GetSpriteAngle(plane.sprite) - joystickAngle#) > plane.turn#)
			if (joystickAngle# < GetSpriteAngle(plane.sprite))
				if (GetSpriteAngle(plane.sprite) - joystickAngle# < 180)
					SetSpriteAngle(plane.sprite, GetSpriteAngle(plane.sprite) - plane.turn#)
				else
					SetSpriteAngle(plane.sprite, GetSpriteAngle(plane.sprite) + plane.turn#)
				endif
			elseif (joystickAngle# > GetSpriteAngle(plane.sprite))
				if (joystickAngle# - GetSpriteAngle(plane.sprite) < 180)
					SetSpriteAngle(plane.sprite, GetSpriteAngle(plane.sprite) + plane.turn#)
				else
					SetSpriteAngle(plane.sprite, GetSpriteAngle(plane.sprite) - plane.turn#)
				endif
			endif
		endif
	endif
	
	// PLANE CONTROL WITH CURSOR KEYS
	if (game.playing = 1 and GetRawKeyState(37))
		SetSpriteAngle(plane.sprite, GetSpriteAngle(plane.sprite) - plane.turn#)
	endif
	if (game.playing = 1 and GetRawKeyState(39))
		SetSpriteAngle(plane.sprite, GetSpriteAngle(plane.sprite) + plane.turn#)
	endif

	// CHECKING FOR MISSILE COLLISIONS AND DISTANCES
	if (game.playing = 1)
		for a = 0 to missile.length - 1
			if (GetSpriteExists(missile[a].sprite))
				if (GetSpriteCollision(missile[a].sprite, plane.sprite))
					StopSound(plane.sound)
					game.playing = 0
					ShowExplosion("Plane", plane.sprite)
					SetSpriteColorAlpha(plane.sprite, 0)
					StopSoundInstance(missile[a].soundInstance)
					StopSound(missile[a].sound)
					DeleteSound(missile[a].sound)
					DeleteSprite(missile[a].sprite)
					DeleteSprite(missile[a].markerCircle)
					DeleteSprite(missile[a].markerPointer)
					if (game.time > game.bestTime)
						game.bestTime = game.time
						SaveSharedVariable("bestTime", str(game.bestTime))
					endif
				endif
				for b = 0 to missile.length - 1
					if (GetSpriteExists(missile[a].sprite) and GetSpriteExists(missile[b].sprite))
						if (a <> b and GetSpriteInScreen(missile[a].sprite) and GetSpriteInScreen(missile[b].sprite))
							if (GetSpriteCollision(missile[a].sprite, missile[b].sprite))
								ShowExplosion("Missile", missile[a].sprite)
								StopSoundInstance(missile[a].soundInstance)
								StopSound(missile[a].sound)
								DeleteSound(missile[a].sound)
								DeleteSprite(missile[a].sprite)
								DeleteSprite(missile[a].markerCircle)
								DeleteSprite(missile[a].markerPointer)
								StopSoundInstance(missile[b].soundInstance)
								StopSound(missile[b].sound)
								DeleteSound(missile[b].sound)
								DeleteSprite(missile[b].sprite)
								DeleteSprite(missile[b].markerCircle)
								DeleteSprite(missile[b].markerPointer)
							endif
						endif
					endif
				next
				if (GetSpriteExists(missile[a].sprite) and GetSoundInstancePlaying(missile[a].soundInstance))
					if (GetspriteDistance(missile[a].sprite, plane.sprite) < 50)
						volume = floor(6.0 * (1.0 - (GetspriteDistance(missile[a].sprite, plane.sprite) / 50)))
						SetSoundInstanceVolume(missile[a].soundInstance, volume)
					else
						SetSoundInstanceVolume(missile[a].soundInstance, 0)
					endif
				endif
			endif
		next
	endif
	
	// DELETE EXPLOSIONS THAT HAVE FINISHED
	for a = explosion.length - 1 to 0 step - 1
		tweenEndedCount = 0
		for b = 0 to 10
			if (GetTweenSpritePlaying(explosion[a].tween[b], explosion[a].sprite[b]) = 0)
				inc tweenEndedCount
			endif
		next
		if (tweenEndedCount = 11)
			for b = 0 to 10
				DeleteSprite(explosion[a].sprite[b])
				DeleteTween(explosion[a].tween[b])
			next
			explosion.remove(a)
		endif
	next
		
	UpdateAllTweens(GetFrameTime())
    Sync()
loop

function AddLeadingZeros(string$ as string, noOfZeros as integer)
	local i as integer
	
	for i = 1 to noOfZeros
		if (len(string$) < noOfZeros)
			string$ = "0" + string$
		endif
	next
endfunction string$

function DestroyAllMissilesAndTweens()
	for a = 0 to missile.length - 1
		StopSoundInstance(missile[a].soundInstance)
		StopSound(missile[a].sound)
		DeleteSound(missile[a].sound)
		DeleteSprite(missile[a].sprite)
		DeleteSprite(missile[a].markerCircle)
		DeleteSprite(missile[a].markerPointer)
		for b = 0 to missile[a].tween.length - 1
			DeleteSprite(missile[a].trail[b])
			DeleteTween(missile[a].tween[b])
		next
	next
	missile.length = 0
	for a = 0 to explosion.length - 1
		for b = 0 to 10
			DeleteSprite(explosion[a].sprite[b])
			DeleteTween(explosion[a].tween[b])
		next
	next
	explosion.length = 0
endfunction

function ShowExplosion(explosionType$ as string, spriteID as integer)
	if (explosionType$ = "Missile")
		PlaySound(explosionSound, 7, 0)
	endif
	if (explosionType$ = "Plane")
		PlaySound(explosionSound, 10, 0)
	endif
	explosion.insert(blankExplosion, 0)
	quarterWidth = floor(GetSpriteWidth(spriteID) / 4.0)
	leftDistance# = GetSpriteX(spriteID) - GetViewOffsetX()
	topDistance# = GetSpriteY(spriteID) - GetViewOffsetY()
	for i = 0 to 10
		explosion[0].sprite[i] = CreateSprite(imgExplosion)
		SetSpritePositionByOffset(explosion[0].sprite[i], GetViewOffsetX() + leftDistance# + random(quarterWidth, quarterWidth * 3), GetViewOffsetY() + topDistance# + random(quarterWidth, quarterWidth * 3)) 
		SetSpriteAngle(explosion[0].sprite[i], random(0, 360))
		SetSpriteSize(explosion[0].sprite[i], GetSpriteWidth(plane.sprite) * (0.1 * random(1, 2)), -1)
		randomColor = random(1, 6)
		if (randomColor = 1) then SetSpriteColor(explosion[0].sprite[i], 133, 2, 0, 255)
		if (randomColor = 2) then SetSpriteColor(explosion[0].sprite[i], 204, 34, 0, 255)
		if (randomColor = 3) then SetSpriteColor(explosion[0].sprite[i], 226, 72, 0, 255)
		if (randomColor = 4) then SetSpriteColor(explosion[0].sprite[i], 255, 119, 0, 255)
		if (randomColor = 5) then SetSpriteColor(explosion[0].sprite[i], 255, 157, 0, 255)
		if (randomColor = 6) then SetSpriteColor(explosion[0].sprite[i], 255, 205, 45, 255)
		explosion[0].tween[i] = CreateTweenSprite(2)
		SetTweenSpriteSizeX(explosion[0].tween[i], GetSpriteWidth(explosion[0].sprite[i]), GetSpriteWidth(explosion[0].sprite[i]) * random(4, 8), TweenEaseOut1())
		SetTweenSpriteSizeY(explosion[0].tween[i], GetSpriteHeight(explosion[0].sprite[i]), GetSpriteHeight(explosion[0].sprite[i]) * random(4, 8), TweenEaseOut1())
		SetTweenSpriteAlpha(explosion[0].tween[i], 255, 0, TweenLinear())
		PlayTweenSprite(explosion[0].tween[i], explosion[0].sprite[i], 0)
	next
endfunction

function StartGame()
	if (game.time > game.bestTime)
		game.bestTime = game.time
		SaveSharedVariable("bestTime", str(game.bestTime))
	endif
	DestroyAllMissilesAndTweens()
	SetSpriteAngle(plane.sprite, 0)
	SetSpriteColorAlpha(plane.sprite, 255)
	if (GetSoundsPlaying(plane.sound) = 0) then PlaySound(plane.sound, 5, 1)
	game.lastMissileTime# = 0
	inc game.playedCount
	game.playing = 1
	game.time = 0
	game.timeStarted# = timer()
endfunction