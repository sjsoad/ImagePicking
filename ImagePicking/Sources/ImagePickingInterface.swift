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

// Extend your Interface protocol with this protocol
public protocol ImagePickingInterface: AppSettingsShowingInterface {

    func showImagePicker(with sourceType: UIImagePickerController.SourceType, imagePickerProvider: ImagePickerProviding, completion: (() -> Void)?)
    
}

public extension ImagePickingInterface where Self: UIViewController&UINavigationControllerDelegate&UIImagePickerControllerDelegate {
    
    func showImagePicker(with sourceType: UIImagePickerController.SourceType, imagePickerProvider: ImagePickerProviding,
                         completion: (() -> Void)? = nil) {
        let imagePicker = imagePickerProvider.imagePicker
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.isSourceTypeAvailable(sourceType) ? sourceType : .photoLibrary
        present(imagePicker, animated: true, completion: completion)
    }
    
}
