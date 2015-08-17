import ReachabilitySwift


public class InternetChange
{
    private let block: (Reachability.NetworkStatus) -> Void
    
    init(block: (Reachability.NetworkStatus) -> Void)
    {
        self.block = block
    }
    
    public func run(status: Reachability.NetworkStatus)
    {
        self.block(status)
    }
}


private func -=(inout lhs: [InternetChange], rhs: InternetChange)
{
    var result: [InternetChange] = []
    for element in lhs {
        if element !== rhs {
            result.append(element)
        }
    }
    lhs = result
}


public class Internet
{
    internal static var reachability: Reachability!
    private static var blocks: [InternetChange] = []
    
    public static func start(hostName: String)
    {
        Internet.start(Reachability(hostname: hostName))
    }
    
    public static func start(reachability: Reachability)
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
    }
    
    public static func start()
    {
        Internet.start(Reachability.reachabilityForInternetConnection())
    }
    
    public static func addChangeBlock(block: InternetChange)
    {
        Internet.blocks.append(block)
    }
    
    public static func removeChangeBlock(block: InternetChange)
    {
        Internet.blocks -= block
    }
    
    public static func areYouThere() -> Bool
    {
        return Internet.reachability.currentReachabilityStatus != .NotReachable
    }
}
