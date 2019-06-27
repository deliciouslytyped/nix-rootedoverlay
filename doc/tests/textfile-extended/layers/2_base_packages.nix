self: super: {
  textRoot =
    super.nixpkgs.makeOverridable ({plugins ? []}:
      super.nixpkgs.writeShellScript "theroot" ''
        cat << EOF
        ${super.lib.gen (["I am ${self.config.iam}"] ++ plugins)}
        EOF
        '') {};
  }
