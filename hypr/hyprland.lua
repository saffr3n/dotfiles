local mainMod  = 'SUPER + '
local ipc      = 'noctalia-shell ipc call '
local menu     = ipc .. 'launcher toggle'
local terminal = 'kitty'
local files    = 'kitty -e yazi'

local colors = {
  primary   = 'rgb(7aa2f7)',
  secondary = 'rgb(bb9af7)',
  error     = 'rgb(f7768e)',
  surface   = 'rgb(1a1b26)',
  shadow    = 'rgba(1a1b2699)',
}

hl.monitor({
  output   = '',
  mode     = 'preferred',
  position = 'auto',
  scale    = 1,
})

hl.on('hyprland.start', function()
  hl.exec_cmd('noctalia-shell')
end)

hl.config({
  general = {
    gaps_in  = 2,
    gaps_out = 4,

    border_size      = 2,
    resize_on_border = true,

    col = {
      active_border   = colors.primary,
      inactive_border = colors.surface,
    },

    allow_tearing = false,
    layout        = 'dwindle',
  },

  group = {
    col = {
      border_active          = colors.secondary,
      border_inactive        = colors.surface,
      border_locked_active   = colors.error,
      border_locked_inactive = colors.surface,
    },

    groupbar = {
      col = {
        active          = colors.secondary,
        inactive        = colors.surface,
        locked_active   = colors.error,
        locked_inactive = colors.surface,
      },
    },
  },

  decoration = {
    rounding         = 8,
    rounding_power   = 2,
    active_opacity   = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled      = true,
      range        = 4,
      render_power = 3,
      color        = colors.shadow,
    },

    blur = {
      enabled  = true,
      size     = 3,
      passes   = 1,
      vibrancy = 0.1696,
    },
  },

  animations = { enabled = true },
})

