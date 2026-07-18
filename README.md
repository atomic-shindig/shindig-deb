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

> Compatible with >= debian:sid or >= ubuntu:questing

`sudo apt-get install bootc`

Latest bootc release archive from gitlab

## Foot (git)

https://codeberg.org/dnkl/foot

> Compatible with >= debian:trixie or >= ubuntu:questing

`sudo apt-get install foot-git`

## Homebrew
...

## BrewProxy (git)
