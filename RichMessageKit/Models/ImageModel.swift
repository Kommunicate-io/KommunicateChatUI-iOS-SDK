//
//  ImageModel.swift
//  RichMessageKit
//
//  Created by Shivam Pokhriyal on 06/02/19.
//

import Foundation

public protocol ImageModel {

    var caption: String? { get }

    var url: String { get }

    var isMyMessage: Bool { get }
    
}
