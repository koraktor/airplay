# Airplay

A client (and someday a server) of the superfancy http content stream technique
that Apple uses in its products.

You can try this in an AppleTV for instance.

## Basic Usage

```ruby
require 'airplay'

airplay = Airplay::Client.new
# To send an image
airplay.send_image("fancy_pants.jpg")
# To stream a video
airplay.send_video("http://www.yo-yo.org/mp4/yu2.mp4")
```

## Useful methods

```ruby
require 'airplay'

airplay = Airplay::Client.new
airplay.browse
#=> [#<Airplay::Node:0x007fbb5a83eb28 @name="elCuervo", @domain="local.", @ip="10.1.0.63">, #<Airplay::Node:0x007fbb5a83b0b8 @name="Apple TV", @domain="local.", @ip="10.1.0.220">]
airplay.use "elCuervo"
airplay.use "Apple TV"
```

## Contributors
[pote](http://github.com/pote)
