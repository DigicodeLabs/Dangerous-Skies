
function CreateRandomCloudImages()
	cloudBump = CreateText("C")
	SetTextSize(cloudBump, 30)
	SetTextAlignment(cloudBump, 1)
	SetTextPosition(cloudBump, 50, 50)
	DrawText(cloudBump)
	
	box = CreateSprite(0)
	SetSpriteColorAlpha(box, 100)
	SetSpritePosition(box, 41, 55.5)
	SetSpriteSize(box, 20, -1)
	
	imgCloudBump = GetImage(41, 55.5, 20, GetSpriteHeight(box))
	SaveImage(imgCloudBump, "CloudBump.png")
	
	ClearScreen()

	DeleteSprite(box)
	DeleteText(cloudBump)

	cloud as integer[5, 5]
	for i = 1 to 20
		maxX = random(3, 5)
		maxY = random(3, 5)
		for y = 0 to maxY - 1
			for x = 0 to maxX - 1
				cloud[y, x] = CreateSprite(LoadImage("CloudBump.png"))
				SetSpriteSize(cloud[y, x], random(10, 20), -1)
				SetSpritePositionByOffset(cloud[y, x], 45.5 - (((maxX - 1) / 2) * 9) + (x * 9), y * 13)
				angle# = random(0, 360)
				if (y = 0 and x = 0) then angle# = 22.5 + random(0, 45)
				if (y = 0 and x > 0 and x < maxX - 1) then angle# = 67.5 + random(0, 45)
				if (y = 0 and x = maxX - 1) then angle# = 157.5 - random(0, 45)
				if (x = 0 and y > 0 and y < maxY - 1) then angle# = -22.5 + random(0, 45)
				if (x = maxX - 1 and y > 0 and y < maxY - 1) then angle# = -202.5 + random(0, 45)
				if (y = maxY - 1 and x = 0) then angle# = -22.5 - random(0, 45)
				if (y = maxY - 1 and x > 0 and x < maxX - 1) then angle# = -67.5 - random(0, 45)
				if (y = maxY - 1 and x = maxX - 1) then angle# = -157.5 + random(0, 45)
				SetSpriteColorAlpha(cloud[y, x], random(100, 150))
				if (random(0, 100) < 15) then SetSpriteColorAlpha(cloud[y, x], 0)
				SetSpriteAngle(cloud[y, x], angle#)
				DrawSprite(cloud[y, x])
			next
		next
		
		imgCloud = GetImage(GetSpriteX(cloud[0, 0]) - 20, GetSpriteY(cloud[0, 0]) - 20, GetSpriteX(cloud[maxY - 1, maxX - 1]) + GetSpriteWidth(cloud[maxY - 1, maxX - 1]) - GetSpriteX(cloud[0, 0]) + 40, GetSpriteY(cloud[maxY - 1, maxX - 1]) + GetSpriteHeight(cloud[maxY - 1, maxX - 1]) - GetSpriteY(cloud[0, 0]) + 40)
		SaveImage(imgCloud, "Cloud" + str(i) + ".png")
	
		ClearScreen()
	
		for y = 0 to maxY - 1
			for x = 0 to maxX - 1
				DeleteSprite(cloud[y, x])
			next
		next
	next
endfunction
