//
//  EventHandler.swift
//  SwiftGCDSocket
//
//  Created by JangTaehwan on 2015. 12. 8..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Dispatch


/**
* Set the 'defaultQueue' to 'dispatch_get_main_queue()' for single thread server model.
* Then all event will dispatch to main queue in GCD, and all tasks will be processed by main thread.
* Examples:
*   public let defaultQueue = dispatch_get_main_queue()
*
* On the other hand if you want multi thread server model and more parallelizing,
* set the defaultQueue to dispatch_get_global_queue(_ ,  0)
*
*/
public let defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

// Below codes are prototype for injecting read event according with Socket's states.
//  I think it's not good way, should find better way
public typealias readCallbackType = (() -> Int)


/**
 * ReadEvent
 * Socket's read event protocol
 *
 * Set read event type in EventHandler according with block and non-block.
 * These classes will be injected when socket's isNonblocking sets.
 *
 */
public protocol ReadEvent {
    func excute(callback : readCallbackType) -> Bool
}
public class BlockingRead : ReadEvent {
    public func excute(callback: readCallbackType) -> Bool {
        repeat{
            guard callback() != 0 else {
                return false
            }
        } while(true)
    }
}
public class NonBlockingRead : ReadEvent {
    public func excute(callback: readCallbackType) -> Bool {
        return callback() != 0
    }
}


/**
 * EventHandler class
 *
 * Manage all socket' read and write event based on GCD.
 *
 * Should change this module to be working in Linux.
 *
 */
public class EventHandler {
    
    let fd : Int32
    
    // Should abstract this queue's setting in Server Model Module
    var queue : dispatch_queue_t
    var source : dispatch_source_t?
    
    var writeQueue : dispatch_queue_t?
    var writeCounts : Int = 0
    
    var readEvent : ReadEvent = BlockingRead()
    
    public init(fd: Int32, queue : dispatch_queue_t = defaultQueue) {
        self.fd = fd
        self.queue = queue
    }
    deinit {
//        log.debug("EventHandler closed")
        if let source = self.source {
            dispatch_source_cancel(source)
        }
    }
    
    public func isEventValid() -> Bool { return self.source != nil ? true : false }
    
    public func isWriting() -> Bool { return self.writeCounts > 0 }
    
    // Should be devided read and write events
    public func cancelEvent() -> Bool {
        if let source = self.source {
            dispatch_source_cancel(source)
            self.source = nil
            return true
        }
        return false
    }
    
    
    /**
     * dispatchReadEvent
     * Dispatch socket's read event.
     *
     * Examples:
     *  eventHandle.dispatchReadEvent(){
     *
     *      let (count, buffer) = clientSocket.read()
     *
     *      clientSocket.write(buffer, length: count, queue: dispatch_get_main_queue())
     *
     *      return count
     *  }
     *
     * @param
     *  First : Should be readCallbackType and return read length. If return 0 this EventHandler's
     *           read event will stop, and parent's socket will deinit. Don't be worry about strong 
     *           reference. All parent's properties will be destroyed.
     *
     *
     * @return
     *  Success or failure.
     */
    public func dispatchReadEvent(callback : readCallbackType) -> Bool {
        source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ,
            UInt(fd), 0, queue)
        
        if let source = self.source {
            dispatch_source_set_event_handler(source) {
                
                guard self.readEvent.excute(callback) else {
                    self.cancelEvent()
                    return
                }
            }
            
            dispatch_resume(source)
            return true
        }
        else {
            log.error("Could not dispatch event")
            return false
        }
    }
    
    /**
     * dispatchWriteEvent
     * Write response data to this socket.
     *
     * Examples:
     *  eventHandle.dispatchWriteEvent(buffer, length : length) {
     *      if self.isClosing { self.close() }
     *  }
     *
     * @param
     *  First : Data buffer pointer<data type>.
     *  Second : Daga length.
     *  Third : Close event to prevent socket closing before writting.
     *
     * @return
     *  Success or failure.
     */
    public func dispatchWriteEvent<M>(buffer : UnsafePointer<M>,
        length : Int, closeSocket : ()->() ) -> Bool {
        
        let typeSize = sizeof(M) <= 0 ? 1 : sizeof(M)
        let bufferSize = length*typeSize
        
        guard bufferSize > 0 else { return true }
        if writeQueue == nil { writeQueue = self.queue }
        
        guard let dispatchData = dispatch_data_create(buffer, bufferSize, writeQueue! , nil) else {
            return false
        }
        
        ++self.writeCounts
        dispatch_write(fd, dispatchData, writeQueue!) {
            _, _ in

            --self.writeCounts
            if !self.isWriting() { closeSocket() }
        }
        
        return true
    }
}