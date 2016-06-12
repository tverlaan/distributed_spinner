defmodule DistributedSpinner.Mixfile do
  use Mix.Project

  @target System.get_env("NERVES_TARGET") || "rpi2"

  def project do
    [app: :distributed_spinner,
     version: "0.0.1",
     target: @target,
     archives: [nerves_bootstrap: "0.1.2"],
     deps_path: "deps/#{@target}",
     build_path: "_build/#{@target}",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps ++ system(@target)]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {DistributedSpinner, []},
     applications: [
        :nerves,
        :logger,
        :nerves_networking,
        :nodefinder,
        :phoenix_pubsub,
        :nerves_io_led
      ]]
  end

  def deps do
    [
      {:nerves, "~> 0.3.0"},
      {:nerves_networking, github: "nerves-project/nerves_networking"},
      {:nodefinder, "~> 1.5"},
      {:phoenix_pubsub, "~> 1.0.0-rc.0"},
      {:nerves_io_led, github: "nerves-project/nerves_io_led"}
    ]
  end

  def system("rpi") do
    [{:nerves_system_rpi, github: "nerves-project/nerves_system_rpi", branch: "stable"}]
  end

  def system(target) do
    [{:"nerves_system_#{target}", ">= 0.0.0"}]
  end

  def aliases do
    ["deps.precompile": ["nerves.precompile", "deps.precompile"],
     "deps.loadpaths":  ["deps.loadpaths", "nerves.loadpaths"]]
  end

end
