

import Foundation
import UIKit

extension UITableView {

    func registerAndGet<T:UITableViewCell>(cell identifier:T.Type) -> T?{
        let cellID = String(describing: identifier)

        if let cell = self.dequeueReusableCell(withIdentifier: cellID) as? T {
            return cell
        } else {
            //regiser
            self.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
            return self.dequeueReusableCell(withIdentifier: cellID) as? T

        }
    }

    func register<T:UITableViewCell>(cell identifier:T.Type) {
        let cellID = String(describing: identifier)
        self.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }

    func getCell<T:UITableViewCell>(identifier:T.Type) -> T?{
        let cellID = String(describing: identifier)
        guard let cell = self.dequeueReusableCell(withIdentifier: cellID) as? T else {
            print("cell not exist")
            return nil
        }
        return cell
    }
    
}

extension UIScrollView {
    func scrollToTop(_ animated : Bool = true) {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: animated)
   }
}
