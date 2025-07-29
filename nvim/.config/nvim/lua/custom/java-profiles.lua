-- Java + Spring Boot Profile Manager for nvim-jdtls
-- Streamlined for Spring Boot development with Spring profile integration
-- Compatible with: nvim-jdtls, which-key

local M = {}

-- ===============================================
-- 🍃 SPRING APPLICATION PROFILE INTEGRATION
-- ===============================================

-- Detected Spring profiles from application.yml/properties files
M.spring_profiles = {}

-- Scan for Spring application profiles
function M.scan_spring_profiles()
  local cwd = vim.fn.getcwd()
  local profiles = {}
  
  -- Common Spring profile file patterns
  local profile_files = {
    "src/main/resources/application-*.yml",
    "src/main/resources/application-*.yaml", 
    "src/main/resources/application-*.properties",
    "application-*.yml",
    "application-*.yaml",
    "application-*.properties",
  }
  
  for _, pattern in ipairs(profile_files) do
    local files = vim.fn.glob(cwd .. "/" .. pattern, false, true)
    for _, file in ipairs(files) do
      local filename = vim.fn.fnamemodify(file, ":t")
      local profile_name = string.match(filename, "application%-([^%.]+)%.")
      if profile_name then
        table.insert(profiles, profile_name)
      end
    end
  end
  
  -- Add common development profiles if not found
  if #profiles == 0 then
    profiles = {"dev", "local", "test"}
  end
  
  M.spring_profiles = profiles
  return profiles
end

-- Get active Spring profiles
function M.get_active_spring_profiles()
  return vim.env.SPRING_PROFILES_ACTIVE or "default"
end

-- Set Spring profiles for next run
function M.set_spring_profiles(profiles)
  vim.env.SPRING_PROFILES_ACTIVE = profiles
  vim.notify("🍃 Spring profiles set: " .. profiles, vim.log.levels.INFO)
end

-- ===============================================
-- 📋 SIMPLIFIED PROFILE DEFINITIONS  
-- ===============================================

M.profiles = {
  -- 🍃 Default Profile (Spring Boot focused)
  default = {
    name = "🍃 Spring Boot",
    description = "Spring Boot development (default)",
    settings = {
      java = {
        completion = {
          maxResults = 100,
          favoriteStaticMembers = {
            -- Spring Framework
            "org.springframework.http.HttpStatus.*",
            "org.springframework.http.MediaType.*",
            "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
            "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
            
            -- Spring Boot
            "org.springframework.boot.test.context.SpringBootTest.*", 
            "org.springframework.test.context.junit.jupiter.SpringJUnitConfig.*",
            
            -- Standard Java
            "java.util.Objects.requireNonNull",
            "java.util.Arrays.*",
            "java.util.Collections.*",
            "java.util.Optional.*",
            "java.time.LocalDateTime.*",
            "java.util.stream.Collectors.*",
            
            -- Testing
            "org.junit.jupiter.api.Assertions.*",
            "org.mockito.Mockito.*",
            "org.hamcrest.Matchers.*",
          },
          importOrder = {
            "java",
            "javax",
            "org.springframework",
            "org.junit",
            "org.mockito",
            "com",
            "static org.springframework",
            "static org.junit",
            "static org.mockito",
          },
        },
        format = {
          settings = {
            profile = "GoogleStyle",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 3,
            staticStarThreshold = 2,
          },
        },
        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
          },
          insertionLocation = "afterCursor",
        },
      },
    },
    bundles = {},
    on_apply = function()
      M.scan_spring_profiles()
      local profiles = M.get_active_spring_profiles()
      vim.notify("🍃 Applied: Spring Boot Profile (active: " .. profiles .. ")", vim.log.levels.INFO)
    end,
  },

  -- 🍃 Enhanced Spring Boot Profile
  spring = {
    name = "🍃 Spring Boot Pro",
    description = "Enhanced Spring Boot with microservices focus",
    settings = {
      java = {
        completion = {
          maxResults = 150,
          favoriteStaticMembers = {
            -- Spring Framework
            "org.springframework.http.HttpStatus.*",
            "org.springframework.http.MediaType.*",
            "org.springframework.http.ResponseEntity.*",
            "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
            "org.springframework.test.web.servlet.result.MockMvcResultMatchers.*",
            
            -- Spring Boot
            "org.springframework.boot.test.context.SpringBootTest.*",
            "org.springframework.test.context.junit.jupiter.SpringJUnitConfig.*",
            "org.springframework.boot.autoconfigure.condition.*",
            
            -- Spring Security
            "org.springframework.security.access.prepost.*",
            "org.springframework.security.core.authority.SimpleGrantedAuthority.*",
            
            -- Spring Data
            "org.springframework.data.domain.PageRequest.*",
            "org.springframework.data.domain.Sort.*",
            
            -- Standard Java
            "java.util.Objects.requireNonNull",
            "java.util.Arrays.*",
            "java.util.Collections.*",
            "java.util.Optional.*",
            "java.time.LocalDateTime.*",
            "java.util.stream.Collectors.*",
            "java.util.concurrent.CompletableFuture.*",
            
            -- Testing
            "org.junit.jupiter.api.Assertions.*",
            "org.mockito.Mockito.*",
            "org.hamcrest.Matchers.*",
            "org.testcontainers.junit.jupiter.*",
          },
          importOrder = {
            "java",
            "javax",
            "org.springframework",
            "org.junit",
            "org.mockito", 
            "org.testcontainers",
            "com",
            "static org.springframework",
            "static org.junit",
            "static org.mockito",
          },
        },
        format = {
          settings = {
            profile = "GoogleStyle",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 3,
            staticStarThreshold = 2,
          },
        },
        codeGeneration = {
          toString = {
            template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
          },
          insertionLocation = "afterCursor",
          generateComments = true,
        },
        maven = {
          downloadSources = true,
          updateSnapshots = false,
        },
      },
    },
    bundles = {},
    on_apply = function()
      M.scan_spring_profiles()
      local profiles = M.get_active_spring_profiles()
      vim.notify("🍃 Applied: Spring Boot Pro Profile (active: " .. profiles .. ")", vim.log.levels.INFO)
    end,
  },
}

