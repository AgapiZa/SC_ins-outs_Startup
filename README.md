# SC_ins-outs_Startup

# SuperCollider Audio Startup GUI

A small SuperCollider startup GUI for choosing audio input/output devices and server options before working.

It lets you choose:

- input device
- output device
- sample rate
- I/O vector size
- signal vector size
- number of input channels
- number of output channels

It also lets you save detected devices into the input/output dropdowns for future sessions.

## Files

- `sc-audio-startup-gui.scd` - the SuperCollider GUI code
- `install.command` - macOS installer that copies the GUI to SuperCollider's `startup.scd`

## Test Before Installing

1. Open `sc-audio-startup-gui.scd` in SuperCollider.
2. Click anywhere inside the block.
3. Run the block with `Shift + Enter`.

The whole file is wrapped in parentheses:

```supercollider
(
// code here
)
```

In SuperCollider, `Shift + Enter` evaluates the current block or selected code. If the cursor is inside the parentheses, SuperCollider should run the whole block and open the GUI.

If your SuperCollider keymap uses a different shortcut, you can also select the whole block manually and evaluate the selection.

## Install As Startup

To make the GUI open automatically whenever SuperCollider starts:

1. Keep `install.command` and `sc-audio-startup-gui.scd` in the same folder.
2. Double-click `install.command`.
3. Close and reopen SuperCollider.

The installer copies:

```text
sc-audio-startup-gui.scd
```

to:

```text
~/Library/Application Support/SuperCollider/startup.scd
```

If a `startup.scd` already exists, the installer makes a timestamped backup first.

## Using The GUI

1. If the device you want is not already in `Input` or `Output`, choose it from the `Detected` dropdown.
2. Click `add input` or `add output`.
3. The chosen detected device is added to the upper `Input` or `Output` dropdown and selected automatically.
4. Choose sample rate and vector sizes.
5. Choose input/output channel counts.
6. Optional: press `save default` to remember this setup.
7. Press `apply + reboot`.

SuperCollider will apply the selected server options and reboot the default server.

## Saved Default Setup

Press:

```text
save default
```

to remember the current GUI selections:

- input device
- output device
- sample rate
- I/O vector size
- signal vector size
- input channel count
- output channel count

The saved setup loads automatically the next time the GUI opens.

## No Input Device

Choose:

```text
No input device
```

to set:

```supercollider
numInputBusChannels = 0
```

This is useful when you only need output.

## Custom Devices

Detected devices appear in the `Detected` dropdown.

The upper `Input` and `Output` dropdowns are the saved working lists. The `Detected` dropdown is the list of devices SuperCollider currently sees on the computer.

To add a detected device to the saved working list:

1. Choose a device from `Detected`.
2. Click `add input` or `add output`.
3. The device is added to the upper `Input` or `Output` dropdown.
4. The added device is selected automatically.

You can use `print devices` to print SuperCollider's detected input and output device names in the Post window.

## Saved Custom Devices

Custom devices are saved automatically.

When you click:

```text
add input
```

or:

```text
add output
```

the selected detected device is stored and will appear again the next time the GUI opens.

Saved custom devices and the saved default setup are stored in the user's SuperCollider support folder:

```text
~/Library/Application Support/SuperCollider/audio-startup-gui-devices.archive
```

This file is created automatically. Users do not need to edit it manually.

## Device Names

The GUI shows detected devices in the `Detected` dropdown.

Device names vary by system, driver, and macOS version. If a device is missing, use `print devices` to check what SuperCollider can see.

