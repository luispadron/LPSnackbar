
Pod::Spec.new do |s|

  s.name         = "LPSnackbar"
  s.version      = "2.1.2"
  s.summary      = "A flexible and easy to use Snackbar control for iOS."

  s.description  = <<-DESC
  Flexible and customizable Android inspired Snackbar control for iOS devices.
                   DESC

  s.homepage     = "https://github.com/luispadron/LPSnackbar"
  s.screenshots  = "https://raw.githubusercontent.com/luispadron/LPSnackbar/master/.github/Screen1.png"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Luis Padron" => "luispadronn@gmail.com" }
  s.social_media_url   = "http://luispadron.com"

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/luispadron/LPSnackbar.git", :tag => "v#{s.version}" }

  s.source_files  = "LPSnackbar", "LPSnackbar/**/*.{h,m}"
end
