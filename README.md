moai-framework
==============

Moai lua framework based on Hanappe/flower. 
While I was using flower for my projects, I've made some modifications to it. Some of them were merged back into main hanappe repo. 
Before starting a new game project I wanted to make own framework for my PyQt editor-host, but ended up using much from hanappe codebase =)
So here it is. 

Main differences from hanappe/flower:
* Lighter that Hanappe. More like flower, but split into different files
* Some GUI stuff included. Currently: Buttons, ScrollView, Dialog. TODO: TableView. I think this is enough for nearly every modern game
* Cartesian coordinate system - origin at center, Y growing up
* By using Display.Sprite constructor you can make Props with different decks initialized to use TexturePacker atlas, single image file, nine patch or grid tile. Nine patch is defined by .9.png extension, grid tiles using .tile.png extension (tiles and nine patches can be packed in atlases too, but without rotation)
* No difference between atlas image and separate png. If you keep unique frame names across all your atlases you can make ResourceMgr to cache their names, and then you'll be able to create props from atlas without specifying atlas name, i.e. just Display.Sprite("image.png"). If separate image.png file exists, then it will take priority, if it's not found, then "image.png" is looked-up in cached sprite names and can be created from atlas. This allows for cleaner live-reload functionality, when you can override packed atlas image with separate png file and tune your artwork without the need to repack atlas. 
* Ads classes to manage ads rotation. Will randomly precache next available ad network
* External tools: layout exporter from Adobe Illustrator and compile_layout.py script to build declarative lua source with that layout; basic obj file converter to lua data, then it can be read to costruct MOAIMesh, currently only vertex data and UV is imported.

