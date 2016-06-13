# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :nerves_io_led, names: [ green: "led0" ]

config :distributed_spinner, initial_nodes:
  [
    :'1@192.168.2.10',
    :'2@192.168.2.11',
    :'3@192.168.2.12',
  ]

import_config "#{Mix.Project.config[:target]}/config.exs"
