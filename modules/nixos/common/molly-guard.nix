{ pkgs, ... }:
{
  # Wraps reboot/shutdown/halt/poweroff so that, when the command is run
  # from an SSH (or mosh) session, it asks you to type the hostname before
  # doing anything - the classic "meant to reboot box A, actually SSH'd
  # into box B" mistake. Non-interactive and local-console invocations pass
  # straight through. molly-guard already ships hiPrio in nixpkgs, so it
  # takes precedence over systemd's own reboot/shutdown/halt/poweroff.
  environment.systemPackages = [ pkgs.molly-guard ];
}
