# Donkey Kong Junior

Analogue Pocket port of Donkey Kong Jr.

## Features

* Dip switches for starting lives, and bonuses.

## Known Issues

* High Score saving doesn't work.
* Tate mode isn't supported.

## Attribution

```
---------------------------------------------------------------------------------
-- 
-- Arcade: Donkey Kong Junior port to MiSTer by gaz68 (https://github.com/gaz68)
-- 12 October 2019
-- 
-- Original Donkey Kong port to MiSTer by Sorgelig
-- 18 April 2018
-- 
---------------------------------------------------------------------------------
-- 
-- dkong Copyright (c) 2003 - 2004 Katsumi Degawa
-- T80   Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org) All rights reserved
-- T48   Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org) All rights reserved
-- 
---------------------------------------------------------------------------------
-- 
```

-  Quartus template and core integration based on the Analogue Pocket port of [Donkey Kong by ericlewis](https://github.com/ericlewis/openFPGA-DonkeyKong)

## ROM Instructions

ROM files are not included, you must use [mra-tools-c](https://github.com/sebdel/mra-tools-c/) to convert to a singular `dkongjr.rom` file, then place the ROM file in `/Assets/dkongjr/common`.
