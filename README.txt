= flame_channel_parser

* http://guerilla-di.org/flame-channel-parser

== DESCRIPTION:

Includes a small library for parsing and baking anmation curves made on Discrodesk Floke/Inflinto, also known as flame.

== FEATURES/PROBLEMS:

* Currently only supports file versions up to and including 2011
* Only constant extrapolation for now, no looping or pingpong

== SYNOPSIS:

    require "flame_channel_parser"
    channels = File.open("TW_Setup.timewarp") do | f |
      FlameChannelParser.parse(f)
    end
    
    # Find the channel that we are interested in
    frame_channel = channels.find{|c| c.name == "Frame" }
    
    # Now sample from frame 20 to frame 250
    (20..250).each do | frame_in_setup |
      p frame_channel.value_at(frame_in_setup)
    end
    
== REQUIREMENTS:

* FIX (list of requirements)

== INSTALL:

* FIX (sudo gem install, anything else)

== LICENSE:

(The MIT License)

Copyright (c) 2011 Julik Tarkhanov

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