-- ===============================================
-- 📊 PROFILE MANAGEMENT FUNCTIONS
-- ===============================================

-- Current active profile
M.current_profile = "default"

-- Get profile by name
function M.get_profile(name)
  return M.profiles[name] or M.profiles.default
end

-- Get current profile
function M.get_current_profile()
  return M.get_profile(M.current_profile)
end

-- List all available profiles
function M.list_profiles()
  local profile_list = {}
  for name, profile in pairs(M.profiles) do
    table.insert(profile_list, {
      name = name,
      display_name = profile.name,
      description = profile.description,
    })
  end
  return profile_list
end

-- Apply profile to JDTLS configuration
function M.apply_profile(profile_name, base_config)
  local profile = M.get_profile(profile_name)
  if not profile then
    vim.notify("❌ Profile not found: " .. profile_name, vim.log.levels.ERROR)
    return base_config
  end

  M.current_profile = profile_name
  
  -- Deep merge profile settings with base config
  local new_config = vim.deepcopy(base_config)
  
  -- Merge settings
  if profile.settings then
    new_config.settings = vim.tbl_deep_extend("force", new_config.settings or {}, profile.settings)
  end
  
  -- Merge bundles
  if profile.bundles and #profile.bundles > 0 then
    new_config.init_options = new_config.init_options or {}
    new_config.init_options.bundles = vim.list_extend(new_config.init_options.bundles or {}, profile.bundles)
  end
  
  -- Execute profile-specific setup
  if profile.on_apply then
    profile.on_apply()
  end
  
  return new_config
end

