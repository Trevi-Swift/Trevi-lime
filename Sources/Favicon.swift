//
//  Favicon.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi

public class Favicon: Middleware {

    public var name: MiddlewareName = .Favicon;

    public init () {

    }

    public func handle(req: IncomingMessage, res: ServerResponse, next: NextCallback?) {

        next!()
    }
}