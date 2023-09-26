//
//  Castled
//
//  Created by Antony Joe Mathew on 11/04/2023.
//

import Foundation

func castledLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if CastledConfigs.sharedInstance.disableLog == false {
#if DEBUG
        items.forEach {
            Swift.print("\($0)", separator: separator, terminator: terminator)
        }
#endif
    }
}
