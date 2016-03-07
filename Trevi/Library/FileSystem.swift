//
//  FileStream.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 3. 6..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv
import Foundation


public class FileSystem {

public struct Options {
    public var fd : Int32! = nil
    public var flags : Int32! = nil
    public var mode : Int32! = nil
}
    
    
// Should be inherited from StreamReadable

public class ReadStream {
    
    public let pipe : Pipe = Pipe()
    public var options : Options = Options()
    
    public init(path : String, options : Options? = nil) {
        
        self.options.flags = O_RDONLY
        self.options.mode = 0o666
        
        if let options = options { self.setOptions(options) }
        
        
        if self.options.fd == nil {
            self.options.fd = FsBase.open(self.pipe.pipeHandle, path : path,
                flags: self.options.flags, mode: self.options.mode)
        }
        
        if self.options.fd <= 0 {
            // Should handle error
            
        }
        else{
            Pipe.open(self.pipe.pipeHandle, fd: self.options.fd)
        }
//        print("read init")
    }
    
    deinit{
//        print("read deinit")
        Handle.close(self.pipe.handle)
    }
    
    func setOptions(options : Options) {
        self.options.fd = options.fd
        self.options.flags = options.flags == nil ? O_RDONLY : options.flags
        self.options.mode = options.mode == nil ?  0o666 : options.mode
    }
    
    public func setCloseCallback(callback : ((handle : uv_handle_ptr)->Void)) {
        
        self.pipe.event.onClose = { (handle) in
            
            callback(handle: handle)
            
            let request = uv_fs_ptr(handle.memory.data)
            FsBase.close(request)
            request.dealloc(1)
        }
        
    }
    
    
    public func readStart(callback : ((error : Int32, data : NSData)->Void)) {
        
        self.pipe.event.onRead = { (handle, data) in
            
            callback(error : 0, data : data)
        }
        
        Stream.readStart(self.pipe.streamHandle)
        Loop.run(mode: UV_RUN_ONCE)
    }
    
}
    
    
// Should be inherited from StreamReadable
    
public class WriteStream {
    
    public let pipe : Pipe = Pipe()
    public var options : Options = Options()
    
    public init(path : String, options : Options? = nil) {
        
        self.options.flags = O_CREAT | O_WRONLY
        self.options.mode = 0o666
        
        if let options = options { self.setOptions(options) }
        
        if self.options.fd == nil {
            self.options.fd = FsBase.open(self.pipe.pipeHandle, path : path,
                flags: self.options.flags, mode: self.options.mode)
        }
        
        if self.options.fd <= 0 {
            // Should handle error
            print(self.options.fd)
        }
        else{
            Pipe.open(self.pipe.pipeHandle, fd: self.options.fd)
        }
        
//        print("write init")
    }
    
    deinit{
//        print("write deinit")
    }
    
    
    func setOptions(options : Options) {
        self.options.fd = options.fd
        self.options.flags = options.flags == nil ? O_CREAT | O_WRONLY : options.flags
        self.options.mode = options.mode == nil ?  0o666 : options.mode
    }
    
    public func close() {
        let request = uv_fs_ptr(self.pipe.pipeHandle.memory.data)
        FsBase.close(request)
        Handle.close(self.pipe.handle)
        request.dealloc(1)
    }
    
    
    public func writeData(data : NSData) {
        
        Stream.doWrite(data, handle: self.pipe.streamHandle)
    }
    
}

}
