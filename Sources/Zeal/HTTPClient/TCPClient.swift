// TCPClient.swift
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
import Venice

struct TCPClient: TCPClientType {
    let host: String
    let port: Int
    let SSL: SSLClientContextType?

    private let closeChannel = Channel<Void>()

    func connect(completion: (Void throws -> StreamType) -> Void) {
        do {
            let ip = try IP(address: self.host, port: self.port)
            let socket = try TCPClientSocket(ip: ip)

            co {
                do {
                    let socketStream = TCPStream(socket: socket)

                    if let SSL = self.SSL {
                        let SSLStream = try SSL.streamType.init(context: SSL, rawStream: socketStream)
                        completion({ SSLStream })
                    }
                    else {
                        completion({ socketStream })
                    }
                } catch {
                    completion({ throw error })
                    self.stop()
                }
            }
            closeChannel.send()
        }
        catch {
            completion({ throw error })
        }
    }

    func stop() {
        closeChannel.receive()
    }
}
