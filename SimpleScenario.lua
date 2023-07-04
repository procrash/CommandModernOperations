-- Enemy AI Script

function addSides()
  local sides = VP_GetSides( )
  if #sides==0 then
  print("Adding Sides")
 
  ScenEdit_AddSide({side='Friendly'})
  ScenEdit_AddSide({side='Enemy'})
 
  --[[
  ScenEdit_AddSide({side='Ukraine'})
  ScenEdit_AddSide({side='Turkey'})
  ScenEdit_AddSide({side='Neutrals'})
  ScenEdit_AddSide({side='NATO'})
  ScenEdit_AddSide({side='Russian Federation'}) 
 ]]--
 
  end
 end

 function addNovernich(side)
  print("Adding Norvenich")
  ScenEdit_ImportInst( side,"Germany/Norvenich Air Base.inst")
end

function addWoodbridge(side)
  print("Adding Woodbridge")
  ScenEdit_ImportInst( side,"UK/RAF Woodbridge 2014.inst")
end

function addEWSensorsGermany(side)
  ScenEdit_ImportInst( side,"Germany/E.W. Sites.inst")
end

function addUnitsToAirbases(installations, unittype, unitname, dbid, loadoutid)
  print("Adding Units to Airbases")
  for i,unit in ipairs(installations) do
    local unitDetails = VP_GetUnit( { guid = unit.guid } ) 

    -- if (string.find(unitDetails.type,'Facility') and unitDetails.subtype=='9001')
    if (string.find(unitDetails.type,'Group') and unitDetails.subtype=='None')  -- for these altitudes need to be defined...
      then
            -- print(unitDetails.name)
            ScenEdit_AddUnit({type =unittype, unitname =unitname, side =unitDetails.side, dbid=dbid, loadoutid=loadoutid,  base=unitDetails.guid}) 
    end
  end
end

function addUnitLatLong(side, lat, long, alt, heading)
  loadoutIds={}
  loadoutIds[0]=12283 
  loadoutIdx = 0
  dbId = 5214 -- Eurofighter
  latStr = "".. lat
  longStr = "" .. long
  loadoutId = loadoutIds[loadoutIdx]
  ScenEdit_AddUnit({type ='Air', unitname ='Eurofighter', loadoutid=loadoutId, dbid =dbId, side =side, Lat=lat,Lon=long,alt=alt, heading=heading}) 
end



function activateSensors(units)
  print("Activating Sensors")
  for i, unit in ipairs(units) do
      local unitDetails = VP_GetUnit( { guid = unit.guid } ) 
      -- print(unitDetails)
      if (unitDetails.type== 'Facility' and 
          unitDetails.subtype=='5001') then
          -- print("Activating Sensor for " .. unitDetails.name)
          ScenEdit_SetEMCON('Unit',unitDetails.guid,'Radar=Active') 
      end
  end
end


function activateSensorsAircrafts(units)
  for i,unit in ipairs(units) do
      local unitDetails = VP_GetUnit( { guid = unit.guid } ) 
      if unitDetails.type=='Aircraft' then
        ScenEdit_SetEMCON('Unit',unitDetails.guid,'Radar=Active') 
      end
  end
end


function getAircrafts(units)
  aircrafts = {}
  index = 1
  for i,unit in ipairs(units) do
      local unitDetails = VP_GetUnit( { guid = unit.guid } ) 
      if unitDetails.type=='Aircraft' then
          aircrafts[index] = unit
          index = index + 1
      end
  end
  return aircrafts
end

function launchAircraft(side, unit, launch)
  ScenEdit_SetUnit({side=side, name=unit.guid, Launch='True'})
end


function launchAllAircrafts(units)
  aircrafts = getAircrafts(units)
  for i, aircraft in ipairs(aircrafts) do
      launchAircraft('Friendly', aircraft, True)
  end
end

