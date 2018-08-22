//
//  ImagePickerAlertSettings.swift
//  ImagePicking
//
//  Created by Sergey on 31.05.2018.
//  Copyright © 2018 Sergey Kostyan. All rights reserved.
//

import Foundation

public protocol ImagePickerAlertSettingsProviding {
    
    var prefferedStyle: UIAlertControllerStyle { get }
    var alertTitle: String? { get }
    var alertMessage: String? { get }
    var cameraActionTitle: String { get }
    var libraryActionTitle: String { get }
    var cancelActionTitle: String { get }
    
}

open class ImagePickerAlertSettings: ImagePickerAlertSettingsProviding {
    
    public let prefferedStyle: UIAlertControllerStyle
    public let alertTitle: String?
    public let alertMessage: String?
    public let cameraActionTitle: String
    public let libraryActionTitle: String
    public let cancelActionTitle: String
    
    public required init(prefferedStyle: UIAlertControllerStyle, alertTitle: String? = nil, alertMessage: String? = nil,
                         cameraActionTitle: String, libraryActionTitle: String, cancelActionTitle: String) {
        self.prefferedStyle = prefferedStyle
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.cameraActionTitle = cameraActionTitle
        self.libraryActionTitle = libraryActionTitle
        self.cancelActionTitle = cancelActionTitle
    }
    
}
