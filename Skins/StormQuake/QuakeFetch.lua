function Initialize()
	sErrorConfig = SKIN:GetVariable("CURRENTCONFIG")
	msWebParser = SKIN:GetMeasure("mQuakesFeed")
	iImageHeight = SKIN:GetVariable("MapHeight")
	iImageWidth = SKIN:GetVariable("MapWidth")
end -- function Initialize

function Update()
	SKIN:Bang('!DisableMeasure mQuakesLua')
	sRaw = msWebParser:GetStringValue()
	ReadFeed( sRaw )
	for i = 1, #tQuakeTitle do
		SKIN:Bang('!ShowMeter' , 'QuakeMeter'..i..'')		
		SKIN:Bang('!SetOption QuakeMeter'..i..' LeftMouseUpAction """!Execute ['..tQuakeLink[i]..']"""')
		SKIN:Bang('!SetOption', 'QuakeMeter'..i..'' , 'ImageName', '#@#images\\c.png')
		SKIN:Bang('!MoveMeter '..(Xpos[i])..' '..(Ypos[i])..' QuakeMeter'..i..'')
		SKIN:Bang('!SetOption QuakeMeter'..i..' ToolTipTitle \"'..tQuakeTitle[i]..'\"')
		sStormTipText ="Date:  "..os.date( "%d %B at %H:%M", LocalEventTime( tQuakeTime[i]) ).."\n".. "Magnitude:  "..tMagnitude[i].."\n".."Profondeur:  "..tDepth[i]
		SKIN:Bang('!SetOption QuakeMeter'..i..' ToolTipText \"'..sStormTipText..'\"')
	end
	--SKIN:Bang('!MoveMeter 5 '..(Ypos[1]+5)..' QuakeHorizontal')
	--SKIN:Bang('!MoveMeter '..(Xpos[1]+5)..' 6 QuakeVertical')
	SKIN:Bang('!SetOption MtEarthQuakes Text "[ '..#tQuakeTitle..' ] Earthquakes, Past Hour\"')
	return "Earthquakes Displayed"

end -- function Update

function ReadFeed(sRaw)	
	local	sPatternOneQuake = '.<entry><id>.-</entry>'
	local	sPatternQuakeTitle = '.-<title>M%s.--%s(.-)</title>'
	local	sPatternQuakeLink = '.-</title>.*type="text/html" href="(.-)"/><'
	local	sPatternQuakeTime = '.-Time</dt><dd>(.-) UTC'
	local	sPatternQuakeMag = '.-<title>M%s(.-)%s'
	local	sPatternQuakeDepth = '.-Depth</dt><dd>(.-)%('	
	local	sPatternLatitude = '.-<georss:point>(.-)%s'
	local	sPatternLongitude = '.-<georss:point>.-%s(.-)</georss:point>'	
	
	tQuakeTitle = {}
	tQuakeLink = {}
	tQuakeTime = {}
	tMagnitude = {}
	tDepth = {}
	Xpos = {}
	Ypos = {}
	for sItem in string.gmatch(sRaw,sPatternOneQuake) do		
			table.insert( tQuakeTitle, 	string.match(sItem, sPatternQuakeTitle)	)
			table.insert( tQuakeLink,   string.match(sItem, sPatternQuakeLink) )
			table.insert( tQuakeTime,   string.match(sItem, sPatternQuakeTime) )
			table.insert( tMagnitude,   string.match(sItem, sPatternQuakeMag) )
			table.insert( tDepth,   string.match(sItem, sPatternQuakeDepth) )
			table.insert( Xpos , math.floor( ((((   tonumber(string.match(sItem, sPatternLongitude))+390)%360)/360)*iImageWidth)-0.5) )
			table.insert( Ypos,  math.floor((((90-tonumber(string.match(sItem, sPatternLatitude) ))/180)*iImageHeight)-0.5) )
	end -- of each quake
end -- function ReadFeed
 
 function LocalEventTime(s)   -- Convert Event Time (UTC) to local time
    local Date = {}			
	local MatchTime ='(%d+)%-(%d+)%-(%d+)%s(%d+)%:(%d+)%:(%d+%.?%d*)$'	
	Date.year, Date.month, Date.day, Date.hour, Date.min, Date.sec = s:match(MatchTime)
      local UTC             = os.date('!*t')
      local LocalTime       = os.date('*t')
      local DaylightSavings = LocalTime.isdst and 3600 or 0
      local LocalOffset     = os.time(LocalTime) - os.time(UTC) + DaylightSavings
	   Date     = os.time(Date) + LocalOffset
     return Date
end
	
