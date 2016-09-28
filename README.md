[![Version](https://img.shields.io/github/release/halo/Brick.svg?style=flat&label=version)](https://github.com/halo/Brick/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/halo/Brick/blob/master/LICENSE.md)
[![Build Status](https://travis-ci.org/halo/Brick.svg?branch=master)](https://travis-ci.org/halo/Brick)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/halo/Brick)

# Prevent your Mac from leaking IPs and phoning home (aka pf GUI)

This is an intuitive status menu application written in Objective-C to help you control outgoing network traffic.
The most common use case is to make sure that *only* VPN traffic will ever leave your computer.

Under the hood, it's just a dummy-proof, configurable, done-right graphical interface for the (pre-installed) firewall `pf`.

If you like this project, feel free to give it a ★ in the top right corner.

![Screenshot](https://cdn.rawgit.com/halo/Brick/master/doc/screenshot.0.0.1.png)

## Requirements

* Mac OS Yosemite
* Administrator privileges (you will be asked for your root password **once**)

## Installation

Grap the latest release of [Brick.app.zip](https://github.com/halo/Brick/releases/latest), extract it, and place it into your `/Applications` directory.

## Are you going to mess up my Mac?

No. The philosophy of Brick is to **never modify existing files** and to be as unobstrusive as possible.

Brick will *not* modify your `/etc/pf.conf`.
It will, however, create a `/etc/pf.anchors/com.funkensturm.Brick` and load those as rules instead.

## Uninstall/Upgrade

Changing pf firewall rules requires superuser privileges, for which a so called "HelperTool" will additionally be installed on your computer when you run Brick for the first time. If you wish to remove the HelperTool, you need to run these commands:

```bash
sudo launchctl unload /Library/LaunchDaemons/com.funkensturm.BrickLayer.plist
sudo rm /Library/LaunchDaemons/com.funkensturm.BrickLayer.plist
sudo rm /Library/PrivilegedHelperTools/com.funkensturm.BrickLayer
```

## Limitations

* If you reconfigure your pf firewall manually, the Brick rules will be lost. You would have to activate Brick again for the changes to take effect again.
  To be clear: if you use the `pfctl -f` flag, dynamic rules will be lost, as that is what this command does.
* The detection for whether the firewall is active or not relies on no manual interference, so if you mess with things yourself, the menu icon may not reflect reality (example: If you stop the firewall with `pfctl -d`, Brick will still look like `pf` is running. Reactivating Brick will enable the proper state again).

## Troubleshooting

To see which Brick rules are currently active in `pf`, you can use the following command:

```bash
sudo pfctl -a "com.apple/249.Brick" -sr
```

To make Brick log to your `Console` app, activate the debug mode like so:

```bash
defaults write com.funkensturm.Brick debug --bool yes
```

## Configuration (advanced users)

**Note:** If anything is unclear in this Readme, I expect you create a Github issue with your question so that we can improve this Readme together.

Brick comes with a small set of default firewall rules you can choose to activate.
If you are comfortable with how `pf` works, you can configure just about anything the way you want.
The configuration is stored in the OS X Foundation `defaults` system, that is `~/Library/Preferences/com.funkensturm.Brick`.
There is no GUI for the configuration ifself so as to keep Brick as simple and flexible as possible.

I recommend you take a look at the [default preferences](https://github.com/halo/Brick/blob/master/Brick/Defaults.plist) to begin with.

As you can see there are two Array keys called `rules.factory` and `rules.user`.
That's how Brick knows which rules exist at all. A simple list of identifiers.
It's conveniently separated into two sets. You should add your own rules to the `rules.user` set.
When a new Brick version is released, and you did not override the `rules.factory` settings, you automatically pick up the updated factory rules.
It is no problem, however, to override that factory Array, too, if you don't feel comfortable with the default set.

Note that there is a rule called `rule.blockout`, which is not visible in the menu, but it is the rule which blocks all outgoing traffic by default. You can edit that one, too if you really need to. That would also be the place to block all incoming traffic if you like.

So let's add a custom rule to allow outgoing SSH traffic.

```bash
# Run this command in the Terminal application
defaults write com.funkensturm.Brick rules.user -array ssh

# Then, verify your settings by looking up what you just did
defaults read com.funkensturm.Brick rules.user

# You can even review and edit the file in the pre-installed plist editor
open ~/Library/Preferences/com.funkensturm.Brick.plist
```

(Note that you can add multiple rules at the same time with e.g. `-array ssh skype dota`.
You will need to do this if you have multiple rules, because this command overwrites the array each time. Try to avoid spaces in the identifiers.)

Now Brick knows about the two new rules, but they don't show up in the Menu yet. Let's add some information about the rules.

```bash
# Let's give the rule a name to show in the status menu
defaults write com.funkensturm.Brick rule.ssh.name "SSH"

# Add a useful comment which is displayed in tooltips and configuration files
# This step is not mandatory, but strongly recommended by your future you
defaults write com.funkensturm.Brick rule.ssh.comment "Outgoing secure-shell sessions"

# Define the pf rules as an Array of Strings
defaults write com.funkensturm.Brick rule.ssh.rules -array "pass out on en0 from any to any port 22" "pass out on en1 from any to any port 22"
```

That's it! You're ready to use your rule. You don't even need to restart Brick.

If you rather want your rule to be active at all times but not visible in the menu, you can use the following commands instead.

```bash
# Skip setting a name so the rule will be invisible in the menu

# Define whether this rule is currently enabled or not
# This is otherwise done whenever you click on the rule in the menu
defaults write com.funkensturm.Brick rule.ssh.activated -bool yes

# Add a comment (just like above)
defaults write com.funkensturm.Brick rule.ssh.comment "Outgoing secure-shell sessions"

# Define the pf rules (just like above)
defaults write com.funkensturm.Brick rule.ssh.rules -array "pass out on en0 from any to any port 22" "pass out on en1 from any to any port 22"
```

In the same way you can modify any existing rule that ships with Brick.

## Future work

* Proper help
* Logger for blocked packets
* Unit Tests
* More intuitive icon, I guess

## Development

Just open the project in Xcode and run it. There are no external dependencies.

[Overview of all ports](https://support.apple.com/en-us/HT202944) used by Apple.

`
cat /etc/services
cat /etc/protocols
`

## Thanks

* The IconWork in the `Link/Images.xcassets` is from [Iconmonstr](http://iconmonstr.com).
* @ianyh made [the code](https://github.com/ianyh/IYLoginItem) to toggle the "Launch at login".

## License

MIT 2016 halo See [MIT-LICENSE](https://github.com/halo/Brick/blob/master/LICENSE.md).
