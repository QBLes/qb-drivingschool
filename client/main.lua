QBCore = exports['qb-core']:GetCoreObject()
local CurrentAction = nil
local CurrentActionMsg = nil
local CurrentActionData = nil
local Licenses = {}
local CurrentTest = nil
local CurrentTestType = nil
local CurrentVehicle = nil
local CurrentCheckPoint, DriveErrors = 0, 0
local LastCheckPoint = -1
local CurrentBlip = nil
local CurrentZoneType = nil
local IsAboveSpeedLimit = false
local LastVehicleHealth = nil


RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    --print('Loaded Driving School')
    end)
RegisterNetEvent('qb-drivingschool:start', function()
    StartTheoryTest()
end)

function DrawMissionText(msg, time)
    ClearPrints()
    BeginTextCommandPrint('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandPrint(time, true)
end

function StartTheoryTest()
    CurrentTest = 'theory'
    SendNUIMessage({
        openQuestion = true
    })
    SetTimeout(200, function()
        SetNuiFocus(true, true)
    end)
end

function StopTheoryTest(success)
    CurrentTest = nil
    SendNUIMessage({
        openQuestion = false
    })
    SetNuiFocus(false)
    if success then
        QBCore.Functions.Notify("You passed theory test , Start your practical test!", "success", 5000)
        TriggerServerEvent('qb-drivingschool:server:givepermit')
    else
        QBCore.Functions.Notify("Failed Theory Test", "error")
    end
end

function StartDriveTest()
    local coords = {
        x = 231.36,
        y = -1394.49,
        z = 30.5,
        h = 239.94,
    }
    local plate = "TESTDRIVE" .. math.random(1111, 9999)
    QBCore.Functions.SpawnVehicle('blista', function(vehicle)
        SetVehicleNumberPlateText(vehicle, "TESTDRIVE" .. tostring(math.random(1000, 9999)))
        SetEntityHeading(vehicle, coords.h)
        exports['LegacyFuel']:SetFuel(vehicle, 100.0)
        Menu.hidden = true
        TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
        SetVehicleCustomPrimaryColour(vehicle, 0, 0, 0)
        SetVehicleEngineOn(vehicle, true, true)
        SetVehicleDirtLevel(vehicle)
        SetVehicleUndriveable(vehicle, false)
        WashDecalsFromVehicle(vehicle, 1.0)
        CurrentTest = 'drive'
        CurrentTestType = 'drive_test'
        CurrentCheckPoint = 0
        LastCheckPoint = -1
        CurrentZoneType = 'residence'
        DriveErrors = 0
        IsAboveSpeedLimit = false
        CurrentVehicle = vehicle
        LastVehicleHealth = GetEntityHealth(vehicle)
    end, coords, true)
end

function StopDriveTest(success)
    if success then
        QBCore.Functions.Notify("Passed Driving Test", "success")
        TriggerServerEvent('qb-drivingschool:server:GetLicense')
    else
        -- despawn current car and teleport them
        ped = PlayerPedId()
        RemoveBlip(CurrentBlip)
        DeleteVehicle(GetVehiclePedIsUsing(ped))
        SetEntityCoords(ped, 235.283, -1398.329, 28.921)
        QBCore.Functions.Notify("Failed Driving Test", "error")
    end
    CurrentTest = nil
    CurrentTestType = nil
end

function SetCurrentZoneType(type)
    CurrentZoneType = type
end

RegisterNUICallback('question', function(data, cb)
    SendNUIMessage({
        openSection = 'question'
    })
    cb()
end)

RegisterNUICallback('close', function(data, cb)
    StopTheoryTest(true)
    cb()
end)

RegisterNUICallback('kick', function(data, cb)
    StopTheoryTest(false)
    cb()
end)

AddEventHandler('qb-drivingschool:hasEnteredMarker', function(zone)
    if zone == 'DMVSchool' then
        CurrentAction = 'dmvschool_menu'
        CurrentActionMsg = ('Press E to give driving test - $500')
        CurrentActionData = {}
    end
end)

AddEventHandler('qb-drivingschool:hasExitedMarker', function(zone)
    CurrentAction = nil
end)


-- Create Blips
CreateThread(function()
    local blip = AddBlipForCoord(Config.Zones.DMVSchool.Pos.x, Config.Zones.DMVSchool.Pos.y, Config.Zones.DMVSchool.Pos.z)
    SetBlipSprite(blip, 525)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.7)
    SetBlipColour(blip, 4)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Driving School')
    EndTextCommandSetBlipName(blip)
end)

-- Display markers
CreateThread(function()
    while true do
        Wait(0)
        local coords = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.Zones) do
            if (v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
                DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
            end
        end
    end
end)