function split (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function RandomPosition(latitudeMin,latitudeMax,longitudeMin,longitudeMax)
	local lat_var = math.random(1,(10^13)) --random number between 1 and 10^13
	local lon_var = math.random(1,(10^13)) --random number between 1 and 10^13
	local pos_lat = math.random(latitudeMin,latitudeMax) + (lat_var/(10^13)) --latitude; 
	local pos_lon = math.random(longitudeMin,longitudeMax) + (lon_var/(10^13)) --longitude; 
	return {latitude=pos_lat,longitude=pos_lon}
end

function CreateCircleOfReferencePointsAroundPoint(point,side,numpoints,radius,prefix)
	local rpTable = {}
	local circle = World_GetCircleFromPoint({latitude=point.latitude,
		longitude=point.longitude,
		radius=radius,
		numpoints=numpoints})
	for k,v in ipairs (circle) do
		local rp = ScenEdit_AddReferencePoint({side=side,
			latitude=v.latitude,
			longitude=v.longitude,
			name=prefix..' '..k,
			highlighted=true})
		table.insert(rpTable,rp.guid)
	end
	return rpTable
end

function CreateCircleOfReferencePointsAroundUnit(unitGUID,numpoints,radius,prefix)
	local unit = ScenEdit_GetUnit({guid=unitGUID})
	local rpTable = {}
	local circle = World_GetCircleFromPoint({latitude=unit.latitude,
		longitude=unit.longitude,
		radius=radius,
		numpoints=numpoints})
	for k,v in ipairs (circle) do
		local rp = ScenEdit_AddReferencePoint({side=unit.side,
			latitude=v.latitude,
			longitude=v.longitude,
			name=prefix..' '..k,
			highlighted=true})
		table.insert(rpTable,rp.guid)
	end
	return rpTable
end

function CreateCircleOfReferencePointsAroundRP(rpGUID,rpSide,numpoints,radius,prefix)
	local unit = ScenEdit_GetReferencePoint({side=rpSide,guid=rpGUID})
	local rpTable = {}
	local circle = World_GetCircleFromPoint({latitude=unit.latitude,
		longitude=unit.longitude,
		radius=radius,
		numpoints=numpoints})
	for k,v in ipairs (circle) do
		local rp = ScenEdit_AddReferencePoint({side=unit.side,
			latitude=v.latitude,
			longitude=v.longitude,
			name=prefix..' '..k,
			highlighted=true})
		table.insert(rpTable,rp.guid)
	end
	return rpTable
end

function CircularRandomPositionMinMax(x_latitude, x_longitude, min_radius, max_radius)
	local randomisationCircle = World_GetCircleFromPoint({
		latitude=x_latitude,
		longitude=x_longitude,
		radius=math.random(min_radius,max_radius),
		numpoints = 72})
	local randomisedPoint = randomisationCircle[math.random(1,#randomisationCircle)]
    return randomisedPoint
end


function CircularRandomPosition(x_latitude, x_longitude, max_radius)
    return CircularRandomPositionMinMax(x_latitude, x_longitude, 0.1, max_radius)
end



function getID(xmlText)
    local splitted = split(xmlText, '<')
    for i, part in ipairs(splitted) do
        if string.find(part, "ID>") and not string.find(part, "/") then
            local splitted2 = split(part, ">")
            if #splitted2>1 then
                return splitted2[2]
            end 
        end
    end
    return ""
end


function getDescriptionName(xmlText)
    local splitted = split(xmlText, '<')
    for i, part in ipairs(splitted) do
        if string.find(part, "Description>") and not string.find(part, "/") then
            local splitted2 = split(part, ">")
            if #splitted2>1 then
                return splitted2[2]
            end 
        end
    end
    return ""
end


function addTrigger()
    local triggers = ScenEdit_SetTrigger( { description='RuleBasedAITrigger', mode = 'list' } )


    --print(triggers)
    for i, trigger in ipairs(triggers['triggers']) do
        local triggerName = getDescriptionName(trigger.xml)
        if #triggerName>0 then
            ScenEdit_SetTrigger({mode='remove',type='RegularTime', name=triggerName})
            -- type=ScenLoaded
            -- type=Time
            -- UnitDetected
        end
    end


    -- { triggers = { [1] = { xml = '<EventTrigger_RegularTime><ID>EC0Q1H-0HMRSB3P9Q855</ID><Description>RegularTime</Description><Interval>12</Interval></EventTrigger_RegularTime>', RegularTime = { ID = 'EC0Q1H-0HMRSB3P9Q855', Interval = '12', Description = 'RegularTime' } } } }
     -- ScenEdit_SetTrigger({mode='remove',type='RegularTime', name='trigger'})

     ScenEdit_SetTrigger({mode='add',type='RegularTime', name='RuleBasedAITrigger', interval = 12})
     -- ScenEdit_SetTrigger({mode='add',type='UnitIsDetected', name='UnitDetectionTrigger'})

end

function addAction() 
    print("Adding Actions")

    scriptText="print('Hello World')\r\nEnemyAISimple(0)"

    local actions = ScenEdit_SetAction( { mode = 'list', description='RuleBasedAIAction' } )
    for i, action in ipairs(actions.actions) do
        local actionDescription = getDescriptionName(action.xml)        
        --print("ActionDescription is " .. actionDescription)
        if #actionDescription>0 then
            print("Removing..." .. actionDescription)
            local action = ScenEdit_SetAction( { mode = 'remove', description=actionDescription } )
        end
    end

   

    local action = ScenEdit_SetAction( { mode = 'add', description='RuleBasedAIAction', type='LuaScript', ScriptText=scriptText } )

    --print(action) -- list of action settings 
end

function addEvent()
 ScenEdit_SetEvent('RuleBasedAIEvent',{mode = 'add', isActive='True', isShown='True', IsRepeatable='True', Probability=100}) 
 ScenEdit_SetEventTrigger('RuleBasedAIEvent', {mode='add', name='RuleBasedAITrigger'})
 ScenEdit_SetEventAction('RuleBasedAIEvent', {mode='add', name='RuleBasedAIAction'})

end

function removeEvents()
    local u = ScenEdit_GetEvents( 4 ) 
    for i, event in ipairs(u) do
        print("Removing event "..event.description)
        ScenEdit_SetEvent(event.description,{mode = 'remove'}) 
    end
end



function setupSimple()
  addSides()

  -- addNovernich('Friendly')
  -- addWoodbridge('Enemy')

  -- addEWSensorsGermany('Friendly')


  local friendly = VP_GetSide( { Side ='Friendly' } ) 
  local enemy = VP_GetSide( { Side ='Enemy' } ) 

  deleteAircrafts(friendly.units)
  deleteAircrafts(enemy.units)


  -- addUnitsToAirbases(friendly.units, 'Air', 'Eurofighter', 5214, 12283)
  -- addUnitsToAirbases(enemy.units, 'Air', 'Eurofighter', 5214, 12283)

  -- activateSensors(friendly.units)
  -- launchAllAircrafts(friendly.units)


  centroid = { latitude = 51, longitude = 7}
    
  for i=1,4 do
    position = CircularRandomPosition(centroid.latitude,centroid.longitude,30)
    heading = math.atan((position.longitude - centroid.longitude), (position.latitude - centroid.latitude)) * 180 / math.pi    
    addUnitLatLong('Friendly', position.latitude, position.longitude, 10000, heading )
  end

  for i=1,4 do
    position = CircularRandomPositionMinMax(centroid.latitude,centroid.longitude,30, 70)
    heading = math.atan((centroid.longitude - position.longitude), (centroid.latitude - position.latitude)) * 180 / math.pi    
    addUnitLatLong('Enemy', position.latitude, position.longitude, 10000, heading )
  end


  -- addUnitLatLong('Friendly', 51, 8, 10000, 0)
  -- addUnitLatLong('Friendly', 51, 9, 10000, 0)
  -- addUnitLatLong('Friendly', 51, 10, 10000, 0)
  aircraftsFriendly = getAircrafts(friendly.units)


  -- addUnitLatLong('Enemy', centroid.latitude, centroid.longitude, 10000, 0)
  -- addUnitLatLong('Enemy', 51.5, 8, 10000, 180)
  -- addUnitLatLong('Enemy', 51.5, 9, 10000, 180)
  -- addUnitLatLong('Enemy', 51.5, 10, 10000, 180)
  aircraftsEnemy = getAircrafts(enemy.units)

  activateSensorsAircrafts(friendly.units)
  activateSensorsAircrafts(enemy.units)

  for i, unit in ipairs(aircraftsFriendly) do
    -- setUnitCourse(unit, 51,7)
    manualAttackContact(aircraftsFriendly[i].guid, aircraftsEnemy[i].guid, 12283, 1) 
  end

  removeEvents()

  addAction()
  addTrigger()
  addEvent()

end




function setUnitCourse(unit, latitude, longitude)

  ScenEdit_SetUnit({side=unit.side, 
                   name=unit.guid, 
                   course={{longitude=longitude, latitude=latitude}}, 
                   TypeOf='ManualPlottedCourseWaypoint'})

end

function manualAttackContact(attacker_id, contact_id, weapon_id, qty, mount_id) --mount_id nil
  if mount_id == nil then
     ScenEdit_AttackContact(attacker_id, contact_id ,{mode='1', weapon=weapon_id, qty=qty})
   else
     ScenEdit_AttackContact(attacker_id, contact_id ,{mode='1', mount=mount_id, weapon=weapon_id, qty=qty})
   end
end

function auto_attack_contact(attacker_id, contact_id)
  ScenEdit_AttackContact(attacker_id, contact_id,{mode='0'})
end

function refuel_unit(side, unit_name, tanker_name)
  ScenEdit_RefuelUnit({side=side, unitname=unit_name, tanker=tanker_name})
end

function auto_refuel(side, unit_name)
  ScenEdit_RefuelUnit({side=side, unitname=unit_name})
end

-- Define the enemy AI behavior
function EnemyAISimple(time)
    contact = ScenEdit_UnitC()
    if not (contact==nil) then
        printMessage("Contact spotted " .. contact.name)
    end
end

 
-- Define the enemy AI behavior
function EnemyAI(time)
  -- Get the current scenario and time
  local currentTime = ScenEdit_CurrentTime()-time

  local friendlyUnits = VP_GetSide( { Side = "Friendly" } ).units 
  -- Loop through each friendly unit
  for i, unit in ipairs(friendlyUnits) do
    -- Check if the unit is active
    -- print(unit.guid)
    local aUnit = ScenEdit_GetUnit({guid=unit.guid})
    if unit then
      -- Perform AI actions based on the unit type
      if aUnit["type"] == "Aircraft" then
        -- Example: Aircraft units perform different tactics based on the time and threat level
        local enemyUnits = VP_GetSide( { Side = "Enemy" } ).units 
        if enemyUnits and #enemyUnits > 0 then
          -- print(currentTime)
          if currentTime < 600 then
            -- Initial phase: Perform reconnaissance
            -- print(aUnit.name)
            -- ScenEdit_SetMission("Reconnaissance", { side = "Friendly", unitname = aUnit,name, target_type = "Area", target_area = { Latitude = 40, Longitude = 30, Radius = 100 } })
            ScenEdit_SetMission("Friendly", "Reconnaissance",  { side = "Friendly", unitname = aUnit,name, target_type = "Area", target_area = { Latitude = 40, Longitude = 30, Radius = 100 } })
            -- print("OK2")

          elseif currentTime < 1200 then
            -- Mid phase: Conduct air strikes
            if unit["WeaponState"]["WeaponState"] == "RTB" then
              -- Reload weapons if returning to base
              ScenEdit_SetReloadAllWeapons({ side = "Friendly", unitname = unit["Name"] })
            else
              -- Select appropriate weapon for the target type
              if enemyUnits[1]["Type"] == "Ship" then
                ScenEdit_SetWeapon({ side = "Friendly", unitname = unit["Name"], weapon = { WeaponType = "AntiShip" } })
              elseif enemyUnits[1]["Type"] == "Submarine" then
                ScenEdit_SetWeapon({ side = "Friendly", unitname = unit["Name"], weapon = { WeaponType = "AntiSubmarine" } })
              elseif enemyUnits[1]["Type"] == "Aircraft" then
                ScenEdit_SetWeapon({ side = "Friendly", unitname = unit["Name"], weapon = { WeaponType = "AirToAir" } })
              else
                ScenEdit_SetWeapon({ side = "Friendly", unitname = unit["Name"], weapon = { WeaponType = "AirToGround" } })
              end

              -- Engage the target
              ScenEdit_SetDoctrine({ side = "Friendly", unitname = unit["Name"], doctrine = { WeaponControlStatus = "Hold" } })
              ScenEdit_SetMission("Strike", { side = "Friendly", unitname = unit["Name"], target_type = "Unit", target_unit = enemyUnits[1]["Name"] })
            end
          else
            -- Late phase: Perform air superiority
            if aUnit["fuel"][2001].current < 25 then
              print("Refuelling")
              -- Refuel if low on fuel
              ScenEdit_SetRefuelAll({ side = "Friendly", unitname = unit["Name"] })
            else
              -- Select appropriate weapon for the target type
              print(aUnit)
              local eUnit = ScenEdit_GetUnit({guid=enemyUnits[1].guid})

              if eUnit["type"] == "Aircraft" then
                ScenEdit_SetWeapon({ side = "Friendly", guid = aUnit.guid, weapon = { WeaponType = "AirToAir" } })
              else
                print("Setting weapon for target type AirToGround")
                ScenEdit_SetWeapon({ side = "Friendly", unitname = unit["Name"], weapon = { WeaponType = "AirToGround" } })
              end

              -- Engage the target
              ScenEdit_SetDoctrine({ side = "Friendly", unitname = unit["Name"], doctrine = { WeaponControlStatus = "Hold", EngagementOrder = "WeaponFree" } })
              ScenEdit_SetMission("AirSuperiority", { side = "Friendly", unitname = unit["Name"], target_type = "Area", target_area = { Latitude = 40, Longitude = 30, Radius = 100 } })
            end
          end
        end
      end
    end
  end
end


function deleteAircrafts(units)
    -- Cleanup
    for i,unit in ipairs(units) do
        local unitDetails = VP_GetUnit( { guid = unit.guid } ) 
        if unitDetails.type=='Aircraft' then
            ScenEdit_DeleteUnit({side=unitDetails.side, guid=unitDetails.guid}) 
        end
    end
end

function deleteAllUnits()
  local sides = VP_GetSides() 
   for i, side in ipairs(sides) do
        deleteAircrafts(side.units)
   end
end



function addUnitToBase(side, base)
  loadoutIds={}
  loadoutIds[0]=12283 
  loadoutIdx = 0
  dbId = 5214 -- Eurofighter
  loadoutId = loadoutIds[loadoutIdx]
  baseStr = "" .. base
  ScenEdit_AddUnit({type ='Air', unitname ='Eurofighter', loadoutid=loadoutId, dbid =dbId, side =side, base=baseStr}) 
end




function addUnitsToAirbases(installations, unittype, unitname, dbid, loadoutid)
  for i,unit in ipairs(installations) do
    local unitDetails = VP_GetUnit( { guid = unit.guid } ) 

    if ((string.find(unitDetails.type,'Group') and unitDetails.subtype=='None'))
    --if (string.find(unitDetails.type,'Facility') and unitDetails.subtype=='9001')
      -- or (string.find(unitDetails.type,'Group') and unitDetails.subtype=='None')  -- for these altitudes need to be defined...
      then
            -- print(unitDetails.name)
            ScenEdit_AddUnit({type =unittype, unitname =unitname, side =unitDetails.side, dbid=dbid, loadoutid=loadoutid,  base=unitDetails.guid}) 
    end
  end
end





function addMissions(referencePointsPatrol)
      -- Delete previsously defined missions
      local sides = VP_GetSides() 
      for i, side in ipairs(sides) do
        local missions = ScenEdit_GetMissions( side.name ) 
        for j, m in ipairs(missions) do 
            ScenEdit_DeleteMission( side.name, m.guid ) 
        end
      end 


    local mission = ScenEdit_AddMission( 'Friendly', 'Patrol', 'patrol',{ type = 'ASW', zone=referencePointsPatrol} )
    local mission = ScenEdit_AddMission( 'Friendly', 'Reconnaissance', 'patrol',{ type = 'ASW'} )
end




function addInstallations()
    -- -------------
    -- Friendly Side
    -- -------------

    side = 'Friendly'

    ScenEdit_ImportInst( side,"UkraineConflict/NATO_Aircraft.inst")
    ScenEdit_ImportInst( side,"UkraineConflict/NATO_Submarine.inst")
    ScenEdit_ImportInst( side,"UkraineConflict/NATO_Facility.inst")
    ScenEdit_ImportInst( side,"UkraineConflict/Turkey_Aircraft.inst")
    ScenEdit_ImportInst( side,"UkraineConflict/Turkey_Facility.inst")
    ScenEdit_ImportInst( side,"UkraineConflict/Ukraine_Aircraft.inst")
    ScenEdit_ImportInst( side,"UkraineConflict/Ukraine_Submarine.inst")
    ScenEdit_ImportInst( side,"UkraineConflict/Ukraine_Facility.inst")
    ScenEdit_ImportInst( side,"UkraineConflict/Neutrals_Facility.inst")
    ScenEdit_ImportInst( side,"UkraineConflict/NATO Support_Aircraft.inst")
    
    -- ----------
    -- Enemy Side
    -- ----------
    -- ScenEdit_ImportInst( "Russian Federation","UkraineConflict/RF.inst")
    side = "Enemy"
    ScenEdit_ImportInst( side,"UkraineConflict/RF_Aircraft.inst")
    ScenEdit_ImportInst( side,"UkraineConflict/RF_Submarine.inst")
    ScenEdit_ImportInst( side,"UkraineConflict/RF_Facility.inst")


end

function printMessage(msg)
  ScenEdit_SpecialMessage( 'playerside', "" .. msg, { latitude = 1.6, longitude = 3.3, time } ) 
end

function addUnit(side, lat, long, alt)
  loadoutIds={}
 loadoutIds[0]=12283 
 loadoutIdx = 0
 dbId = 5214 -- Eurofighter
 latStr = "".. lat
 longStr = "" .. long
 loadoutId = loadoutIds[loadoutIdx]
 ScenEdit_AddUnit({type ='Air', unitname ='Eurofighter', loadoutid=loadoutId, dbid =dbId, side =side, Lat=lat,Lon=long,alt=alt}) 
end



function setup()


    addSides()
    addInstallations()
    referencePointsPatrol = addZones()

    referencePointsPatrol = getZoneReferenceGuids('UkraineLandBorder')
    addMissions(referencePointsPatrol)
    
    -- ScenEdit_SetStartTime({Date="01.01.1980", Time="00.00.00", Duration="3650:0:0"}) 
    ScenEdit_SetStartTime({Date="02.20.2014", Time= "00.00.00"})
    ScenEdit_SetTime({Date= "02.20.2014", Time= "00.00.00"}) 
     
    -- 1393028842
    -- 1393028870 1s
    -- 1393028886 1 minute
    -- 1393028906 1 hour

    local friendly = VP_GetSide( { Side ='Friendly' } ) 
    local enemy = VP_GetSide( { Side ='Enemy' } ) 

    deleteAircrafts(friendly.units)
    deleteAircrafts(enemy.units)


    print("Adding Friendly units")
    addUnitsToAirbases(friendly.units, 'Air', 'MiG-29MU1 Fulcrum C', 2613, 5356)
    print("Adding Enemy units")
    addUnitsToAirbases(enemy.units, 'Air', 'MiG-29MU1 Fulcrum C', 843, 1828)



    aircraftsFriendly = getAircrafts(friendly.units)
    aircraftsEnemy = getAircrafts(enemy.units)

    for i, name in ipairs(aircraftsFriendly) do
       ScenEdit_AssignUnitToMission(name.guid, 'Patrol')
    end


    local time = ScenEdit_CurrentTime()    
    EnemyAI(time)

end

function getZoneReferenceGuids(zoneName)

  local sides = VP_GetSides() 
  referenceGUIDs = {}
  referenceCounter = 1

  -- Search in No Nav Zones
  for i, side in ipairs(sides) do
   local aSide = VP_GetSide( { Side =side.name } ) 
   for j, z in ipairs(aSide.nonavzones) do
        if z.name == zoneName then
            for k, rp in z.area do
                referenceGUIDs[referenceCounter] = rp.guid
                referenceCounter = referenceCounter + 1
            end
        end
   end

  -- Search in Exclusion Zones
   for j, z in ipairs(aSide.exclusionzones) do
        if z.name == zoneName then
            for k, rp in z.area do
                referenceGUIDs[referenceCounter] = rp.guid
                referenceCounter = referenceCounter + 1
            end
        end
   end

  -- Search in Standard Zones
   for j, z in ipairs(aSide.standardzones) do
        if z.name == zoneName then
            for k, rp in z.area do
                referenceGUIDs[referenceCounter] = rp.guid
                referenceCounter = referenceCounter + 1
            end
        end
   end

  -- Search in Custom Environment Zones
   for j, z in ipairs(aSide.customenvironmentzones) do
        if z.name == zoneName then
            for k, rp in z.area do
                referenceGUIDs[referenceCounter] = rp.guid
                referenceCounter = referenceCounter + 1
            end
        end
   end

  end

  return referenceGUIDs

end


function addZones()

 local sides = VP_GetSides() 
  local scen = VP_GetScenario( ) 
  -- print(scen)
  for i, side in ipairs(sides) do
  -- print(side)
   local aSide = VP_GetSide( { Side =side.name } ) 
    print(aSide)
   for j, z in ipairs(aSide.nonavzones) do
    ScenEdit_RemoveZone( aSide.name, 0, { Description = z.guid } ) 
   end

   for j, z in ipairs(aSide.exclusionzones) do
    ScenEdit_RemoveZone( aSide.name, 1, { Description = z.guid } ) 
   end

   -- TODO Is Number 1 correct?!?

   for j, z in ipairs(aSide.standardzones) do
    ScenEdit_RemoveZone( aSide.name, 0, { Description = z.guid } ) 
   end


   -- TODO Is Number 2 correct?!?
   for j, z in ipairs(aSide.customenvironmentzones) do
    ScenEdit_RemoveZone( aSide.name, 2, { Description = z.guid } ) 
   end


  end

  -- Ensure that all reference points are deleted...


  --print(aSide.nonavzones )
  --print(aSide.exclusionzones)
  --print(aSide.standardzones)
  --print(aSide.customenvironmentzones)

  ScenEdit_AddZone('Friendly', 0, {description='E Minefield', affects={'Ship','Submarine','Facility','Vehicle'}, area={{ latitude = '46.565588780542', longitude = '30.933339052786', name='RP-1410'},{ latitude = '46.52286021402', longitude = '30.945185754271', name='RP-1411'},{ latitude = '46.463668987', longitude = '30.999011006663', name='RP-1412'},{ latitude = '46.374213397593', longitude = '31.050859944064', name='RP-1413'},{ latitude = '46.216295998037', longitude = '31.047457213741', name='RP-1414'},{ latitude = '46.120216904435', longitude = '31.04768301016', name='RP-1415'},{ latitude = '45.959605411621', longitude = '31.133261666375', name='RP-1416'},{ latitude = '45.813292068315', longitude = '31.141139261341', name='RP-1417'},{ latitude = '45.645704802422', longitude = '31.10171620257', name='RP-1418'},{ latitude = '45.675428406648', longitude = '31.649773698346', name='RP-1419'},{ latitude = '46.177188996515', longitude = '31.606304453213', name='RP-1420'},{ latitude = '46.443337011468', longitude = '31.448882126975', name='RP-1421'},{ latitude = '46.604258384183', longitude = '31.263092669104', name='RP-1422'}}, affects={'Ship','Submarine','Facility','Vehicle'}})
  ScenEdit_AddZone('Friendly', 0, {description='W Minefield', affects={'Ship','Submarine','Facility','Vehicle'}, area={{ latitude = '46.245739919139', longitude = '30.663989306396', name='RP-1423'},{ latitude = '46.221374436553', longitude = '30.776842471879', name='RP-1424'},{ latitude = '46.127103923303', longitude = '30.814715967581', name='RP-1425'},{ latitude = '45.986351786191', longitude = '30.860421541636', name='RP-1426'},{ latitude = '45.904922213963', longitude = '30.842352165818', name='RP-1427'},{ latitude = '45.805742578391', longitude = '30.86275892453', name='RP-1428'},{ latitude = '45.715205132087', longitude = '30.802167409681', name='RP-1429'},{ latitude = '45.80342763096', longitude = '30.320385551774', name='RP-1430'}}, affects={'Ship','Submarine','Facility','Vehicle'}})
  ScenEdit_AddZone('Friendly', 0, {description='NATO Ukraine / RF NNZ', affects={'Aircraft','Ship','Submarine','Facility'}, area={{ latitude = '47.010362019047', longitude = '32.394749274241', name='RP-1453'},{ latitude = '47.458625239884', longitude = '31.781339171941', name='RP-1454'},{ latitude = '46.882727456327', longitude = '29.894387699925', name='RP-1455'},{ latitude = '46.981159573105', longitude = '29.085880343832', name='RP-1456'},{ latitude = '47.918259663186', longitude = '28.268129392445', name='RP-1457'},{ latitude = '48.544353393129', longitude = '26.943258898277', name='RP-1458'},{ latitude = '48.028423129025', longitude = '24.808518752237', name='RP-1459'},{ latitude = '48.382960989943', longitude = '22.702400488047', name='RP-1460'},{ latitude = '49.615697432468', longitude = '22.893257823305', name='RP-1461'},{ latitude = '69.126271848604', longitude = '11.13867267612', name='RP-1462'},{ latitude = '71.91163111296', longitude = '83.68689772737', name='RP-1463'},{ latitude = '61.672363158034', longitude = '85.924235018367', name='RP-1464'},{ latitude = '42.96064189271', longitude = '78.065313573797', name='RP-1465'},{ latitude = '19.365733826591', longitude = '63.206170679139', name='RP-1466'},{ latitude = '22.602527365435', longitude = '52.708576286203', name='RP-1467'},{ latitude = '28.606921973536', longitude = '44.331843246461', name='RP-1468'},{ latitude = '34.820135165408', longitude = '31.734983273978', name='RP-1469'},{ latitude = '39.89137335428', longitude = '37.573030275752', name='RP-1470'},{ latitude = '44.626419969139', longitude = '37.414550294208', name='RP-1471'},{ latitude = '44.975971258461', longitude = '36.32599652821', name='RP-1472'},{ latitude = '44.970965986151', longitude = '35.840572861986', name='RP-1473'},{ latitude = '45.23852931707', longitude = '35.67448074233', name='RP-1474'},{ latitude = '45.576478711681', longitude = '35.293410763052', name='RP-1475'},{ latitude = '46.139176653006', longitude = '34.84992927934', name='RP-1476'},{ latitude = '46.187747535578', longitude = '33.433581466696', name='RP-1477'},{ latitude = '46.687378641536', longitude = '32.841168270251', name='RP-1478'}}, affects={'Aircraft','Ship','Submarine','Facility'}})
  ScenEdit_AddZone('Friendly', 0, {description='Snake Island NNZ', affects={'Aircraft','Ship','Facility','Vehicle'}, area={{ latitude = '45.483344486003', longitude = '29.929975545296', name='Snake Island RP1'},{ latitude = '45.432694762754', longitude = '30.508705251573', name='Snake Island RP2'},{ latitude = '45.101565267192', longitude = '30.522521652134', name='Snake NNZ RP3'},{ latitude = '45.078821925819', longitude = '29.923548524578', name='Snake Island RP4'}}, affects={'Aircraft','Ship','Facility','Vehicle'}})
  ScenEdit_AddZone('Friendly', 0, {description='NATO Crimea NNZ', affects={'Aircraft','Ship','Submarine','Facility'}, area={{ latitude = '44.181226114922', longitude = '32.996578598886', name='RP-5369'},{ latitude = '45.414034714575', longitude = '32.048519527416', name='RP-5370'},{ latitude = '46.211590547787', longitude = '31.564208568586', name='RP-5371'},{ latitude = '47.10989779778', longitude = '30.587633759726', name='RP-5372'},{ latitude = '47.480646886245', longitude = '31.789639540567', name='RP-5373'},{ latitude = '46.20408599332', longitude = '33.443819241869', name='RP-5374'},{ latitude = '46.146892979014', longitude = '34.832853634784', name='RP-5375'},{ latitude = '45.05931612093', longitude = '36.441549431843', name='RP-5376'},{ latitude = '44.428741809994', longitude = '37.90955372738', name='RP-5377'},{ latitude = '43.566639201712', longitude = '36.037389330051', name='RP-5378'}}, affects={'Aircraft','Ship','Submarine','Facility'}})
  ScenEdit_AddZone('Friendly', 0, {description='Dardanelles Strait NNZ', affects={'Ship','Submarine'}, area={{ latitude = '40.504750520141', longitude = '26.753019369577', name='RP-5515'},{ latitude = '40.327878320153', longitude = '26.757598574619', name='RP-5516'},{ latitude = '39.91204968432', longitude = '26.164541063314', name='RP-5517'},{ latitude = '40.082369248543', longitude = '26.169433209524', name='RP-5518'}}, affects={'Ship','Submarine'}})
  ScenEdit_AddZone('Friendly', 0, {description='Turkey NE NNZ', affects={'Aircraft','Ship','Submarine','Facility'}, area={{ latitude = '45.509225589722', longitude = '29.642838533427', name='RP-1810'},{ latitude = '45.021134370229', longitude = '29.765034604318', name='RP-1811'},{ latitude = '44.259140152366', longitude = '33.475133367546', name='RP-1812'},{ latitude = '43.620017964984', longitude = '36.032888988294', name='RP-1813'},{ latitude = '41.718139200082', longitude = '41.602833987355', name='RP-1814'},{ latitude = '41.692786875688', longitude = '42.850077883998', name='RP-1815'},{ latitude = '41.33157803096', longitude = '43.64061880858', name='RP-1816'},{ latitude = '41.516187534521', longitude = '45.319093206457', name='RP-1817'},{ latitude = '41.646535015708', longitude = '48.685955661952', name='RP-1818'},{ latitude = '38.867371480586', longitude = '46.850040197359', name='RP-1819'},{ latitude = '33.503618584842', longitude = '47.047214663271', name='RP-1820'},{ latitude = '15.233444330613', longitude = '71.418976265293', name='RP-1821'},{ latitude = '76.472659294417', longitude = '94.468873367479', name='RP-1822'},{ latitude = '70.794840336695', longitude = '26.094991842377', name='RP-1823'},{ latitude = '54.773702513947', longitude = '19.465229331904', name='RP-1824'},{ latitude = '48.368940278614', longitude = '20.817539087727', name='RP-1825'},{ latitude = '43.861079692255', longitude = '22.677727197688', name='RP-1826'},{ latitude = '43.725625114253', longitude = '28.561634684258', name='RP-1827'}}, affects={'Aircraft','Ship','Submarine','Facility'}})
  ScenEdit_AddZone('Friendly', 0, {description='E MF', affects={'Ship','Submarine','Facility','Vehicle'}, area={{ latitude = '46.543140544415', longitude = '30.94438961442', name='RP-1435'},{ latitude = '46.446243737711', longitude = '31.0155053818', name='RP-1436'},{ latitude = '46.226052084095', longitude = '31.067481329705', name='RP-1437'},{ latitude = '46.112502118616', longitude = '31.06029411979', name='RP-1438'},{ latitude = '45.944494367098', longitude = '31.14979439948', name='RP-1439'},{ latitude = '45.790685903351', longitude = '31.159397297891', name='RP-1440'},{ latitude = '45.68243518571', longitude = '31.246544068982', name='RP-1441'},{ latitude = '45.653700876138', longitude = '31.542178290448', name='RP-1442'},{ latitude = '45.755857118331', longitude = '31.644404668476', name='RP-1443'},{ latitude = '46.203920846351', longitude = '31.621022030638', name='RP-1444'},{ latitude = '46.588210075909', longitude = '31.487033109519', name='RP-1445'}}, affects={'Ship','Submarine','Facility','Vehicle'}})
  ScenEdit_AddZone('Friendly', 0, {description='W MF', affects={'Ship','Submarine','Facility','Vehicle'}, area={{ latitude = '46.240736493808', longitude = '30.740878834164', name='RP-1446'},{ latitude = '46.080929555501', longitude = '30.529220810165', name='RP-1447'},{ latitude = '45.791687924527', longitude = '30.329591375663', name='RP-1448'},{ latitude = '45.721818327851', longitude = '30.817989315861', name='RP-1449'},{ latitude = '45.809177867838', longitude = '30.862887396164', name='RP-1450'},{ latitude = '46.010498915812', longitude = '30.868078801443', name='RP-1451'},{ latitude = '46.183713410541', longitude = '30.80672232916', name='RP-1452'}}, affects={'Ship','Submarine','Facility','Vehicle'}})
  ScenEdit_AddZone('Enemy', 0, {description='E Minefield', affects={'Ship','Submarine'}, area={{ latitude = '46.545834830374', longitude = '30.850629389332', name='RP-1388'},{ latitude = '46.596408203099', longitude = '31.320386224263', name='RP-1389'},{ latitude = '46.384242061495', longitude = '31.398331961281', name='RP-1390'},{ latitude = '46.248168270255', longitude = '31.435829176586', name='RP-1391'},{ latitude = '46.201412299803', longitude = '31.604534946048', name='RP-1392'},{ latitude = '45.901217339856', longitude = '31.624788817955', name='RP-1393'},{ latitude = '45.703454246105', longitude = '31.633264340102', name='RP-1394'},{ latitude = '45.618691179826', longitude = '31.552054218025', name='RP-1395'},{ latitude = '45.642105118225', longitude = '31.115039294994', name='RP-1396'},{ latitude = '45.810516979018', longitude = '31.141225230431', name='RP-1397'},{ latitude = '45.95715459617', longitude = '31.058682883504', name='RP-1398'},{ latitude = '46.130273588706', longitude = '31.041316398718', name='RP-1399'},{ latitude = '46.45947838878', longitude = '31.024122680301', name='RP-1400'}}, affects={'Ship','Submarine'}})
  ScenEdit_AddZone('Enemy', 0, {description='W Minefield', affects={'Ship','Submarine'}, area={{ latitude = '46.548995351007', longitude = '30.66541040238', name='RP-1401'},{ latitude = '46.455952748052', longitude = '30.600981641805', name='RP-1402'},{ latitude = '46.15161890659', longitude = '30.510188178654', name='RP-1403'},{ latitude = '45.778880052972', longitude = '30.345416500064', name='RP-1404'},{ latitude = '45.746441499255', longitude = '30.636764301993', name='RP-1405'},{ latitude = '45.747757190532', longitude = '30.856774272987', name='RP-1406'},{ latitude = '45.979359001748', longitude = '30.86722914274', name='RP-1407'},{ latitude = '46.045286345251', longitude = '30.813858236168', name='RP-1408'},{ latitude = '46.406174225582', longitude = '30.81213908624', name='RP-1409'}}, affects={'Ship','Submarine'}})
  ScenEdit_AddZone('Enemy', 0, {description='RF Turkey NNZ', affects={'Aircraft','Ship','Submarine','Facility'}, area={{ latitude = '35.905255129924', longitude = '36.162646314794', name='RP-2950'},{ latitude = '35.973062925539', longitude = '35.899890929243', name='RP-2951'},{ latitude = '36.303541853372', longitude = '35.763848046226', name='RP-2952'},{ latitude = '36.518596858504', longitude = '35.727056350399', name='RP-2953'},{ latitude = '36.494155414945', longitude = '35.286214953091', name='RP-2954'},{ latitude = '35.908241928195', longitude = '33.091160488051', name='RP-2955'},{ latitude = '36.517287153688', longitude = '31.025669529571', name='RP-2956'},{ latitude = '35.833112213495', longitude = '30.370129047946', name='RP-2957'},{ latitude = '36.349166367846', longitude = '28.318560376247', name='RP-2958'},{ latitude = '36.67082286469', longitude = '27.091069392464', name='RP-2959'},{ latitude = '38.421533569515', longitude = '26.237050226259', name='RP-2960'},{ latitude = '41.291543487417', longitude = '24.765561691527', name='RP-2961'},{ latitude = '42.066445364306', longitude = '27.18326914424', name='RP-2962'},{ latitude = '41.28402944729', longitude = '30.421946594009', name='RP-2963'},{ latitude = '42.036830329064', longitude = '33.386214599194', name='RP-2964'},{ latitude = '42.19074587444', longitude = '34.838509089893', name='RP-2965'},{ latitude = '41.669639058474', longitude = '38.046229437464', name='RP-2966'},{ latitude = '41.466742057853', longitude = '41.485324360726', name='RP-2967'},{ latitude = '41.412990215076', longitude = '43.318052690518', name='RP-2968'},{ latitude = '39.777451457636', longitude = '44.576867412829', name='RP-2969'},{ latitude = '37.091099571404', longitude = '44.710360265019', name='RP-2970'},{ latitude = '37.131886210486', longitude = '42.356531531151', name='RP-2971'},{ latitude = '36.789834815094', longitude = '38.733349986053', name='RP-2972'},{ latitude = '36.836690536812', longitude = '36.660206272562', name='RP-2973'}}, affects={'Aircraft','Ship','Submarine','Facility'}})
  ScenEdit_AddZone('Enemy', 0, {description='Cyprus NNZ', affects={'Aircraft','Ship','Submarine','Facility'}, area={{ latitude = '35.745836418037', longitude = '34.538905610663', name='RP-2974'},{ latitude = '35.446403935041', longitude = '33.728883076227', name='RP-2975'},{ latitude = '35.44872951936', longitude = '32.878038752572', name='RP-2976'},{ latitude = '35.262596763999', longitude = '32.535040513513', name='RP-2977'},{ latitude = '35.115463096585', longitude = '32.186699285514', name='RP-2978'},{ latitude = '34.468196661656', longitude = '32.475927886388', name='RP-2979'},{ latitude = '34.547645154658', longitude = '33.12639180261', name='RP-2980'},{ latitude = '34.936768354149', longitude = '34.139642320418', name='RP-2981'},{ latitude = '35.647224678687', longitude = '34.679536455149', name='RP-2982'}}, affects={'Aircraft','Ship','Submarine','Facility'}})
  ScenEdit_AddZone('Enemy', 0, {description='RF Europe NNZ', affects={'Aircraft','Ship','Submarine','Facility'}, area={{ latitude = '45.194367868263', longitude = '29.753839381796', name='RP-3041'},{ latitude = '44.772909246335', longitude = '29.66171958907', name='RP-3042'},{ latitude = '44.574856926324', longitude = '29.030720723164', name='RP-3043'},{ latitude = '43.706014559604', longitude = '28.648802917404', name='RP-3044'},{ latitude = '43.289030502261', longitude = '28.478095206623', name='RP-3045'},{ latitude = '42.014999432432', longitude = '27.959448474795', name='RP-3046'},{ latitude = '41.875514023868', longitude = '26.2545695281', name='RP-3047'},{ latitude = '36.652449336661', longitude = '15.14302149289', name='RP-3048'},{ latitude = '35.492263070769', longitude = '-5.886688183903', name='RP-3049'},{ latitude = '62.488716148503', longitude = '-6.4336988116288', name='RP-3050'},{ latitude = '69.72134118534', longitude = '28.241577847386', name='RP-3051'},{ latitude = '64.621180294001', longitude = '29.124992173361', name='RP-3052'},{ latitude = '62.377517655444', longitude = '30.749215081746', name='RP-3053'},{ latitude = '60.605005787798', longitude = '27.17656452909', name='RP-3054'},{ latitude = '57.874062864829', longitude = '27.364522190315', name='RP-3055'},{ latitude = '56.090665133105', longitude = '27.532478707397', name='RP-3056'},{ latitude = '55.72107625695', longitude = '26.391028671769', name='RP-3057'},{ latitude = '55.125515645716', longitude = '25.864541801627', name='RP-3058'},{ latitude = '54.436591054542', longitude = '25.222786434107', name='RP-3059'},{ latitude = '54.053410716725', longitude = '23.420080599466', name='RP-3060'},{ latitude = '52.779192587916', longitude = '23.752159305074', name='RP-3061'},{ latitude = '52.234658013063', longitude = '23.007784750708', name='RP-3062'},{ latitude = '51.557318858545', longitude = '23.728573574727', name='RP-3063'},{ latitude = '51.496276643241', longitude = '26.984195551195', name='RP-3064'},{ latitude = '51.028831175846', longitude = '33.053591764884', name='RP-3065'},{ latitude = '48.511929896473', longitude = '33.461170263547', name='RP-3066'},{ latitude = '47.871504150245', longitude = '31.144590705888', name='RP-3067'},{ latitude = '48.154607089017', longitude = '28.476845342725', name='RP-3068'},{ latitude = '48.286537315324', longitude = '26.463217670261', name='RP-3069'},{ latitude = '46.123702675946', longitude = '27.555714753368', name='RP-3070'}}, affects={'Aircraft','Ship','Submarine','Facility'}})
  ScenEdit_AddZone('Enemy', 1, {description='RF', affects={'Aircraft','Ship','Submarine'}, area={{ latitude = '46.553493776219', longitude = '31.504212046495', name='RP-4206'},{ latitude = '46.301775317409', longitude = '31.529330653461', name='RP-4207'},{ latitude = '46.156478041991', longitude = '31.663319962073', name='RP-4208'},{ latitude = '45.977828464787', longitude = '32.34020454654', name='RP-4209'},{ latitude = '45.811007172046', longitude = '32.62517137981', name='RP-4210'},{ latitude = '45.614499709942', longitude = '32.445942036667', name='RP-4211'},{ latitude = '45.351039426189', longitude = '32.292360561518', name='RP-4212'},{ latitude = '44.978309820931', longitude = '33.295042797767', name='RP-4213'},{ latitude = '44.538046872779', longitude = '33.134360558026', name='RP-4214'},{ latitude = '44.187659032381', longitude = '33.939199975865', name='RP-4215'},{ latitude = '44.699114135144', longitude = '35.958858158503', name='RP-4216'},{ latitude = '44.322468821362', longitude = '37.487032140878', name='RP-4217'},{ latitude = '42.74226943064', longitude = '40.682759944199', name='RP-4218'},{ latitude = '41.022635618089', longitude = '49.231487730492', name='RP-4219'},{ latitude = '52.940330498868', longitude = '50.277352360072', name='RP-4220'},{ latitude = '53.018917772893', longitude = '35.028051954106', name='RP-4221'},{ latitude = '51.453705900575', longitude = '34.461088431534', name='RP-4222'},{ latitude = '50.430589743123', longitude = '35.408155447006', name='RP-4223'},{ latitude = '49.97445356017', longitude = '35.107066610419', name='RP-4224'},{ latitude = '49.316897311183', longitude = '34.715509485933', name='RP-4225'},{ latitude = '48.497393302071', longitude = '33.437753645645', name='RP-4226'},{ latitude = '47.306812996036', longitude = '31.416035399788', name='RP-4227'},{ latitude = '46.992413493267', longitude = '31.434445371547', name='RP-4228'}}, markas='Hostile', affects={'Aircraft','Ship','Submarine'}})
  ScenEdit_AddZone('Enemy', 1, {description='RF 30 SSD', affects={'Aircraft','Ship'}, area={{ latitude = '45.935882509967', longitude = '32.168891084486', name='RP-4765'},{ latitude = '45.899827616948', longitude = '32.637105190882', name='RP-4766'},{ latitude = '45.580191101692', longitude = '32.53766439743', name='RP-4767'},{ latitude = '45.666135505048', longitude = '32.006184414932', name='RP-4768'}}, markas='Hostile', affects={'Aircraft','Ship'}})
  ScenEdit_AddZone('Enemy', 1, {description='Snake Island', affects={'Aircraft','Ship','Submarine','Facility'}, area={{ latitude = '45.343009183729', longitude = '30.069224100913', name='RP-4775'},{ latitude = '45.343066649716', longitude = '30.337165061054', name='RP-4776'},{ latitude = '45.171877927366', longitude = '30.33685458974', name='RP-4777'},{ latitude = '45.171799683086', longitude = '30.069709222184', name='RP-4778'}}, markas='Unfriendly', affects={'Aircraft','Ship','Submarine','Facility'}})

  -- Ukraine Border
  
  -- Don't use 2 as this environment zone is not convertible
  ScenEdit_AddZone('Friendly', 1, {description='UkraineLandBorder', area={{ latitude = '49.021671154816', longitude = '22.880830040362', name='RP-2'},{ latitude = '49.096875917633', longitude = '22.908475582396', name='RP-3'},{ latitude = '49.167730234725', longitude = '22.737953479173', name='RP-4'},{ latitude = '49.323817430655', longitude = '22.740232398163', name='RP-5'},{ latitude = '49.525732703823', longitude = '22.666137709056', name='RP-6'},{ latitude = '50.309439090225', longitude = '23.633647109181', name='RP-7'},{ latitude = '50.427099138882', longitude = '23.81974411172', name='RP-8'},{ latitude = '50.446256074711', longitude = '24.023082090123', name='RP-9'},{ latitude = '50.446256074711', longitude = '24.023082090123', name='RP-10'},{ latitude = '50.631848171369', longitude = '24.099403206658', name='RP-11'},{ latitude = '50.799053543212', longitude = '23.993042260098', name='RP-12'},{ latitude = '50.841910437832', longitude = '24.077265739777', name='RP-13'},{ latitude = '50.955320316534', longitude = '23.994962745709', name='RP-14'},{ latitude = '51.293269819526', longitude = '23.668155692015', name='RP-15'},{ latitude = '51.61202828801', longitude = '23.645911956361', name='RP-16'},{ latitude = '51.651643980555', longitude = '23.875043763857', name='RP-17'},{ latitude = '51.59469171366', longitude = '24.055018616468', name='RP-18'},{ latitude = '51.729245834015', longitude = '24.322214968453', name='RP-19'},{ latitude = '51.928120000349', longitude = '24.432363423812', name='RP-20'},{ latitude = '51.903543377251', longitude = '25.007197752409', name='RP-21'},{ latitude = '51.981326354149', longitude = '25.257414333423', name='RP-22'},{ latitude = '51.902960706273', longitude = '25.523980082803', name='RP-23'},{ latitude = '51.919342096221', longitude = '25.85289998093', name='RP-24'},{ latitude = '51.759705197811', longitude = '27.210792140165', name='RP-25'},{ latitude = '51.567631760573', longitude = '27.709370408978', name='RP-26'},{ latitude = '51.649924193001', longitude = '28.278760846507', name='RP-27'},{ latitude = '51.446120320355', longitude = '28.79481049211', name='RP-28'},{ latitude = '51.622573291512', longitude = '29.153713880479', name='RP-29'},{ latitude = '51.399901138748', longitude = '29.426242677845', name='RP-30'},{ latitude = '51.465174234455', longitude = '30.078826319057', name='RP-31'},{ latitude = '51.451487467043', longitude = '30.320707251816', name='RP-32'},{ latitude = '51.266395961007', longitude = '30.581958163855', name='RP-33'},{ latitude = '51.573154066733', longitude = '30.574626545365', name='RP-34'},{ latitude = '52.078164242584', longitude = '31.003430902053', name='RP-35'},{ latitude = '52.121795028566', longitude = '31.530337979048', name='RP-36'},{ latitude = '52.047178080721', longitude = '32.047052013998', name='RP-37'},{ latitude = '52.192385130742', longitude = '32.365963305339', name='RP-38'},{ latitude = '52.340821052203', longitude = '32.444989679157', name='RP-39'},{ latitude = '52.266332650047', longitude = '32.888576093531', name='RP-40'},{ latitude = '52.324236884969', longitude = '33.569553217967', name='RP-41'},{ latitude = '52.318794840825', longitude = '33.949860817515', name='RP-42'},{ latitude = '51.890736907782', longitude = '34.253758028488', name='RP-43'},{ latitude = '51.739431229815', longitude = '34.452934785179', name='RP-44'},{ latitude = '51.661725722826', longitude = '34.118114950349', name='RP-45'},{ latitude = '51.465097309283', longitude = '34.261672081169', name='RP-46'},{ latitude = '51.261482762525', longitude = '34.286187639578', name='RP-47'},{ latitude = '51.192918751098', longitude = '35.106446733761', name='RP-48'},{ latitude = '51.012016326878', longitude = '35.373477819949', name='RP-49'},{ latitude = '50.677818795445', longitude = '35.504754751848', name='RP-50'},{ latitude = '50.350612006698', longitude = '35.69927989195', name='RP-51'},{ latitude = '50.438746693522', longitude = '36.181926101147', name='RP-52'},{ latitude = '50.255347834893', longitude = '36.589411536972', name='RP-53'},{ latitude = '50.412715664075', longitude = '37.435279687662', name='RP-54'},{ latitude = '49.938821846155', longitude = '38.045465337918', name='RP-55'},{ latitude = '50.051784588878', longitude = '38.335200123251', name='RP-56'},{ latitude = '49.91124288202', longitude = '38.810021022386', name='RP-57'},{ latitude = '49.714915271908', longitude = '39.400068952105', name='RP-58'},{ latitude = '49.586107238469', longitude = '40.065938064279', name='RP-59'},{ latitude = '49.289741764256', longitude = '40.186042666412', name='RP-60'},{ latitude = '49.048146005641', longitude = '39.930137971351', name='RP-61'},{ latitude = '49.025974418781', longitude = '39.699723786001', name='RP-62'},{ latitude = '48.881512960514', longitude = '40.065344906729', name='RP-63'},{ latitude = '48.801972601341', longitude = '40.002862914128', name='RP-64'},{ latitude = '48.827206204896', longitude = '39.79936222518', name='RP-65'},{ latitude = '48.620307989244', longitude = '39.661131242186', name='RP-66'},{ latitude = '48.292952395261', longitude = '39.921915791934', name='RP-67'},{ latitude = '47.821558028885', longitude = '39.753548503413', name='RP-68'},{ latitude = '47.864745536734', longitude = '38.868480513938', name='RP-69'},{ latitude = '47.681011917412', longitude = '38.783200774767', name='RP-70'},{ latitude = '47.606804543567', longitude = '38.45542932268', name='RP-71'},{ latitude = '47.370401178169', longitude = '38.286920788586', name='RP-72'},{ latitude = '47.145382748779', longitude = '38.2391628302', name='RP-73'},{ latitude = '46.890967785004', longitude = '37.320727982793', name='RP-74'},{ latitude = '46.647313411525', longitude = '36.768462800578', name='RP-75'},{ latitude = '46.478332203441', longitude = '36.10645087612', name='RP-76'},{ latitude = '46.082838688911', longitude = '35.054408619738', name='RP-77'},{ latitude = '45.780659594835', longitude = '34.943751730376', name='RP-78'},{ latitude = '45.403647131169', longitude = '35.790789850741', name='RP-79'},{ latitude = '45.471249567332', longitude = '36.340617495113', name='RP-80'},{ latitude = '45.340598570499', longitude = '36.657937035102', name='RP-81'},{ latitude = '45.056029367169', longitude = '36.424994049029', name='RP-82'},{ latitude = '44.981782415474', longitude = '35.840034940659', name='RP-83'},{ latitude = '45.130699635438', longitude = '35.541964625645', name='RP-84'},{ latitude = '44.785718140061', longitude = '35.065857621064', name='RP-85'},{ latitude = '44.778915471449', longitude = '34.558073675863', name='RP-86'},{ latitude = '44.462668508529', longitude = '34.171596180347', name='RP-87'},{ latitude = '44.40411172926', longitude = '33.741424593654', name='RP-88'},{ latitude = '44.58454269949', longitude = '33.302348767336', name='RP-89'},{ latitude = '44.853347286273', longitude = '33.564144306413', name='RP-90'},{ latitude = '45.187191327717', longitude = '33.504210852321', name='RP-91'},{ latitude = '45.243822613137', longitude = '33.092593178425', name='RP-92'},{ latitude = '45.386981526237', longitude = '32.860890287004', name='RP-93'},{ latitude = '45.318605799796', longitude = '32.657853792579', name='RP-94'},{ latitude = '45.400831234874', longitude = '32.466450385293', name='RP-95'},{ latitude = '45.918677875644', longitude = '33.613357445361', name='RP-96'},{ latitude = '46.100867212266', longitude = '33.280359697814', name='RP-97'},{ latitude = '46.160949509198', longitude = '32.322564103794', name='RP-98'},{ latitude = '46.317108780845', longitude = '31.555594305569', name='RP-99'},{ latitude = '46.54107096409', longitude = '30.850333797178', name='RP-100'},{ latitude = '45.557394061522', longitude = '29.756537641532', name='RP-101'},{ latitude = '45.277888454508', longitude = '29.741920233702', name='RP-102'},{ latitude = '45.277888454508', longitude = '29.741920233702', name='RP-103'},{ latitude = '45.468517136188', longitude = '29.347933062331', name='RP-104'},{ latitude = '45.255727319249', longitude = '28.620384174787', name='RP-105'},{ latitude = '45.487581508095', longitude = '28.239152194782', name='RP-106'},{ latitude = '45.799811346163', longitude = '28.663680257553', name='RP-107'},{ latitude = '46.114514313618', longitude = '28.978113373303', name='RP-108'},{ latitude = '46.419724019625', longitude = '28.949866446031', name='RP-109'},{ latitude = '46.480867988511', longitude = '29.27393862725', name='RP-110'},{ latitude = '46.396646206084', longitude = '29.623934757666', name='RP-111'},{ latitude = '46.444258258273', longitude = '29.860846989697', name='RP-112'},{ latitude = '46.415622355426', longitude = '30.105175505776', name='RP-113'},{ latitude = '46.733326021627', longitude = '29.964313863606', name='RP-114'},{ latitude = '47.076392336831', longitude = '29.624460907212', name='RP-115'},{ latitude = '47.350269975339', longitude = '29.404440485379', name='RP-116'},{ latitude = '47.740649367137', longitude = '29.260057651978', name='RP-117'},{ latitude = '48.026510623224', longitude = '28.939290917514', name='RP-118'},{ latitude = '48.09895411509', longitude = '28.547922996497', name='RP-119'},{ latitude = '48.281988612601', longitude = '28.107064324333', name='RP-120'},{ latitude = '48.488925804258', longitude = '27.697713070051', name='RP-121'},{ latitude = '48.40776854951', longitude = '27.378174275333', name='RP-122'},{ latitude = '48.405553299877', longitude = '26.746415812458', name='RP-123'},{ latitude = '48.063658113863', longitude = '26.243801588398', name='RP-124'},{ latitude = '47.944655513456', longitude = '25.524014474264', name='RP-125'},{ latitude = '47.744561061444', longitude = '24.956071729105', name='RP-126'},{ latitude = '47.962680449384', longitude = '24.399177752578', name='RP-127'},{ latitude = '48.010493651984', longitude = '23.625753199312', name='RP-128'},{ latitude = '48.119278031308', longitude = '23.14840842829', name='RP-129'},{ latitude = '48.015944707048', longitude = '22.910231897084', name='RP-130'},{ latitude = '48.439541097923', longitude = '22.160903163054', name='RP-131'},{ latitude = '49.080817701885', longitude = '22.517400209782', name='RP-132'}}})
  ScenEdit_TransformZone ( 'Friendly', 'UkraineLandBorder', 'standard' )

end

function printSpecificZone(aZone)
      latitudes = {}
      longitudes = {}
      names = {}
      sideName = ""
      areaStr = "area={"
      local counter = 1
      for k, wp in ipairs(aZone.area) do
        -- print(wp.name .. " " .. wp.latitude .. " " .. wp.longitude .. " " .. wp.side)
        -- print("ScenEdit_AddReferencePoint( {side=\"" .. wp.side .. "\", name=\"" .. wp.name .. "\", latitude=" .. wp.latitude .. ", longitude=" .. wp.longitude .. ", highlighted=true, color='red' } )")
        latitudes[counter] = wp.latitude
        longitudes[counter] = wp.longitude
        names[counter] = wp.name
        sideName = wp.side

        if counter>1 then
            areaStr = areaStr .. ","
        end
        areaStr = areaStr .. "{ latitude = '" .. wp.latitude .. "', longitude = '" .. wp.longitude .. "', name='" .. wp.name .. "'}"

        counter = counter + 1
      end
      areaStr = areaStr .. "}"

    zoneType = 2
    if aZone.type=='Command_Core.NoNavZone' then
        zoneType = 0
    elseif aZone.type== 'Command_Core.ExclusionZone' then
        zoneType = 1
    elseif aZone.type=='Command_Core.Zone' then
        zoneType = 1
    end 

    markasStr = ""
    if not (aZone.markas==nil) then
        markasStr = ", markas='"
        markasStr = markasStr .. aZone.markas .. "'"
    end

    affectsStr = ""
    if not (aZone.affects==nil) then
        affectsStr=", affects={'"
        for i, v in ipairs(aZone.affects) do
            if i>1 then
                affectsStr =  affectsStr .. ",'"
            end

            affectsStr = affectsStr .. v .. "'"
        end
        affectsStr =  affectsStr .. "}"
    end

    -- ZoneType
    -- 0 Non Navigation
    -- 1 Exclusion
    -- 2 Custom

    -- markas for Exclusion Zones only...
    -- 0 = Neutral (N)
    -- 1 = Friendly (F)
    -- 2 = Unfriendly (U)
    -- 3 = Hostile (H)
    -- 4 = Unknown (X)

    if sideName == 'Ukraine' then
        sideName = 'Friendly'
    end

    if sideName == 'Turkey' then
        sideName = 'Friendly'
    end

    if sideName == 'NATO' then
        sideName = 'Friendly'
    end



    if sideName == 'RF' then
        sideName = 'Enemy'
    end

    print("ScenEdit_AddZone('" .. sideName .. "', " .. zoneType .. ", {description='" .. aZone.description .. "'" .. affectsStr ..", " .. areaStr .. markasStr .. affectsStr .."})")

end

function printZones()
  local sides = VP_GetSides() 
  local scen = VP_GetScenario( ) 
  -- print(scen)
  for i, side in ipairs(sides) do
  -- print(side)
   local aSide = VP_GetSide( { Side =side.name } ) 
  --print(aSide.nonavzones )
  --print(aSide.exclusionzones)
  --print(aSide.standardzones)
  --print(aSide.customenvironmentzones)

  --for j, zone in ipairs(aSide.nonavzones) do
      -- print(zone.guid)
  --    aZone = side:getnonavzone(zone.guid)
    

  for j, zone in ipairs(aSide.nonavzones) do
      -- print(zone.guid)
      aZone = side:getnonavzone(zone.guid)
      printSpecificZone(aZone)
      -- print(aZone)
      --[[
        local a = ScenEdit_AddZone('sidea', 1, {description='excluding',affects={'ship'}, area={ 
        { latitude = '34.2833063729007', longitude = '138.371434386706', name = 'RP-3136'},
        { latitude = '34.2751713567346', longitude = '139.122576855883', name = 'RP-3137'},
        { latitude = '33.823657691087', longitude = '139.111731172117', name = 'RP-3138' },
        { latitude = '33.8329383336795', longitude = '138.36485402628', name = 'RP-3139'}},
        markas='unfriendly' } ) 
    ]]--
  end
  

  for j, zone in ipairs(aSide.exclusionzones) do
      -- print(zone.guid)
      aZone = side:getexclusionzone(zone.guid)
      printSpecificZone(aZone)
  end

  for j, zone in ipairs(aSide.standardzones) do
      -- print(zone.guid)
      aZone = side:getstandardzone(zone.guid)
      printSpecificZone(aZone)
  end

  for j, zone in ipairs(aSide.customenvironmentzones) do
      -- print(zone.guid)
      aZone = side:getcustomenvironmentzone(zone.guid)
      printSpecificZone(aZone)
  end

    --  local points = ScenEdit_GetReferencePoints( { side=side.name, area={ "rp-100", "rp-101", "rp-102", "rp-103", "rp-104"} } ) 
  end
end

function is_in_dict(key, dict)
  if #dict == 0 then
       return false
  end

  -- if #dict==0 or (not has_value(dict, details.type)) then
  -- end
  for u, unit in ipairs(dict) do
       if unit == key then
           return true
       end
  end
end

function exportInstallations()

  local sides = VP_GetSides() 
  local uniqueTypes = {}
  
  for i, side in ipairs(sides) do
      -- local ship_units = myside:unitsBy('Ship')
      -- local units_in_myArea = mySide:unitsInArea(myArea)
      guids = {}
      types = {}
      dict = {}

      dictCounter = 0
      typeCounter = {}
        
      counter = 1
      facilityCounter = 1
      for u, unit in ipairs(side.units) do
          local details = VP_GetUnit( { guid = unit.guid} ) 
          
          if not is_in_dict(details.type, types)==true then

            typeCounter[details.type] = 1
            types[counter] = details.type
            dict[details.type] = {}
            counter = counter + 1
          end

          dict[details.type][typeCounter[details.type]] = unit.guid

          typeCounter[details.type] = typeCounter[details.type] + 1

          types[counter] = details.type
  
          uniqueTypes[details.type] = true
    
      end


      for k,v in pairs(dict) do
        typeName = k
        filename = "UkraineConflict/" .. side.name .. "_" .. typeName .. ".inst"
        if (#v > 0) and (not (typeName=='Group')) and (not (typeName=='Ship')) then
            print(filename)

            ScenEdit_ExportInst(side.name, v, {filename=filename,name='Ukraine conflict 2022 ' .. side.name .. " side" .. typeName,comment='Ukraine conflict 2022'}) 
        end
      end
  end 
  
    -- for k,v in pairs(uniqueTypes) do 
    --    print(k) 
    -- end
end



-- local action = ScenEdit_SetTrigger( { description='my trigger', mode = 'list' } )
-- print(action) 

-- local aMission = ScenEdit_GetMission( 'Friendly', 'Patrol' )
-- print(aMission)

function finalize()
    friendly = VP_GetSide( { Side ='Friendly' } ) 
    print("Friendly is")
    print(friendly)

    enemy = VP_GetSide( { Side ='Enemy' } ) 


    print("Triggering Mission")
    ScenEdit_SetMission('Friendly','Patrol',{isactive='False'}) 
    local mission = ScenEdit_SetMission('Friendly','Patrol',{isactive='True'}) 


    local aircraftsFriendly = getAircrafts(friendly.units)
    local aircraftsEnemy = getAircrafts(enemy.units)
    print(friendly)
    for i, name in ipairs(aircraftsFriendly) do
    --    print(name)
    end

    -- list of trigger settings 

    --  ScenEdit_AddUnit({type ='Air', unitname ='F-15C Eagle', loadoutid =16934, dbid =3500, side ='NATO', Lat="5.123",Lon="-12.51",alt=5000}) 
    -- base = GUID

    -- ScenEdit_SetEventTrigger("EnemyAI", "TimerEvent", { recurring = true, timeIncrement = 1 }, "EnemyAI()")

    -- ScenEdit_SetEventTrigger("EnemyAI",  {mode='add', id='GameTimeTrigger', name='test action points'})

    -- ScenEdit_SetEventTrigger('Time',{mode = 'add', description = 'EnemyAI'}) 
end


function debugFields(obj)
    -- First Boolean declares if a value can be set
    -- Second Boolean declares if a value can be read

    local a = obj
    print(a.fields) -- shows dump of all the property and method names associated with this wrapper
    -- show the values of each of the properties in the 'unit' wrapper
    for k,v in pairs(a.fields) do
     if string.find(k,'property_') ~= nil then -- is a property
       print("\r\n" .. v)
       local vt = {}
       local i = 0
       for w in string.gmatch(v,'%g+[^, ]') do
        vt[i] = w
        print(vt[i])
        i=i+1
       end

      print("\r\n[object] = " .. string.sub(vt[0],2) ) -- property name
      if vt[3] == 'True' then -- can the property be read
       print( a[ string.sub(vt[0],2) ] ) -- value of property
      else
       print( 'no get function' ) -- value of property
      end
     end
    end
end

function SetupSideAsAI(sideName)
  -- ScenEdit_SetSidePosture('Civilian', sideName, 'F')
  -- ScenEdit_SetSidePosture('Nature', sideName, 'F')
  ScenEdit_SetDoctrine({side=sideName}, {
    weapon_control_status_air = 0,
    weapon_control_status_surface = 0,
    weapon_control_status_subsurface = 0,
    weapon_control_status_land = 0,
    engage_opportunity_targets = true
    })
end

function createUnitWithRandomHeading()
  local x =0
  local la="N46"
  local lo="E25"
  
  while x<math.random(10,50) do
  
      la = "N" .. math.random(29.5,36.5)  
      lo = "E" .. math.random(60,71)
  
      ScenEdit_AddUnit({type = 'FACILITY', name = 'Convoy',
      heading = math.random(0,359), dbid = 624, side = 'NOTSOVIET', 
      Latitude=la, 
      Longitude=lo,  
      autodetectable="false", 
      course={{lat="N".. math.random(30,37), lon="E" .. math.random(60,71)}}
      })
      
      -- ScenEdit_AddUnit({type="air", side="Mercs", name="Plane", dbid=1160, loadoutid=12354, latitude="29.297778", longitude="90.911944", altitude="5000 ft", heading=0})
  
      x=x+1
  end
end


function colorizeZones()

  local sides = VP_GetSides() 
  local scen = VP_GetScenario( ) 
  -- print(scen)
  for i, side in ipairs(sides) do
  -- print(side)
   local aSide = VP_GetSide( { Side =side.name } ) 
   for j, zone in ipairs(aSide.standardzones) do
        aZone = side:getstandardzone(zone.guid)
--        debugFields(aZone)
        aZone.areacolor='Green'
        print(aZone.areacolor)
   end

  end

end

function ai_vs_ai()
    local sides = VP_GetSides()
    for i, side in ipairs(sides) do
        print("Setting up side as AI " .. side.name)
        SetupSideAsAI(side.name)
    end
end

function addStrikeAirInterceptMission(sideName)
  --local missionParams = {
  --  side = 
  --}
  --local mission = ScenEdit_AddMission( 'USA', 'Marker strike', 'strike',{ type = 'AIR '} )

end


function CreateAirInterceptMission(sideName, missionName)
  -- Define the mission parameters
  local missionParams = {
    side = sideName,
    name = missionName,
    type = "strike",  
    subtype = "Air Intercept",  -- specifically for intercepting aircraft
    isactive = 'True',
    starttime='',
    endtime = '',
    SISH='False',
    aar = {FuelQtyToStartLookingForTanker_Airborne = 30, TankerFollowsReceivers = 'Yes', Doctrine_UseReplenishment = 'Always_ExceptTankersRefuellingTankers', TankerMaxDistance_Airborne = 'internal', MaxReceiversInQueuePerTanker_Airborne = 0, TankerUsage = 'Automatic'},
    unitlist = {}
  }
  -- Create the mission
  ScenEdit_AddMission(missionParams)
end


function addMissions()
 -- Reconnaissance
 -- Strike
 -- Anti-Submarine Warfare (ASW)
 -- Combat Air Patrol (CAP)
 -- Air Superiority
 -- Refuel
 -- Interdiction
 -- Search and Rescue (SAR)
 -- Escort
 -- Electronic Warfare (EW)
 -- Suppression of Enemy Air Defenses (SEAD)
 -- Close Air Support (CAS)
 -- Airborne Early Warning and Control (AEW&C)
 -- Deep Strike
 -- Force Projection
 -- Strategic Bombing
 -- Counter-insurgency (COIN)
 -- Blockade
 -- Amphibious Assault
 -- Special Operations
 -- Mine Laying/Mine Sweeping
 -- Artillery Support
 -- Signals Intelligence (SIGINT)


 -- ----------------
 -- COMMAND Missions
 -- ----------------

 -- Strike
    -- Air Intercept
    -- Land Strike
    -- Naval ASuW Strike
    -- ASW Strike

 -- Patrol
    -- AAW Patrol
    -- ASuW Patrol (Naval)
    -- ASuW Patrol (Ground)
    -- ASuW Patrol (Mixed)
    -- ASW Patrol
    -- SEAD Patrol
    -- Sea Control Patrolg

 -- Support 
 -- Ferry 
 -- Mine
 -- Mine-Clearing
 -- Cargo
    -- Delivery
    -- Transfer

end


-- setup()
setupSimple()

-- ai_vs_ai()

-- colorizeZones()


-- debug()
-- setup()



-- printZones()
--finalize()









