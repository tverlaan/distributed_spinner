# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :distributed_spinner, if_eth0: [
    mode: "static",
    ip: "192.168.2.11",
    router: "192.168.2.1",
    mask: "24",
    subnet: "255.255.255.0",
    hostname: "dist_spinner"
  ]

config :nerves_io_led, names: [ green: "led1" ]
