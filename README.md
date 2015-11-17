# vim-doubles

A plugin for vim that adds the `ii` and `aa` text objects. They act as any of
`(`, `[`, `{`, `'`, `"`; whichever is closest. For example, typing `dii` with
the cursor inside the square brackets in the following text:

    foo (bar [baz] quux)

would result in:

    foo (bar [] quux)