-- Enter / Exit marker events
CreateThread(function()
    while true do
        Wait(100)
        local coords = GetEntityCoords(PlayerPedId())
        local isInMarker = false
        local currentZone = nil
        for k, v in pairs(Config.Zones) do
            if (GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
                isInMarker = true
                currentZone = k
            end
        end
        if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
            HasAlreadyEnteredMarker = true
            LastZone = currentZone
            TriggerEvent('qb-drivingschool:hasEnteredMarker', currentZone)
        end
        if not isInMarker and HasAlreadyEnteredMarker then
            HasAlreadyEnteredMarker = false
            TriggerEvent('qb-drivingschool:hasExitedMarker', LastZone)
        end
    end
end)

-- Block UI
CreateThread(function()
    while true do
        Wait(1)
        if CurrentTest == 'theory' then
            local playerPed = PlayerPedId()
            DisableControlAction(0, 1, true)-- LookLeftRight
            DisableControlAction(0, 2, true)-- LookUpDown
            DisablePlayerFiring(playerPed, true)-- Disable weapon firing
            DisableControlAction(0, 142, true)-- MeleeAttackAlternate
            DisableControlAction(0, 106, true)-- VehicleMouseControlOverride
        else
            Wait(500)
        end
    end
end)

-- Key Controls
CreateThread(function()
    while true do
        Wait(0)
        if CurrentAction then
            helpText(CurrentActionMsg)
            if IsControlJustReleased(0, 38) then
                TriggerEvent('opendriving')
                CurrentAction = nil
            end
        else
            Wait(500)
        end
    end
end)

-- Drive test
CreateThread(function()
    while true do
        Wait(0)
        if CurrentTest == 'drive' then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local nextCheckPoint = CurrentCheckPoint + 1
            if Config.CheckPoints[nextCheckPoint] == nil then
                if DoesBlipExist(CurrentBlip) then
                    RemoveBlip(CurrentBlip)
                end
                CurrentTest = nil
                QBCore.Functions.Notify("Driving Test Complete", "error")
                if DriveErrors < Config.MaxErrors then
                    StopDriveTest(true)
                end
            else
                if CurrentCheckPoint ~= LastCheckPoint then
                    if DoesBlipExist(CurrentBlip) then
                        RemoveBlip(CurrentBlip)
                    end
                    CurrentBlip = AddBlipForCoord(Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z)
                    SetBlipRoute(CurrentBlip, 1)
                    LastCheckPoint = CurrentCheckPoint
                end
                local distance = GetDistanceBetweenCoords(coords, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, true)
                if distance <= 100.0 then
                    DrawMarker(1, Config.CheckPoints[nextCheckPoint].Pos.x, Config.CheckPoints[nextCheckPoint].Pos.y, Config.CheckPoints[nextCheckPoint].Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.5, 102, 204, 102, 100, false, true, 2, false, false, false, false)
                end
                if distance <= 3.0 then
                    Config.CheckPoints[nextCheckPoint].Action(playerPed, CurrentVehicle, SetCurrentZoneType)
                    CurrentCheckPoint = CurrentCheckPoint + 1
                end
                if DriveErrors == Config.MaxErrors then
                    StopDriveTest(false)
                end
            end
        else
            -- not currently taking driver test
            Wait(500)
        end
    end
end)

-- Speed / Damage control
CreateThread(function()
    while true do
        Wait(10)
        if CurrentTest == 'drive' then
            local playerPed = PlayerPedId()
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                local speed = GetEntitySpeed(vehicle) * Config.SpeedMultiplier
                local tooMuchSpeed = false
                for k, v in pairs(Config.SpeedLimits) do
                    if CurrentZoneType == k and speed > v then
                        tooMuchSpeed = true
                        if not IsAboveSpeedLimit then
                            DriveErrors = DriveErrors + 1
                            IsAboveSpeedLimit = true
                            QBCore.Functions.Notify("Driving Too Fast! Allowed Speed: " .. v .. " ", "error")
                            QBCore.Functions.Notify("Mistakes - " .. DriveErrors .. " / " .. Config.MaxErrors .. " ", "error")
                        end
                    end
                end
                if not tooMuchSpeed then
                    IsAboveSpeedLimit = false
                end
                local health = GetEntityHealth(vehicle)
                if health < LastVehicleHealth then
                    DriveErrors = DriveErrors + 1
                    QBCore.Functions.Notify("You damaged Vehicle!", "error")
                    QBCore.Functions.Notify("Mistakes - " .. DriveErrors .. " / " .. Config.MaxErrors .. " ", "error")
                    -- avoid stacking faults
                    LastVehicleHealth = health
                    Wait(1500)
                end
            end
        else
            -- not currently taking driver test
            Wait(500)
        end
    end
end)

helpText = function(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

RegisterNetEvent('opendriving', function()
        
        -- do a trigger to server toi see if meta is set to true for driver license
        QBCore.Functions.TriggerCallback('qb-drivingschool:server:HasLicense', function(HasItem)
                
                if HasItem then
                    QBCore.Functions.Notify("Looks like you have already passed your test! Go to City Hall to get a new License", "error", 10000)
                else
                    TriggerEvent('opendriving:theory')
                end
        end)
end)


RegisterNetEvent('opendriving:theory', function()
    QBCore.Functions.TriggerCallback('qb-drivingschool:server:hasfunds', function(HasFunds)
        if HasFunds then
            TriggerEvent('qb-drivingschool:client:starttest')
        else
            QBCore.Functions.Notify("Looks like you do not have enough funds in your bank!")
        end
    end)
end)

RegisterNetEvent('qb-drivingschool:client:starttest', function()
    QBCore.Functions.TriggerCallback('qb-drivingschool:server:HasPermit', function(HasItem)
        if HasItem then
            StartDriveTest()
        else
            QBCore.Functions.Notify("You cannot close screen until and unless you give theory test", "error")
            StartTheoryTest()
        end
    end)
end)