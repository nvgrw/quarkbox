# Quarkbox
Quarkbox is an Atom package that allows you to build and run **TurboPascal** programs. Bundled is the TurboPascal compiler from [borlandc.org](http://borlandc.org).

## Requirements
- Willpower to use such an ancient language.
- DOSBox 0.74 installed in the default directory.
    - It may be necessary to change the path of your DOSBox executable in the Quarkbox settings before using the package.
    - If you use a newer version of DOSBox you will also need to update this setting.

## Using Quarkbox
Open a .PAS file with Atom. You may need [this](https://atom.io/packages/language-pascal) package for the proper syntax highlighting.

To Build and Run, select the Packages > Quarkbox > Build and Run option or press <kbd>ctrl</kbd>+<kbd>alt</kbd>+<kbd>o</kbd>.

To Build only, select the Packages > Quarkbox > Build option or press <kbd>ctrl</kbd>+<kbd>alt</kbd>+<kbd>shift</kbd>+<kbd>o</kbd>.

### Errors
If there is an error during the compilation of your program, Quarkbox will halt future operations (such as running) and alert the error. The area of code that the compiler specifies will also be highlighted.

## License
See [LICENSE.md](LICENSE.md)
