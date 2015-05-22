# Non-null Types and Non-null By Default (NNBD)

[Dart Enhancement Process][DEP] (DEP) proposal for ***non-null types*** and ***non-null by default***. View the complete proposal in [PDF](doc/dep-non-null.pdf). Markdown sources used in creating this proposal can be found under [doc-src](doc-src).

[DEP]: https://github.com/dart-lang/dart_enhancement_proposals

-----

### Generating the proposal PDF

1. To build the proposal you will need [Pandoc](http://pandoc.org), which can be installed as a [brew](http://brew.sh) [cask](http://caskroom.io) as follows:

    ```shell
    $ brew cask install pandoc
    ```

    (The `pandoc` cask takes minutes to install, against hours for the homebrew `pandoc` Formula.)

2. We also have a simple custom Pandoc filter that requires a node package so run:

    ```shell
    $ npm install
    ```

3. To generate a PDF run:

    ```shell
    $ make
    ```
