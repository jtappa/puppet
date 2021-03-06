require 'puppet/application'

class Puppet::Application::Cert < Puppet::Application

  run_mode :master

  attr_accessor :all, :ca, :digest, :signed

  def subcommand
    @subcommand
  end

  def subcommand=(name)
    # Handle the nasty, legacy mapping of "clean" to "destroy".
    sub = name.to_sym
    @subcommand = (sub == :clean ? :destroy : sub)
  end

  option("--clean", "-c") do |arg|
    self.subcommand = "destroy"
  end

  option("--all", "-a") do |arg|
    @all = true
  end

  option("--digest DIGEST") do |arg|
    @digest = arg
  end

  option("--signed", "-s") do |arg|
    @signed = true
  end

  option("--debug", "-d") do |arg|
    options[:debug] = true
    set_log_level
  end

  option("--list", "-l") do |arg|
    self.subcommand = :list
  end

  option("--revoke", "-r") do |arg|
    self.subcommand = :revoke
  end

  option("--generate", "-g") do |arg|
    self.subcommand = :generate
  end

  option("--sign", "-s") do |arg|
    self.subcommand = :sign
  end

  option("--print", "-p") do |arg|
    self.subcommand = :print
  end

  option("--verify", "-v") do |arg|
    self.subcommand = :verify
  end

  option("--fingerprint", "-f") do |arg|
    self.subcommand = :fingerprint
  end

  option("--reinventory") do |arg|
    self.subcommand = :reinventory
  end

  option("--[no-]allow-dns-alt-names") do |value|
    options[:allow_dns_alt_names] = value
  end

  option("--[no-]allow-authorization-extensions") do |value|
    options[:allow_authorization_extensions] = value
  end

  option("--verbose", "-v") do |arg|
    options[:verbose] = true
    set_log_level
  end

  option("--human-readable", "-H") do |arg|
    options[:format] = :human
  end

  option("--machine-readable", "-m") do |arg|
    options[:format] = :machine
  end

  option("--interactive", "-i") do |arg|
    options[:interactive] = true
  end

  option("--assume-yes", "-y") do |arg|
    options[:yes] = true
  end

  def summary
    _("Manage certificates and requests (Disabled)")
  end

  def help
     <<-HELP
This command is no longer functional, please use `puppetserver ca` instead.

puppet-cert(8) -- #{summary}
========

ACTIONS
-------
Every action except 'list' and 'generate' requires a hostname to act on,
unless the '--all' option is set.

* clean:
  Use `puppetserver ca clean --certname NAME[,NAME...]`

* fingerprint:
  Use openssl directly:
  `openssl x509 -noout -fingerprint -<digest> -inform pem -in certificate.crt`

* generate:
  Use `puppetserver ca generate --certname NAME[,NAME...]`

* list:
  Use `puppetserver ca list [--all]`

* print:
  Use openssl directly:
  `openssl x509 -noout -text -in certificate.pem`

* revoke:
  Use `puppetserver ca revoke --cerntname NAME[,NAME...]`

* sign:
  Use `puppetserver ca sign --cerntname NAME[,NAME...]`

* verify:
  Use `puppet ssl verify [--certname NAME]`

* reinventory:
  Removed.

OPTIONS
-------
There are a couple important notes about previously-supported options.

* --allow-dns-alt-names:
  In order to sign certificates with subject alternative names using
  `puppetserver ca sign`, the `allow-subject-alt-names` setting must be
  set to true in the `certificate-authority` section of Puppet Server's
  config.

* --allow-authorization-extensions:
  In order to sign certificates with authorization extensions using
  `puppetserver ca sign`, the `allow-authorization-extensions` setting must be
  set to true in the `certificate-authority` section of Puppet Server's
  config.
HELP
  end

  def main
    help
  end

  def setup
    deprecate
  end

  def parse_options
    # handle the bareword subcommand pattern.
    result = super
    unless self.subcommand then
      if sub = self.command_line.args.shift then
        self.subcommand = sub
      else
        puts help
        exit
      end
    end

    result
  end
end
