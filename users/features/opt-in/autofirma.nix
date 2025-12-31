# users/features/opt-in/autofirma.nix
#
# AutoFirma - Spanish public administration digital signing
# Integrates with Firefox and supports YubiKey/smart card certificates
#
# Requires: yubikey feature for smart card support
#
{ inputs, ... }:
{
  imports = [ inputs.autofirma-nix.homeManagerModules.default ];

  programs.autofirma = {
    enable = true;

    # Firefox integration - must match profile name in firefox.nix
    firefoxIntegration.profiles = {
      "uu5fkg20.default-release" = {
        enable = true;
      };
    };

    # AutoFirma configuration
    config = {
      # Skip confirmation when closing
      omitAskOnClose = true;

      # Enable JMultiCard for smart card support
      enabledJmulticard = true;

      # Signature settings
      allowInvalidSignatures = false;
      cadesImplicitMode = true;
    };
  };
}
