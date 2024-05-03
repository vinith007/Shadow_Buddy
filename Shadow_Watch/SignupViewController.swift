import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignupViewController: UIViewController {
    
    // UI Components
    private let firstNameTextField = UITextField()
    private let lastNameTextField = UITextField()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let ageTextField = UITextField()
    private let minHeartRateTextField = UITextField()
    private let maxHeartRateTextField = UITextField()
    private let contactNumberTextField = UITextField()
    private let signupButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI() {
        // Configure each text field
        configureTextField(textField: firstNameTextField, placeholder: "First Name")
        configureTextField(textField: lastNameTextField, placeholder: "Last Name")
        configureTextField(textField: emailTextField, placeholder: "Email")
        configureTextField(textField: passwordTextField, placeholder: "Password", isSecure: true)
        configureTextField(textField: ageTextField, placeholder: "Age")
        configureTextField(textField: minHeartRateTextField, placeholder: "Min Heart Rate")
        configureTextField(textField: maxHeartRateTextField, placeholder: "Max Heart Rate")
        configureTextField(textField: contactNumberTextField, placeholder: "Contact Number")
        
        // Configure the signup button
        signupButton.setTitle("Sign Up", for: .normal)
        signupButton.backgroundColor = UIColor.systemBlue
        signupButton.setTitleColor(.white, for: .normal)
        signupButton.layer.cornerRadius = 5
        signupButton.addTarget(self, action: #selector(handleSignup), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [
            firstNameTextField, lastNameTextField, emailTextField, passwordTextField,
            ageTextField, minHeartRateTextField, maxHeartRateTextField, contactNumberTextField, signupButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])
    }
    
    private func configureTextField(textField: UITextField, placeholder: String, isSecure: Bool = false) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = isSecure
        textField.autocapitalizationType = .none
    }
    
    @objc private func handleSignup() {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Email and password are required")
            return
        }
        
        // Firebase Auth to create a new user
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("Failed to create user: \(error.localizedDescription)")
                return
            }
            
            guard let uid = authResult?.user.uid else { return }
            
            // Save additional details in Firestore
            let userData: [String: Any] = [
                "firstName": self?.firstNameTextField.text ?? "",
                "lastName": self?.lastNameTextField.text ?? "",
                "age": self?.ageTextField.text ?? "",
                "minHeartRate": self?.minHeartRateTextField.text ?? "",
                "maxHeartRate": self?.maxHeartRateTextField.text ?? "",
                "contactNumber": self?.contactNumberTextField.text ?? ""
            ]
            
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData(userData) { error in
                if let error = error {
                    print("Failed to save user details: \(error.localizedDescription)")
                } else {
                    print("User details saved successfully")
                    // Navigate to the main app or show a success message
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
