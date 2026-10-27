// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Apple Inc. and the SwiftNIO project authors

import NIOCore

@available(anyAppleOS 26, *)
public struct QUICConnectionStreamStorageReleasedFutureOption: ChannelOption {
    public typealias Value = EventLoopFuture<Void>
    public init() {}
}

@available(anyAppleOS 26, *)
final class QUICConnectionStreamStorage {
    private let promise: EventLoopPromise<Void>
    private var children = 0
    private(set) var isAcceptingChildren = true
    private var isSealed = false
    private var completed = false

    init(eventLoop: any EventLoop) {
        self.promise = eventLoop.makePromise(of: Void.self)
    }

    var futureResult: EventLoopFuture<Void> { self.promise.futureResult }

    func registerChild() -> Bool {
        self.promise.futureResult.eventLoop.preconditionInEventLoop()
        guard self.isAcceptingChildren else { return false }
        self.children += 1
        return true
    }

    func closeAdmission() {
        self.promise.futureResult.eventLoop.preconditionInEventLoop()
        self.isAcceptingChildren = false
    }

    func releaseChild() {
        self.promise.futureResult.eventLoop.preconditionInEventLoop()
        precondition(self.children > 0)
        self.children -= 1
        self.completeIfReleased()
    }

    func seal() {
        self.promise.futureResult.eventLoop.preconditionInEventLoop()
        precondition(!self.isAcceptingChildren)
        self.isSealed = true
        self.completeIfReleased()
    }

    private func completeIfReleased() {
        guard self.isSealed, self.children == 0, !self.completed else { return }
        self.completed = true
        self.promise.succeed()
    }
}
