# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: Mix.env()

environment :prod do
  set commands: [
    config: "rel/commands/config.sh"
  ]
  set include_erts: true
  set include_src: false
  set cookie: :"1u[<S!I(rduF/Rzy8)&A<,$D{;y:&av9?V],2S/37FKidw5JKpq|j17^D2Gz]N=m"
  set config_providers: [
    {Imager.Config, path: "/etc/imager/config.toml"},
    {Imager.Config, path: "${RELEASE_ROOT_DIR}/etc/imager/config.toml"},
    {Imager.Config, path: "${IMAGER_CONFIG}"},
  ]
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :imager do
  set version: current_version(:imager)
  set applications: [
    :imager,
    :runtime_tools
  ]
end
