ESX = exports.es_extended:getSharedObject()

exports.qtarget:AddTargetModel({Config.npc.pedill.id}, {
    options = {
        {
            event = "in_menu_car",
            icon = "fa-solid fa-lock",
            label = "Ruba Macchina",
        }
    },
    distance = 2.5
})

RegisterNetEvent('in_menu_car', function()
    lib.registerContext({
        id = 'car_menu',
        title = 'Menu CarThief',
        options = {
            {
                title = 'Ruba Macchina',
                description = 'Ruba Macchina Tra I Disponibili!',
                onSelect = function()
                    TriggerEvent('car:ok')
                end,
                metadata = {
                    {label = 'Veicoli Disponibili', value = 'blista | bf400'},
                }
            },
        }
    })
    lib.showContext('car_menu')
end)

RegisterNetEvent('car:ok', function()
    local random = math.random(1, 2)
    local randomcoords = math.random(1, 5)
    local veicolo = nil
    local coords = nil

    if random == 1 then
        veicolo = 'blista'
    elseif random == 2 then
        veicolo = 'bf400'
    end

    if randomcoords == 1 then
        coords = Config.Spawn.pos1
    elseif randomcoords == 2 then
        coords = Config.Spawn.pos2
    elseif randomcoords == 3 then
        coords = Config.Spawn.pos3
    elseif randomcoords == 4 then
        coords = Config.Spawn.pos4
    elseif randomcoords == 5 then
        coords = Config.Spawn.pos5
    end

    if ESX.Game.IsSpawnPointClear(coords, 3.0) then
        ESX.Game.SpawnVehicle(veicolo, coords, 86.29, function(v)
            SetVehicleDoorShut(v, 0, false)
            SetVehicleDoorShut(v, 1, false)
            SetVehicleDoorShut(v, 2, false)
            SetVehicleDoorShut(v, 3, false)
            SetVehicleDoorsLocked(v, 2)
            PlayVehicleDoorCloseSound(v, 1)
            exports.qtarget:AddTargetModel({-344943009, 86520421}, {
                options = {
                    {
                        event = "cb_item",
                        icon = "fa-solid fa-lock",
                        label = "Scassina Macchina",
                    }
                },
                distance = 2.5
            })
        end)
        ESX.ShowNotification('Raggiungi La Zona di Consegna Del Veicolo!')
        waypoint1 = SetNewWaypoint(coords)
        blip1 = AddBlipForCoord(coords)
        SetBlipSprite(blip1, 535)
        SetBlipColour(blip1, 3)
    end
end)

RegisterNetEvent('cb_item', function()
    TriggerServerEvent('controllo:item')
end)

RegisterNetEvent('skill:opencar', function()
    local vehicle = ESX.Game.GetClosestVehicle()
    local coordsconsegna = nil
    FreezeEntityPosition(PlayerPedId(), true)
    RequestAnimDict("mini@repair")
    while (not HasAnimDictLoaded("mini@repair")) do Citizen.Wait(0) end
    TaskPlayAnim(PlayerPedId(),"mini@repair","fixing_a_ped",8.0, 8.0, -1, 80, 0, 0, 0, 0)
    local success = lib.skillCheck({'easy', 'easy', 'easy', 'medium'})
    local random = math.random(1, 5)
    local rapinando = false

    if random == 1 then
        coordsconsegna = Config.Consegna.pos1
    elseif random == 2 then
        coordsconsegna = Config.Consegna.pos2
    elseif random == 3 then
        coordsconsegna = Config.Consegna.pos3
    elseif random == 4 then
        coordsconsegna = Config.Consegna.pos4
    elseif random == 5 then
        coordsconsegna = Config.Consegna.pos5
    end

    if success then
        rapinando = true
        SetVehicleDoorsLocked(vehicle, 1)
        PlayVehicleDoorOpenSound(vehicle, 0)
        ClearPedTasks(PlayerPedId())
        FreezeEntityPosition(PlayerPedId(), false)
        RemoveAnimDict(animazione)
        RemoveBlip(blip1)
        DeleteWaypoint(waypoint1)
        ESX.ShowNotification("Hai Scassinato Il Veicolo!")
        waypointconsegna = SetNewWaypoint(coordsconsegna)
        blipconsegna = AddBlipForCoord(coordsconsegna)
        SetBlipSprite(blipconsegna, 535)
        SetBlipColour(blipconsegna, 3)
        TriggerEvent('gridsystem:registerMarker', {
            name = "consegnaveicolo",
            type = 22,
            pos = coordsconsegna,
            msg = '',
            color = { r = 255, b = 255, g = 255 },
            scale = vector3(0.8, 0.8, 0.8),
            interact =  vector3(0.8, 0.8, 0.8),
            action = function()
                if rapinando then
                    TriggerEvent('consegna:veicolo')
                    rapinando = false
                else
                    ESX.ShowNotification("Non Stai Rubando Una Macchina")
                end
            end,
            onEnter = function()
                ESX.ShowHelpNotification("Primi [E] Per Consegnare Il Veicolo") 
            end
        })
    else
        Dispatch()
        RemoveAnimDict(animazione)
        RemoveBlip(blip1)
        DeleteWaypoint(waypoint1)
        ClearPedTasks(PlayerPedId())
        FreezeEntityPosition(PlayerPedId(), false)
        ESX.ShowNotification("Ops! Non Sei Riuscito a Scassinare Il Veicolo! Il Padrone Ha Chiamato la Polizia Scappa!")
    end
end)

RegisterNetEvent('consegna:veicolo', function()
    local randomcash = math.random(Config.MoneyRandom.random1, Config.MoneyRandom.random2)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)

    if not IsPedInAnyVehicle(PlayerPedId()) then
        ESX.ShowNotification('Non Sei In Un Veicolo')
    else
        ESX.ShowNotification("Hai Consegnato Il Veicolo!")
        DeleteEntity(veh)
        RemoveBlip(blipconsegna)
        DeleteWaypoint(waypointconsegna)
        TriggerServerEvent('pagamento:cash', randomcash)
    end
end)


Citizen.CreateThread(function()
    Wait(250)
    local lester = Config.npc.pedill
        RequestModel(lester.id)
    while not HasModelLoaded(lester.id) do
        Wait(0)
    end
    local ped_lester = CreatePed(4, lester.id, lester.x, lester.y, lester.z, lester.h)
    SetEntityHeading(ped_lester, lester.h)
    FreezeEntityPosition(ped_lester, true)
    SetBlockingOfNonTemporaryEvents(ped_lester, true)
    SetEntityInvincible(ped_lester, true)
    startAnim(ped_lester, "amb@prop_human_seat_computer@male@react_shock", "left")
end)

function startAnim(playeranim, lib, anim)
    ESX.Streaming.RequestAnimDict(lib, function()
        TaskPlayAnim(playeranim, lib, anim, 8.0, -8.0, -1, 1, 1, true, true, true)
    end)
end
