# Lime

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Mac OS X](https://img.shields.io/badge/platform-osx-lightgrey.svg?style=flat)](https://developer.apple.com/swift/)
[![Ubuntu](https://img.shields.io/badge/platform-linux-lightgrey.svg?style=flat)](http://www.ubuntu.com/)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)

## Overview
Lime is improved web framework for Trevi, and Lime refers to express.js. (Lime does not support many core modules in express yet.)

## Versioning
Lime follows the semantic versioning scheme. The API change and backwards compatibility rules are those indicated by SemVer.

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

## License
This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE.txt).