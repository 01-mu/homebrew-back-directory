class BackDirectory < Formula
  desc "Session-scoped directory backtracking with bash and zsh wrappers"
  homepage "https://github.com/01-mu/back-directory"
  url "https://github.com/01-mu/back-directory/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "152ee3a1b9a4533567f9efe6d40c82f334f2740b08b1c430c9f9a8efbd5f9768"
  license "MIT"
  head "https://github.com/01-mu/back-directory.git", branch: "main"

  bottle do
    root_url "https://raw.githubusercontent.com/01-mu/homebrew-back-directory/main/bottles"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "9fa3d67a91e68bb214323aced3fa1b709963148868dfdc0c5c2ff17cc2f3b0ec"
  end

  resource "bd-core-aarch64-apple-darwin" do
    url "https://github.com/01-mu/back-directory/releases/download/v0.1.2/bd-core-aarch64-apple-darwin.tar.gz"
    sha256 "e10e9db643145b6d03f78095c2a9f130259dfb0ce64d31aeb87f074bec5dd9ab"
  end

  resource "bd-core-x86_64-apple-darwin" do
    url "https://github.com/01-mu/back-directory/releases/download/v0.1.2/bd-core-x86_64-apple-darwin.tar.gz"
    sha256 "f2ec85774e1580ec038bb5063cf209c84076f7c2f2e6e5ddb4afb1fa033590d7"
  end

  resource "bd-core-x86_64-unknown-linux-gnu" do
    url "https://github.com/01-mu/back-directory/releases/download/v0.1.2/bd-core-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "87813972c7873bd88c41dafa5acd7918b8ab1b2f39f258f858661555f2a4906c"
  end

  def install
    target = if OS.mac? && Hardware::CPU.arm?
      "bd-core-aarch64-apple-darwin"
    elsif OS.mac?
      "bd-core-x86_64-apple-darwin"
    elsif OS.linux? && Hardware::CPU.intel?
      "bd-core-x86_64-unknown-linux-gnu"
    else
      odie "back-directory does not provide a prebuilt release for this platform"
    end

    resource(target).stage do
      bin.install "bd-core"
    end

    pkgshare.install "scripts/bd.bash", "scripts/bd.zsh"
  end

  def post_install
    home = Pathname(ENV.fetch("HOME"))
    append_source_line(select_rc_file(home, ".zshrc", ".zprofile"), %(source "#{opt_pkgshare}/bd.zsh"))
    append_source_line(select_rc_file(home, ".bashrc", ".bash_profile", ".profile"), %(source "#{opt_pkgshare}/bd.bash"))
  end

  def select_rc_file(home, *candidates)
    candidates
      .map { |name| home/name }
      .find { |path| path.exist? && path.writable? } || home/candidates.first
  end

  def append_source_line(rc_path, line)
    rc_path.dirname.mkpath
    rc_path.touch unless rc_path.exist?
    return if rc_path.read.include?(line)

    rc_path.atomic_write("#{rc_path.read}#{rc_path.size.positive? ? "\n" : ""}#{line}\n")
  end

  def caveats
    <<~EOS
      The Homebrew install appended the wrapper source lines when they were missing:

        bash: source "#{opt_pkgshare}/bd.bash"
        zsh:  source "#{opt_pkgshare}/bd.zsh"

      Start a new shell or source your rc file if the current shell was already open.
    EOS
  end

  test do
    assert_match "back-directory uses a local SQLite database", shell_output("#{bin}/bd-core --help")
  end
end