-- Auto-detect profile (simplified for Spring Boot focus)
function M.auto_detect_profile()
  local cwd = vim.fn.getcwd()
  
  -- Always default to Spring Boot for simplified system
  -- Check for Spring Boot indicators
  if vim.fn.filereadable(cwd .. "/pom.xml") == 1 then
    local pom_content = vim.fn.readfile(cwd .. "/pom.xml")
    for _, line in ipairs(pom_content) do
      if string.find(line, "spring-boot") then
        return "spring"  -- Use enhanced profile if Spring Boot detected
      end
    end
  end
  
  if vim.fn.filereadable(cwd .. "/build.gradle") == 1 or vim.fn.filereadable(cwd .. "/build.gradle.kts") == 1 then
    local build_files = {}
    if vim.fn.filereadable(cwd .. "/build.gradle") == 1 then
      vim.list_extend(build_files, vim.fn.readfile(cwd .. "/build.gradle"))
    end
    if vim.fn.filereadable(cwd .. "/build.gradle.kts") == 1 then
      vim.list_extend(build_files, vim.fn.readfile(cwd .. "/build.gradle.kts"))
    end
    
    for _, line in ipairs(build_files) do
      if string.find(line, "spring-boot") then
        return "spring"  -- Use enhanced profile if Spring Boot detected
      end
    end
  end
  
  -- Default to basic Spring Boot profile
  return "default"
end

-- Interactive profile selector using vim.ui.select
function M.select_profile(callback)
  local profiles = M.list_profiles()
  
  -- Create display options
  local options = {}
  for _, profile in ipairs(profiles) do
    table.insert(options, profile.display_name .. " - " .. profile.description)
  end
  
  vim.ui.select(options, {
    prompt = "Select Java Profile:",
    format_item = function(item)
      return item
    end,
  }, function(choice, idx)
    if choice and idx then
      local selected_profile = profiles[idx]
      M.current_profile = selected_profile.name
      if callback then
        callback(selected_profile.name)
      end
      vim.notify("🎯 Selected: " .. selected_profile.display_name, vim.log.levels.INFO)
    end
  end)
end

-- Quick profile switch function
function M.quick_switch(profile_name)
  if not M.profiles[profile_name] then
    vim.notify("❌ Unknown profile: " .. profile_name, vim.log.levels.ERROR)
    return false
  end
  
  M.current_profile = profile_name
  vim.notify("🔄 Switched to: " .. M.profiles[profile_name].name .. " (restart required)", vim.log.levels.WARN)
  return true
end

-- Get profile status for statusline
function M.get_status()
  local profile = M.get_current_profile()
  local spring_profiles = M.get_active_spring_profiles()
  return profile.name .. " (" .. spring_profiles .. ")"
end

-- ===============================================
-- 🚀 SPRING BOOT RUN COMMANDS
-- ===============================================

-- Run Spring Boot application with specific profiles
function M.run_spring_app(profiles, additional_args)
  local cwd = vim.fn.getcwd()
  local cmd = ""
  
  -- Set Spring profiles
  if profiles then
    M.set_spring_profiles(profiles)
  end
  
  -- Build command based on project type
  if vim.fn.filereadable(cwd .. "/mvnw") == 1 then
    cmd = "./mvnw spring-boot:run"
  elseif vim.fn.filereadable(cwd .. "/pom.xml") == 1 then
    cmd = "mvn spring-boot:run"
  elseif vim.fn.filereadable(cwd .. "/gradlew") == 1 then
    cmd = "./gradlew bootRun"
  elseif vim.fn.filereadable(cwd .. "/build.gradle") == 1 or vim.fn.filereadable(cwd .. "/build.gradle.kts") == 1 then
    cmd = "gradle bootRun"
  else
    vim.notify("❌ No Spring Boot project detected", vim.log.levels.ERROR)
    return
  end
  
  -- Add additional arguments
  if additional_args then
    cmd = cmd .. " " .. additional_args
  end
  
  -- Run in terminal
  vim.cmd("split | terminal " .. cmd)
  vim.notify("🚀 Running Spring Boot app with profiles: " .. (profiles or M.get_active_spring_profiles()), vim.log.levels.INFO)
end

-- Interactive Spring profile selector
function M.select_spring_profiles(callback)
  M.scan_spring_profiles()
  
  if #M.spring_profiles == 0 then
    vim.notify("ℹ️ No Spring profiles found, using default", vim.log.levels.INFO)
    if callback then callback("default") end
    return
  end
  
  vim.ui.select(M.spring_profiles, {
    prompt = "Select Spring Profiles (comma-separated):",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if choice then
      if callback then
        callback(choice)
      else
        M.set_spring_profiles(choice)
      end
    end
  end)
end

return M