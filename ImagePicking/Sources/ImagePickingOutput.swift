//
//  ImagePickingOutput.swift
//  Yada
//
//  Created by Sergey on 07.03.2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import SKCameraPermissions
import SKPhotosPermissions
import AlertActionBuilder
import SKAlertControllerShowing
import SKAppSettingsShowing

// Extend your Presenter with this protocol
public protocol ImagePicking: AppSettingsShowing {
    
    var cameraPermissions: CameraPermissions? { get }
    var photoLibraryPermissions: PhotoLibraryPermissions? { get }
    
    var imagePickingInterface: ImagePickingInterface? { get }
    
    func showImagePickerAlert(imagePickerAlertSettings: ImagePickerAlertSettingsProviding, presentingCompletion: (() -> Void)?,
                              popoveConfigurationHandler: PopoveConfigurationHandler?,
                              actionCompletion: @escaping ((UIImagePickerController.SourceType) -> Void))
    func checkCameraPermissions(with stringsProvider: AppSettingsAlertStringsProviding, presentingCompletion: (() -> Void)?,
                                appSettingsShowingCompletion: ((Bool) -> Void)?, authorizedCompletion: @escaping (() -> Void))
    func checkCameraRollPermissions(with stringsProvider: AppSettingsAlertStringsProviding, presentingCompletion: (() -> Void)?,
                                    appSettingsShowingCompletion: ((Bool) -> Void)?, authorizedCompletion: @escaping (() -> Void))
    func showImagePicker(with sourceType: UIImagePickerController.SourceType, imagePickerProvider: ImagePickerProviding,
                         presentationCompletion: (() -> Void)?)
}

public extension ImagePicking where Self: NSObject {
    
    var appSettingsShowingInterface: AppSettingsShowingInterface? {
        return imagePickingInterface
    }
    
    func showImagePickerAlert(imagePickerAlertSettings: ImagePickerAlertSettingsProviding, presentingCompletion: (() -> Void)? = nil,
                              popoveConfigurationHandler: PopoveConfigurationHandler? = nil,
                              actionCompletion: @escaping ((UIImagePickerController.SourceType) -> Void)) {
        let cameraActionConfig = AlertActionConfig(title: imagePickerAlertSettings.cameraActionTitle, style: .default) { (_) in
            actionCompletion(.camera)
        }
        let libraryActionConfig = AlertActionConfig(title: imagePickerAlertSettings.libraryActionTitle, style: .default) { (_) in
            actionCompletion(.photoLibrary)
        }
        let cancelActionConfig = AlertActionConfig(title: imagePickerAlertSettings.cancelActionTitle, style: .cancel)
        imagePickingInterface?.showAlertController(with: imagePickerAlertSettings.alertTitle, message: imagePickerAlertSettings.alertMessage,
                                                   actionsConfiguration: [cameraActionConfig, libraryActionConfig, cancelActionConfig],
                                                   preferredStyle: imagePickerAlertSettings.prefferedStyle,
                                                   completion: presentingCompletion, popoveConfigurationHandler: popoveConfigurationHandler)

    }
    
    func checkCameraPermissions(with stringsProvider: AppSettingsAlertStringsProviding, presentingCompletion: (() -> Void)? = nil,
                                appSettingsShowingCompletion: ((Bool) -> Void)? = nil, authorizedCompletion: @escaping (() -> Void)) {
        guard let cameraPermissions = cameraPermissions else { return }
        let state: AVAuthorizationStatus = cameraPermissions.permissionsState()
        if state == .notDetermined {
            cameraPermissions.requestPermissions(handler: { [weak self] (_) in
                self?.checkCameraPermissions(with: stringsProvider, presentingCompletion: presentingCompletion,
                                             appSettingsShowingCompletion: appSettingsShowingCompletion, authorizedCompletion: authorizedCompletion)
            })
        }
        if state == .authorized {
            authorizedCompletion()
        }
        if state == .denied {
            showAppSettingsAlert(with: stringsProvider, alertPresentingCompletion: presentingCompletion,
                                 appSettingsShowingCompletion: appSettingsShowingCompletion)
        }
    }
    
    func checkCameraRollPermissions(with stringsProvider: AppSettingsAlertStringsProviding, presentingCompletion: (() -> Void)? = nil,
                                    appSettingsShowingCompletion: ((Bool) -> Void)? = nil, authorizedCompletion: @escaping (() -> Void)) {
        guard let photoLibraryPermissions = photoLibraryPermissions else { return }
        let state: PHAuthorizationStatus = photoLibraryPermissions.permissionsState()
        if state == .notDetermined {
            photoLibraryPermissions.requestPermissions(handler: { [weak self] (_) in
                self?.checkCameraRollPermissions(with: stringsProvider, presentingCompletion: presentingCompletion,
                                                 appSettingsShowingCompletion: appSettingsShowingCompletion,
                                                 authorizedCompletion: authorizedCompletion)
            })
        }
        if state == .authorized {
            authorizedCompletion()
        }
        if state == .denied {
            showAppSettingsAlert(with: stringsProvider, alertPresentingCompletion: presentingCompletion,
                                 appSettingsShowingCompletion: appSettingsShowingCompletion)
        }
    }

    func showImagePicker(with sourceType: UIImagePickerController.SourceType, imagePickerProvider: ImagePickerProviding = DefaultImagePickerProvider(),
                         presentationCompletion: (() -> Void)? = nil) {
        imagePickingInterface?.showImagePicker(with: sourceType, imagePickerProvider: imagePickerProvider, completion: presentationCompletion)
    }
    
}

// Extend your Output protocol with this protocol
public protocol ImagePickingOutput {

    func viewTriggeredShowImagePickerAlert()
    func viewTriggedImageSelectionEvent(with info: [UIImagePickerController.InfoKey: Any])
    
}
