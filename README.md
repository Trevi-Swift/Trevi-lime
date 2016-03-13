# Trevi-Lime

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Mac OS X](https://img.shields.io/badge/platform-osx-lightgrey.svg?style=flat)](https://developer.apple.com/swift/)
[![Ubuntu](https://img.shields.io/badge/platform-linux-lightgrey.svg?style=flat)](http://www.ubuntu.com/)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)

## Overview
Lime is improved web framework for Trevi, and Lime refers to express.js. 

## Notice
If you want to build or test all projects at Xcode, please check out [Trevi-Dev](https://github.com/Trevi-Swift/Trevi-Dev). 
Otherwise, you can build Trevi, lime and other packages by using Swift Package manager.  
[Here](https://github.com/Trevi-Swift/example-trevi-lime) are an example and it now runs on Linux.  

## Features
- powerful routing
- user-friendly usage
- HTTP sub modules (redirection, favicon, etc)
- View render supporting Swift Server Page template engines
- Can parsing all type of body data
- Make high performance.

## Swift version
Trevi works with the latest version of Swift 2.2 Snapshot. You can download Swift binaries on [here](https://swift.org/download/#latest-development-snapshots).

## Installation (Ubuntu; APT-based linux)
1. Install Swift dependencies on linux :
    ```bash
    sudo apt-get install clang libicu-dev
    ```
  
2. Install libuv dependencies on linux :
    ```bash
    sudo apt-get install autoconf make build-essential gcc g++
    ```
  
3. Install Swift depending on your platform on the follow [link](https://swift.org/download) (The latest version are recommended).

4. After installation of Swift, check your PATH environment variable whether Swift binary path is set or not. If it is not set execute below. :
    ```bash
    $ export PATH=/path/to/swift/installed:"${PATH}"
    ```

    More details : 'Linux' on [here](https://swift.org/download)
  
5. Clone libuv :
    ```bash
    $ git clone https://github.com/libuv/libuv.git
    ```
  
6. Install libuv :
    ```bash
    $ cd libuv
    $ sh autogen.sh
    $ ./configure
    $ make
    $ make check
    $ make install
    ```

    More details : Build Instructions on [libuv](https://github.com/libuv/libuv)

## Installation (OS X)
1. Install Swift depending on your platform on the follow [link](https://swift.org/download) (The latest version are recommended).

2. After installation of Swift, check your PATH environment variable whether Swift binary path is set or not. If it is not set execute below. :
    ```bash
    $ export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:"${PATH}"
    ```

    More details : 'Apple Platforms' on [here](https://swift.org/download)
  
3. Clone libuv :
    ```bash
    $ git clone https://github.com/libuv/libuv.git
    ```
  
4. Install libuv :
    ```bash
    $ cd libuv
    $ sh autogen.sh
    $ ./configure
    $ make
    $ make check
    $ make install
    ```

    or using Homebrew :

    ```bash
    $ brew install --HEAD libuv
    ```

    More details : Build Instructions on [libuv](https://github.com/libuv/libuv)

## Usage
1. Create a new project directory
    ```bash
    mkdir HelloLime
    ```
  
2. Initialize this project as a new Swift package project
    ```bash
    cd HelloLime
    swift build --init
    ```
    Now your directory structure under HelloLime should look like this :
    <pre>
    HelloLime
    ├── Package.swift
    ├── Sources
    │   └── main.swift
    └── Tests
      └── <i>empty</i>
    </pre>
    **Note**: For more information on the Swift Package Manager, go [here](https://swift.org/package-manager)

3. Add a dependency of Trevi for your project (Package.swift) :
    ```swift
    import PackageDescription
    
    let package = Package(
        name: "HelloLime",
        dependencies: [
          .Package(url: "https://github.com/Trevi-Swift/Trevi-lime.git", versions: Version(0,1,0)..<Version(0,2,0)),
        ])
    ```

4. Import the modules in your code (ex: Sources/main.swift) :
    ```swift
    import Trevi
	import Lime
    ```

5. Implement one or more routers :
    ```swift
    public class Root {	    
	    private let lime = Lime()
	    private var router: Router!
	    
	    public init() {        
	        router = lime.router
            
	        router.get("/") { req , res , next in
	            res.send("Hello Lime!")
	        }

	        router.get("/param/:param") { req , res , next in
	            if let param = req.params["param"] {
	                res.send(param)
	            }
	            next!()
	        }
	    }
	}

	extension Root: Require {
	    public func export() -> Router {
	        return self.router
	    }
	}
    ```

6. Get instance of Lime and put router :
    ```swift
	let lime = Lime()
	lime.use("/", Root())
	lime.use { (req, res, next) in
	    res.statusCode = 404
	    res.send("404 error")
	}
    ```

7. Create and start a server :
    ```swift
    let server = Http ()
    server.createServer(lime).listen(8080)
    ```

8. Then your code should look like this :
    ```swift
    import Trevi
	import Lime

    public class Root {	    
	    private let lime = Lime()
	    private var router: Router!
	    
	    public init() {        
	        router = lime.router
            
	        router.get("/") { req , res , next in
	            res.send("Hello Lime!")
	        }

	        router.get("/param/:param") { req , res , next in
	            if let param = req.params["param"] {
	                res.send(param)
	            }
	            next!()
	        }
	    }
	}

	extension Root: Require {
	    public func export() -> Router {
	        return self.router
	    }
	}

	let lime = Lime()
	lime.use("/", Root())
	lime.use { (req, res, next) in
	    res.statusCode = 404
	    res.send("404 error")
	}

    let server = Http()
    server.createServer(lime).listen(8080)
    ```


8. Build your application :
    - Mac OS X :
		```bash
		swift build -Xcc -fblocks -Xswiftc -I/usr/local/include -Xlinker -L/usr/local/lib
		```
    - Ubuntu:
		```bash
		swift build -Xcc -fblocks
		```

9. Now run your application:
    ```bash
    .build/debug/HelloLime
    ```

10. Open your browser at [http://localhost:8080](http://localhost:8080)

11. Enjoy Lime!

## Versioning
Lime follows the semantic versioning scheme. The API change and backwards compatibility rules are those indicated by SemVer.

## License
This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE.txt).
