//
//  ImagePickingInterface.swift
//  Yada
//
//  Created by Sergey on 07.03.2018.
//Copyright © 2018 Sergey. All rights reserved.
//

import UIKit
import Foundation
import SKAlertControllerShowing
import SKAppSettingsShowing

// Extend your ViewController with this protocol
public protocol ImagePickingConfigurating {
    
    var delegate: (UIImagePickerControllerDelegate&UINavigationControllerDelegate)? { get }
    var imagePickerController: UIImagePickerController { get }
    
}

public extension ImagePickingConfigurating where Self: UIViewController {
    
    var delegate: (UIImagePickerControllerDelegate&UINavigationControllerDelegate)? {
        return self as? (UIImagePickerControllerDelegate & UINavigationControllerDelegate)
    }
    
    var imagePickerController: UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = delegate
        return imagePicker
    }
    
}

// Extend your Interface protocol with this protocol
public protocol ImagePickingInterface: AppSettingsShowingInterface {


    func showImagePicker(with sourceType: UIImagePickerControllerSourceType, completion: (() -> Void)?)
    
}

public extension ImagePickingInterface where Self: UIViewController&ImagePickingConfigurating {
    
    func showImagePicker(with sourceType: UIImagePickerControllerSourceType, completion: (() -> Void)? = nil) {
        imagePickerController.sourceType = UIImagePickerController.isSourceTypeAvailable(sourceType) ? sourceType : .photoLibrary
        present(imagePickerController, animated: true, completion: completion)
    }
    
}
