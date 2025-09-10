/=  m  /common/markdown/types
::
=>  |%
      :: Set label for collapsed / shortcut reference links
      ++  backfill-ref-link
        |=  [a=link:inline:m]
        ^-  link:inline:m
        =/  t  target.a
        ?+  -.t  a                    :: only reference links
          %ref
            ?:  =(%full type.t)  a                   :: only collapsed / shortcut links
            =/  node=element:inline.m  (head contents.a)
            ?+  -.node  a                :: ...and it's a %text node
              %text
                %_  a
                  target  %_  t
                    label  text.node
                  ==
                ==
            ==
        ==
      ::
      ++  whitespace  (mask " \09\0d\0a")                  ::  whitespace: space, tab, or newline
      ::
      ++  all-link-ref-definitions                         :: Recursively get link ref definitions
        =<  process-nodes
        |%
          ++  process-nodes
            |=  [nodes=markdown:m]
            ^-  (map @t urlt:ln:m)
            ?~  nodes  ~
            %-  %~(uni by (process-node (head nodes)))
            $(nodes +.nodes)
          ::
          ++  process-nodeses
            |=  [nodeses=(list markdown:m)]
            ^-  (map @t urlt:ln:m)
            ?~  nodeses  ~
            %-  %~(uni by (process-nodes (head nodeses)))
            $(nodeses +.nodeses)
          ::
          ++  process-node
            |=  [node=node:markdown:m]
            ^-  (map @t urlt:ln:m)
            =/  result  *(map @t urlt:ln:m)
            ?-  -.node
              %leaf                                        :: Leaf node: check if it's a link ref def
                =/  leaf=node:leaf:m  +.node
                ?+  -.leaf  result
                  %link-ref-definition    (~(put by result) label.leaf urlt.leaf)
                ==
              ::
              %container
                =/  container=node:container:m  +.node
                ?-  -.container
                  %block-quote            (process-nodes markdown.container)
                  %ol                     (process-nodeses contents.container)
                  %ul                     (process-nodeses contents.container)
                  %tl                     (process-nodeses (turn contents.container |=([is-checked=? =markdown:m] markdown)))
                ==
            ==
        --
      ::
      ::  Get a preview-image for a document
      ++  get-preview-img
        =<  |=  [doc=markdown:m]
            ^-  (unit @t)
            =/  ref-links  (all-link-ref-definitions doc)
            (~(process-nodes . ref-links) doc)
        |_  [reference-links=(map @t urlt:ln:m)]
          ++  get-direct-link      :: DUPE: get-direct-link
            |=  [=target:ln:m]
            ^-  urlt:ln:m
            ?-  -.target
              %direct  urlt.target                          :: Direct link; use it
              %ref                                          :: Ref link; look it up
                ~|  "reflink not found: {<label.target>}"
                (~(got by reference-links) label.target)
            ==
          ++  process-nodes
            |=  [nodes=markdown:m]
            ^-  (unit @t)
            ?~  nodes  ~
            ?^  a=(process-node (head nodes))  a
            $(nodes +.nodes)
          ::
          ++  process-nodeses
            |=  [nodeses=(list markdown:m)]
            ^-  (unit @t)
            ?~  nodeses  ~
            ?^  a=(process-nodes (head nodeses))  a
            $(nodeses +.nodeses)
          ::
          ++  process-contents
            |=  [=contents:inline:m]
            ^-  (unit @t)
            ?~  contents  ~
            ?^  a=(process-inline (head contents))  a
            $(contents +.contents)
          ++  process-inline
            |=  [el=element:inline:m]
            ^-  (unit @t)
            ?+  -.el  ~
              %image  [~ text.url:(get-direct-link target.el)]
              %emphasis  (process-contents contents.el)
              %strong  (process-contents contents.el)
              %strikethru  (process-contents contents.el)
              %link  (process-contents contents.el)
            ==
          ++  process-node
            |=  [node=node:markdown:m]
            ^-  (unit @t)
            ?-  -.node
              %leaf                                        :: Leaf node: check if it's a link ref def
                =/  leaf=node:leaf:m  +.node
                ?+  -.leaf  ~
                  %heading  (process-contents contents.leaf)
                  %paragraph  (process-contents contents.leaf)
                ==
              ::
              %container
                =/  container=node:container:m  +.node
                ?-  -.container
                  %block-quote            (process-nodes markdown.container)
                  %ol                     (process-nodeses contents.container)
                  %ul                     (process-nodeses contents.container)
                  %tl                     (process-nodeses (turn contents.container |=([is-checked=? =markdown:m] markdown)))
                ==
            ==
        --
      ++  get-headers
        =<  process-doc
        |%
          ++  process-doc
            |=  [doc=markdown:m]
            ^-  (list [lvl=@ txt=tape])
            %+  turn
              (skim doc |=(a=node:markdown:m ?=([%leaf %heading *] a)))
              |=  [h=node:markdown:m]
              ?>  ?=([%leaf %heading *] h)
              ^-  [lvl=@ txt=tape]
              [level.h (process-contents contents.h)]
          ++  process-contents
            |=  [=contents:inline:m]
            ^-  tape
            ?~  contents  ~
            %+  welp  (process-inline (head contents))
            $(contents +.contents)
          ++  process-inline
            |=  [el=element:inline:m]
            ^-  tape
            ?+  -.el  ~
              %text  (trip text.el)
              %code-span  (trip text.el)
              %autolink  (trip text.el)
              %escape  (trip char.el)
              %entity  `tape`~[code.el]  :: cheat
              %emphasis  (process-contents contents.el)
              %strong  (process-contents contents.el)
              %strikethru  (process-contents contents.el)
              %link  (process-contents contents.el)
            ==
        --
    --
