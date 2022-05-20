//
//  ThemeViewController.swift
//  Centralis
//
//  Created by Somica on 19/05/2022.
//

import UIKit

class ThemeViewController: BaseTableViewController {
    
    var themes: [[Theme]] = [
        [
            Theme(lightName: "Theme.LightTint", darkName: "Theme.DarkTint", name: "Tint"),
            Theme(lightName: "Theme.LightBackground", darkName: "Theme.DarkBackground", name: "Background"),
            Theme(lightName: "Theme.LightSecondaryBackground", darkName: "Theme.DarkSecondaryBackground", name: "Secondary Background")
        ],
        [
            Theme(lightName: "Theme.LightPresent", darkName: "Theme.DarkPresent", name: "Present"),
            Theme(lightName: "Theme.LightUnauthorised", darkName: "Theme.DarkUnauthorised", name: "Unauthorised"),
            Theme(lightName: "Theme.LightAbsent", darkName: "Theme.DarkAbsent", name: "Absent"),
            Theme(lightName: "Theme.LightLate", darkName: "Theme.DarkLate", name: "Late")
        ]
    ]
    
    struct Theme {
        var lightName: String
        var darkName: String
        var name: String
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Theme"
        tableView.register(ThemeSelectorCell.self, forCellReuseIdentifier: "Centralis.ThemeSelectorCell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        themes.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        themes[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Centralis.ThemeSelectorCell", for: indexPath) as! ThemeSelectorCell
        let theme = themes[indexPath.section][indexPath.row]
        cell.set(name: theme.name, light: theme.lightName, dark: theme.darkName, presentationController: self)
        return cell
    }

}
