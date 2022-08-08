
type typeResolutions
	name as string
	width as integer
	height as integer
endtype

global resolutions as typeResolutions[]

AddResolution("iPad 7th Gen", 1620, 2160)
AddResolution("iPad Air (2022)", 1640, 2360)
AddResolution("iPad Pro 11 (2021)", 1668, 2388)
AddResolution("iPhone 11", 828, 1792)
AddResolution("iPhone 11 Pro", 1125, 2436)
AddResolution("iPhone 12", 1170, 2532)
AddResolution("iPhone 12 Pro", 1170, 2532)
AddResolution("iPhone 13", 1170, 2532)
AddResolution("iPhone 13 Pro", 1170, 2532)
AddResolution("iPhone 7", 750, 1334)
AddResolution("iPhone 7 Plus", 1242, 2208)
AddResolution("iPhone 8", 750, 1334)
AddResolution("iPhone 8 Plus", 1242, 2208)
AddResolution("iPhone X", 1125, 2436)
AddResolution("iPhone XR", 828, 1792)
AddResolution("iPhone XS", 1125, 2436)
AddResolution("iPhone XS Max", 1242, 2688)
AddResolution("Samsung S10", 1440, 3040)
AddResolution("Samsung S10+", 1440, 3040)
AddResolution("Samsung S20", 1080, 2400)
AddResolution("Samsung S21", 1080, 2400)
AddResolution("Samsung S22", 1080, 2340)
AddResolution("Samsung S22+", 1080, 2340)
AddResolution("Samsung S9", 1440, 2960)
AddResolution("Samsung S9+", 1440, 2960)


function AddResolution(name as string, width as integer, height as integer)
	resolutions.length = resolutions.length + 1
	resolutions[resolutions.length].name = name
	resolutions[resolutions.length].width = width
	resolutions[resolutions.length].height = height
endfunction

function FindResolutionHeight(name as string)
	local height as integer : height = 960
	
	for i = 0 to resolutions.length
		if (lower(resolutions[i].name) = lower(name))
			height = resolutions[i].height
			exit
		endif
	next
endfunction height

function FindResolutionWidth(name as string)
	local width as integer : width = 640
	
	for i = 0 to resolutions.length
		if (lower(resolutions[i].name) = lower(name))
			width = resolutions[i].width
			exit
		endif
	next
endfunction width