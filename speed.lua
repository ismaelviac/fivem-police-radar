--[[------------------------------------------------------------------------

	Radar movil coches 
	Usar Numpad5 encender
    Usar Numpad8 congelar

------------------------------------------------------------------------]]
--
ESX  = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)


local radar = {
    shown = false,
    freeze = false,
    info = "~y~Iniciando RADAR...~w~321...~y~Cargado! ",
    info2 = "~y~Iniciando RADAR...~w~321...~y~Cargado! ",
    minSpeed = 1.0,
    maxSpeed = 750.0,
}

--local distanceToCheckFront = 50
function DrawAdvancedText(x, y, w, h, sc, text, r, g, b, a, font, jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
    N_0x4e096588b13ffeca(jus)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x + w, y + h) -- Sin desplazamiento negativo
end

-- DECLARA AQUÍ, FUERA DEL BUCLE:
local frozenFront = { plate = "---", model = "---", speed = 0 }
local frozenRear  = { plate = "---", model = "---", speed = 0 }

Citizen.CreateThread(function()
    local fplate, fmodel, fvspeed = "---", "---", 0
    local bplate, bmodel, bvspeed = "---", "---", 0

    while true do
        Wait(0)

        if IsControlJustPressed(1, 128) then
            if ESX.PlayerData.job and ESX.PlayerData.job.name == 'police' then
                if radar.shown then 
                    radar.shown = false 
                    radar.info = string.format("~y~Iniciando RADAR...~w~321...~y~Cargado! ")
                    radar.info2 = string.format("~y~Iniciando RADAR...~w~321...~y~Cargado! ")
                else 
                    radar.shown = true 
                end	
            else
                Wait(0)
            end
            Wait(75)
        end

        if radar.shown then
            if not radar.freeze then
                -- Solo actualiza si no está congelado
                fplate, fmodel, fvspeed = "---", "---", 0
                bplate, bmodel, bvspeed = "---", "---", 0

                local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
                local coordA = GetOffsetFromEntityInWorldCoords(veh, 0.0, 1.0, 1.0)
                local coordB = GetOffsetFromEntityInWorldCoords(veh, 0.0, 105.0, 0.0)
                local frontcar = StartShapeTestCapsule(coordA, coordB, 3.0, 10, veh, 7)
                local a, b, c, d, e = GetShapeTestResult(frontcar)
                if IsEntityAVehicle(e) then
                    fmodel = GetDisplayNameFromVehicleModel(GetEntityModel(e))
                    fvspeed = GetEntitySpeed(e)*3.59999953
                    fplate = GetVehicleNumberPlateText(e)
                    radar.info = string.format("~y~Matricula: ~w~%s  ~y~Modelo: ~w~%s  ~y~Velocidad: ~w~%s kmh", fplate, fmodel, math.ceil(fvspeed))
                end

                local bcoordB = GetOffsetFromEntityInWorldCoords(veh, 0.0, -105.0, 0.0)
                local rearcar = StartShapeTestCapsule(coordA, bcoordB, 3.0, 10, veh, 7)
                local f, g, h, i, j = GetShapeTestResult(rearcar)
                if IsEntityAVehicle(j) then
                    bmodel = GetDisplayNameFromVehicleModel(GetEntityModel(j))
                    bvspeed = GetEntitySpeed(j)*3.59999953
                    bplate = GetVehicleNumberPlateText(j)
                    radar.info2 = string.format("~y~Matricula: ~w~%s  ~y~Modelo: ~w~%s  ~y~Velocidad: ~w~%s kmh", bplate, bmodel, math.ceil(bvspeed))
                end
            end

            -- Aquí, después de actualizar los datos, detecta el botón de congelar
            if IsControlJustPressed(1, 127) then
                radar.freeze = not radar.freeze
                if radar.freeze then
                    -- Guarda los datos actuales al congelar
                    frozenFront.plate = fplate
                    frozenFront.model = fmodel
                    frozenFront.speed = math.ceil(fvspeed or 0)
                    frozenRear.plate  = bplate
                    frozenRear.model  = bmodel
                    frozenRear.speed  = math.ceil(bvspeed or 0)
                end
            end

            -- ENVÍA LOS DATOS AL NUI AQUÍ
            SendNUIMessage({
                type = "radar",
                show = radar.shown,
                front = radar.freeze and frozenFront or {
                    plate = fplate or "---",
                    model = fmodel or "---",
                    speed = math.ceil(fvspeed or 0)
                },
                rear = radar.freeze and frozenRear or {
                    plate = bplate or "---",
                    model = bmodel or "---",
                    speed = math.ceil(bvspeed or 0)
                }
            })
        else
            -- Si el radar no está mostrado, oculta el NUI
            SendNUIMessage({
                type = "radar",
                show = false,
                front = { plate = "---", model = "---", speed = 0 },
                rear = { plate = "---", model = "---", speed = 0 }
            })
        end

        if not IsPedInAnyVehicle(GetPlayerPed(-1)) then
            radar.shown = false
            radar.info = string.format("~y~Iniciando RADAR...~w~321...~y~Cargado! ")
            radar.info2 = string.format("~y~Iniciando RADAR...~w~321...~y~Cargado! ")
            -- Oculta el NUI si sales del vehículo
            SendNUIMessage({
                type = "radar",
                show = false,
                front = { plate = "---", model = "---", speed = 0 },
                rear = { plate = "---", model = "---", speed = 0 }
            })
        end
    end
end)

-- Elimina o comenta la función DrawRadarPanel y su llamada