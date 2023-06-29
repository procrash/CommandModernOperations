-- Enemy AI Script

-- Define the enemy AI behavior
function EnemyAI()
  -- Get the current scenario and time
  local scenario = ScenEdit_GetScenarioInfo()
  local currentTime = scenario["Time"]["CurrentTime"]

  -- Get the list of friendly units
  local friendlyUnits = ScenEdit_GetUnitList({ side = "Friendly" })

  -- Loop through each friendly unit
  for i, unit in ipairs(friendlyUnits) do
    -- Check if the unit is active
    if unit["ActiveUnit"] then
      -- Perform AI actions based on the unit type
      if unit["Type"] == "Aircraft" then
        -- Example: Aircraft units perform different tactics based on the time and threat level
        local enemyUnits = ScenEdit_GetUnitList({ side = "Enemy" })
        if #enemyUnits > 0 then
          if currentTime < 600 then
            -- Initial phase: Perform reconnaissance
            ScenEdit_SetMission({ side = "Friendly", unitname = unit["Name"], mission = { MissionType = "Reconnaissance", TargetType = "Area", TargetArea = { Latitude = 40, Longitude = 30, Radius = 100 } } })
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
              ScenEdit_SetMission({ side = "Friendly", unitname = unit["Name"], mission = { MissionType = "Strike", TargetType = "Unit", TargetUnit = enemyUnits[1]["Name"] } })
            end
          else
            -- Late phase: Perform air superiority
            if unit["FuelState"] < 25 then
              -- Refuel if low on fuel
              ScenEdit_SetRefuelAll({ side = "Friendly", unitname = unit["Name"] })
            else
              -- Select appropriate weapon for the target type
              if enemyUnits[1]["Type"] == "Aircraft" then
                ScenEdit_SetWeapon({ side = "Friendly", unitname = unit["Name"], weapon = { WeaponType = "AirToAir" } })
              else
                ScenEdit_SetWeapon({ side = "Friendly", unitname = unit["Name"], weapon = { WeaponType = "AirToGround" } })
              end

              -- Engage the target
              ScenEdit_SetDoctrine({ side = "Friendly", unitname = unit["Name"], doctrine = { WeaponControlStatus = "Hold", EngagementOrder = "WeaponFree" } })
              ScenEdit_SetMission({ side = "Friendly", unitname = unit["Name"], mission = { MissionType = "AirSuperiority", TargetType = "Area", TargetArea = { Latitude = 40, Longitude = 30, Radius = 100 } } })
            end
          end
        end
      end
    end
  end
end

-- Set the AI behavior to execute every minute
ScenEdit_SetEventTrigger("EnemyAI", "GameTimeTrigger", { Year = "*", Month = "*", Day = "*", Hour = "*", Minute = "*" }, "EnemyAI()")
