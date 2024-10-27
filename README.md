# nix-mozid

A set of Nix functions exposed via `lib` for retrieving Mozilla extension IDs from an XPI add-on package. It automates the process of downloading the XPI file from Mozilla's add-ons websites, extracting the `manifest.json`, and displaying the unique ID.

**Important:**
This is a fork and slight adaptation of the already useful a command-line tool by [tupakkatapa](https://github.com/tupakkatapa/mozid). 

This tool was inspired by the difficulty of retrieving the extension ID when non-declarative installations are blocked in Firefox, as discussed in this [thread](https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/17).

## Package Usage

Run the script by passing it a program-specific base URL and an add-on URL as an argument.
```sh
nix run github:tupakkatapa/mozid -- <base-url> <extension-url>
```

### Without Nix

Clone the repository and make the script executable.
```sh
git clone https://github.com/tupakkatapa/mozid.git
cd mozid
chmod +x mozid.sh
```

Run the script analogous to above.
```sh
./mozid.sh <base-url> <extension-url>
```

## Lib Usage

...