::
::  Parse to and from Markdown text format
|%
      ++  de                                               ::  de:md  Deserialize (parse)
        =<
            |=  [t=@t]
            ^-  (unit markdown:m)
            (rush t markdown)
        |%
          ++  escaped
            |=  [char=@t]
            (cold char (jest (crip (snoc "\\" char))))
          ::
          ++  newline
            %+  cold  '\0a'                                :: EOL, with or without carriage return '\0d'
            ;~(pfix ;~(pose (just '\0d') (easy ~)) (just '\0a'))
          ++  line-end                                     :: Either EOL or EOF
            %+  cold  '\0a'
            ;~(pose newline (full (easy ~)))
          ::
          ++  ln                                           ::  Links and urls
            |%
              ++  url
                =<  %+  cook  |=(a=url:ln:m a)                 :: Cast
                    ;~(pose with-triangles without-triangles)
                |%
                  ++  with-triangles
                    ;~  plug
                      %+  cook  crip
                        %+  ifix  [gal gar]
                        %-  star
                        ;~  pose
                          (escaped '<')
                          (escaped '>')
                          ;~(less gal gar line-end prn)    :: Anything except '<', '>' or newline
                        ==
                      (easy %.y)                               :: "yes triangles"
                    ==
                  ++  without-triangles
                    ;~  plug
                      %+  cook  crip
                        ;~  less
                            gal                                :: Doesn't start with '<'
                            %-  plus                           :: Non-empty
                              ;~  less
                                  whitespace                   :: No whitespace allowed
                                  ;~  pose
                                    (escaped '(')
                                    (escaped ')')
                                    ;~(less pal par line-end prn)    :: Anything except '(', ')' or newline
                                  ==
                              ==
                        ==
                      (easy %.n)                               :: "no triangles"
                    ==
                --
              ::
              ++  urlt
                %+  cook  |=(a=urlt:ln:m a)                :: Cast
                ;~  plug
                  url
                  %-  punt                                 :: Optional title-text
                    ;~  pfix  (plus whitespace)            :: Separated by some whitespace
                      %+  cook  crip  ;~  pose             :: Enclosed in single quote, double quote, or '(...)'
                        (ifix [soq soq] (star ;~(pose (escaped '\'') ;~(less soq prn))))
                        (ifix [doq doq] (star ;~(pose (escaped '"') ;~(less doq prn))))
                        (ifix [pal par] (star ;~(pose (escaped '(') (escaped ')') ;~(less pal par prn))))
                      ==
                    ==
                ==
              ::
              ::  Labels are used in inline link targets and in a block-level element (labeled link references)
              ++  label
                %+  cook  crip
                %+  ifix  [sel ser]                        :: Enclosed in '[...]'
                %+  ifix  :-  (star whitespace)            :: Strip leading and trailing whitespapce
                              (star whitespace)
                %-  plus  ;~  pose                         :: Non-empty
                  (escaped '[')
                  (escaped ']')
                  ;~(less sel ser prn)                     :: Anything except '[', ']' (must be escaped)
                ==
              ::
              ++  target                                   :: Link target, either reference or direct
                =<  %+  cook  |=(a=target:ln:m a)
                    ;~(pose target-direct target-ref)
                |%
                  ++  target-direct
                    %+  cook  |=(a=target:ln:m a)
                    %+  stag  %direct
                    %+  ifix  [pal par]                        :: Direct links are enclosed in '(...)'
                    %+  ifix  :-  (star whitespace)            :: Strip leading and trailing whitespace
                                  (star whitespace)
                    urlt                                       :: Just the target
                  ++  target-ref
                    %+  cook  |=(a=target:ln:m a)
                    %+  stag  %ref
                    ;~  pose
                      %+  stag  %full  label
                      %+  stag  %collapsed  (cold '' (jest '[]'))
                      %+  stag  %shortcut  (easy '')
                    ==
                --
            --
          ++  inline       :: Inline elements
            |%
              ++  contents  (cook |=(a=contents:inline:m a) (star element))                 :: Element sequence
              ++  element                                  :: Any element
                %+  cook  |=(a=element:inline:m a)
                ;~  pose
                  escape
                  entity
                  strong
                  emphasis
                  strikethru
                  code
                  link
                  image
                  autolink
                  text
                  softbrk
                  hardbrk
                ==
              ::
              ++  text
                %+  knee  *text:inline:m  |.  ~+   :: recurse
                %+  cook  |=(a=text:inline:m a)
                %+  stag  %text
                %+  cook  crip
                %-  plus                                   :: At least one character
                ;~  less                                   :: ...which doesn't match any other inline rule
                  escape
                  entity
                  link
                  image
                  autolink
                  emphasis
                  strong
                  strikethru
                  code
                  softbrk
                  hardbrk
                  :: ...etc
                  prn
                ==
              ::
              ++  escape
                %+  cook  |=(a=escape:inline:m a)
                %+  stag  %escape
                ;~  pose
                  ::  \!\"\#\$\%\&\'\(\)\*\+\,\-\.\/\:\;\<\=\>\?\@\[\\\]\^\_\`\{\|\}\~
                  (escaped '[')  (escaped ']')  (escaped '(')  (escaped ')')
                  (escaped '!')  (escaped '*')  (escaped '*')  (escaped '_')
                  (escaped '&')  (escaped '\\')
                  :: etc
                ==
              ++  entity
                %+  cook  |=(a=entity:inline:m a)
                %+  stag  %entity
                %+  ifix  [pam mic]
                %+  cook  crip
                ;~  pose
                  ;~(plug hax (stun [1 7] nud))            :: '#' and one to seven digits
                  (plus alf)                               :: Named entity
                ==
              ::
              ++  softbrk                                  :: Newline
                %+  cook  |=(a=softbrk:inline:m a)
                %+  stag  %soft-line-break
                (cold ~ newline)
              ::
              ++  hardbrk
                %+  cook  |=(a=hardbrk:inline:m a)
                %+  stag  %line-break
                %+  cold  ~
                ;~  pose
                  ;~(plug (jest '  ') (star ace) newline)   :: Two or more spaces before a newline
                  ;~(plug (just '\\') newline)              :: An escaped newline
                ==
              ++  link
                %+  knee  *link:inline:m  |.  ~+   :: recurse
                %+  cook  backfill-ref-link
                %+  stag  %link
                ;~  plug
                  %+  ifix  [sel ser]                      :: Display text is wrapped in '[...]'
                    %-  star  ;~  pose                     :: Display text can contain various contents
                      escape
                      entity
                      emphasis
                      strong
                      strikethru
                      code
                      image
                      :: Text: =>
                      %+  knee  *text:inline:m  |.  ~+   :: recurse
                      %+  cook  |=(a=text:inline:m a)
                      %+  stag  %text
                      %+  cook  crip
                      %-  plus                                   :: At least one character
                      ;~  less                                   :: ...which doesn't match any other inline rule
                        escape
                        entity
                        emphasis
                        strong
                        strikethru
                        code
                        ser                                   :: No closing ']'
                        prn
                      ==
                    ==
                  target:ln
                ==
              ::
              ++  image
                %+  cook  |=(a=image:inline:m a)
                %+  stag  %image
                ;~  plug
                  %+  ifix  [(jest '![') (just ']')]       :: alt-text is wrapped in '![...]'
                    %+  cook  crip
                    %-  star  ;~  pose
                      (escaped ']')
                      ;~(less ser prn)
                    ==
                  target:ln
                ==
              ::
              ++  autolink
                %+  cook  |=(a=autolink:inline:m a)
                %+  stag  %autolink
                %+  ifix  [gal gar]                       :: Enclosed in '<...>'
                %+  cook  crip
                %-  star  ;~  pose
                  ;~(less ace gar prn)                    :: Spaces are not allowed; neither are backslash-escapes
                ==
              ::
              ++  emphasis
                %+  knee  *emphasis:inline:m  |.  ~+   :: recurse
                %+  cook  |=(a=emphasis:inline:m a)
                %+  stag  %emphasis
                ;~  pose
                  %+  ifix  [tar tar]
                    ;~  plug
                      (easy '*')
                      %-  plus  ;~  pose                   :: Display text can contain various contents
                        escape
                        entity
                        strong
                        strikethru
                        link
                        autolink
                        code
                        image
                        link
                        softbrk
                        hardbrk
                        %+  knee  *text:inline:m  |.  ~+   :: recurse
                        %+  cook  |=(a=text:inline:m a)
                        %+  stag  %text
                        %+  cook  crip
                        %-  plus                           :: At least one character
                        ;~  less                           :: ...which doesn't match any other inline rule
                          escape
                          entity
                          strong
                          strikethru
                          link
                          autolink
                          code
                          image
                          link
                          softbrk
                          hardbrk
                          ::
                          tar                              :: If a '*', then it's the end of the `emphasis`
                          ::
                          prn
                        ==
                      ==
                    ==
                  %+  ifix  [cab cab]
                    ;~  plug
                      (easy '_')
                      %-  plus  ;~  pose                   :: Display text can contain various contents
                        escape
                        entity
                        strong
                        strikethru
                        link
                        autolink
                        code
                        image
                        link
                        softbrk
                        hardbrk
                        %+  knee  *text:inline:m  |.  ~+   :: recurse
                        %+  cook  |=(a=text:inline:m a)
                        %+  stag  %text
                        %+  cook  crip
                        %-  plus                           :: At least one character
                        ;~  less                           :: ...which doesn't match any other inline rule
                          escape
                          entity
                          strong
                          strikethru
                          link
                          autolink
                          code
                          image
                          link
                          softbrk
                          hardbrk
                          ::
                          cab                              :: If a '*', then it's the end of the `emphasis`
                          ::
                          prn
                        ==
                      ==
                    ==
                ==
              ::
              ++  strong
                %+  knee  *strong:inline:m  |.  ~+         :: recurse
                %+  cook  |=(a=strong:inline:m a)
                %+  stag  %strong
                ;~  pose                                   :: Either tars '**' or cabs '__'
                  %+  ifix  [(jest '**') (jest '**')]
                    ;~  plug
                      (easy '*')                           :: Note down the emphasis char
                      %-  plus  ;~  pose                   :: Display text can contain various contents
                        escape
                        emphasis
                        strikethru
                        link
                        autolink
                        code
                        image
                        link
                        softbrk
                        hardbrk
                        %+  knee  *text:inline:m  |.  ~+   :: recurse
                        %+  cook  |=(a=text:inline:m a)
                        %+  stag  %text
                        %+  cook  crip
                        %-  plus                           :: At least one character
                        ;~  less                           :: ...which doesn't match any other inline rule
                          escape
                          emphasis
                          strikethru
                          link
                          autolink
                          code
                          image
                          link
                          softbrk
                          hardbrk
                          :: ...etc
                          (jest '**')                      :: If a '**', then it's the end of the `strong`
                          prn
                        ==
                      ==
                    ==
                  %+  ifix  [(jest '__') (jest '__')]
                    ;~  plug  (easy '_')                   :: Note down the emphasis char
                      %-  plus  ;~  pose                   :: Display text can contain various contents
                        escape
                        emphasis
                        strikethru
                        link
                        autolink
                        code
                        image
                        link
                        softbrk
                        hardbrk
                        %+  knee  *text:inline:m  |.  ~+   :: recurse
                        %+  cook  |=(a=text:inline:m a)
                        %+  stag  %text
                        %+  cook  crip
                        %-  plus                           :: At least one character
                        ;~  less                           :: ...which doesn't match any other inline rule
                          escape
                          emphasis
                          strikethru
                          link
                          autolink
                          code
                          image
                          link
                          softbrk
                          hardbrk
                          ::
                          (jest '__')                      :: If a '**', then it's the end of the `strong`
                          prn
                        ==
                      ==
                    ==
                ==
              ::
              ++  strikethru
                %+  knee  *strikethru:inline:m  |.  ~+         :: recurse
                %+  cook  |=(a=strikethru:inline:m a)
                %+  stag  %strikethru
                ;~  pose                                 :: Either 1 sig '~' or 2 '~~'
                  %+  ifix  [sig sig]
                    ;~  plug
                      (easy 1)                           :: Enclosed in just 1 sig '~'
                      %-  plus  ;~  pose                   :: Display text can contain various contents
                        escape
                        emphasis
                        strong
                        link
                        autolink
                        code
                        image
                        link
                        softbrk
                        hardbrk
                        %+  knee  *text:inline:m  |.  ~+   :: recurse
                        %+  cook  |=(a=text:inline:m a)
                        %+  stag  %text
                        %+  cook  crip
                        %-  plus                           :: At least one character
                        ;~  less                           :: ...which doesn't match any other inline rule
                          escape
                          emphasis
                          strong
                          link
                          autolink
                          code
                          image
                          link
                          softbrk
                          hardbrk
                          :: ...etc
                          sig                      :: If a '~', then it's the end of the `strikethru`
                          prn
                        ==
                      ==
                    ==
                  %+  ifix  [(jest '~~') (jest '~~')]
                    ;~  plug
                      (easy 2)                             :: Enclosed in 2 sigs '~~'
                      %-  plus  ;~  pose                   :: Display text can contain various contents
                        escape
                        emphasis
                        strong
                        link
                        autolink
                        code
                        image
                        link
                        softbrk
                        hardbrk
                        %+  knee  *text:inline:m  |.  ~+   :: recurse
                        %+  cook  |=(a=text:inline:m a)
                        %+  stag  %text
                        %+  cook  crip
                        %-  plus                           :: At least one character
                        ;~  less                           :: ...which doesn't match any other inline rule
                          escape
                          emphasis
                          strong
                          link
                          autolink
                          code
                          image
                          link
                          softbrk
                          hardbrk
                          :: ...etc
                          (jest '~~')                      :: If a '~~', then it's the end of the `strikethru`
                          prn
                        ==
                      ==
                    ==
                ==
              ::
              ++  code
                =<  %+  cook  |=(a=code:inline:m a)
                    %+  stag  %code-span
                    inner-parser
                |%
                  ++  inner-parser
                    |=  =nail
                    =/  vex  ((plus tic) nail)                    :: Read the first backtick string
                    ?~  q.vex  vex  :: If no vex is found, fail
                    =/  tic-sequence  ^-  tape  p:(need q.vex)
                    %.
                      q:(need q.vex)
                    %+  cook  |=  [a=tape]                        :: Attach the backtick length to it
                              [(lent tic-sequence) (crip a)]
                    ;~  sfix
                      %+  cook
                        |=  [a=(list tape)]
                        ^-  tape
                        (zing a)
                      %-  star  ;~  pose
                          %+  cook  trip  ;~(less tic prn)          :: Any character other than a backtick
                          %+  sear                       :: A backtick string that doesn't match the opener
                            |=  [a=tape]
                            ^-  (unit tape)
                            ?:  =((lent a) (lent tic-sequence))
                              ~
                            `a
                          (plus tic)
                        ==
                      (jest (crip tic-sequence))                    :: Followed by a closing backtick string
                    ==
                --
            --
          ::
          ++  leaf
            |%
              ++  node
                %+  cook  |=(a=node:leaf:m a)
                ;~  pose
                  blank-line
                  break
                  heading
                  codeblk-indent
                  codeblk-fenced
                  link-ref-def
                  :: ...etc
                  table
                  paragraph
                ==
              ++  blank-line
                %+  cook  |=(a=blank-line:leaf:m a)
                %+  stag  %blank-line
                (cold ~ newline)
              ++  heading
                =<  %+  cook  |=(a=heading:leaf:m a)
                    %+  stag  %heading
                    ;~(pose atx setext)
                |%
                  ++  atx
                    =/  atx-eol   ;~  pose
                                    line-end               :: just end-of-line
                                    ;~  plug
                                      (plus ace)
                                      (star hax)
                                      (star ace)
                                      line-end
                                    ==
                                  ==
                    %+  stag  %atx
                    %+  cook                               :: Parse heading inline content
                      |=  [level=@ text=tape]
                      [level (scan text contents:inline)]
                    ;~  pfix
                      (stun [0 3] ace)                     :: Ignore up to 3 leading spaces
                      ;~  plug
                        (cook |=(a=tape (lent a)) (stun [1 6] hax))                   :: Heading level
                        %+  ifix  [(plus ace) atx-eol]     :: One leading space is required; rest is ignored
                          %-  star
                          ;~(less atx-eol prn)             :: Trailing haxes/spaces are ignored
                      ==
                    ==
                  ++  setext
                    %+  stag  %setext
                    %+  cook
                      |=  [text=tape level=@]
                      [level (scan text contents:inline)]
                    ;~  plug                                   :: Wow this is a mess
                      %+  ifix  [(stun [0 3] ace) (star ace)]  :: Strip up to 3 spaces, and trailing space
                        (star ;~(less ;~(pfix (star ace) newline) prn))     :: Any text...
                      ;~  pfix
                        newline                         :: ...followed by newline...
                        (stun [0 3] ace)                     :: ...up to 3 spaces (stripped)...
                        ;~  sfix
                          ;~  pose                             :: ...and an underline
                            (cold 1 (plus (just '-')))         :: Underlined by '-' means heading lvl 1
                            (cold 2 (plus (just '=')))         :: Underlined by '=' means heading lvl 2
                          ==
                          ;~(plug (star ace) line-end)
                        ==
                      ==
                    ==
                --
              ++  break
                %+  cook  |=(a=break:leaf:m a)
                %+  stag  %break
                %+  cook
                  |=  [first-2=@t trailing=tape]
                  [(head trailing) (add 2 (lent trailing))]
                %+  ifix  :-  (stun [0 3] ace)                  :: Strip indent and trailing space
                              ;~  plug
                                (star (mask " \09"))
                                line-end                    :: No other chars allowed on the line
                              ==
                  ;~  pose
                    ;~(plug (jest '**') (plus tar))       :: At least 3, but can be more
                    ;~(plug (jest '--') (plus hep))
                    ;~(plug (jest '__') (plus cab))
                  ==
              ::
              ++  codeblk-indent
                =>  |%
                      ++  indented-chunk                   :: A block of indented code, delimited by newlines
                        %+  cook  |=(a=(list tape) (zing a))
                        %-  plus                           :: 1 or more lines
                        ;~  pfix  (jest '    ')            :: with 4 leading spaces
                          %+  cook  snoc  ;~  plug
                            (star ;~(less line-end prn))
                            line-end
                          ==
                        ==
                    --
                %+  cook  |=(a=codeblk-indent:leaf:m a)
                %+  stag  %indent-codeblock
                %+  cook  |=([a=tape b=(list tape)] (crip (welp a (zing b))))
                ;~  plug                                   :: 1 or more chunks
                  indented-chunk
                  %-  star
                  %+  cook  |=([newlines=tape chunk=tape] `tape`(welp newlines chunk))
                  ;~  plug
                    (star newline)                         :: separated by zero or more blank lines
                    indented-chunk
                  ==
                ==
              ::
              ++  codeblk-fenced
                =+  |%
                      :: Returns a 3-tuple:
                      :: - indent size
                      :: - char type
                      :: - fence length
                      ++  code-fence
                        ;~  plug
                          %+  cook  |=(a=tape (lent a))  (stun [0 3] ace)
                          %+  cook  |=(a=tape [(head a) (lent a)])   :: Get code fence char and length
                          ;~  pose
                            (stun [3 999.999.999] sig)
                            (stun [3 999.999.999] tic)
                          ==
                        ==
                      ::
                      ++  info-string
                        %+  cook  crip
                        %+  ifix  [(star ace) line-end]    :: Strip leading whitespace
                        (star ;~(less line-end tic prn))   :: No backticks in a code fence
                    --
                |*  =nail
                :: Get the marker and indent size
                =/  vex  (code-fence nail)
                ?~  q.vex  vex  :: If no match found, fail
                =/  [indent=@ char=@t len=@]  p:(need q.vex)
                =/  closing-fence
                  ;~  plug
                    (star ace)
                    (stun [len 999.999.999] (just char))   :: Closing fence must be at least as long as opener
                    (star ace)                             :: ...and cannot have any following text except space
                    line-end
                  ==
                :: Read the rest of the list item block
                %.
                  q:(need q.vex)
                %+  cook  |=(a=codeblk-fenced:leaf:m a)
                %+  stag  %fenced-codeblock
                ;~  plug
                  %+  cook  |=(a=@t a)  (easy char)
                  (easy len)
                  %+  cook  |=(a=@t a)  info-string
                  (easy indent)
                  %+  cook  |=(a=(list tape) (crip (zing a)))
                  ;~  sfix
                    %-  star                               :: Any amount of lines
                    ;~  less  closing-fence                :: ...until the closing code fence
                      ;~  pfix  (stun [0 indent] ace)      :: Strip indent up to that of the opening fence
                        %+  cook  |=(a=tape a)
                        ;~  pose                           :: Avoid infinite loop at EOF
                          %+  cook  trip  newline     :: A line is either a blank line...
                          %+  cook  snoc
                          ;~  plug                         :: Or a non-blank line
                            (plus ;~(less line-end prn))
                            line-end
                          ==
                        ==
                      ==
                    ==
                    ;~(pose closing-fence (full (easy ~)))
                  ==
                ==
              ::
              ++  link-ref-def
                %+  cook  |=(a=link-ref-def:leaf:m a)
                %+  stag  %link-ref-definition
                %+  ifix  [(stun [0 3] ace) line-end]            :: Strip leading space
                  ;~  plug
                    ;~(sfix label:ln col)                 :: Label (enclosed in "[...]"), followed by col ":"
                    ;~  pfix                                :: Optional whitespace, including up to 1 newline
                      (star ace)
                      (stun [0 1] newline)
                      (star ace)
                      urlt:ln
                    ==
                  ==
              ::
              ++  paragraph
                %+  cook  |=(a=paragraph:leaf:m a)
                %+  stag  %paragraph
                %+  cook                                   :: Reparse the paragraph text as elements
                  |=  [a=(list tape)]
                  (scan (zing a) contents:inline)
                %-  plus                                   :: Read lines until a non-paragraph object is found
                  ;~  less
                    heading
                    break
                    node:container                     :: Block quotes and lists can interrupt paragraphs
                    :: TODO: fenced code blocks can interrupt paragraphs
                    %+  cook  snoc  ;~  plug
                      %-  plus  ;~(less line-end prn)  :: Lines must be non-empty
                      line-end
                    ==
                  ==
              ::
              ++  table
                =>  |%
                      +$  cell-t  [len=@ =contents:inline:m]
                      ++  row
                        ;~  pfix  bar                                 :: A bar in front...
                          %-  star
                            %+  cook                                  :: compute the length and parse inlines
                              |=  [pfx=@ stuff=tape sfx=@]
                              [;:(add pfx (lent stuff) sfx) (scan stuff contents:inline)]   :: inline elements...
                            ;~  plug
                              (cook lent (star ace))
                              (star ;~(less newline ;~(plug (star ace) bar) prn))
                              (cook lent ;~(sfix (star ace) bar))
                            ==
                        ==
                      ++  delimiter-row
                        ;~  pfix  bar                                 :: A bar in front...
                          %-  star
                            %+  cook
                              |=  [pfx=@ lal=? heps=@ ral=? sfx=@]
                              :-  ;:(add pfx ?:(ral 1 0) heps ?:(lal 1 0) sfx)
                              ?:(ral ?:(lal %c %r) ?:(lal %l %n))
                            ;~  plug
                              (cook lent (star ace))                          :: Delimiter: leading space...
                              (cook |=(a=tape .?(a)) (stun [0 1] col))        :: maybe a ':'...
                              (cook lent (plus hep))                          :: a bunch of '-'...
                              (cook |=(a=tape .?(a)) (stun [0 1] col))        :: maybe another ':'...
                              (cook lent ;~(sfix (star ace) bar))             :: ..and a bar as a terminator
                            ==
                        ==
                    --
                |*  =nail :: Make it a (redundant) gate so I can use `=>` to add a helper core
                %.  nail  :: apply the following parser
                %+  cook
                  |=  [hdr=(list cell-t) del=(list [len=@ al=?(%c %r %l %n)]) bdy=(list (list cell-t))]
                  ^-  table:leaf:m
                  =/  widths=(list @)  (turn del |=([len=@ al=*] len))
                  =/  rows=(list (list cell-t))  (snoc bdy hdr)  :: since they're the same data type
                  =/  computed-widths
                    |-
                      ?~  rows  widths
                      %=  $
                        rows  (tail rows)
                        widths  =/  row=(list cell-t)  (head rows)
                                |-
                                  ?~  row  ~
                                  :-  (max (head widths) len:(head row))
                                  %=  $
                                    widths  (tail widths)
                                    row     (tail row)
                                  ==
                      ==
                  :*  %table
                      computed-widths
                      (turn hdr |=(cell=cell-t contents.cell))
                      (turn del |=([len=@ al=?(%c %r %l %n)] al))
                      (turn bdy |=(row=(list cell-t) (turn row |=(cell=cell-t contents.cell))))
                  ==
                ;~  plug
                  ;~(sfix row line-end)
                  ;~(sfix delimiter-row line-end)
                  (star ;~(sfix row line-end))
                ==
            --
          ::
          ++  container
            =+  |%
                  ::
                  ++  line                                 :: Read a line of plain text
                    %+  cook  |=([a=tape b=tape c=tape] ;:(weld a b c))
                    ;~  plug
                      (star ;~(less line-end prn))
                      (cook trip line-end)
                      (star newline)  :: Can have blank lines in a list item
                    ==
                  ++  block-quote-marker
                    ;~  plug           :: Single char '>'
                      (stun [0 3] ace) :: Indented up to 3 spaces
                      gar
                      (stun [0 1] ace) :: Optionally followed by a space
                    ==
                  ++  block-quote-line
                    %+  cook  snoc
                    ;~  plug                 :: Single line...
                      ;~  pfix  block-quote-marker           :: ...starting with ">..."
                        (star ;~(less line-end prn))         :: can be empty
                      ==
                      line-end
                    ==
                  ::
                  +$  ul-marker-t  [indent=@ char=@t len=@]
                  ++  ul-marker
                    %+  cook                               :: Compute the length of the whole thing
                      |=  [prefix=tape bullet=@t suffix=tape]
                      ^-  ul-marker-t
                      :*  (lent prefix)
                          bullet
                          ;:(add 1 (lent prefix) (lent suffix))
                      ==
                    ;~  plug
                      (stun [0 3] ace)
                      ;~(pose hep lus tar)                 :: Bullet char
                      (stun [1 4] ace)
                    ==
                  ::
                  ::  Produces a 3-tuple:
                  ::  - bullet char (*, +, or -)
                  ::  - indent level (number of spaces before the bullet)
                  ::  - item contents (markdown)
                  +$  ul-item-t  [char=@t indent=@ =markdown:m]
                  ++  ul-item
                    |*  =nail
                    :: Get the marker and indent size
                    =/  vex  (ul-marker nail)
                    ?~  q.vex  vex  :: If no match found, fail
                    =/  mrkr=ul-marker-t  p:(need q.vex)
                    :: Read the rest of the list item block
                    %.
                      q:(need q.vex)
                    %+  cook
                      |=  [a=(list tape)]
                      ^-  ul-item-t
                      :*  char.mrkr
                          indent.mrkr
                          (scan (zing a) markdown)
                      ==
                    ;~  plug
                      line                                 :: First line
                      %-  star  ;~  pfix
                        (stun [len.mrkr len.mrkr] ace)     :: Subsequent lines must have the same indent
                        line                               :: the line
                      ==
                    ==
                  ::
                  +$  ol-marker-t  [indent=@ char=@t number=@ len=@]
                  ++  ol-marker
                    %+  cook                               :: Compute the length of the whole thing
                      |=  [prefix=tape number=@ char=@t suffix=tape]
                      ^-  ol-marker-t
                      :*  (lent prefix)
                          char
                          number
                          ;:(add 1 (lent (a-co:co number)) (lent prefix) (lent suffix))
                      ==
                    ;~  plug
                      (stun [0 3] ace)
                      dem
                      ;~(pose dot par)                 :: Bullet char
                      (stun [1 4] ace)
                    ==
                  ::
                  ::  Produces a 4-tuple:
                  ::  - delimiter char: either dot '.' or par ')'
                  ::  - list item number
                  ::  - indent level (number of spaces before the number)
                  ::  - item contents (markdown)
                  +$  ol-item-t  [char=@t number=@ indent=@ =markdown:m]
                  ++  ol-item
                    |*  =nail
                    ::^-  edge
                    :: Get the marker and indent size
                    =/  vex  (ol-marker nail)
                    ?~  q.vex  vex  :: If no match found, fail
                    =/  mrkr=ol-marker-t  p:(need q.vex)
                    :: Read the rest of the list item block
                    %.
                      q:(need q.vex)
                    %+  cook
                      |=  [a=(list tape)]
                      ^-  ol-item-t
                      :*  char.mrkr
                          number.mrkr
                          indent.mrkr
                          (scan (zing a) markdown)
                      ==
                    ;~  plug
                      line                                 :: First line
                      %-  star  ;~  pfix                   :: Subsequent lines must have the same indent
                        (stun [len.mrkr len.mrkr] ace)     :: the indent
                        line                               :: the line
                      ==
                    ==
                  ::
                  ++  tl-checkbox
                    ;~  pose
                      %+  cold  %.y  (jest '[x]')
                      %+  cold  %.n  (jest '[ ]')
                    ==
                  ::
                  ::  Produces a 4-tuple:
                  ::  - bullet char (*, +, or -)
                  ::  - indent level (number of spaces before the bullet)
                  ::  - is-checked
                  ::  - item contents (markdown)
                  +$  tl-item-t  [char=@t indent=@ is-checked=? =markdown:m]
                  ++  tl-item
                    |*  =nail
                    :: Get the marker and indent size
                    =/  vex  (;~(plug ul-marker ;~(sfix tl-checkbox ace)) nail)
                    ?~  q.vex  vex  :: If no match found, fail
                    =/  [mrkr=ul-marker-t is-checked=?]  p:(need q.vex)
                    :: Read the rest of the list item block
                    %.
                      q:(need q.vex)
                    %+  cook
                      |=  [a=(list tape)]
                      ^-  tl-item-t
                      :*  char.mrkr
                          indent.mrkr
                          is-checked
                          (scan (zing a) markdown)
                      ==
                    ;~  plug
                      line                                 :: First line
                      %-  star  ;~  pfix                   :: Subsequent lines must have the same indent
                        (stun [len.mrkr len.mrkr] ace)     :: the indent
                        line                               :: the line
                      ==
                    ==
                --
            |%
              ++  node
                %+  cook  |=(a=node:container:m a)
                ;~  pose
                  block-quote
                  tl
                  ul
                  ol
                ==
              ::
              ++  block-quote
                %+  cook  |=(a=block-quote:container:m a)
                %+  stag  %block-quote
                %+  cook  |=  [a=(list tape)]
                          (scan (zing a) markdown)
                ;~  plug
                  block-quote-line
                  %-  star                                   :: At least one line
                  ;~  pose
                    block-quote-line
                    %+  cook  zing  %-  plus              :: Paragraph continuation (copied from `paragraph` above)
                      ;~  less                     :: ...basically just text that doesn't matchZ anything else
                        heading:leaf
                        break:leaf
                        :: ol
                        :: ul
                        block-quote-marker                   :: Can't start with ">"
                        line-end                             :: Can't be blank
                        %+  cook  snoc  ;~  plug
                          %-  star  ;~(less line-end prn)
                          line-end
                        ==
                      ==
                  ==
                ==
              ::
              ++  ul
                |*  =nail
                :: Start by finding the type of the first bullet (indent level and bullet char)
                =/  vex  (ul-item nail)
                ?~  q.vex  vex  :: Fail if it doesn't match a list item
                =/  first-item=ul-item-t  p:(need q.vex)
                :: Check for more list items
                %.
                  q:(need q.vex)
                %+  cook  |=(a=ul:container:m a)
                %+  stag  %ul
                ;~  plug                                     :: Give the first item, first
                  (easy indent.first-item)
                  (easy char.first-item)
                  (easy markdown.first-item)
                  %-  star
                    %+  sear                                 :: Reject items that don't have the same bullet char
                      |=  [item=ul-item-t]
                      ^-  (unit markdown:m)
                      ?.  =(char.item char.first-item)
                        ~
                      `markdown.item
                    ul-item
                ==
              ::
              ++  ol
                |*  =nail
                :: Start by finding the first number, char, and indent level
                =/  vex  (ol-item nail)
                ?~  q.vex  vex  :: Fail if it doesn't match a list item
                =/  first-item=ol-item-t  p:(need q.vex)
                :: Check for more list items
                %.
                  q:(need q.vex)
                %+  cook  |=(a=ol:container:m a)
                %+  stag  %ol
                ;~  plug                                     :: Give the first item, first
                  (easy indent.first-item)
                  (easy char.first-item)
                  (easy number.first-item)
                  (easy markdown.first-item)
                  %-  star
                    %+  sear                                 :: Reject items that don't have the same delimiter
                      |=  [item=ol-item-t]
                      ^-  (unit markdown:m)
                      ?.  =(char.item char.first-item)
                        ~
                      `markdown.item
                    ol-item
                ==
              ::
              ++  tl
                |*  =nail
                :: Start by finding the type of the first bullet (indent level and bullet char)
                =/  vex  (tl-item nail)
                ?~  q.vex  vex  :: Fail if it doesn't match a list item
                =/  first-item=tl-item-t  p:(need q.vex)
                :: Check for more list items
                %.
                  q:(need q.vex)
                %+  cook  |=(a=tl:container:m a)
                %+  stag  %tl
                ;~  plug                                     :: Give the first item, first
                  (easy indent.first-item)
                  (easy char.first-item)
                  (easy [is-checked.first-item markdown.first-item])
                  %-  star
                    %+  sear                                 :: Reject items that don't have the same bullet char
                      |=  [item=tl-item-t]
                      ^-  (unit [is-checked=? markdown:m])
                      ?.  =(char.item char.first-item)
                        ~
                      `[is-checked.item markdown.item]
                    tl-item
                ==
            --
          ::
          ++  markdown
            %+  cook  |=(a=markdown:m a)
            %-  star  ;~  pose
              (stag %container node:container)
              (stag %leaf node:leaf)
            ==
        --
      ::
      ::  Enserialize (write out as text)
      ++  en
        =<  markdown
        |%
          ++  escape-chars
            |=  [text=@t chars=(list @t)]
            ^-  tape
            %+  rash  text
            %+  cook
              |=(a=(list tape) `tape`(zing a))
            %-  star  ;~  pose
              (cook |=(a=@t `tape`~['\\' a]) (mask chars))
              (cook trip prn)
            ==
          ::
          ++  ln
            |%
              ++  url
                =<  |=  [u=url:ln:m]
                    ^-  tape
                    ?:  has-triangle-brackets.u
                      (with-triangles text.u)
                    (without-triangles text.u)
                |%
                  ++  with-triangles
                    |=  [text=@t]
                    ;:  weld
                      "<"                    :: Put it inside triangle brackets
                      (escape-chars text "<>") :: Escape triangle brackets in the text
                      ">"
                    ==
                  ++  without-triangles
                    |=  [text=@t]
                    (escape-chars text "()")               :: Escape all parentheses '(' and ')'
                --
              ++  urlt
                |=  [u=urlt:ln:m]
                ^-  tape
                ?~  title-text.u      :: If there's no title text, then it's just an url
                  (url url.u)
                ;:(weld (url url.u) " \"" (escape-chars (need title-text.u) "\"") "\"")
              ++  label
                |=  [text=@t]
                ^-  tape
                ;:(weld "[" (escape-chars text "[]") "]")
              ++  target
                |=  [t=target:ln:m]
                ^-  tape
                ?-  -.t
                  %direct   ;:(weld "(" (urlt urlt.t) ")")          :: Wrap in parentheses
                  ::
                  %ref      ?-  type.t
                              %full       (label label.t)
                              %collapsed  "[]"
                              %shortcut   ""
                            ==
                ==
            --
          ::
          ++  inline
            |%
              ++  contents
                |=  [=contents:inline:m]
                ^-  tape
                %-  zing  %+  turn  contents  element
              ++  element
                |=  [e=element:inline:m]
                ?-  -.e
                  %text  (text e)
                  %link  (link e)
                  %escape  (escape e)
                  %entity  (entity e)
                  %code-span  (code e)
                  %strong  (strong e)
                  %emphasis  (emphasis e)
                  %strikethru  (strikethru e)
                  %soft-line-break  (softbrk e)
                  %line-break  (hardbrk e)
                  %image  (image e)
                  %autolink  (autolink e)
                ==
              ++  text
                |=  [t=text:inline:m]
                ^-  tape
                (trip text.t)                                     :: So easy!
              ::
              ++  entity
                |=  [e=entity:inline:m]
                ^-  tape
                ;:(weld "&" (trip code.e) ";")
              ::
              ++  link
                |=  [l=link:inline:m]
                ^-  tape
                ;:  weld
                  "["
                  (contents contents.l)
                  "]"
                  (target:ln target.l)
                ==
              ::
              ++  image
                |=  [i=image:inline:m]
                ^-  tape
                ;:  weld
                  "!["
                  (escape-chars alt-text.i "]")
                  "]"
                  (target:ln target.i)
                ==
              ::
              ++  autolink
                |=  [a=autolink:inline:m]
                ^-  tape
                ;:  weld
                  "<"
                  (trip text.a)
                  ">"
                ==
              ::
              ++  escape
                |=  [e=escape:inline:m]
                ^-  tape
                (snoc "\\" char.e)                 :: Could use `escape-chars` but why bother-- this is shorter
              ::
              ++  softbrk
                |=  [s=softbrk:inline:m]
                ^-  tape
                "\0a"
              ++  hardbrk
                |=  [h=hardbrk:inline:m]
                ^-  tape
                "\\\0a"
              ++  code
                |=  [c=code:inline:m]
                ^-  tape
                ;:(weld (reap num-backticks.c '`') (trip text.c) (reap num-backticks.c '`'))
              ::
              ++  strong
                |=  [s=strong:inline:m]
                ^-  tape
                ;:  weld
                  (reap 2 emphasis-char.s)
                  (contents contents.s)
                  (reap 2 emphasis-char.s)
                ==
              ::
              ++  emphasis
                |=  [e=emphasis:inline:m]
                ^-  tape
                ;:  weld
                  (trip emphasis-char.e)
                  (contents contents.e)
                  (trip emphasis-char.e)
                ==
              ::
              ++  strikethru
                |=  [s=strikethru:inline:m]
                ^-  tape
                ;:  weld
                  (reap sig-count.s '~')
                  (contents contents.s)
                  (reap sig-count.s '~')
                ==
            --
          ::
          ++  leaf
            |%
              ++  node
                |=  [n=node:leaf:m]
                ?-  -.n
                  %blank-line  (blank-line n)
                  %break  (break n)
                  %heading  (heading n)
                  %indent-codeblock  (codeblk-indent n)
                  %fenced-codeblock  (codeblk-fenced n)
                  %link-ref-definition  (link-ref-def n)
                  %paragraph  (paragraph n)
                  %table  (table n)
                  :: ...etc
                ==

              ++  blank-line
                |=  [b=blank-line:leaf:m]
                ^-  tape
                "\0a"
              ::
              ++  break
                |=  [b=break:leaf:m]
                ^-  tape
                (weld (reap char-count.b char.b) "\0a")
              ::
              ++  heading
                |=  [h=heading:leaf:m]
                ^-  tape
                ?-  style.h
                  %atx
                    ;:(weld (reap level.h '#') " " (contents:inline contents.h) "\0a")
                  %setext
                    =/  line  (contents:inline contents.h)
                    ;:(weld line "\0a" (reap (lent line) ?:(=(level.h 1) '-' '=')) "\0a")
                ==
              ::
              ++  codeblk-indent
                |=  [c=codeblk-indent:leaf:m]
                ^-  tape
                %+  rash  text.c
                %+  cook
                  |=  [a=(list tape)]
                  ^-  tape
                  %-  zing  %+  turn  a  |=(t=tape (weld "    " t))
                %-  plus  %+  cook  snoc  ;~(plug (star ;~(less (just '\0a') prn)) (just '\0a'))
              ::
              ++  codeblk-fenced
                |=  [c=codeblk-fenced:leaf:m]
                ^-  tape
                ;:  weld
                  (reap indent-level.c ' ')
                  (reap char-count.c char.c)
                  (trip info-string.c)
                  "\0a"
                  ^-  tape  %+  rash  text.c
                  %+  cook  zing  %-  star                   :: Many lines
                    %+  cook  |=  [a=tape newline=@t]        :: Prepend each line with "> "
                              ^-  tape
                              ;:  weld
                                  ?~(a "" (reap indent-level.c ' '))   :: If the line is blank, no indent
                                  a
                                  "\0a"
                              ==
                    ;~  plug                                 :: Break into lines
                      (star ;~(less (just '\0a') prn))
                      (just '\0a')
                    ==
                  (reap indent-level.c ' ')
                  (reap char-count.c char.c)
                  "\0a"
                ==
              ::
              ++  link-ref-def
                |=  [l=link-ref-def:leaf:m]
                ^-  tape
                ;:  weld
                  "["
                  (trip label.l)
                  "]: "
                  (urlt:ln urlt.l)
                  "\0a"
                ==
              ::
              ++  table
                =>  |%
                      ++  cell
                        |=  [width=@ c=contents:inline:m]
                        ^-  tape
                        =/  contents-txt  (contents:inline c)
                        ;:  weld
                          " "
                          contents-txt
                          (reap (sub width (add 1 (lent contents-txt))) ' ')
                          "|"
                        ==
                      ++  row
                        |=  [widths=(list @) cells=(list contents:inline:m)]
                        ^-  tape
                        ;:  weld
                          "|"
                          |-
                            ^-  tape
                            ?~  widths  ~
                            %+  weld
                              (cell (head widths) (head cells))
                            $(widths (tail widths), cells (tail cells))
                          "\0a"
                        ==
                      ++  delimiter-row
                        |=  [widths=(list @) align=(list ?(%l %c %r %n))]
                        ^-  tape
                        ;:  weld
                          "|"
                          |-
                            ^-  tape
                            ?~  align  ~
                            ;:  weld
                              " "
                              ?-  (head align)
                                %l  (weld ":" (reap ;:(sub (head widths) 3) '-'))
                                %r  (weld (reap ;:(sub (head widths) 3) '-') ":")
                                %c  ;:(weld ":" (reap ;:(sub (head widths) 4) '-') ":")
                                %n  (reap ;:(sub (head widths) 2) '-')
                              ==
                              " |"
                              $(align (tail align), widths (tail widths))
                            ==
                          "\0a"
                        ==
                    --
                |=  [t=table:leaf:m]
                ^-  tape
                ;:  weld
                  (row widths.t head.t)
                  (delimiter-row widths.t align.t)
                  =/  rows  rows.t
                  |-
                    ^-  tape
                    ?~  rows  ~
                    %+  weld  (row widths.t (head rows))  $(rows (tail rows))
                ==
              ::
              ++  paragraph
                |=  [p=paragraph:leaf:m]
                ^-  tape
                (contents:inline contents.p)
            --
          ::
          ++  container
            =>  |%
                  ++  line
                    %+  cook  snoc
                    ;~  plug
                      (star ;~(less (just '\0a') prn))
                      (just '\0a')
                    ==
                --
            |%
              ++  node
                |=  [n=node:container:m]
                ?-  -.n
                  %block-quote  (block-quote n)
                  %ul           (ul n)
                  %ol           (ol n)
                  %tl           (tl n)
                ==
              ::
              ++  block-quote
                |=  [b=block-quote:container:m]
                ^-  tape
                %+  scan  (markdown markdown.b)            :: First, render the contents
                %+  cook  zing  %-  plus                   :: Many lines
                  %+  cook  |=  [a=tape newline=@t]        :: Prepend each line with "> "
                            ^-  tape
                            ;:  weld
                              ">"
                              ?~(a "" " ")                 :: If the line is blank, no trailing space
                              a
                              "\0a"
                            ==
                  ;~  plug                                 :: Break into lines
                    (star ;~(less (just '\0a') prn))
                    (just '\0a')
                  ==
              ::
              ++  ul
                |=  [u=ul:container:m]
                ^-  tape
                %-  zing  %+  turn  contents.u             :: Each bullet point...
                  |=  [item=markdown:m]
                  ^-  tape
                  %+  scan  (markdown item)                   :: First, render bullet point contents
                  %+  cook  zing
                  ;~  plug
                    %+  cook  |=  [a=tape]                 :: Prepend 1st line with indent + bullet char
                              ;:  weld
                                (reap indent-level.u ' ')
                                (trip marker-char.u)
                                " "
                                a
                              ==
                      line  :: first line
                    %-  star
                      %+  cook  |=  [a=tape]               :: Subsequent lines just get indent
                                ?:  ?|(=("" a) =("\0a" a))  a
                                ;:  weld
                                  (reap indent-level.u ' ')
                                  "  "  :: 2 spaces, to make it even with the 1st line
                                  a
                                ==
                        line  :: second and thereafter lines
                  ==
              ++  tl
                |=  [t=tl:container:m]
                ^-  tape
                %-  zing  %+  turn  contents.t             :: Each bullet point...
                  |=  [is-checked=? item=markdown:m]
                  ^-  tape
                  %+  scan  (markdown item)                   :: First, render bullet point contents
                  %+  cook  zing
                  ;~  plug
                    %+  cook  |=  [a=tape]                 :: Prepend 1st line with indent, bullet char, checkbox
                              ;:  weld
                                (reap indent-level.t ' ')
                                (trip marker-char.t)
                                " ["
                                ?:(is-checked "x" " ")
                                "] "
                                a
                              ==
                      line  :: first line
                    %-  star
                      %+  cook  |=  [a=tape]               :: Subsequent lines just get indent
                                ?:  ?|(=("" a) =("\0a" a))  a
                                ;:  weld
                                  (reap indent-level.t ' ')
                                  "  "  :: 2 spaces, to make it even with the 1st line
                                  a
                                ==
                        line  :: second and thereafter lines
                  ==
              ::
              ++  ol
                |=  [o=ol:container:m]
                ^-  tape
                %-  zing  %+  turn  contents.o             :: Each item...
                  |=  [item=markdown:m]
                  ^-  tape
                  %+  scan  (markdown item)                   :: First, render item contents
                  %+  cook  zing
                  ;~  plug
                    %+  cook  |=  [a=tape]                 :: Prepend 1st line with indent + item number
                              ;:  weld
                                (reap indent-level.o ' ')
                                (a-co:co start-num.o)
                                (trip marker-char.o)
                                " "
                                a
                              ==
                      line  :: first line
                    %-  star
                      %+  cook  |=  [a=tape]               :: Subsequent lines just get indent
                                ?:  ?|(=("" a) =("\0a" a))  a
                                ;:  weld
                                  (reap indent-level.o ' ')
                                  (reap (lent (a-co:co start-num.o)) ' ')
                                  "  "  :: 2 spaces, to make it even with the 1st line
                                  a
                                ==
                        line  :: second and thereafter lines
                  ==
            --
          ::
          ++  markdown
            |=  [a=markdown:m]
            ^-  tape
            %-  zing  %+  turn  a   |=  [item=node:markdown:m]
                                    ?-  -.item
                                      %leaf  (node:leaf +.item)
                                      %container  (node:container +.item)
                                    ==
        --
  ::
  ::  Enserialize as Sail (manx and marl)
  ++  sail-en
    =<
        |=  [document=markdown:m]
        =/  link-ref-defs  (all-link-ref-definitions document)
        ^-  manx
        ;div
          ;*  (~(markdown sail-en link-ref-defs) document)
        ==
    ::
    |_  [reference-links=(map @t urlt:ln:m)]
      ++  inline
        =>  |%
              ++  get-direct-link  :: DUPE: get-direct-link
                |=  [=target:ln:m]
                ^-  urlt:ln:m
                ?-  -.target
                  %direct  urlt.target                          :: Direct link; use it
                  %ref                                          :: Ref link; look it up
                    ~|  "reflink not found: {<label.target>}"
                    (~(got by reference-links) label.target)
                ==
            --
        |%
          ++  contents
            |=  [=contents:inline:m]
            ^-  marl
            %+  turn  contents  element
          ++  element
            |=  [e=element:inline:m]
            ^-  manx
            ?-  -.e
              %text  (text e)
              %link  (link e)
              %code-span  (code e)
              %escape  (escape e)
              %entity  (entity e)
              %strong  (strong e)
              %emphasis  (emphasis e)
              %strikethru  (strikethru e)
              %soft-line-break  (softbrk e)
              %line-break  (hardbrk e)
              %image  (image e)
              %autolink  (autolink e)
            ==
          ++  text
            |=  [t=text:inline:m]
            ^-  manx
            [[%$ [%$ (trip text.t)] ~] ~]  :: Magic; look up the structure of a `manx` if you want
          ++  escape
            |=  [e=escape:inline:m]
            ^-  manx
            [[%$ [%$ (trip char.e)] ~] ~]  :: Magic; look up the structure of a `manx` if you want
          ++  entity
            |=  [e=entity:inline:m]
            ^-  manx
            =/  fulltext  (crip ;:(weld "&" (trip code.e) ";"))
            [[%$ [%$ `tape`[fulltext ~]] ~] ~]             :: We do a little sneaky
          ++  softbrk
            |=  [s=softbrk:inline:m]
            ^-  manx
            (text [%text ' '])
          ++  hardbrk
            |=  [h=hardbrk:inline:m]
            ^-  manx
            ;br;
          ++  code
            |=  [c=code:inline:m]
            ^-  manx
            ;code: {(trip text.c)}
          ++  link
            |=  [l=link:inline:m]
            ^-  manx
            =/  =urlt:ln:m  (get-direct-link target.l)
            ;a(href (trip text.url.urlt), title (trip (fall title-text.urlt '')))
              ;*  (contents contents.l)
            ==
          ++  image
            |=  [i=image:inline:m]
            ^-  manx
            =/  target  target.i
            =/  =urlt:ln:m  (get-direct-link target.i)
            ;img(src (trip text.url.urlt), alt (trip alt-text.i));
          ++  autolink
            |=  [a=autolink:inline:m]
            ^-  manx
            ;a(href (trip text.a)): {(trip text.a)}
          ++  emphasis
            |=  [e=emphasis:inline:m]
            ^-  manx
            ;em
              ;*  (contents contents.e)
            ==
          ++  strong
            |=  [s=strong:inline:m]
            ^-  manx
            ;strong
              ;*  (contents contents.s)
            ==
          ++  strikethru
            |=  [s=strikethru:inline:m]
            ^-  manx
            ;strike
              ;*  (contents contents.s)
            ==
        --
      ++  leaf
        |%
          ++  node
            |=  [n=node:leaf:m]
            ^-  manx
            ?-  -.n
              %blank-line  (blank-line n)
              %break  (break n)
              %heading  (heading n)
              %indent-codeblock  (codeblk-indent n)
              %fenced-codeblock  (codeblk-fenced n)
              %table  (table n)
              %paragraph  (paragraph n)
              %link-ref-definition  (text:inline [%text ' '])  :: Link ref definitions don't render as anything
              :: ...etc
            ==
          ++  heading
            |=  [h=heading:leaf:m]
            ^-  manx
            :-
              :_  ~   ?+  level.h  !!                     :: Tag and attributes; attrs are empty (~)
                        %1  %h1
                        %2  %h2
                        %3  %h3
                        %4  %h4
                        %5  %h5
                        %6  %h6
                      ==
            (contents:inline contents.h)
          ++  blank-line
            |=  [b=blank-line:leaf:m]
            ^-  manx
            (text:inline [%text ' '])
          ++  break
            |=  [b=break:leaf:m]
            ^-  manx
            ;hr;
          ++  codeblk-indent
            |=  [c=codeblk-indent:leaf:m]
            ^-  manx
            ;pre
              ;code: {(trip text.c)}
            ==
          ++  codeblk-fenced
            |=  [c=codeblk-fenced:leaf:m]
            ^-  manx
            ;pre
              ;+  ?:  =(info-string.c '')
                    ;code: {(trip text.c)}
                  ;code(class (weld "language-" (trip info-string.c))): {(trip text.c)}
            ==
          ++  table
            |=  [t=table:leaf:m]
            ^-  manx
            ;table
              ;thead
                ;tr
                  ;*  =/  hdr  head.t
                      =/  align  align.t
                      |-
                        ?~  hdr  ~
                        :-  ;th(align ?-((head align) %c "center", %r "right", %l "left", %n ""))
                              ;*  (contents:inline (head hdr))
                            ==
                        $(hdr (tail hdr), align (tail align))

                ==
              ==
              ;tbody
                ;*  %+  turn  rows.t
                    |=  [r=(list contents:inline:m)]
                    ^-  manx
                    ;tr
                      ;*  =/  row  r
                          =/  align  align.t
                          |-
                            ?~  row  ~
                            :-  ;td(align ?-((head align) %c "center", %r "right", %l "left", %n ""))
                                  ;*  (contents:inline (head row))
                                ==
                            $(row (tail row), align (tail align))
                    ==
              ==
            ==
          ++  paragraph
            |=  [p=paragraph:leaf:m]
            ^-  manx
            ;p
              ;*  (contents:inline contents.p)
            ==
        --
      ::
      ++  container
        |%
          ++  node
            |=  [n=node:container:m]
            ^-  manx
            ?-  -.n
              %block-quote  (block-quote n)
              %ul           (ul n)
              %ol           (ol n)
              %tl           (tl n)
            ==
          ::
          ++  block-quote
            |=  [b=block-quote:container:m]
            ^-  manx
            ;blockquote
              ;*  (~(. markdown reference-links) markdown.b)
            ==
          ::
          ++  ul
            |=  [u=ul:container:m]
            ^-  manx
            ;ul
              ;*  %+  turn  contents.u  |=  [a=markdown:m]
                                        ^-  manx
                                        ;li
                                          ;*  (~(. markdown reference-links) a)
                                        ==
            ==
          ::
          ++  ol
            |=  [o=ol:container:m]
            ^-  manx
            ;ol(start (a-co:co start-num.o))
              ;*  %+  turn  contents.o  |=  [a=markdown:m]
                                        ^-  manx
                                        ;li
                                          ;*  (~(. markdown reference-links) a)
                                        ==
            ==
          ++  tl
            |=  [t=tl:container:m]
            ^-  manx
            ;ul.task-list
              ;*  %+  turn  contents.t  |=  [is-checked=? a=markdown:m]
                                        ^-  manx
                                        ;li
                                          ;+  ?:  is-checked
                                                ;input(type "checkbox", checked "true");
                                              ;input(type "checkbox");
                                          ;*  (~(. markdown reference-links) a)
                                        ==
            ==
        --
      ::
      ++  markdown
        |=  [a=markdown:m]
        ^-  marl
        %+  turn  a   |=  [item=node:markdown:m]
                      ?-  -.item
                        %leaf  (node:leaf +.item)
                        %container  (node:container +.item)
                      ==
    --
--
