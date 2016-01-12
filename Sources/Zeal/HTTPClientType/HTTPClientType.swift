// HTTPClientType.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Core
import HTTP

public protocol HTTPClientType {
    var client: TCPClientType { get }
    var serializer: HTTPRequestSerializerType  { get }
    var parser: HTTPResponseParserType { get }
}

public typealias ResponsePair = (Response, StreamType)

extension HTTPClientType {
    public func send(request: Request, result: (Void throws -> ResponsePair) -> Void) {
        client.connect { connectResult in
            do {
                let stream = try connectResult()
                var headers = request.headers
                headers["Host"] = "\(self.client.host):\(self.client.port)"
                let newRequest = Request(
                    method: request.method,
                    uri: request.uri,
                    majorVersion: request.majorVersion,
                    minorVersion: request.minorVersion,
                    headers: headers,
                    body: request.body
                )
                self.serializer.serializeRequest(stream, request: newRequest) { serializeResult in
                    do {
                        try serializeResult()
                    } catch {
                        result({ throw error })
                        self.client.stop()
                    }
                }
                self.parser.parseResponse(stream) { parseResult in
                    do {
                        // TODO: Need a similar concept as Responder for request responses, with a context that allows conditionally closing the stream or piping
                        let response = try parseResult()
                        let pipedStream = stream.pipe()
                        result({ (response, pipedStream) })
                        // self.client.stop()
                    } catch {
                        result({ throw error })
                        self.client.stop()
                    }
                }
            } catch {
                result({ throw error })
                self.client.stop()
            }
        }
    }

    public func delete(uri: String, headers: [String: String] = [:], body: [Int8] = [], result: (Void throws -> ResponsePair) -> Void) {
        let request = Request(
            method: Method.DELETE,
            uri: URI(string: uri),
            headers: headers,
            body: body
        )
        send(request, result: result)
    }

    public func delete(uri: String, headers: [String: String] = [:], body: String, result: (Void throws -> ResponsePair) -> Void) {
        delete(uri, headers: headers, body: body.data, result: result)
    }

    public func get(uri: String, headers: [String: String] = [:], body: [Int8] = [], result: (Void throws -> ResponsePair) -> Void) {
        let request = Request(
            method: Method.GET,
            uri: URI(string: uri),
            headers: headers,
            body: body
        )
        send(request, result: result)
    }

    public func get(uri: String, headers: [String: String] = [:], body: String, result: (Void throws -> ResponsePair) -> Void) {
        get(uri, headers: headers, body: body.data, result: result)
    }

    public func head(uri: String, headers: [String: String] = [:], body: [Int8] = [], result: (Void throws -> ResponsePair) -> Void) {
        let request = Request(
            method: Method.HEAD,
            uri: URI(string: uri),
            headers: headers,
            body: body
        )
        send(request, result: result)
    }

    public func head(uri: String, headers: [String: String] = [:], body: String, result: (Void throws -> ResponsePair) -> Void) {
        head(uri, headers: headers, body: body.data, result: result)
    }

    public func post(uri: String, headers: [String: String] = [:], body: [Int8] = [], result: (Void throws -> ResponsePair) -> Void) {
        let request = Request(
            method: Method.POST,
            uri: URI(string: uri),
            headers: headers,
            body: body
        )
        send(request, result: result)
    }

    public func post(uri: String, headers: [String: String] = [:], body: String, result: (Void throws -> ResponsePair) -> Void) {
        post(uri, headers: headers, body: body.data, result: result)
    }

    public func put(uri: String, headers: [String: String] = [:], body: [Int8] = [], result: (Void throws -> ResponsePair) -> Void) {
        let request = Request(
            method: Method.PUT,
            uri: URI(string: uri),
            headers: headers,
            body: body
        )
        send(request, result: result)
    }

    public func put(uri: String, headers: [String: String] = [:], body: String, result: (Void throws -> ResponsePair) -> Void) {
        put(uri, headers: headers, body: body.data, result: result)
    }

    public func connect(uri: String, headers: [String: String] = [:], body: [Int8] = [], result: (Void throws -> ResponsePair) -> Void) {
        let request = Request(
            method: Method.CONNECT,
            uri: URI(string: uri),
            headers: headers,
            body: body
        )
        send(request, result: result)
    }

    public func connect(uri: String, headers: [String: String] = [:], body: String, result: (Void throws -> ResponsePair) -> Void) {
        connect(uri, headers: headers, body: body.data, result: result)
    }

    public func options(uri: String, headers: [String: String] = [:], body: [Int8] = [], result: (Void throws -> ResponsePair) -> Void) {
        let request = Request(
            method: Method.OPTIONS,
            uri: URI(string: uri),
            headers: headers,
            body: body
        )
        send(request, result: result)
    }

    public func options(uri: String, headers: [String: String] = [:], body: String, result: (Void throws -> ResponsePair) -> Void) {
        options(uri, headers: headers, body: body.data, result: result)
    }

    public func trace(uri: String, headers: [String: String] = [:], body: [Int8] = [], result: (Void throws -> ResponsePair) -> Void) {
        let request = Request(
            method: Method.TRACE,
            uri: URI(string: uri),
            headers: headers,
            body: body
        )
        send(request, result: result)
    }

    public func trace(uri: String, headers: [String: String] = [:], body: String, result: (Void throws -> ResponsePair) -> Void) {
        trace(uri, headers: headers, body: body.data, result: result)
    }
}
