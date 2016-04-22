//
//  Favicon.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 5..
//  Copyright © 2015 Trevi Community. All rights reserved.
//

import Foundation
import Trevi

// use for favicon.io
public class Favicon: Middleware {

    public var name: MiddlewareName = .Favicon;

    public init () {

    }

    public func handle(req: Request, res: Response, next: NextCallback?) {


        if req.url == "/favicon.ico" {

            #if os(Linux)
            #else
                guard let bundlePath = NSBundle.mainBundle().pathForResource(NSURL(fileURLWithPath: req.url).lastPathComponent!, ofType: nil) else{
                    return next!()
                }
                
                let file = FileSystem.ReadStream(path: bundlePath)
                
                let faviconData :NSMutableData! = NSMutableData()
                file?.onClose() { handle in
                    return res.send(faviconData,type: "image/x-icon")
                }
                
                file?.readStart() { error, data in
                    if error == 0{
                        faviconData.appendData(data)
                    }else{
                        return next!()
                    }
                }

            #endif
        }else{
            return next!()
        }
    }
}