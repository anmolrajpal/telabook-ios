//
//  GalleryViewController.swift
//  Telabook
//
//  Created by Anmol Rajpal on 29/05/19.
//  Copyright © 2019 Anmol Rajpal. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController {

    override func loadView() {
        super.loadView()
        setupViews()
        setupConstraints()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBarAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "GALLERY"
    }
    
    fileprivate func setupViews() {
        
    }
    fileprivate func setupConstraints() {
        
    }
}
