function Initialize()
	sErrorConfig = SKIN:GetVariable("CURRENTCONFIG")
	msWebParserMeasure = SKIN:GetMeasure("mStormsFeed")
	iImageHeight = SKIN:GetVariable("MapHeight")
	iImageWidth = SKIN:GetVariable("MapWidth")
end -- function Initialize

function Update()
		SKIN:Bang('!DisableMeasure mStormsLua')
		sRaw = msWebParserMeasure:GetStringValue()
		bNoActiveStorms = CheckForStorms(sRaw)
		if bNoActiveStorms then
			print(sErrorConfig.." => No storms found  ***")
			SKIN:Bang('!DisableMeasure mStormsLua')
			SKIN:Bang('!SetOption MtActiveStorms Text \"- No Active Storms\"')
			return sErrorConfig.."..No active storms.."
		end
		ReadFeed(sRaw, iNumItems)
		for i = 1, iNumItems do
				if tLatitude[i] and tLongitude[i] then	
						sTitleTipText = sTitleTipText.."- "..tStormName[i].."\n"
						SKIN:Bang('!SetOption MtActiveStorms ToolTipText \"'..sTitleTipText..'\"')
						SKIN:Bang('!SetOption StormMeter'..i..' LeftMouseUpAction """['..tStormLink[i]..']"""')
						SKIN:Bang('!ShowMeter' , 'StormMeter'..i..'')		
						SKIN:Bang('!MoveMeter '..(Xpos[i]-7)..' '..(Ypos[i]-7)..' StormMeter'..i..'')					
						SKIN:Bang('!SetOption StormMeter'..i..' ToolTipTitle \"'..tStormName[i]..'\"')
						sStormTipText = "Vitesse:  "..tWind[i].."\n".."Direction:  "..tMoving[i]
						SKIN:Bang('!SetOption StormMeter'..i..' ToolTipText \"'..sStormTipText..'\"')
						SKIN:Bang('!ShowMeter' , 'StormArrow'..i..'')		
						SKIN:Bang('!MoveMeter '..(Xpos[i]-8)..'  4 StormArrow'..i..'')		
						iNumStorms = iNumStorms+1
					end		
		end
		if iNumStorms==1 then 
			SKIN:Bang('!SetOption MtActiveStorms Text "[ '..iNumStorms..' ] Active Storm\"')
			else
			SKIN:Bang('!SetOption MtActiveStorms Text "[ '..iNumStorms..' ] Active Storms\"')
		end	
		SKIN:Bang('!SetOption MtActiveStorms ToolTipTitle "Active Storms"')
		return "Storms Plotted"
end -- function Update


function CheckForStorms(sRaw, sErrorConfig)
	local bNoActiveStorms = false
	if string.match(sRaw, '<item>.-<title>(.-)%s') == 'No' 
		then 
			bNoActiveStorms = true
		else			
			sRawCounted, iNumItems = string.gsub(sRaw, '<item>',"")
			sPatternOneStorm =  '<item>.-</item>'
			sPatternStormTitle ='<title.->(.-)</title>'
			sPatternStormLink =  '<link.->(.-)</link>'
			sPatternStormWind = 'Wind.-[%s](.-)|'			
			sPatternStormMoving = 'Movement.-[%s](.-)<br'	
			sPatternLatitude = 'Location.-[%s](.-)[%s]'
			sPatternLongitude = 'Location.-[%s].-[%s](.-)[%s]'
			iNumStorms=0
			sTitleTipText = ""
		end	
	return bNoActiveStorms
end -- function CheckForStorms

function ReadFeed(sRaw, iNumItems)
	tStormName = {}	
	tStormLink = {}
	tWind = {}
	tMoving = {}
	tLatitude = {}
	tLongitude = {}
	Xpos = {}
	Ypos = {}
	local iInit = 0
	if iNumItems then
		for i = 1, (iNumItems) do
			iItemStart, iItemEnd = string.find(sRaw, sPatternOneStorm, iInit)
			sItem = string.sub(sRaw, iItemStart, iItemEnd)
			tStormName[i] = string.match(sItem, sPatternStormTitle)		
			if tStormName[i] == '' then tStormName[i] = '(No Name)' end
			tStormLink[i] = string.match(sItem, sPatternStormLink)
			if string.match(sItem, sPatternStormWind) then
				tWind[i] = string.match(sItem, sPatternStormWind)
				--
                windSpeed = tonumber(string.match(tWind[i], '(.-) MPH'))
                tWind[i] = math.round((windSpeed * 1.60934))..' KPH'
				-- fonction kph to mph
				tMoving[i] = string.match(sItem, sPatternStormMoving)
			else
				tWind[i] = ''
				tMoving[i] = ''
			end	
			tLatitude[i] = ResolveLatLong(sItem, sPatternLatitude, '[NS]' , 'N' )
			tLongitude[i] = ResolveLatLong(sItem, sPatternLongitude, '[WE]' , 'E' )							
			if tLatitude[i] and tLongitude[i] then		
					Ypos[i]=math.floor((((90-tLatitude[i] )/180)*iImageHeight)-0.5)	+10		
					Xpos[i]=math.floor( ((((tLongitude[i]+390)%360)/360)*iImageWidth)-0.5)+13
		    end	
			iInit = iItemEnd + 1
		end 
	end	
end -- function ReadFeed

function ResolveLatLong(sItem, sPattern, Cardinal, Positive)
		LatLong=  string.match(sItem, sPattern) 						
		if string.match( LatLong, Cardinal) then			
				local NS=string.match( LatLong, Cardinal)
				local Value =  string.gsub(LatLong, Cardinal, '') 	
				if NS==Positive then 
								LatLong= tonumber( Value )   
						 else LatLong= -tonumber( Value)  
				end
				if LatLong >180  then LatLong=180-(LatLong-180) end			
		else
				LatLong= tonumber( string.match(sItem, sPattern)  )
	    end 				
		return LatLong
end -- function ResolveLatLong
	
function math.round(num, idp)
   assert(tonumber(num), 'Round expects a number.')
   
   local mult = 10 ^ (idp or 0)
   if num >= 0 then
      return math.floor(num * mult + 0.5) / mult
   else
      return math.ceil(num * mult - 0.5) / mult
   end
   
end -- function KPH