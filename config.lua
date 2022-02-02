Config = {}
Config.DrawDistance = 100.0
Config.MaxErrors = 5
Config.SpeedMultiplier = 3.6
Config.Price = 500

Config.SpeedLimits = {
    residence = 50,
    town = 80,
    freeway = 120
}


Config.Vehicles = {
    ["blista"] = "blista",
}

Config.Zones = {
    DMVSchool = {
        Pos = {x = 239.62, y = -1381.08, z = 33.74},
        Size = {x = 0.5, y = 0.3, z = 0.3},
        Color = {r = 255, g = 255, b = 255},
        Type = 20
    },

}

Config.CheckPoints = {
        
        {
            Pos = {x = 255.139, y = -1400.731, z = 29.537},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                QBCore.Functions.Notify("Next Point Speed - " .. Config.SpeedLimits['residence'] .. " ", "success", 5000)
            
            end
        },
        
        {
            Pos = {x = 271.874, y = -1370.574, z = 30.932},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                QBCore.Functions.Notify('Go to Next Point', "success", 5000)
            end
        },
        
        {
            Pos = {x = 217.821, y = -1410.520, z = 28.292},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                setCurrentZoneType('town')
                
                Citizen.CreateThread(function()
                    QBCore.Functions.Notify("Stop Look Left - " .. Config.SpeedLimits['town'] .. " ", "error", 5000)
                    PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
                    FreezeEntityPosition(vehicle, true)
                    Citizen.Wait(6000)
                    
                    FreezeEntityPosition(vehicle, false)
                    QBCore.Functions.Notify('Good Turn Right', "success", 5000)
                end)
            end
        },
        
        {
            Pos = {x = 178.550, y = -1401.755, z = 27.725},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                QBCore.Functions.Notify('Watch Traffic Light', "error", 5000)
            end
        },
        
        {
            Pos = {x = 113.160, y = -1365.276, z = 27.725},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                QBCore.Functions.Notify('Go To Next Point', "success", 5000)
            end
        },
        
        {
            Pos = {x = -73.542, y = -1364.335, z = 27.789},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                QBCore.Functions.Notify('Stop For Passing', "error", 5000)
                PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
            end
        },
        
        {
            Pos = {x = -355.143, y = -1420.282, z = 27.868},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                QBCore.Functions.Notify('Go To Next Point', "success", 5000)
            end
        },
        
        {
            Pos = {x = -439.148, y = -1417.100, z = 27.704},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                QBCore.Functions.Notify('Go To Next Point', "success", 5000)
            end
        },
        
        {
            Pos = {x = -453.790, y = -1444.726, z = 27.665},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                setCurrentZoneType('freeway')
                
                
                QBCore.Functions.Notify("Free way time - " .. Config.SpeedLimits['freeway'] .. " ", "error", 5000)
                PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
            end
        },
        
        {
            Pos = {x = -463.237, y = -1592.178, z = 37.519},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                QBCore.Functions.Notify('Go To Next Point', "success", 5000)
            end
        },
        
        {
            Pos = {x = -900.647, y = -1986.28, z = 26.109},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                QBCore.Functions.Notify('Go To Next Point', "success", 5000)
            end
        },
        
        {
            Pos = {x = 1225.759, y = -1948.792, z = 38.718},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                QBCore.Functions.Notify('Go To Next Point', "success", 5000)
            end
        },
        
        {
            Pos = {x = 1225.759, y = -1948.792, z = 38.718},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                setCurrentZoneType('town')
                QBCore.Functions.Notify("In Town Speed - " .. Config.SpeedLimits['town'] .. " ", "error", 5000)
            end
        },
        
        {
            Pos = {x = 1163.603, y = -1841.771, z = 35.679},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                QBCore.Functions.Notify('Stay Alert', "error", 5000)
                PlaySound(-1, 'RACE_PLACED', 'HUD_AWARDS', false, 0, true)
            end
        },
        
        {
            Pos = {x = 235.283, y = -1398.329, z = 28.921},
            Action = function(playerPed, vehicle, setCurrentZoneType)
                DeleteVehicle(vehicle)
            end
        }

}
