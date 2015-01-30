## 0.1.1
* (Hopefully) fixed Windows not liking single quotes when passing arguments to DOSBox.

## 0.1.0
* Fixed bug that prevented the running of .PAS files with spaces in the filepath.
* Updated for the latest Atom v0.174.0 APIs.
* Added a run option so that programs can be run without rebuilding – <kbd>ctrl</kbd>+<kbd>alt</kbd>+<kbd>cmd</kbd>+<kbd>o</kbd> – I don't know what this maps to on Windows but hopefully it works!
* Refined some of the output text.
* Configuration settings should now appear as soon as Quarkbox is installed.
* Configuration settings now have helpful descriptions.

__NOTE:__
Some configuration keys might have changed, so verify that your configuration is correct.
## 0.0.9
* Specify a custom configuration file to pass to DOSBox.
This is optional, the default configuration file will be used by default.

## 0.0.8
* Register settings defaults before and during activation

## 0.0.7
* Fixed default Windows DOSBox path

## 0.0.6
* Spaces in filenames now automatically replaced with underscores
* Long filenames shortened internally (note: first 8 characters of filenames still need to be unique)
* Option to disable PAUSE after run
* Option to save before building
* Spaces in DOSBox path now accepted

## 0.0.5
* Fixed platform detection

## 0.0.1 - Initial Release
* Build or Build and Run Pascal programs right from Atom
