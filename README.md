Debian/Ubuntu repo for the bootc package

Check https://github.com/jumpyvi/ubuntu-bootc-remix for a ready-made Bootc Ubuntu image

# Install

## Import GPG key
`curl -fsSL https://raw.githubusercontent.com/bootc-shindig/bootc-deb/refs/heads/main/bootc-deb.asc | sudo gpg --dearmor -o /usr/share/keyrings/bootc-deb.gpg`

## Add repo
`echo "deb [signed-by=/usr/share/keyrings/bootc-deb.gpg] https://bootc-shindig.github.io/bootc-deb/debian stable main" | sudo tee /etc/apt/sources.list.d/bootc-deb.list`

`sudo apt-get update`


# Available Packages

## Bootc

https://bootc.dev/

> Compatible with sid/questing and newer

`sudo apt-get install bootc`

Latest bootc release archive from gitlab

## Foot (git)

https://codeberg.org/dnkl/foot

> Compatible with trixie/questing and newer

`sudo apt-get install foot-git`

## Homebrew

https://github.com/ublue-os/brew

> Compatible with trixie/questing and newer

`sudo apt-get install homebrew`


## BrewProxy (git)

https://codeberg.org/HastD/brew-proxy

> Compatible with trixie/questing and newer

`sudo apt-get install brewproxy-git`


# Thanks

Homebrew packages adapted from https://github.com/Lumaeris/homebrew-arch