class Webmux < Formula
  desc "Web-based terminal with persistent sessions via webmux-term"
  homepage "https://github.com/alphatechlab/webmux"
  url "https://github.com/alphatechlab/webmux.git", branch: "main"
  version "0.1.3"
  license "MIT"

  depends_on "node"
  depends_on "rust" => :build
  depends_on "python@3"
  depends_on "ffmpeg"

  def install
    # 1. Build webmux-term sidecar
    cd "webmux-term" do
      system "cargo", "build", "--release"
      bin.install "target/release/webmux-term" => "alacritty-sidecar"
    end

    # 2. Install ALL deps (including devDeps for tsc/vite), build, then prune
    system "npm", "install"
    system "npm", "run", "build"
    system "npm", "prune", "--omit=dev"

    # 3. Install server + client assets to libexec
    libexec.install "dist", "node_modules", "package.json", "config.example.cjs"

    # 4. Install whisper files
    (libexec/"whisper").install Dir["whisper/server.py", "whisper/requirements.txt",
                                    "whisper/install.sh", "whisper/config.example.yaml"]

    # 5. Create wrapper script
    node = Formula["node"].opt_bin/"node"
    (bin/"webmux").write <<~EOS
      #!/bin/bash
      exec #{node} "#{libexec}/dist/server/index.js" "$@"
    EOS
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

      The webmux-app manages services automatically.
    EOS
  end

  test do
    assert_match "webmux", shell_output("#{bin}/webmux --help 2>&1", 1)
  end
end
