import ReachabilitySwift


public class Internet
{
    public class Change
    {
        private let block: (Reachability.NetworkStatus) -> Void
        
        public init(block: (Reachability.NetworkStatus) -> Void)
        {
            self.block = block
        }
        
        public func run(status: Reachability.NetworkStatus)
        {
            self.block(status)
        }
    }
    
    internal static var reachability: Reachability!
    private static var blocks: [Change] = []
    
    public static func start(hostName: String) throws
    {
        try Internet.start(Reachability(hostname: hostName))
    }
    
    public static func start(reachability: Reachability) throws
    {
        Internet.reachability = reachability
        let statusBlock = { (reachability: Reachability) -> Void in
            let status = reachability.currentReachabilityStatus
            for block in Internet.blocks {
                block.run(status)
            }
        }
        Internet.reachability.whenReachable = statusBlock
        Internet.reachability.whenUnreachable = statusBlock
        try Internet.reachability.startNotifier()
    }
    
    public static func start() throws
    {
        try Internet.start(Reachability.reachabilityForInternetConnection())
    }
    
    public static func pause()
    {
        Internet.reachability.stopNotifier()
    }
    
    public static func addChangeBlock(block: (Reachability.NetworkStatus) -> Void) -> Internet.Change
    {
        let result = Internet.Change(block: block)
        Internet.blocks.append(result)
        return result
    }
    
    public static func removeChangeBlock(block: Internet.Change)
    {
        Internet.blocks -= block
    }
    
    public static func areYouThere() -> Bool
    {
        return Internet.reachability.currentReachabilityStatus != .NotReachable
    }
}

private func -=(inout lhs: [Internet.Change], rhs: Internet.Change)
{
    var result: [Internet.Change] = []
    for element in lhs {
        if element !== rhs {
            result.append(element)
        }
    }
    lhs = result
}
