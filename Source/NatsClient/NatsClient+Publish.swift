//
//  NatsClient+Publish.swift
//  SwiftyNats
//
//  Created by Ray Krow on 2/27/18.
//

import Foundation

extension NatsClient: NatsPublish {
    
    // MARK - Implement NatsPublish Protocol
    
    open func publish(_ payload: String, to subject: String) {
        sendMessage(NatsMessage.publish(payload: payload, subject: subject))
    }
    
    open func publish(_ payload: String, to subject: NatsSubject) {
        publish(payload, to: subject.subject)
    }
    
    open func reply(toMessage message: NatsMessage, withPayload payload: String) {
        guard let replySubject = message.replySubject else { return }
        publish(payload, to: replySubject.subject)
    }
    
    open func publishSync(_ payload: String, to subject: String) throws {
        
        let group = DispatchGroup()
        group.enter()
                
        var response: NatsResponse?
        
        DispatchQueue.global().async {
            response = self.getResponseFromStream()
            group.leave()
        }
        
        publish(payload, to: subject)
        
        group.wait()

        if response?.type == .error {
            throw NatsPublishError(response?.message ?? "")
        }
        
    }
    
    open func publishSync(_ payload: String, to subject: NatsSubject) throws {
        try publishSync(payload, to: subject.subject)
    }
    
    open func replySync(toMessage message: NatsMessage, withPayload payload: String) throws {
        guard let replySubject = message.replySubject else { return }
        try publishSync(payload, to: replySubject.subject)
    }
    
}
