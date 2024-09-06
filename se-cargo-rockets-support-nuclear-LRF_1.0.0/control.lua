local function get_nuclear_fuel_value()
  local nuclear_fuel = game.fluid_prototypes["nuclear-liquid-rocket-fuel"]
  if nuclear_fuel then
      local fuel_value_str = nuclear_fuel.fuel_value
      if type(fuel_value_str) == "string" then
          local value, unit = string.match(fuel_value_str, "(%d+%.?%d*)(%a+)")
          value = tonumber(value)
          if value then
              if unit == "MJ" then
                  return value * 1000000 -- Convert MJ to J
              elseif unit == "kJ" then
                  return value * 1000 -- Convert kJ to J
              elseif unit == "J" then
                  return value -- Already in J
              end
          end
      elseif type(fuel_value_str) == "number" then
          return fuel_value_str -- Assume it's already in J
      end
      log("Unexpected fuel value format: " .. tostring(fuel_value_str))
  else
      log("Nuclear liquid rocket fuel prototype not found")
  end
  return nil
end

local function register_fuel()
  local nuclear_fuel_value = get_nuclear_fuel_value()
  if not nuclear_fuel_value then
      log("Failed to get nuclear liquid rocket fuel value")
      return
  end

  local lrf_fuel_value = game.fluid_prototypes["se-liquid-rocket-fuel"].fuel_value
  local exchange_rate = nuclear_fuel_value / lrf_fuel_value

  remote.call("se-cargo-rocket-custom-fuel-lib", "add_fuel", {
      name = "nuclear-liquid-rocket-fuel",
      fuel_value = nuclear_fuel_value,
      require_space = false
  })

  log("Registered nuclear liquid rocket fuel with value: " .. nuclear_fuel_value .. " J and exchange rate: " .. exchange_rate)
end

local function on_nth_tick_handler(event)
  register_fuel()
  script.on_nth_tick(1, nil) -- Remove the handler after it runs
end

script.on_init(function()
  script.on_nth_tick(1, on_nth_tick_handler)
end)

script.on_load(function()
  script.on_nth_tick(1, on_nth_tick_handler)
end)

script.on_configuration_changed(function(data)
  if data.mod_changes["se-cargo-rocket-custom-fuel-lib"] or 
     data.mod_changes["space-exploration"] or 
     data.mod_changes["nuclear-liquid-rocket-fuel"] then
      script.on_nth_tick(1, on_nth_tick_handler)
  end
end)