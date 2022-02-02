QBCore = exports['qb-core']:GetCoreObject()


QBCore.Functions.CreateCallback('qb-drivingschool:server:hasfunds', function(source, cb)
	local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
	local bankamount = xPlayer.PlayerData.money["bank"]
	if bankamount >= Config.Price then
		xPlayer.Functions.RemoveMoney('bank', 500)
        cb(true)
    else
        cb(false)
    end
end)



RegisterServerEvent('qb-drivingschool:server:GetLicense', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)


    local info = {}
        info.firstname = Player.PlayerData.charinfo.firstname
        info.lastname = Player.PlayerData.charinfo.lastname
        info.birthdate = Player.PlayerData.charinfo.birthdate
        info.type = "Class C Driver License"
    Player.Functions.RemoveItem('driving_test_permit', 1)
    Player.Functions.AddItem('driver_license', 1, nil, info)
    -- add the meta to add license to true
    local licenses = {["driver"] = true, ['weapon'] = Player.PlayerData.metadata["licences"].weapon, ["business"] = Player.PlayerData.metadata["licences"].business}
    Player.Functions.SetMetaData("licences", licenses)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['driver_license'], 'add')
end)

QBCore.Functions.CreateCallback('qb-drivingschool:server:HasLicense', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local license = Player.PlayerData.metadata["licences"].driver
    if license then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('qb-drivingschool:server:HasPermit', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local permit = Player.Functions.GetItemByName("driving_test_permit")
    if permit ~= nil then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('qb-drivingschool:server:givepermit', function()
Player = QBCore.Functions.GetPlayer(source)
Player.Functions.AddItem('driving_test_permit', 1, nil, info)
end)