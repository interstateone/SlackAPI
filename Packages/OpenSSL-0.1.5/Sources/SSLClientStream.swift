// SSLClientStream.swift
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
// IMPLIED, INCLUDINbG BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Core
import COpenSSL

public final class SSLClientStream: SSLClientStreamType {
	let rawStream: StreamType
	private let context: SSLClientContext
	private let ssl: SSLSession
	private let readIO: SSLIO
	private let writeIO: SSLIO

    private var waitingData = [Int8]()

	public enum Error: ErrorType {
		case UnsupportedContext
	}

	public convenience init(context: SSLClientContextType, rawStream: StreamType) throws {
        try self.init(context: context, rawStream: rawStream, session: nil, readIO: nil, writeIO: nil)
	}

    private init(context: SSLClientContextType, rawStream: StreamType, session: SSLSession?, readIO: SSLIO?, writeIO: SSLIO?) throws {
		guard let sslContext = context as? SSLClientContext else {
			throw Error.UnsupportedContext
		}

		OpenSSL.initialize()

		self.context = sslContext
		self.rawStream = rawStream

        if let ssl = session, readIO = readIO, writeIO = writeIO {
            self.ssl = ssl
            self.readIO = readIO
            self.writeIO = writeIO   
        }
        else {
            self.ssl = SSLSession(context: sslContext)

            self.readIO = SSLIO(method: .Memory)
            self.writeIO = SSLIO(method: .Memory)
            self.ssl.setIO(readIO: self.readIO, writeIO: self.writeIO)

            self.ssl.withSSL { ssl in
                SSL_set_connect_state(ssl)
            }
        }
    }

	public func receive(completion: (Void throws -> [Int8]) -> Void) {
		self.rawStream.receive { result in
			do {
				let encryptedData = try result()
				guard encryptedData.count > 0 else { return }
				self.readIO.write(encryptedData)

                if self.ssl.state != .OK {
                    self.ssl.doHandshake()
                    self.sendEncryptedDataIfNecessary { result in
                        do {
                            try result()
                        } catch {
                            completion({ throw error })
                        }
                        guard self.ssl.state == .OK && self.waitingData.count > 0 else { return }

                        self.ssl.write(self.waitingData)
                        self.waitingData = []
                        let encryptedData = self.writeIO.read()
                        guard encryptedData.count > 0 else { return }
                        self.rawStream.send(encryptedData) { serializeResult in
                            try! serializeResult()
                        }
                    }
                }
                else {
                    var unencryptedData = self.ssl.read() 
                    while unencryptedData.count > 0 {
                        completion({ unencryptedData })
                        unencryptedData = self.ssl.read() 
                    }
                }
            } catch {
                completion({ throw error })
            }
        }
    }

    public func send(data: [Int8], completion: (Void throws -> Void) -> Void) {
        if self.ssl.state != .OK {
            self.waitingData = data
            self.ssl.doHandshake()
        } else {
            self.ssl.write(data)
        }

        sendEncryptedDataIfNecessary { result in
            do { try result() }
            catch { completion({ throw error }) }
        }
    }

	public func close() {
		self.rawStream.close()
	}

	public func pipe() -> StreamType {
        // Reuse the existing SSL session and BIOs
		return try! SSLClientStream(context: self.context, rawStream: self.rawStream.pipe(), session: ssl, readIO: readIO, writeIO: writeIO)
	}

    private func sendEncryptedDataIfNecessary(completion: (Void throws -> Void) -> Void) {
        let encryptedData = self.writeIO.read()
        guard encryptedData.count > 0 else { completion({}); return }
        self.rawStream.send(encryptedData) { serializeResult in
            do {
                try serializeResult()
                completion({})
            } catch {
                completion({ throw error })
            }
        }
    }
}
