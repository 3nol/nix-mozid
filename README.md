# nix-mozid

A set of Nix tools exposed via `apps` for retrieving Mozilla extension IDs from an XPI add-on package. It automates the process of downloading the XPI file from Mozilla's add-ons websites, extracting the `manifest.json`, and displaying the unique ID.

**Important:**
This is a fork and slight adaptation of the already useful a command-line tool by [tupakkatapa](https://github.com/tupakkatapa/mozid). 

This tool was inspired by the difficulty of retrieving the extension ID when non-declarative installations are blocked in Firefox, as discussed in this [thread](https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/17).

## Package Usage

Run the script by passing it a program-specific base URL and an extension URL as arguments.
```sh
nix run github:3nol/nix-mozid#mozid -- <base-url> <extension-url>
```

For example, use can use "https://addons.mozilla.org/firefox/downloads/file" as base URL and "https://addons.mozilla.org/en-US/firefox/addon/vimium-ff" as extension URL to determine the Mozilla ID of this XPI package.

### Without Nix

Clone the repository and make the script executable.
```sh
git clone https://github.com/3nol/nix-mozid.git
cd nix-mozid
chmod +x mozid.sh
```

Run the script analogous to above.
```sh
./mozid.sh <base-url> <extension-url>
```

## Apps Usage

The provided apps do _not_ make use of the `<base url>` argument, they use their own default.
- `mozid-firefox` defaults to using the Firefox base URL.
- `mozid-thunderbird` defaults to using the Thunderbird base URL.

Analogously, run the script by passing an extension URL as argument.
```sh
nix run github:3nol/nix-mozid#mozid-<base> -- <extension url>
```

Picking up the example from above, now use this instead.
```sh
nix run github:3nol/nix-mozid#mozid-firefox -- "https://addons.mozilla.org/en-US/firefox/addon/vimium-ff"
```
