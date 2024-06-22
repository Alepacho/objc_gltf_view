# .gltf viewer! (with animations)

This is a simple .glTF viewer I made in 5-6 days.

Written in Objective-C (using my own framework instead of Foundation).

Libraries: SDL, OpenGL (Glad), cglm and cgltf.
Check vendor for more info.

## How 2 run

Well, I use CMake, Clang and VSCode.

Follow the instructions:

```sh
# clone this repo, then:
$ git submodule update --init --recursive  
# Compile Base library first (check /vendor/base/README.md)
# Then:
$ mkdir build && cd build
$ cmake ..              
```

It should work on macOS. For Windows/Linux just change some CMakeLists.txt params.
That's it, I guess...

## Controls

```
WASDQE        : Move model
ARROWS and <> : Rotate Model
1 or 2        : Prev/Next frame
LEFT SHIFT    : same as upper controls but with more power
J             : Show Joints
SPACE         : Start/Stop Rotation
ENTER         : Start/Stop Animation
```

## Specification

[glTF-2.0 spec](https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html)

[Sample Models](https://github.com/KhronosGroup/glTF-Sample-Assets)

[Useful Image](gltfOverview-2.0.0a.png)

## License

```
   Copyright 2024 Alepacho

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```
