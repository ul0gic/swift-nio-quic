/// Current admission occupancy and saturating lifetime drop decisions for one handler.
/// Drop counts include repeated attempts; sampled occupancy is not a historical maximum.
@available(anyAppleOS 26, *)
public struct QUICConnectionAdmissionSnapshot: Sendable {
    public let activeConnections: Int
    public let pendingHandshakes: Int
    public let droppedForConnectionLimit: UInt64
    public let droppedForHandshakeLimit: UInt64
    public let droppedForRateLimit: UInt64
}
