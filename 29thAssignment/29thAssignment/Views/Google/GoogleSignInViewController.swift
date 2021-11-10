//
//  GoogleSignInViewController.swift
//  29thAssignment
//
//  Created by taehy.k on 2021/10/03.
//

import UIKit

import FirebaseAuth
import SnapKit

class GoogleSignInViewController: UIViewController {
    
    // MARK: - Properties
    private var signInView = CommonAuthView(.SignIn)
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAttribute()
        setupLayout()
        setupAction()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        signInView.clearTextFields()
    }
    
    // MARK: - Setup Functions
    private func setupAttribute() {
        setupNavigationBar()
    }
    
    private func setupLayout() {
        view.addSubview(signInView)
        signInView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupAction() {
        signInView.signUpButton.press { [weak self] in
            self?.goToSignUpVC()
        }
        
        signInView.confirmButton.press { [weak self] in
            self?.signInAction()
        }
    }
    
    // ✨ 실제 로그인하는 부분 (4주차 과제)
    private func signInAction() {
        guard let userInfo = signInView.userInfo() else { return }
        APIClient.request(CommonResponse<AuthResponse>.self,
                          router: .signIn(signInRequest: userInfo)) { [weak self] models in
            print(models)
        } failure: { error in
            print(error)
        }

    }
    
    private func signInActionWithFirebase() {
        guard let userInfo = signInView.userInfo() else { return }
        
        FirebaseAuth.Auth.auth().signIn(withEmail: userInfo.email, password: userInfo.password) { [weak self] (user, error) in
            guard let self = self else { return }
            
            if let error = error, user == nil {
                let alert = UIAlertController(title: "로그인 실패", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true, completion: nil)
            } else {
                self.goToConfirmVC()
            }
        }
    }
    
    private func goToConfirmVC() {
        let confirmVC = GoogleConfirmViewController()
        confirmVC.name = self.signInView.name()
        confirmVC.modalPresentationStyle = .fullScreen
        show(confirmVC, sender: self)
    }
    
    private func goToSignUpVC() {
        let signUpVC = GoogleSignUpViewController()
        show(signUpVC, sender: self)
    }
}
