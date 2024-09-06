local function register_fuel()
  -- We'll use game.fluid_prototypes here, which is available during runtime
  local lrf_fuel_value = game.fluid_prototypes["se-liquid-rocket-fuel"].fuel_value
  local biomethanol_fuel_value = lrf_fuel_value / 2.6667

  remote.call("se-cargo-rocket-custom-fuel-lib", "add_fuel", {
      name = "biomethanol",
      fuel_value = biomethanol_fuel_value,
      require_space = false
  })
end

-- We'll use on_init and on_load to ensure this runs in all scenarios
script.on_init(function()
  -- We need to delay the registration until the first tick
  script.on_nth_tick(1, function(event)
      register_fuel()
      script.on_nth_tick(1, nil) -- Remove the handler after it runs
  end)
end)

script.on_load(function()
  -- Similar approach for on_load
  script.on_nth_tick(1, function(event)
      register_fuel()
      script.on_nth_tick(1, nil)
  end)
end)

-- We'll also use on_configuration_changed to handle mod updates
script.on_configuration_changed(function(data)
  -- Check if our mod or any dependency was changed
  if data.mod_changes["se-cargo-rocket-custom-fuel-lib"] or 
     data.mod_changes["space-exploration"] or 
     data.mod_changes["Krastorio2"] then
      -- Again, delay the registration
      script.on_nth_tick(1, function(event)
          register_fuel()
          script.on_nth_tick(1, nil)
      end)
  end
end)