hl.curve('easeOutQuint',   { type = 'bezier', points = { { 0.23, 1    }, { 0.32, 1 } } })
hl.curve('easeInOutCubic', { type = 'bezier', points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve('linear',         { type = 'bezier', points = { { 0, 0       }, { 1, 1    } } })
hl.curve('almostLinear',   { type = 'bezier', points = { { 0.5, 0.5   }, { 0.75, 1 } } })
hl.curve('quick',          { type = 'bezier', points = { { 0.15, 0    }, { 0.1, 1  } } })
hl.curve('easy',           { type = 'spring', mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = 'global',        enabled = true, speed = 10,   bezier = 'default'                           })
hl.animation({ leaf = 'border',        enabled = true, speed = 5.39, bezier = 'easeOutQuint'                      })
hl.animation({ leaf = 'windows',       enabled = true, speed = 4.79, spring = 'easy'                              })
hl.animation({ leaf = 'windowsIn',     enabled = true, speed = 4.1,  spring = 'easy',         style = 'popin 87%' })
hl.animation({ leaf = 'windowsOut',    enabled = true, speed = 1.49, bezier = 'linear',       style = 'popin 87%' })
hl.animation({ leaf = 'fadeIn',        enabled = true, speed = 1.73, bezier = 'almostLinear'                      })
hl.animation({ leaf = 'fadeOut',       enabled = true, speed = 1.46, bezier = 'almostLinear'                      })
hl.animation({ leaf = 'fade',          enabled = true, speed = 3.03, bezier = 'quick'                             })
hl.animation({ leaf = 'layers',        enabled = true, speed = 3.81, bezier = 'easeOutQuint'                      })
hl.animation({ leaf = 'layersIn',      enabled = true, speed = 4,    bezier = 'easeOutQuint', style = 'fade'      })
hl.animation({ leaf = 'layersOut',     enabled = true, speed = 1.5,  bezier = 'linear',       style = 'fade'      })
hl.animation({ leaf = 'fadeLayersIn',  enabled = true, speed = 1.79, bezier = 'almostLinear'                      })
hl.animation({ leaf = 'fadeLayersOut', enabled = true, speed = 1.39, bezier = 'almostLinear'                      })
hl.animation({ leaf = 'workspaces',    enabled = true, speed = 1.94, bezier = 'almostLinear', style = 'fade'      })
hl.animation({ leaf = 'workspacesIn',  enabled = true, speed = 1.21, bezier = 'almostLinear', style = 'fade'      })
hl.animation({ leaf = 'workspacesOut', enabled = true, speed = 1.94, bezier = 'almostLinear', style = 'fade'      })
hl.animation({ leaf = 'zoomFactor',    enabled = true, speed = 7,    bezier = 'quick'                             })

hl.config({
  dwindle   = { preserve_split = true },
  master    = { new_status = 'master' },
  scrolling = { fullscreen_on_one_column = true },
})

hl.config({
  misc = {
    disable_hyprland_logo    = true,
    disable_splash_rendering = true,
    background_color         = colors.surface,
  },
})

hl.config({
  input = {
    kb_layout  = 'us,ru,tr',
    kb_variant = '',
    kb_model   = '',
    kb_options = 'grp:win_space_toggle',
    kb_rules   = '',

    numlock_by_default = true,
    follow_mouse       = 1,
    sensitivity        = 0, -- -1.0 - 1.0, 0 means no modification
    touchpad           = { natural_scroll = true },
  },
})

hl.gesture({
  fingers   = 3,
  direction = 'horizontal',
  action    = 'workspace',
})

hl.bind(mainMod .. 'D',         hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. 'Return',    hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. 'E',         hl.dsp.exec_cmd(files))
hl.bind(mainMod .. 'Q',         hl.dsp.window.close())
hl.bind(mainMod .. 'SHIFT + Q', hl.dsp.window.kill())
hl.bind(mainMod .. 'F',         hl.dsp.window.fullscreen({ action = 'toggle' }))
hl.bind(mainMod .. 'V',         hl.dsp.window.float({ action = 'toggle' }))
hl.bind(mainMod .. 'P',         hl.dsp.window.pseudo({ action = 'toggle' }))
hl.bind(mainMod .. 'G',         hl.dsp.layout('togglesplit')) -- dwindle
hl.bind(mainMod .. 'M',         hl.dsp.exec_cmd(ipc .. 'sessionMenu toggle'))

hl.bind('Print', hl.dsp.exec_cmd('grimblast -nf copysave area'))

hl.bind('ALT + Tab',         hl.dsp.window.cycle_next({ next = true  }))
hl.bind('ALT + SHIFT + Tab', hl.dsp.window.cycle_next({ next = false }))

hl.bind(mainMod .. 'H', hl.dsp.focus({ direction = 'left'  }))
hl.bind(mainMod .. 'J', hl.dsp.focus({ direction = 'down'  }))
hl.bind(mainMod .. 'K', hl.dsp.focus({ direction = 'up'    }))
hl.bind(mainMod .. 'L', hl.dsp.focus({ direction = 'right' }))

hl.bind(mainMod .. 'SHIFT + H', hl.dsp.window.swap({ direction = 'left'  }))
hl.bind(mainMod .. 'SHIFT + J', hl.dsp.window.swap({ direction = 'down'  }))
hl.bind(mainMod .. 'SHIFT + K', hl.dsp.window.swap({ direction = 'up'    }))
hl.bind(mainMod .. 'SHIFT + L', hl.dsp.window.swap({ direction = 'right' }))

hl.bind(mainMod .. 'CTRL + H', hl.dsp.window.resize({ x = -64, y =   0, relative = true }), { repeating = true })
hl.bind(mainMod .. 'CTRL + J', hl.dsp.window.resize({ x =   0, y =  64, relative = true }), { repeating = true })
hl.bind(mainMod .. 'CTRL + K', hl.dsp.window.resize({ x =   0, y = -64, relative = true }), { repeating = true })
hl.bind(mainMod .. 'CTRL + L', hl.dsp.window.resize({ x =  64, y =   0, relative = true }), { repeating = true })

hl.bind(mainMod .. 'ALT + H', hl.dsp.window.move({ x = -64, y =   0, relative = true }), { repeating = true })
hl.bind(mainMod .. 'ALT + J', hl.dsp.window.move({ x =   0, y =  64, relative = true }), { repeating = true })
hl.bind(mainMod .. 'ALT + K', hl.dsp.window.move({ x =   0, y = -64, relative = true }), { repeating = true })
hl.bind(mainMod .. 'ALT + L', hl.dsp.window.move({ x =  64, y =   0, relative = true }), { repeating = true })

for i = 1, 10 do
  local key = i % 10
  hl.bind(mainMod .. key,               hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. 'SHIFT + ' .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. 'S',         hl.dsp.workspace.toggle_special('magic'))
hl.bind(mainMod .. 'SHIFT + S', hl.dsp.window.move({ workspace = 'special:magic' }))

hl.bind(mainMod .. 'mouse_down', hl.dsp.focus({ workspace = 'e+1' }))
hl.bind(mainMod .. 'mouse_up',   hl.dsp.focus({ workspace = 'e-1' }))

hl.bind(mainMod .. 'mouse:272', hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. 'mouse:273', hl.dsp.window.resize(), { mouse = true })

hl.bind('XF86AudioRaiseVolume',  hl.dsp.exec_cmd(ipc .. 'volume increase'),     { locked = true, repeating = true })
hl.bind('XF86AudioLowerVolume',  hl.dsp.exec_cmd(ipc .. 'volume decrease'),     { locked = true, repeating = true })
hl.bind('XF86MonBrightnessUp',   hl.dsp.exec_cmd(ipc .. 'brightness increase'), { locked = true, repeating = true })
hl.bind('XF86MonBrightnessDown', hl.dsp.exec_cmd(ipc .. 'brightness decrease'), { locked = true, repeating = true })

-- Ignore maximize requests from all apps
hl.window_rule({
  name           = 'suppress-maximize-events',
  match          = { class = '.*' },
  suppress_event = 'maximize',
})

-- Fix some dragging issues with XWayland
hl.window_rule({
  name  = 'fix-xwayland-drags',
  match = {
    class      = '^$',
    title      = '^$',
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },
  no_focus = true,
})
