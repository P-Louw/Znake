## Snake 🐍 zig
<p align="center" width="100%">
    <img width="33%" src="https://github.com/P-Louw/Znake/blob/master/znake_preview.gif"> 
</p>

Simple snake version written in zig using [SDL-zig](https://github.com/MasterQ32/SDL.zig) for bindings and a few wrapper functions.
Build with master version of zig (at writing 0.10.0).

### Building

The zig sdl wrapper is included using submodules, this needs to be fetched.
```
git submodule update --init --recursive
```

In order to build you need the following libs on your system.
- SDL2-devel
- SDL2-ttf-devel

To build and run.
```
zig build run
```




