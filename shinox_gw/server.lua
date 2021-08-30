


ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('esx_gangwar:getFlag')
AddEventHandler('esx_gangwar:getFlag', function(flags)
local xPlayers = ESX.GetPlayers()
_source = source
local xSource = ESX.GetPlayerFromId(_source)
    
MySQL.Async.fetchAll(
  'SELECT * FROM flaggen WHERE robbing = @robbing',
  {          
    ['@robbing'] = 1
    },
  function (robbing)
  
    if robbing[1] == nil then
            MySQL.Async.fetchAll(
            'SELECT * FROM flaggen WHERE name = @name',
            {          
              ['@name'] = flags.name
              
              },
            function (results)
              for i=1, #Config.BlacklistedFraks do
                if xSource.getJob().name == Config.BlacklistedFraks[i] then
                  TriggerClientEvent('notifications', _source, 'RED', 'Gangwar','Du bist in keiner berechtigten Fraktion!')
                  return
                elseif xSource.getJob().name == results[1].frak then
                  TriggerClientEvent('notifications', _source, 'RED', 'Gangwar','Das Ganggebiet "' .. results[1].zone_name .. '" gehört deiner Fraktion bereits!')
                  return
                
                end
              end
                    
                    MySQL.Async.execute('UPDATE flaggen SET robbing = 1 WHERE zone_name = @zone_name', {
                      ['@zone_name'] = results[1].zone_name
                    }, function (rowsChanged)
                    end) 
                  
                    MySQL.Async.execute('UPDATE flaggen SET attacker = @attacker WHERE zone_name = @zone_name', {
                      ['@zone_name'] = results[1].zone_name,
                      ['@attacker'] = xSource.getJob().name
                    }, function (rowsChanged)
                    end)  
              
                    TriggerClientEvent('notifications', _source, 'GREEN', 'GANGWAR', 'Du greifst das Ganggebiet "' .. results[1].zone_name .. '" der Fraktion ' .. results[1].frak:gsub("^%l", string.upper) .. ' an!')
                    for i=1, #xPlayers, 1 do
                      local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
                        
                        if xPlayer.getJob().name == results[1].frak then
                            
                            TriggerClientEvent('notifications', xPlayers[i], 'GREEN', 'GANGWAR', 'Dein Ganggebiet "' .. results[1].zone_name .. '" wird von ' .. xSource.getJob().label .. ' angegriffen!')
                        end
                    end

              
            end
          )
        elseif robbing[1] ~= nil then
      TriggerClientEvent('notifications', _source, 'RED', 'Gangwar','Es wird bereits ein Ganggebiet eingenommen!') 
    end
   end
 )

end)

RegisterServerEvent('esx_gangwar:enterDimension')
AddEventHandler('esx_gangwar:enterDimension', function()
 _source = source
local xSource = ESX.GetPlayerFromId(_source)
  MySQL.Async.fetchAll(
    'SELECT * FROM flaggen WHERE robbing = 1',
    {          

      
      },
    function (results)
      if results[1] == nil then
        TriggerClientEvent('notifications', _source, 'RED', 'Gangwar','Es wir gerade kein Ganggebiet eingenommen!') 
    
      elseif xSource.getJob().name == results[1].frak or xSource.getJob().name == results[1].attacker then

        SetPlayerRoutingBucket(_source, 1)
        
        
        TriggerClientEvent('esx_gangwar:enterDimension', _source, results[1].name)
        TriggerClientEvent('esx_gangwar:showNUI', _source, Config.Fraks[results[1].attacker].color, Config.Fraks[results[1].frak].color, results[1].attacker:gsub("^%l", string.upper), results[1].frak:gsub("^%l", string.upper), results[1].attacker, results[1].frak)

      elseif xSource.getJob().name ~= results[1].frak or xSource.getJob().name ~= results[1].attacker then
        TriggerClientEvent('notifications', _source, 'RED', 'Gangwar','Es wird bereits ein Ganggebiet von einer anderen Fraktion eingenommen!')

      end
    end
  )

end)

RegisterServerEvent('esx_gangwar:setBlip')
AddEventHandler('esx_gangwar:setBlip', function()
 _source = source
local xSource = ESX.GetPlayerFromId(_source)
  MySQL.Async.fetchAll(
    'SELECT * FROM flaggen',
    {          
      },
    function (results)
        
        TriggerClientEvent('esx_gangwar:setBlip', _source, results)
    end
  )

end)

RegisterServerEvent('esx_gangwar:leaveDimension')
AddEventHandler('esx_gangwar:leaveDimension', function()
 _source = source
local xPlayer = ESX.GetPlayerFromId(_source)


SetPlayerRoutingBucket(_source, 0)
        
        
TriggerClientEvent('esx_gangwar:leaveDimension', _source)
TriggerClientEvent('esx_gangwar:closeNUI', _source)
end)

RegisterServerEvent('esx_gangwar:killed')
AddEventHandler('esx_gangwar:killed', function(killer)
_source = source
_killer = killer
print(killer)
print(source)
  local xSource = ESX.GetPlayerFromId(_source)
  local xKiller = ESX.GetPlayerFromId(_killer)

  MySQL.Async.fetchAll(
    'SELECT * FROM flaggen WHERE robbing = 1',
    {          

      
      },
    function (results)
      if results[1] ~= nil then
        local killerinfo = {}
        TriggerClientEvent('notifications', _source, 'RED', 'Gangwar', 'Du wurdest von ' .. xKiller.getName() .. ' getötet!')
        
        if xKiller.getJob().name == results[1].frak then
          --RECHTS
            if xKiller.getJob().name == xSource.getJob().name then
                TriggerClientEvent('esx_gangwar:setPoints', -1, true, 'rechts')

                TriggerClientEvent('notifications', _killer, 'RED', 'Gangwar', '-3 Punkte für das Töten eines Fraktionsmitgliedes! (' .. xSource.getName() .. ')')
            elseif xKiller.getJob().name ~= xSource.getJob().name then
                TriggerClientEvent('esx_gangwar:setPoints', -1, false, 'rechts')

                TriggerClientEvent('notifications', _killer, '#00b0ff', 'Gangwar', '+3 Punkte für das Töten eines Gegners! (' .. xSource.getName() .. ')')
            end
        elseif xKiller.getJob().name == results[1].attacker then
          --LINKS
            if xKiller.getJob().name == xSource.getJob().name then
              TriggerClientEvent('esx_gangwar:setPoints', -1, true, 'links')

              TriggerClientEvent('notifications', _killer, 'RED', 'Gangwar', '-3 Punkte für das Töten eines Fraktionsmitgliedes! (' .. xSource.getName() .. ')')
            elseif xKiller.getJob().name ~= xSource.getJob().name then
                TriggerClientEvent('esx_gangwar:setPoints', -1, false, 'links')

                TriggerClientEvent('notifications', _killer, '#00b0ff', 'Gangwar', '+3 Punkte für das Töten eines Gegners! (' .. xSource.getName() .. ')')
            end
        end
          

      end
    end
  )







end)






