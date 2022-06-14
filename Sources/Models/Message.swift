/*
 MIT License

 Copyright (c) 2017-2020 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

open class Message: Codable {
    open var timestamp: Int64
    open var sender: String
    public let message_type: String
    public let message_id: String
    open var message: String
    open var media: [MessageMedia]
    open var sms_sender_email: String?
    open var edited: Bool
    open var is_internal_message: Bool {
        get {
            return message_type == "internal_message"
        }
    }
    open var mentioned_users: [String]?
    public let delivery_timestamp: Int64?
    public let delivery_status: String?
    public let c2c: C2C?

    public init(timestamp: Int64,
         members: [Member],
         sender: String,
         type: String,
         messageId: String,
         message: String,
         media: [MessageMedia],
         smsSenderEmail: String?,
         edited: Bool,
         mentions: [String],
         deliveryTimestamp: Int64?,
         deliveryStatus: String?,
         c2c: C2C?) {
        self.timestamp = timestamp
        self.sender = sender
        self.message_type = type
        self.message_id = messageId
        self.message = message
        self.media = media
        self.sms_sender_email = smsSenderEmail
        self.mentioned_users = mentions
        self.edited = edited
        self.delivery_timestamp = deliveryTimestamp
        self.delivery_status = deliveryStatus
        self.c2c = c2c
    }
}

open class SingleMessage: Codable {
    public let thread_type: String
    public let thread_members: [Member]
    public let thread_id: String
    public let message: Message
}

public struct MessageResponse: Codable {
    public let message: String
    public let data: SingleMessage
    public let code: Int
}

open class SendFileResponseThread: Codable {
    public let c2c_type: String?
    open var thread_members: [Member]
    public let thread_id: String
    public let thread_type: String
    public let is_c2c: Bool
}

open class SendFileResponse: Codable {
    public let thread: SendFileResponseThread
    public let message_id: String
    public let message: String
    public let mobile_callback_id: String
    public let thread_id: String
    public let code: Int
}
