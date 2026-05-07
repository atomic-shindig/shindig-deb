Debian/Ubuntu repo for the bootc package

# Compatibility
- Debian
  - Forky, Sid
- Ubuntu
  - Questing, Resolute
- PikaOS
  - Latest

# Install

## Import GPG key
`curl -fsSL https://raw.githubusercontent.com/jumpyvi/bootc-deb/refs/heads/main/bootc-deb.asc | sudo gpg --dearmor -o /usr/share/keyrings/bootc-deb.gpg`

## Add repo
`echo "deb [signed-by=/usr/share/keyrings/bootc-deb.gpg] https://jumpyvi.github.io/bootc-deb/debian stable main" | sudo tee /etc/apt/sources.list.d/bootc-deb.list`

`sudo apt-get update`

## Install bootc
`sudo apt-get install bootc`