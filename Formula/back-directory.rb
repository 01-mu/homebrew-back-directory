class BackDirectory < Formula
  desc "Session-scoped directory backtracking with bash and zsh wrappers"
  homepage "https://github.com/01-mu/back-directory"
  url "https://github.com/01-mu/back-directory/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "152ee3a1b9a4533567f9efe6d40c82f334f2740b08b1c430c9f9a8efbd5f9768"
  license "MIT"
  head "https://github.com/01-mu/back-directory.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args

    pkgshare.install "scripts/bd.bash", "scripts/bd.zsh"
  end

  def caveats
    <<~EOS
      `bd` is a shell wrapper, so you need to source the matching script in your shell rc:

        bash: source "#{opt_pkgshare}/bd.bash"
        zsh:  source "#{opt_pkgshare}/bd.zsh"

      Then start a new shell or source your rc file.
    EOS
  end

  test do
    assert_match "back-directory uses a local SQLite database", shell_output("#{bin}/bd-core --help")
  end
end
