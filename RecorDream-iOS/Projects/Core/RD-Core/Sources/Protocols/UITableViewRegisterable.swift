//
//  UITableViewRegisterable.swift
//
//  Created by Junho Lee on 2022/09/24.
//  Copyright © 2022 RecorDream. All rights reserved.
//

import UIKit

protocol UITableViewRegisterable {
    static var isFromNib: Bool { get }
    static func register(target: UITableView)
}

extension UITableViewRegisterable where Self: UITableViewCell {
    static func register(target: UITableView) {
        if self.isFromNib {
          target.register(UINib(nibName: Self.className, bundle: nil), forCellReuseIdentifier: Self.className)
        } else {
            target.register(Self.self, forCellReuseIdentifier: Self.className)
        }
    }
}

protocol UITableViewHeaderFooterRegisterable {
    static var isFromNib: Bool { get }
    static func register(target: UITableView)
}

extension UITableViewHeaderFooterRegisterable where Self: UITableViewHeaderFooterView {
    static func register(target: UITableView) {
        if self.isFromNib {
          target.register(UINib(nibName: Self.className, bundle: nil), forHeaderFooterViewReuseIdentifier: Self.className)
        } else {
          target.register(Self.self, forHeaderFooterViewReuseIdentifier: Self.className)
        }
    }
}
