/*
 * DO NOT EDIT.
 *
 * Generated by the protocol buffer compiler.
 * Source: loader.proto
 *
 */

/*
 * Copyright 2017, gRPC Authors All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import Foundation
import Dispatch
import gRPC
import SwiftProtobuf

/// Type for errors thrown from generated server code.
internal enum Iroha_Network_Proto_LoaderServerError : Error {
  case endOfStream
}

/// To build a server, implement a class that conforms to this protocol.
internal protocol Iroha_Network_Proto_LoaderProvider {
  func retrieveblocks(request : Iroha_Network_Proto_BlocksRequest, session : Iroha_Network_Proto_LoaderretrieveBlocksSession) throws
  func retrieveblock(request : Iroha_Network_Proto_BlockRequest, session : Iroha_Network_Proto_LoaderretrieveBlockSession) throws -> Iroha_Protocol_Block
}

/// Common properties available in each service session.
internal class Iroha_Network_Proto_LoaderSession {
  fileprivate var handler : gRPC.Handler
  internal var requestMetadata : Metadata { return handler.requestMetadata }

  internal var statusCode : Int = 0
  internal var statusMessage : String = "OK"
  internal var initialMetadata : Metadata = Metadata()
  internal var trailingMetadata : Metadata = Metadata()

  fileprivate init(handler:gRPC.Handler) {
    self.handler = handler
  }
}

// retrieveBlocks (Server Streaming)
internal class Iroha_Network_Proto_LoaderretrieveBlocksSession : Iroha_Network_Proto_LoaderSession {
  private var provider : Iroha_Network_Proto_LoaderProvider

  /// Create a session.
  fileprivate init(handler:gRPC.Handler, provider: Iroha_Network_Proto_LoaderProvider) {
    self.provider = provider
    super.init(handler:handler)
  }

  /// Send a message. Nonblocking.
  internal func send(_ response: Iroha_Protocol_Block, completion: @escaping ()->()) throws {
    try handler.sendResponse(message:response.serializedData()) {completion()}
  }

  /// Run the session. Internal.
  fileprivate func run(queue:DispatchQueue) throws {
    try self.handler.receiveMessage(initialMetadata:initialMetadata) {(requestData) in
      if let requestData = requestData {
        do {
          let requestMessage = try Iroha_Network_Proto_BlocksRequest(serializedData:requestData)
          // to keep providers from blocking the server thread,
          // we dispatch them to another queue.
          queue.async {
            do {
              try self.provider.retrieveblocks(request:requestMessage, session: self)
              try self.handler.sendStatus(statusCode:self.statusCode,
                                          statusMessage:self.statusMessage,
                                          trailingMetadata:self.trailingMetadata,
                                          completion:{})
            } catch (let error) {
              print("error: \(error)")
            }
          }
        } catch (let error) {
          print("error: \(error)")
        }
      }
    }
  }
}

// retrieveBlock (Unary)
internal class Iroha_Network_Proto_LoaderretrieveBlockSession : Iroha_Network_Proto_LoaderSession {
  private var provider : Iroha_Network_Proto_LoaderProvider

  /// Create a session.
  fileprivate init(handler:gRPC.Handler, provider: Iroha_Network_Proto_LoaderProvider) {
    self.provider = provider
    super.init(handler:handler)
  }

  /// Run the session. Internal.
  fileprivate func run(queue:DispatchQueue) throws {
    try handler.receiveMessage(initialMetadata:initialMetadata) {(requestData) in
      if let requestData = requestData {
        let requestMessage = try Iroha_Network_Proto_BlockRequest(serializedData:requestData)
        let replyMessage = try self.provider.retrieveblock(request:requestMessage, session: self)
        try self.handler.sendResponse(message:replyMessage.serializedData(),
                                      statusCode:self.statusCode,
                                      statusMessage:self.statusMessage,
                                      trailingMetadata:self.trailingMetadata)
      }
    }
  }
}


/// Main server for generated service
internal class Iroha_Network_Proto_LoaderServer {
  private var address: String
  private var server: gRPC.Server
  private var provider: Iroha_Network_Proto_LoaderProvider?

  /// Create a server that accepts insecure connections.
  internal init(address:String,
              provider:Iroha_Network_Proto_LoaderProvider) {
    gRPC.initialize()
    self.address = address
    self.provider = provider
    self.server = gRPC.Server(address:address)
  }

  /// Create a server that accepts secure connections.
  internal init?(address:String,
               certificateURL:URL,
               keyURL:URL,
               provider:Iroha_Network_Proto_LoaderProvider) {
    gRPC.initialize()
    self.address = address
    self.provider = provider
    guard
      let certificate = try? String(contentsOf: certificateURL, encoding: .utf8),
      let key = try? String(contentsOf: keyURL, encoding: .utf8)
      else {
        return nil
    }
    self.server = gRPC.Server(address:address, key:key, certs:certificate)
  }

  /// Start the server.
  internal func start(queue:DispatchQueue = DispatchQueue.global()) {
    guard let provider = self.provider else {
      assert(false) // the server requires a provider
    }
    server.run {(handler) in
      print("Server received request to " + handler.host
        + " calling " + handler.method
        + " from " + handler.caller
        + " with " + String(describing:handler.requestMetadata) )

      do {
        switch handler.method {
        case "/iroha.network.proto.Loader/retrieveBlocks":
          try Iroha_Network_Proto_LoaderretrieveBlocksSession(handler:handler, provider:provider).run(queue:queue)
        case "/iroha.network.proto.Loader/retrieveBlock":
          try Iroha_Network_Proto_LoaderretrieveBlockSession(handler:handler, provider:provider).run(queue:queue)
        default:
          break // handle unknown requests
        }
      } catch (let error) {
        print("Server error: \(error)")
      }
    }
  }
}
