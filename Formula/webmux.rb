class Webmux < Formula
  desc "Web-based terminal with persistent sessions via Alacritty sidecar"
  homepage "https://github.com/alphatechlab/webmux"
  url "https://github.com/alphatechlab/webmux.git", branch: "main"
  version "0.1.0"
  license "MIT"

  depends_on "node"
  depends_on "rust" => :build
  depends_on "python@3"

  def install
    # 1. Build Alacritty sidecar
    cd "alacritty-sidecar" do
      system "cargo", "build", "--release"
      bin.install "target/release/alacritty-sidecar"
    end

    # 2. Install Node dependencies and build
    system "npm", "install", "--omit=dev"
    system "npm", "run", "build"

    # 3. Install server + client assets to libexec
    libexec.install "dist", "node_modules", "package.json", "config.example.cjs"

    # 4. Install whisper files
    (libexec/"whisper").install Dir["whisper/server.py", "whisper/requirements.txt",
                                    "whisper/install.sh", "whisper/config.example.yaml"]

    # 5. Create wrapper script
    (bin/"webmux").write_env_script libexec/"dist/server/index.js",
      NODE_ENV: "production",
      PATH:     "#{Formula["node"].opt_bin}:$PATH"

    # Make wrapper use node explicitly
    inreplace bin/"webmux" do |s|
      s.gsub!(/^exec /, "exec #{Formula["node"].opt_bin}/node ")
    end
  end

  def post_install
    # Create config from example if it doesn't exist
    unless (libexec/"config.cjs").exist?
      cp libexec/"config.example.cjs", libexec/"config.cjs"
    end
  end

  def caveats
    <<~EOS
      webmux has been installed to #{libexec}

      To configure:
        #{libexec}/config.cjs

      To start manually:
        webmux

      Whisper (optional voice input, macOS Apple Silicon only):
        cd #{libexec}/whisper && bash install.sh

      The webmux-client app manages services automatically.
    EOS
  end

  test do
    assert_match "webmux", shell_output("#{bin}/webmux --help 2>&1", 1)
  end
end
