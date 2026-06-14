//
//  FirebaseServices.swift
//
//  Реализации протоколов AuthService / DataRepository / PushService на Firebase.
//  Включается флагом AppConfig.useFirebase = true.
//
//  Google-вход требует пакета GoogleSignIn-iOS. Пока он не добавлен,
//  код всё равно компилируется (#if canImport), а Google отдаёт notConfigured.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import SwiftUI
import GoogleSignIn

// MARK: - Auth

final class FirebaseAuthService: AuthService {

    func currentUser() -> SANUser? {
        guard let u = Auth.auth().currentUser else { return nil }
        return SANUser(id: u.uid, name: u.displayName ?? "Друг",
                       email: u.email, provider: .email)
    }

    func signInWithEmail(_ email: String, password: String) async throws -> SANUser {
        let r = try await Auth.auth().signIn(withEmail: email, password: password)
        return map(r.user, provider: .email)
    }

    func registerWithEmail(name: String, email: String, password: String) async throws -> SANUser {
        let r = try await Auth.auth().createUser(withEmail: email, password: password)
        let change = r.user.createProfileChangeRequest()
        change.displayName = name
        try await change.commitChanges()
        return SANUser(id: r.user.uid, name: name, email: email, provider: .email)
    }

    func signInWithGoogle() async throws -> SANUser {
        #if canImport(GoogleSignIn)
        guard let clientID = FirebaseApp.app()?.options.clientID,
              let root = await UIApplication.shared.firstKeyWindow?.rootViewController
        else { throw AuthError.notConfigured("Google") }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: root)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.invalidCredentials
        }
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString)
        let authResult = try await Auth.auth().signIn(with: credential)
        return map(authResult.user, provider: .google)
        #else
        // Пакет GoogleSignIn ещё не добавлен — см. FIREBASE_SETUP.md, шаг 2.
        throw AuthError.notConfigured("Google (нужен пакет GoogleSignIn-iOS)")
        #endif
    }

    func signInWithApple(_ c: AppleCredential) async throws -> SANUser {
        // Обмениваем Apple id-token + nonce на Firebase-credential.
        guard let token = c.idTokenString, let nonce = c.rawNonce else {
            throw AuthError.invalidCredentials
        }
        let credential = OAuthProvider.appleCredential(
            withIDToken: token, rawNonce: nonce, fullName: nil)
        let result = try await Auth.auth().signIn(with: credential)
        // Имя Apple отдаёт только при первом входе — сохраняем в профиль Firebase.
        if let name = c.name, result.user.displayName == nil {
            let change = result.user.createProfileChangeRequest()
            change.displayName = name
            try? await change.commitChanges()
        }
        return map(result.user, provider: .apple)
    }

    func continueAsGuest() async throws -> SANUser {
        let r = try await Auth.auth().signInAnonymously()
        return SANUser(id: r.user.uid, name: "Гость", email: nil, provider: .guest)
    }

    func signOut() {
        try? Auth.auth().signOut()
        #if canImport(GoogleSignIn)
        GIDSignIn.sharedInstance.signOut()
        #endif
    }

    private func map(_ u: User, provider: AuthProvider) -> SANUser {
        SANUser(id: u.uid, name: u.displayName ?? "Друг", email: u.email, provider: provider)
    }
}

// MARK: - Firestore

final class FirebaseDataRepository: DataRepository {
    private let db = Firestore.firestore()

    func fetchVenues() async throws -> [Venue] {
        let snap = try await db.collection("venues").getDocuments()
        print("🔥 venues snap: \(snap.documents.count) docs")
        return snap.documents.compactMap { doc -> Venue? in
            let v = Venue(firestore: doc.data(), id: doc.documentID)
            if v == nil { print("⚠️ venue mapping failed [\(doc.documentID)]: \(doc.data())") }
            return v
        }
    }

    func fetchDeals() async throws -> [Deal] {
        let snap = try await db.collection("deals")
            .whereField("validUntil", isGreaterThan: Timestamp(date: .now))
            .getDocuments()
        print("🔥 deals snap: \(snap.documents.count) docs")
        return snap.documents.compactMap { doc -> Deal? in
            let d = Deal(firestore: doc.data(), id: doc.documentID)
            if d == nil { print("⚠️ deal mapping failed [\(doc.documentID)]: \(doc.data())") }
            return d
        }
    }
}

// MARK: - Push (FCM)

final class FirebasePushService: NSObject, PushService {
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        if granted {
            await MainActor.run { UIApplication.shared.registerForRemoteNotifications() }
        }
        return granted
    }
    func subscribe(topic: String) { Messaging.messaging().subscribe(toTopic: topic) }
    func unsubscribe(topic: String) { Messaging.messaging().unsubscribe(fromTopic: topic) }
}

// MARK: - Маппинг Firestore → модели
// Схема документов описана в FIREBASE_SETUP.md.

private let categoryMap: [String: VenueCategory] = [
    "cafe": .cafe, "coffee": .coffee, "fastfood": .fastfood,
    "restaurant": .restaurant, "teahouse": .teahouse, "bakery": .bakery
]

private let typeMap: [String: DealType] = [
    "discount": .discount, "promo": .promo, "novelty": .novelty
]

extension Venue {
    init?(firestore d: [String: Any], id: String) {
        guard let name = d["name"] as? String,
              let categoryKey = d["category"] as? String,
              let category = categoryMap[categoryKey] ?? VenueCategory(rawValue: categoryKey)
        else { return nil }

        self.init(
            id: id,
            name: name,
            category: category,
            district: d["district"] as? String ?? "",
            address: d["address"] as? String ?? "",
            phone: d["phone"] as? String ?? "",
            emoji: d["emoji"] as? String ?? "🍽",
            gradient: [
                Color(hexString: d["gradientFrom"] as? String) ?? .sanAccent,
                Color(hexString: d["gradientTo"] as? String) ?? .orange
            ]
        )
    }
}

extension Deal {
    init?(firestore d: [String: Any], id: String) {
        guard let venueID = d["venueID"] as? String,
              let typeKey = d["type"] as? String,
              let type = typeMap[typeKey] ?? DealType(rawValue: typeKey),
              let title = d["title"] as? String
        else { return nil }

        self.init(
            id: id,
            venueID: venueID,
            type: type,
            title: title,
            details: d["details"] as? String ?? "",
            emoji: d["emoji"] as? String ?? "🔥",
            oldPrice: (d["oldPrice"] as? NSNumber)?.intValue,
            newPrice: (d["newPrice"] as? NSNumber)?.intValue,
            discountPercent: (d["discountPercent"] as? NSNumber)?.intValue,
            validUntil: (d["validUntil"] as? Timestamp)?.dateValue() ?? .now
        )
    }
}

private extension Color {
    /// Парсит "#RRGGBB" или "RRGGBB" в Color.
    init?(hexString: String?) {
        guard var s = hexString else { return nil }
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6, let v = UInt(s, radix: 16) else { return nil }
        self.init(hex: v)
    }
}

private extension UIApplication {
    var firstKeyWindow: UIWindow? {
        connectedScenes.compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }.first { $0.isKeyWindow }
    }
}
