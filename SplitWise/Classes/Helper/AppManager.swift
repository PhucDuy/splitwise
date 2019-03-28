//
//  AppManager.swift
//  SplitWise
//
//  Created by Duy Phuc on 3/25/19.
//  Copyright © 2019 YOMIStudio. All rights reserved.
//

import UIKit

class AppManager: NSObject {
    // MARK: - Singleton
    static let shared = AppManager()
    var sceneCoordinator: SceneCoordinatorType?
    func migrationDatabase() {
        PersistenceService.shared.autoMigration()
    }
    func startFromGroupsScene(sceneCoordinator: SceneCoordinatorType) {
        let groupService = GroupService()
        let groupsViewModel = GroupsViewModel(groupService: groupService,
                                              coordinator: sceneCoordinator)
        let groupsScene = Scene.groups(groupsViewModel)
        self.sceneCoordinator = sceneCoordinator
        sceneCoordinator.transition(to: groupsScene, type: .root)
    }
}
