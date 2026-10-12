class Claudius < Formula
  desc "Claude Code usage limits in your macOS menu bar"
  homepage "https://abd-k.github.io/claudius-claude-code-usage/"
  url "https://github.com/Abd-K/claudius-claude-code-usage/archive/refs/tags/v1.1.1.tar.gz"
  sha256 "ed7d1b043ac1a624217afba04d7597da975910647c16a7e9d16b7866d9708950"
  license "MIT"

  depends_on macos: :ventura

  def install
    system "swiftc", "-O", "-parse-as-library", "-o", "Claudius", *Dir["Sources/*.swift"]
    contents = prefix/"Claudius.app/Contents"
    (contents/"MacOS").install "Claudius"
    contents.install "Info.plist"
    (contents/"Resources").install "AppIcon.icns"
    system "codesign", "--force", "--sign", "-", prefix/"Claudius.app"

    bin.install "claude-usage"
    (bin/"claudius").write <<~SH
      #!/bin/zsh
      # Put Claudius in Applications (replacing an older copy) and start it.
      set -e
      dest=/Applications
      [ -w "$dest" ] || { dest="$HOME/Applications"; mkdir -p "$dest"; }
      pkill -x Claudius 2>/dev/null || true
      rm -rf "$dest/Claudius.app"
      cp -R "#{opt_prefix}/Claudius.app" "$dest/"
      open "$dest/Claudius.app"
      echo "Claudius is running in your menu bar ($dest/Claudius.app)."
    SH
    chmod 0755, bin/"claudius"
  end

  def caveats
    <<~EOS
      Run `claudius` to put Claudius in your Applications folder and start it.
      Run it again after `brew upgrade claudius` to switch to the new version.
      Claudius reads the sign-in Claude Code keeps, so sign in to `claude` first.
    EOS
  end

  test do
    assert_match "usage", shell_output("#{bin}/claude-usage --help")
    assert_path_exists prefix/"Claudius.app/Contents/MacOS/Claudius"
  end
end
