ESX = exports["GameMode"].getSharedObject()

local cashMoney, bankMoney, blackMoney = 0, 0, 0
local display = false

Citizen.CreateThread(function()
    while true do
        local playerData = ESX.GetPlayerData()
        if playerData and playerData.accounts then
            RefreshAccounts(playerData.accounts)
        end
        Citizen.Wait(1000)
    end
end)

function RefreshAccounts(accounts)
    for _, account in pairs(accounts) do
        if account.name == 'black_money' then
            blackMoney = account.money
        elseif account.name == 'bank' then
            bankMoney = account.money
        elseif account.name == 'money' or account.name == 'cash' then
            cashMoney = account.money
        end
    end
    SendNUIMessage({
        action = "updateMoney",
        cash = cashMoney or 0,
        bank = bankMoney or 0,
        black = blackMoney or 0,
        crypto = 0
    })
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    RefreshAccounts(xPlayer.accounts)
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Citizen.Wait(1000)
    local playerData = ESX.GetPlayerData()
    if playerData and playerData.accounts then
        RefreshAccounts(playerData.accounts)
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)
            local speed = math.floor(GetEntitySpeed(vehicle) * 3.6)
            local gear = GetVehicleCurrentGear(vehicle)
            local maxSpeed = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fInitialDriveMaxFlatVel')
            local fuel = math.floor(GetVehicleFuelLevel(vehicle))
            SendNUIMessage({
                type = "speedometer",
                display = true,
                speed = speed,
                gear = gear,
                maxSpeed = maxSpeed,
                fuel = fuel
            })
            display = true
        elseif display then
            SendNUIMessage({
                type = "speedometer",
                display = false
            })
            display = false
        end
        Citizen.Wait(100)
    end
end)


