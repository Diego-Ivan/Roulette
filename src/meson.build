roulette_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
  'Roulette.vala',
  'ValidatableNode.vala',
  'CairoArcNode.vala',
  'GLArcNode.vala',
  'ArcNode.vala',
  'RouletteItem.vala',
]

cc = meson.get_compiler('c')
math = cc.find_library('m', required: true)

roulette_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.2'),
  math,
]

roulette_sources += gnome.compile_resources('roulette-resources',
  'roulette.gresource.xml',
  c_name: 'roulette'
)

executable('roulette', roulette_sources,
  dependencies: roulette_deps,
       install: true,
)
