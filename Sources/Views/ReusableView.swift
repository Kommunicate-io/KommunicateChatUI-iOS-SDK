//
//  ReusableView.swift
//  KommunicateChatUI-iOS-SDK
//
//  Created by Mukesh Thawani on 04/05/17.
//

import Foundation
import UIKit

protocol ReusableView: AnyObject {
    static var reuseIdentifier: String { get }
    static var heightForView: CGFloat { get }
}

extension ReusableView where Self: UIView {
    static var reuseIdentifier: String {
        let name = NSStringFromClass(self).components(separatedBy: ".").last!
        return name
    }

    static var heightForView: CGFloat {
        return 44.0
    }
}

extension UICollectionViewCell: ReusableView {}

extension UITableViewCell: ReusableView {}
extension UITableViewHeaderFooterView: ReusableView {}

protocol NibLoadableView: AnyObject {
    static var nibName: String { get }
}

extension UIView: NibLoadableView {
    static var nibName: String {
        let name = NSStringFromClass(self).components(separatedBy: ".").last!
        return name
    }
}

extension UITableView {
    func register<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func registerNib<T: UITableViewCell>(_: T.Type, bundle: Bundle? = nil) {
        register(UINib(nibName: String(describing: T.self), bundle: bundle), forCellReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }

        return cell
    }

    func register<T: UITableViewHeaderFooterView>(_: T.Type) {
        register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
    }

    func registerNib<T: UITableViewHeaderFooterView>(_: T.Type, bundle: Bundle? = nil) {
        register(
            UINib(nibName: String(describing: T.self), bundle: bundle),
            forHeaderFooterViewReuseIdentifier: T.reuseIdentifier
        )
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
        guard let view = dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as? T
        else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return view
    }
}

extension UICollectionView {
    func register<T: UICollectionViewCell>(_: T.Type) {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }

        return cell
    }
}
