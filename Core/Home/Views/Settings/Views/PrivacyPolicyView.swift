//
//  PrivacyPolicyView.swift
//  Focus
//
//  Created by Kasra on 2024-07-12.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                
                ZStack {
                    
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack(alignment: .center, spacing: 20) {
                        Text("Privacy Policy")
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Text("Last Updated: August 4, 2024")
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        1. Introduction
                        Welcome to Focus, operated by Focus Inc. ("we", "our", "us"). This Privacy Policy explains how we collect, use, disclose, and protect your information when you use our app. We comply with the Personal Information Protection and Electronic Documents Act (PIPEDA) and applicable privacy laws in Ontario.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        2. Information Collection
                        We collect various types of information, including:
                        - **Personal Information**: Information that identifies you personally, such as your name, email address, and phone number.
                        - **Usage Data**: Information about how you use our app, including your interactions with the app, and device information.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        3. Use of Information
                        We use the collected information to:
                        - Provide and maintain our app.
                        - Improve and personalize your user experience.
                        - Communicate with you, including sending updates and promotional materials.
                        - Analyze usage patterns to improve our services.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        4. Sharing of Information
                        We may share your information with third parties in the following situations:
                        - **Service Providers**: To perform services on our behalf, such as hosting and data analysis.
                        - **Legal Requirements**: If required by law or in response to valid requests by public authorities.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        5. Data Security
                        We implement various security measures to protect your data, including encryption and access controls. However, no method of transmission over the internet or electronic storage is 100% secure.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        6. User Rights
                        You have the right to:
                        - Access the personal information we hold about you.
                        - Request corrections to any inaccurate information.
                        - Withdraw your consent to our continued use of your personal information.
                        - Request the deletion of your personal information, subject to legal and contractual restrictions.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        7. Data Retention
                        We retain your personal information only for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        8. Children's Privacy
                        Our app is not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If we become aware that we have inadvertently received personal information from a child under 13, we will delete such information from our records.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        9. International Transfers
                        Your information may be transferred to and processed in countries other than Canada. We take appropriate measures to ensure that your personal information remains protected in accordance with this Privacy Policy.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        10. Changes to the Privacy Policy
                        We may update this Privacy Policy from time to time. We will notify you of any changes by updating the "Last Updated" date at the top of this Privacy Policy. We encourage you to review this Privacy Policy periodically for any changes.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        11. Contact Information
                        If you have any questions or concerns about this Privacy Policy, please contact us at:
                        Focus Inc.
                        contact@focusapp.ca
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        By using Focus, you acknowledge that you have read, understood, and agree to be bound by this Privacy Policy.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        contact@focusapp.ca
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                    }
                    .padding()
                }
            }
        }
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
