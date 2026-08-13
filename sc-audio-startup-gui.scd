/*
General SuperCollider audio setup GUI.

Use as a startup file:
~/Library/Application Support/SuperCollider/startup.scd

Or run manually from SuperCollider when you want to choose devices.
*/

(
~deviceOptionsFind = { |devices, names|
	devices.detect { |device|
		names.any { |name| device.asString.find(name).notNil }
	};
};

~deviceOptionsConfigPath = Platform.userAppSupportDir +/+ "audio-startup-gui-devices.archive";

~deviceOptionsLoadConfig = {
	var config;
	if(File.exists(~deviceOptionsConfigPath)) {
		config = Object.readArchive(~deviceOptionsConfigPath);
		if(config.isNil) {
			config = ();
		};
	} {
		config = ();
	};
	config;
};

~deviceOptionsSaveConfig = { |inDevices, outDevices, defaultSetup = nil|
	var oldConfig = ~deviceOptionsLoadConfig.();
	var setup = defaultSetup ? oldConfig[\defaultSetup];
	(
		customInputs: inDevices,
		customOutputs: outDevices,
		defaultSetup: setup
	).writeArchive(~deviceOptionsConfigPath);
	("Saved audio startup GUI devices to: " ++ ~deviceOptionsConfigPath).postln;
};

~deviceOptionsMenuValue = { |menu, items, value, fallback = 0|
	var index = items.indexOfEqual(value.asString);
	menu.value_(index ? fallback);
};

~deviceOptionsUniqueSorted = { |items|
	var result = List.new;
	items.do { |item|
		if(item.notNil) {
			if(item.asString.size > 0) {
				if(result.includes(item).not) {
					result.add(item);
				};
			};
		};
	};
	result.asArray.sort;
};

~deviceOptionsApply = { |inDevice, outDevice, sampleRate = 48000, ioVectorSize = 256, signalVectorSize = 64, ins = 2, outs = 2|
	var options = Server.default.options;

	if(inDevice.asString == "No input device") {
		options.inDevice = nil;
		ins = 0;
	} {
		if(inDevice.notNil and: { inDevice.asString.size > 0 }) {
			options.inDevice = inDevice.asString;
		};
	};
	if(outDevice.notNil and: { outDevice.asString.size > 0 }) {
		if(outDevice.asString == "Default output device") {
			options.outDevice = nil;
		} {
			options.outDevice = outDevice.asString;
		};
	};

	options.sampleRate = sampleRate.asInteger;
	options.hardwareBufferSize = ioVectorSize.asInteger;
	options.blockSize = signalVectorSize.asInteger;
	options.numInputBusChannels = ins.asInteger;
	options.numOutputBusChannels = outs.asInteger;

	"SC audio setup applied:".postln;
	("input: " ++ (options.inDevice ? "No input device")).postln;
	("output: " ++ options.outDevice).postln;
	("sample rate: " ++ options.sampleRate).postln;
	("I/O vector size: " ++ options.hardwareBufferSize).postln;
	("signal vector size: " ++ options.blockSize).postln;
	("inputs: " ++ options.numInputBusChannels).postln;
	("outputs: " ++ options.numOutputBusChannels).postln;

	Server.default.reboot;
};

~deviceOptionsGUI = {
	{
		var win, inMenu, outMenu, detectedMenu, srMenu, ioMenu, sigMenu, insMenu, outsMenu;
		var config = ~deviceOptionsLoadConfig.();
		var customInputs = config[\customInputs] ? [];
		var customOutputs = config[\customOutputs] ? [];
		var defaultSetup = config[\defaultSetup];
		var inputDefaults = [
			"No input device"
		];
		var outputDefaults = [
			"Default output device"
		];
		var detectedInputs = ServerOptions.inDevices;
		var detectedOutputs = ServerOptions.outDevices;
		var detectedDevices = ~deviceOptionsUniqueSorted.(detectedInputs ++ detectedOutputs);
		var inDevices = ~deviceOptionsUniqueSorted.(inputDefaults ++ customInputs);
		var outDevices = ~deviceOptionsUniqueSorted.(outputDefaults ++ customOutputs);
		var sampleRates = ["8000", "11025", "16000", "22050", "32000", "44100", "48000", "88200", "96000"];
		var ioVectorSizes = ["32", "64", "128", "256", "512", "1024", "2048"];
		var signalVectorSizes = ["16", "32", "64", "128", "256", "512", "1024", "2048"];
		var inputCounts = (0..64).collect(_.asString);
		var outputCounts = (1..64).collect(_.asString);
		var bg = Color(0.90, 0.89, 0.93);
		var panel = Color(0.96, 0.95, 0.97);
		var ink = Color(0.24, 0.23, 0.28);
		var button = Color(0.84, 0.82, 0.88);
		var refreshMenus, currentSetup, saveDefault, addDevice, removeSelected;

		if(detectedDevices.isEmpty) {
			detectedDevices = ["No detected devices"];
		};

		refreshMenus = {
			var selectedIn = inDevices[inMenu.value];
			var selectedOut = outDevices[outMenu.value];
			if(inDevices.isEmpty) { inDevices = [""] };
			if(outDevices.isEmpty) { outDevices = [""] };
			inMenu.items_(inDevices);
			outMenu.items_(outDevices);
			inMenu.value_(inDevices.indexOfEqual(selectedIn) ? 0);
			outMenu.value_(outDevices.indexOfEqual(selectedOut) ? 0);
		};

		currentSetup = {
			(
				input: inDevices[inMenu.value],
				output: outDevices[outMenu.value],
				sampleRate: sampleRates[srMenu.value],
				ioVector: ioVectorSizes[ioMenu.value],
				signalVector: signalVectorSizes[sigMenu.value],
				inputs: inputCounts[insMenu.value],
				outputs: outputCounts[outsMenu.value]
			)
		};

		saveDefault = {
			defaultSetup = currentSetup.();
			~deviceOptionsSaveConfig.(customInputs, customOutputs, defaultSetup);
			("saved default setup: " ++ defaultSetup).postln;
		};

		addDevice = { |target|
			var name = detectedDevices[detectedMenu.value];
			if(name == "No detected devices") {
				"No detected devices available. Use print devices to check SuperCollider's device list.".warn;
			} {
				if(target == \input) {
					if(inDevices.includes(name)) {
						("input device already exists: " ++ name).postln;
					};
					inDevices = ~deviceOptionsUniqueSorted.(inDevices ++ [name]);
					customInputs = ~deviceOptionsUniqueSorted.(customInputs ++ [name]);
					inMenu.items_(inDevices);
					inMenu.value_(inDevices.indexOfEqual(name) ? 0);
					("added input device: " ++ name).postln;
				} {
					if(outDevices.includes(name)) {
						("output device already exists: " ++ name).postln;
					};
					outDevices = ~deviceOptionsUniqueSorted.(outDevices ++ [name]);
					customOutputs = ~deviceOptionsUniqueSorted.(customOutputs ++ [name]);
					outMenu.items_(outDevices);
					outMenu.value_(outDevices.indexOfEqual(name) ? 0);
					("added output device: " ++ name).postln;
				};
				~deviceOptionsSaveConfig.(customInputs, customOutputs, defaultSetup);
			};
		};

		removeSelected = { |target|
			var removed;
			if(target == \input) {
				removed = inDevices[inMenu.value];
				customInputs = customInputs.reject { |item| item == removed };
				inDevices = inDevices.reject { |item| item == removed };
				("removed input device: " ++ removed).postln;
			} {
				removed = outDevices[outMenu.value];
				customOutputs = customOutputs.reject { |item| item == removed };
				outDevices = outDevices.reject { |item| item == removed };
				("removed output device: " ++ removed).postln;
			};
			~deviceOptionsSaveConfig.(customInputs, customOutputs, defaultSetup);
			refreshMenus.();
		};

		win = Window("SuperCollider Audio Devices", Rect(120, 120, 590, 370)).front.alwaysOnTop_(true);
		win.view.background_(bg);

		StaticText(win, Rect(18, 16, 500, 20)).string_("Choose input/output devices, then apply + reboot.").stringColor_(ink);

		StaticText(win, Rect(18, 50, 110, 20)).string_("Input").stringColor_(ink);
		inMenu = PopUpMenu(win, Rect(135, 48, 400, 24)).items_(inDevices);
		inMenu.background_(panel);
		inMenu.value_(0);

		StaticText(win, Rect(18, 84, 110, 20)).string_("Output").stringColor_(ink);
		outMenu = PopUpMenu(win, Rect(135, 82, 400, 24)).items_(outDevices);
		outMenu.background_(panel);
		outMenu.value_(0);

		StaticText(win, Rect(18, 124, 110, 20)).string_("Detected").stringColor_(ink);
		detectedMenu = PopUpMenu(win, Rect(135, 122, 210, 24)).items_(detectedDevices).value_(0);
		detectedMenu.background_(panel);
		Button(win, Rect(355, 122, 95, 24)).states_([["add input", ink, button]]).action_({ addDevice.(\input) });
		Button(win, Rect(460, 122, 95, 24)).states_([["add output", ink, button]]).action_({ addDevice.(\output) });

		Button(win, Rect(135, 152, 150, 24)).states_([["remove selected input", ink, button]]).action_({ removeSelected.(\input) });
		Button(win, Rect(300, 152, 160, 24)).states_([["remove selected output", ink, button]]).action_({ removeSelected.(\output) });

		StaticText(win, Rect(18, 196, 110, 20)).string_("Sample rate").stringColor_(ink);
		srMenu = PopUpMenu(win, Rect(135, 194, 90, 24)).items_(sampleRates).value_(6);
		srMenu.background_(panel);

		StaticText(win, Rect(255, 196, 120, 20)).string_("I/O vector").stringColor_(ink);
		ioMenu = PopUpMenu(win, Rect(390, 194, 90, 24)).items_(ioVectorSizes).value_(2);
		ioMenu.background_(panel);

		StaticText(win, Rect(18, 230, 110, 20)).string_("Signal vector").stringColor_(ink);
		sigMenu = PopUpMenu(win, Rect(135, 228, 90, 24)).items_(signalVectorSizes).value_(2);
		sigMenu.background_(panel);

		StaticText(win, Rect(255, 230, 120, 20)).string_("Inputs").stringColor_(ink);
		insMenu = PopUpMenu(win, Rect(390, 228, 90, 24)).items_(inputCounts).value_(2);
		insMenu.background_(panel);

		StaticText(win, Rect(18, 264, 110, 20)).string_("Outputs").stringColor_(ink);
		outsMenu = PopUpMenu(win, Rect(135, 262, 90, 24)).items_(outputCounts).value_(1);
		outsMenu.background_(panel);

		if(defaultSetup.notNil) {
			if(defaultSetup[\input].notNil) {
				~deviceOptionsMenuValue.(inMenu, inDevices, defaultSetup[\input], 0);
			};
			if(defaultSetup[\output].notNil) {
				~deviceOptionsMenuValue.(outMenu, outDevices, defaultSetup[\output], 0);
			};
			~deviceOptionsMenuValue.(srMenu, sampleRates, defaultSetup[\sampleRate], 6);
			~deviceOptionsMenuValue.(ioMenu, ioVectorSizes, defaultSetup[\ioVector], 2);
			~deviceOptionsMenuValue.(sigMenu, signalVectorSizes, defaultSetup[\signalVector], 2);
			~deviceOptionsMenuValue.(insMenu, inputCounts, defaultSetup[\inputs], 2);
			~deviceOptionsMenuValue.(outsMenu, outputCounts, defaultSetup[\outputs], 1);
		};

		Button(win, Rect(18, 318, 115, 32)).states_([["print devices", ink, button]]).action_({
			"Input devices:".postln;
			ServerOptions.inDevices.postln;
			"Output devices:".postln;
			ServerOptions.outDevices.postln;
		});

		Button(win, Rect(143, 318, 125, 32)).states_([["save default", ink, button]]).action_({
			saveDefault.();
		});

		Button(win, Rect(278, 318, 155, 32)).states_([["apply + reboot", ink, button]]).action_({
			~deviceOptionsApply.(
				inDevices[inMenu.value],
				outDevices[outMenu.value],
				sampleRates[srMenu.value].asInteger,
				ioVectorSizes[ioMenu.value].asInteger,
				signalVectorSizes[sigMenu.value].asInteger,
				inputCounts[insMenu.value].asInteger,
				outputCounts[outsMenu.value].asInteger
			);
		});

		Button(win, Rect(515, 318, 40, 32)).states_([["x", ink, button]]).action_({
			win.close;
		});
	}.defer;
};

~deviceOptionsGUI.();
)
