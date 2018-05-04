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
    
    var cameraActionTitle: String? { get }
    var libraryActionTitle: String? { get }
    var cancelActionTitle: String? { get }
    var alertTitle: String? { get }
    var alertMessage: String? { get }
    
    func showImagePickerAlert(presentingCompletion: (() -> Void)?, appSettingsShowingCompletion: ((Bool) -> Void)?)
    func showImagePicker(with sourceType: UIImagePickerControllerSourceType, presentingCompletion: (() -> Void)?,
                         appSettingsShowingCompletion: ((Bool) -> Void)?)
}

extension ImagePicking where Self: NSObject {
    
    public func showImagePickerAlert(presentingCompletion: (() -> Void)? = nil, appSettingsShowingCompletion: ((Bool) -> Void)? = nil) {
        let cameraActionConfig = AlertActionConfig(title: cameraActionTitle, style: .default) { [weak self] (_) in
            self?.checkCameraPermissions(presentingCompletion: presentingCompletion,
                                         appSettingsShowingCompletion: appSettingsShowingCompletion)
        }
        let libraryActionConfig = AlertActionConfig(title: libraryActionTitle, style: .default) { [weak self] (_) in
            self?.checkCameraRollPermissions(presentingCompletion: presentingCompletion,
                                             appSettingsShowingCompletion: appSettingsShowingCompletion)
        }
        let cancelActionConfig = AlertActionConfig(title: cancelActionTitle, style: .cancel)
        imagePickingInterface?.showAlertController(with: alertTitle, message: alertMessage,
                                                   actionsConfiguration: [cameraActionConfig, libraryActionConfig, cancelActionConfig],
                                                   preferredStyle: .actionSheet,
                                                   completion: presentingCompletion)
    }

    public func showImagePicker(with sourceType: UIImagePickerControllerSourceType, presentingCompletion: (() -> Void)? = nil,
                                appSettingsShowingCompletion: ((Bool) -> Void)? = nil) {
        switch sourceType {
        case .camera:
            checkCameraPermissions(presentingCompletion: presentingCompletion, appSettingsShowingCompletion: appSettingsShowingCompletion)
        case .photoLibrary, .savedPhotosAlbum:
            checkCameraRollPermissions(presentingCompletion: presentingCompletion, appSettingsShowingCompletion: appSettingsShowingCompletion)
        }
    }
    
    // MARK: - Private -
    
    private var appSettingsShowingInterface: AppSettingsShowingInterface? {
        return imagePickingInterface
    }

    private func showImagePicker(with sourceType: UIImagePickerControllerSourceType, completion: (() -> Void)?) {
        imagePickingInterface?.showImagePicker(with: sourceType, completion: completion)
    }

    private func checkCameraPermissions(presentingCompletion: (() -> Void)?, appSettingsShowingCompletion: ((Bool) -> Void)?) {
        guard let cameraPermissions = cameraPermissions else { return }
        let state: AVAuthorizationStatus = cameraPermissions.permissionsState()
        if state == .notDetermined {
            cameraPermissions.requestPermissions(handler: { [weak self] (_) in
                self?.checkCameraPermissions(presentingCompletion: presentingCompletion, appSettingsShowingCompletion: appSettingsShowingCompletion)
            })
        }
        if state == .authorized {
            showImagePicker(with: .camera, completion: presentingCompletion)
        }
        if state == .denied {
            showAppSettingsAlert(alertPresentingCompletion: presentingCompletion, appSettingsShowingCompletion: appSettingsShowingCompletion)
        }
    }

    private func checkCameraRollPermissions(presentingCompletion: (() -> Void)?, appSettingsShowingCompletion: ((Bool) -> Void)?) {
        guard let photoLibraryPermissions = photoLibraryPermissions else { return }
        let state: PHAuthorizationStatus = photoLibraryPermissions.permissionsState()
        if state == .notDetermined {
            photoLibraryPermissions.requestPermissions(handler: { [weak self] (_) in
                self?.checkCameraRollPermissions(presentingCompletion: presentingCompletion,
                                                 appSettingsShowingCompletion: appSettingsShowingCompletion)
            })
        }
        if state == .authorized {
            showImagePicker(with: .photoLibrary, completion: presentingCompletion)
        }
        if state == .denied {
            showAppSettingsAlert(alertPresentingCompletion: presentingCompletion, appSettingsShowingCompletion: appSettingsShowingCompletion)
        }
    }
    
}

// Extend your Output protocol with this protocol

public protocol ImagePickingOutput {

    func viewTriggeredCallImagePickerEvent()
    func viewTriggedImageSelectionEvent(with info: [String : Any])
    
}

