# MyHub [![Build Status](https://travis-ci.org/Arcterus/MyHub.png)] #

A simple GitHub client designed for iOS 7.

## Dependencies ##
#### Build ####

* `xctool`
* iOS SDK (at least v7.0)

#### Runtime ####

* iPhone 4 or better

## Build Instructions ##

Before building, you'll need to add an ```include/MHClientSecret.h``` file with
the macros CLIENT_ID and CLIENT_SECRET defined like so:
```c
#define CLIENT_ID     "123456789"
#define CLIENT_SECRET "123456789abcdefghij"
```

After that, you will be able to actually build MyHub:

```bash
$ ./bootstrap.sh
$ xctool -project MyHub.xcodeproj -scheme MyHub build
```

## Legal ##

Copyright (C) 2013 kRaken Research.  All rights reserved.  

This project is licensed under the MPL v2.0.  See LICENSE for more details.
