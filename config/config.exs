# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :nerves, :firmware,
  rootfs_additions: "config/rootfs-additions/"

config :nerves_io_led, names: [ green: "led0" ]

import_config "#{Mix.Project.config[:target]}/config.exs"
