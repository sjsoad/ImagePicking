//
//  ImagePickerProviding.swift
//  Pods
//
//  Created by Sergey Kostyan on 24.06.2018.
//
//

import UIKit

public protocol ImagePickerProviding {

    var imagePicker: UIImagePickerController { get }
    
}

open class DefaultImagePickerProvider: ImagePickerProviding {
    
    private var allowEditing: Bool
    
    public init(allowEditing: Bool = false) {
        self.allowEditing = allowEditing
    }
    
    public var imagePicker: UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = allowEditing
        return imagePicker
    }
    
}
