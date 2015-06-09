EDST
====
[![Build Status](https://travis-ci.org/IceDragon200/edst.svg?branch=master)](https://travis-ci.org/IceDragon200/edst)
[![Code Climate](https://codeclimate.com/github/IceDragon200/edst/badges/gpa.svg)](https://codeclimate.com/github/IceDragon200/edst)
[![Test Coverage](https://codeclimate.com/github/IceDragon200/edst/badges/coverage.svg)](https://codeclimate.com/github/IceDragon200/edst)
[![Inline docs](http://inch-ci.org/github/IceDragon200/edst.svg?branch=master)](http://inch-ci.org/github/IceDragon200/edst)

EDST is a specialized markup language for writing game documents and story writing, it serves both as a data language and reading language.
EDST in its parsed form is made up of trees of nodes.

## Usage
```shell
# renders an edst file to html by default
edst my_edst.edst
# you can specify the renderer using -r or --render-engine
edst -r md my_edst.edst
edst --render-engine text my_edst.edst
```

## API
Parsing an edst string is done via:
```ruby
EDST.parse(edst_string)
```

This produces a root EDST::AST with the parsed children, EDST is manipulated by using the AST directly, straight off the parser.

EDST does post processing on the parsed result when using `.parse`, if you wish to obtain the unaltered form, use `.parse_bare` instead.

## Node kinds
EDST has several kinds of nodes when parsed:

| Kind            | Description                                                                        | Example |
| --------------- | ---------------------------------------------------------------------------------- | ------- |
| :comment        | Comment.                                                                           | `# Just like ruby, just not ruby.` |
| :dialogue       | Apart of the story writing, this is a specialized form for dialogue writing.       | `@ IceDragon "Yes, and this is awesome."` |
| :dialogue_group | Same as `:list` but for `:dialogue`s.                                              | `` |
| :div            | A block.                                                                           | `{ my content }` |
| :header         | Header.                                                                            | `~HEADER` |
| :label          | Used for marking off areas in an edst string.                                      | `-- And the sky fell that day --` |
| :list           | Groups recurring `:ln`.                                                            | `` |
| :ln             | A list item node.                                                                  | `--- I am an item` |
| :p              | Paragraphs, or just lots of words.                                                 | `Look at him go!` |
| :root           | Top most node produced by parsing a EDST string.                                   | `` |
| :split          | A form of empty label, used as a barrier for areas in the text                     | `-- --` |
| :tag            | Used for creating key-value pairs, they come in 2 forms a `%key value` and `%%key` | `%name IceDragon` |
| :word           | Unbroken string, from bare parsing, converted to `:p` during processing.           | `word` |

Tags with `%%` are used as `:div` keys: 
```
%%notes
{
  Moving on...
}
```

This results in only 1 node, a `:div` node, not a `:tag`

## Special strings
EDST has 3 main special string, not handled by the parser:
The first is the action `* does something stupid *`, the second is the reference `<Egg>`, and the third is the backtick fence ``` `Oh really now` ```, these are left unescaped by default, and are escaped by the renderers on a need to basis.

## Example
```
#
# edst/sample/complex.edst
#
~EXAMPLE:EDST
%%head
{
  %name Complex EDST example
  This is an example of a more complex .edst format file.

  %%note
  {
    The html renderer by default has special a special css format for note
    tags.
  }
}
%%body
{
-- Raw Parsing --

  The EDST::Parser isn't exactly the smartest thing on the earth, its raw
  parsed data has lots of useless nodes that will need further processing to
  make them useful.

-- --

-- AstProcessor --

  The EDST::AstProcessor is used to merge common nodes and clean up the :word
  node mess produced by the Parser.
  By default, it will merge words together to form initial paragraphs, and
  then later merge those paragraphs together to create larger ones.
  It is also in this process that it merges block tag nodes with their div nodes.

-- --

-- There is no hard or fast rule --

  EDST is designed to used for writing and tagging, as well as being somewhat
  easy to navigate the AST to extract data.

-- --

-- Dialogue --

  EDST was originally designed for writing story board scripts, as such
  it has a special form for dialogue.

    @ IceDragon "Dialogues take the form of @ <Speaker> <Message>"

  The message is parsed using the StringParser, however its node is never
  included in the tree, its value is taken and placed on the dialogue node
  instead.

-- --

-- Common Nodes --

  The following is a list of most common nodes you'll encounter in the AST

  # You don't need to state that the block is a list, it will automatically
  # group multiple list items
  %%list.common_nodes
  {
    ---
    # root is produced from using the EDST.parse method
    --- :root
    # there is usually only 1 header per EDST file, though is is not
    # some rule that is enforced by EDST.
    --- :header
    # Comments are lines that start with a #, you cannot inline a comment.
    --- :comment
    # :labels are phrases enclosed in a -- pair, and empty label is transformed
    # as :splitter
    --- :label
    --- :splitter
    # these are list related node kinds
    # list items (:ln) are start with ---, :list are automatically generated
    # with 1 or more :ln items as its children.
    --- :list
    --- :ln
    # these are dialogue related nodes, a :dialogue_group will contain
    # multiple :dialogue nodes, and possibly comments.
    # :dialogue nodes, will have their key equal to the Speaker, and their
    # value as the message
    --- :dialogue_group
    --- :dialogue
    # :tag nodes will appear as key/value nodes, while block tags will become divs
    --- :tag
    # :div nodes are usually a combo of %%block and { }, its possibly to have
    # free floating divs
    --- :div
    # :p nodes are a dump node for things that didn't match the rest of the parsing,
    # but most times, its just words.
    # :string are enclosed with a ` or a ", though, they are transformed into
    # a :p node, after call #dump on its contents
    --- :p
    --- :string
    # :el are empty paragraphs, they won't appear in a regular parse, but
    # may appear in a raw_parse, their use is to stop the paragraph grouper
    # from joining all the paragraphs together.
    --- :el
  }

-- --
}

```
