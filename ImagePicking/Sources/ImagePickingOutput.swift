//
//  ImagePickingOutput.swift
//  Yada
//
//  Created by Sergey on 07.03.2018.
//  Copyright © 2018 Sergey. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import Photos
import SKCameraPermissions
import SKPhotosPermissions
import AlertActionBuilder
import SKAppSettingsShowing

// Extend your Presenter with this protocol
public protocol ImagePicking: AppSettingsShowing {
    
    var cameraPermissions: CameraPermissions? { get }
    var photoLibraryPermissions: PhotoLibraryPermissions? { get }
    
    var imagePickingInterface: ImagePickingInterface? { get }
    
    func showImagePickerAlert(imagePickerAlertSettings: ImagePickerAlertSettingsProviding, cameraAppSettingsAlert: AppSettingsAlertStringsProviding,
                              cameraRollAppSettingsAlert: AppSettingsAlertStringsProviding, presentingCompletion: (() -> Void)?,
                              appSettingsShowingCompletion: ((Bool) -> Void)?)
    func showImagePicker(with stringsProvider: AppSettingsAlertStringsProviding, sourceType: UIImagePickerControllerSourceType,
                         presentingCompletion: (() -> Void)?, appSettingsShowingCompletion: ((Bool) -> Void)?)
}

public extension ImagePicking where Self: NSObject {
    
    var appSettingsShowingInterface: AppSettingsShowingInterface? {
        return imagePickingInterface
    }
    
    func showImagePickerAlert(imagePickerAlertSettings: ImagePickerAlertSettingsProviding, cameraAppSettingsAlert: AppSettingsAlertStringsProviding,
                              cameraRollAppSettingsAlert: AppSettingsAlertStringsProviding, presentingCompletion: (() -> Void)? = nil,
                              appSettingsShowingCompletion: ((Bool) -> Void)? = nil) {
        let cameraActionConfig = AlertActionConfig(title: imagePickerAlertSettings.cameraActionTitle, style: .default) { [weak self] (_) in
            self?.checkCameraPermissions(with: cameraAppSettingsAlert, presentingCompletion: presentingCompletion,
                                         appSettingsShowingCompletion: appSettingsShowingCompletion)
        }
        let libraryActionConfig = AlertActionConfig(title: imagePickerAlertSettings.libraryActionTitle, style: .default) { [weak self] (_) in
            self?.checkCameraRollPermissions(with: cameraRollAppSettingsAlert, presentingCompletion: presentingCompletion,
                                             appSettingsShowingCompletion: appSettingsShowingCompletion)
        }
        let cancelActionConfig = AlertActionConfig(title: imagePickerAlertSettings.cancelActionTitle, style: .cancel)
        imagePickingInterface?.showAlertController(with: imagePickerAlertSettings.alertTitle, message: imagePickerAlertSettings.alertMessage,
                                                   actionsConfiguration: [cameraActionConfig, libraryActionConfig, cancelActionConfig],
                                                   preferredStyle: imagePickerAlertSettings.prefferedStyle,
                                                   completion: presentingCompletion)
    }

    func showImagePicker(with stringsProvider: AppSettingsAlertStringsProviding, sourceType: UIImagePickerControllerSourceType,
                         presentingCompletion: (() -> Void)? = nil, appSettingsShowingCompletion: ((Bool) -> Void)? = nil) {
        switch sourceType {
        case .camera:
            checkCameraPermissions(with: stringsProvider, presentingCompletion: presentingCompletion,
                                   appSettingsShowingCompletion: appSettingsShowingCompletion)
        case .photoLibrary:
            checkCameraRollPermissions(with: stringsProvider, presentingCompletion: presentingCompletion,
                                       appSettingsShowingCompletion: appSettingsShowingCompletion)
        default:
            print("\(sourceType) not implemented")
        }
    }
    
    // MARK: - Private -

    private func showImagePicker(with sourceType: UIImagePickerControllerSourceType, completion: (() -> Void)?) {
        imagePickingInterface?.showImagePicker(with: sourceType, completion: completion)
    }

    private func checkCameraPermissions(with stringsProvider: AppSettingsAlertStringsProviding, presentingCompletion: (() -> Void)?,
                                        appSettingsShowingCompletion: ((Bool) -> Void)?) {
        guard let cameraPermissions = cameraPermissions else { return }
        let state: AVAuthorizationStatus = cameraPermissions.permissionsState()
        if state == .notDetermined {
            cameraPermissions.requestPermissions(handler: { [weak self] (_) in
                self?.checkCameraPermissions(with: stringsProvider, presentingCompletion: presentingCompletion,
                                             appSettingsShowingCompletion: appSettingsShowingCompletion)
            })
        }
        if state == .authorized {
            showImagePicker(with: .camera, completion: presentingCompletion)
        }
        if state == .denied {
            showAppSettingsAlert(with: stringsProvider, alertPresentingCompletion: presentingCompletion,
                                 appSettingsShowingCompletion: appSettingsShowingCompletion)
        }
    }

    private func checkCameraRollPermissions(with stringsProvider: AppSettingsAlertStringsProviding, presentingCompletion: (() -> Void)?,
                                            appSettingsShowingCompletion: ((Bool) -> Void)?) {
        guard let photoLibraryPermissions = photoLibraryPermissions else { return }
        let state: PHAuthorizationStatus = photoLibraryPermissions.permissionsState()
        if state == .notDetermined {
            photoLibraryPermissions.requestPermissions(handler: { [weak self] (_) in
                self?.checkCameraRollPermissions(with: stringsProvider, presentingCompletion: presentingCompletion,
                                                 appSettingsShowingCompletion: appSettingsShowingCompletion)
            })
        }
        if state == .authorized {
            showImagePicker(with: .photoLibrary, completion: presentingCompletion)
        }
        if state == .denied {
            showAppSettingsAlert(with: stringsProvider, alertPresentingCompletion: presentingCompletion,
                                 appSettingsShowingCompletion: appSettingsShowingCompletion)
        }
    }
    
}

// Extend your Output protocol with this protocol
public protocol ImagePickingOutput {

    func viewTriggeredCallImagePickerEvent()
    func viewTriggedImageSelectionEvent(with info: [String: Any])
    
}

