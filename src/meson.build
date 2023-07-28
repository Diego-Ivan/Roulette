roulette_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
  'Roulette.vala',
]

roulette_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.2'),
]

roulette_sources += gnome.compile_resources('roulette-resources',
  'roulette.gresource.xml',
  c_name: 'roulette'
)

executable('roulette', roulette_sources,
  dependencies: roulette_deps,
       install: true,
)
