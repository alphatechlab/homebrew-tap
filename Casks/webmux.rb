cask "webmux" do
  version "1.1.1"
  sha256 "d5191c872b47462b6ab5940e56a6fdea5e7bc78433bc8c5ac7a4e9b99cce5d85"

  url "https://github.com/alphatechlab/webmux-app/releases/download/v#{version}/Webmux.app.tar.gz"
  name "Webmux"
  desc "Menu bar app for webmux — install, manage, and access your terminal from anywhere"
  homepage "https://github.com/alphatechlab/webmux"

  app "Webmux.app"

  postflight do
    system_command "/usr/bin/xattr", args: ["-cr", "#{appdir}/Webmux.app"]
  end

  zap trash: [
    "~/Library/LaunchAgents/com.user.webmux.plist",
    "~/Library/LaunchAgents/com.user.webmux-whisper.plist",
  ]
end
