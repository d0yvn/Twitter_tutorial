import Firebase
import UIKit

struct AuthCredentials {
    let email: String
    let password: String
    let fullname : String
    let username : String
    let profileImage : UIImage
}
struct AuthService {
    static let shared = AuthService()
    
    //Login
    func logUserIn(withEmail email:String, password:String,completion:AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
        print("Debug email is \(email),password is \(password)")
    }
    
    //Register
    func registerUser(credential: AuthCredentials, completion:@escaping(Error?,DatabaseReference)->Void){
        
        let email = credential.email
        let password = credential.password
        let fullname = credential.fullname
        let username = credential.username
        
        guard let imageData = credential.profileImage.jpegData(compressionQuality: 0.3) else { return }
        
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_PROFILE_IMAGES.child(filename)
        
        //storage에 이미지 정보 저장
        storageRef.putData(imageData, metadata: nil) { (meta,error) in
            //storage에 저장된 imageURL 조회
            storageRef.downloadURL { url, error in
                
                guard let profileImageURL = url?.absoluteString else { return }
                
                // 유저 생성
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("Debug error : \(error.localizedDescription)")
                        return
                    }
                    
                    guard let uid = result?.user.uid else { return }
                    
                    let values = ["email": email,
                                  "username" : username,
                                  "fullname" : fullname,
                                  "profileImageUrl" : profileImageURL]
                    
                    // email,username,fullname,profileImageUrl을 User database에 저장
                    REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
                    
                }
            }
        }
    }
}
