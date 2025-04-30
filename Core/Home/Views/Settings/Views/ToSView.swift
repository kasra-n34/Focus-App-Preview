//
//  ToSView.swift
//  Focus
//
//  Created by Kasra on 2024-07-12.
//

import SwiftUI

struct ToSView: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                
                ZStack {
                    
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack(alignment: .center, spacing: 20) {
                        Text("Terms of Service")
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            
                        
                        Text("Last Updated: August 4, 2024")
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        1. Introduction
                        Welcome to Focus, operated by Focus Inc. ("we", "our", "us"). By accessing or using our app, you agree to be bound by these Terms of Service ("Terms"). If you do not agree with any part of these Terms, please do not use our app.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        2. Acceptance of Terms
                        By using [App Name], you agree to comply with and be bound by these Terms. If you do not agree with these Terms, you should not use our app.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        3. Modifications to Terms
                        We reserve the right to update or modify these Terms at any time. We will notify you of any changes by updating the "Last Updated" date at the top of these Terms. Your continued use of the app after any modifications indicates your acceptance of the new Terms.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        4. User Accounts
                        To use certain features of Focus, you may need to create an account. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account or any other breach of security.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        5. User Responsibilities
                        You agree not to misuse Focus or engage in any illegal activities. Specifically, you agree not to:
                        - Use the app for any unlawful purpose or in violation of any local, provincial, national, or international law.
                        - Post or transmit any content that is infringing, libelous, defamatory, obscene, pornographic, abusive, or otherwise offensive.
                        - Access, tamper with, or use non-public areas of the app, our computer systems, or the technical delivery systems of our providers.
                        - Attempt to probe, scan, or test the vulnerability of any of our systems or networks or breach any security or authentication measures.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        6. Privacy Policy
                        Our Privacy Policy, which can be found in 'Data Usage' tab within Focus, is incorporated into these Terms by reference. Please review our Privacy Policy to understand how we collect, use, and protect your information.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        7. Intellectual Property
                        We own the intellectual property rights to Focus and its content. You may not use our intellectual property without our prior written consent. All trademarks, service marks, logos, trade names, and any other proprietary designations of Focus used herein are trademarks or registered trademarks of Focus Inc.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        8. Third-Party Services
                        Focus may integrate with third-party services. We are not responsible for the terms or actions of these third-party services. You should review the terms and conditions of any third-party services you access through our app.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        9. Termination
                        We reserve the right to terminate or suspend your account at our discretion, without notice, if you violate these Terms. Upon termination, your access to the app will be revoked, and any data associated with your account may be deleted. You may also terminate your account at any time by following the instructions within the app or contacting us directly.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        10. Limitation of Liability
                        To the maximum extent permitted by applicable law, [Your Company Name] and its affiliates, officers, directors, employees, agents, and licensors shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible losses, resulting from:
                        - Your use or inability to use the app.
                        - Any unauthorized access to or use of our servers and/or any personal information stored therein.
                        - Any interruption or cessation of transmission to or from the app.
                        - Any bugs, viruses, trojan horses, or the like that may be transmitted to or through our app by any third party.
                        - Any errors or omissions in any content or for any loss or damage incurred as a result of the use of any content posted, emailed, transmitted, or otherwise made available through the app.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        11. Governing Law
                        These Terms are governed by and construed in accordance with the laws of the Province of Ontario and the federal laws of Canada applicable therein. Any disputes arising out of or related to these Terms or the app will be subject to the exclusive jurisdiction of the courts of Ontario.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        12. Contact Information
                        If you have any questions or concerns about these Terms, please contact us at:
                        contact@focusapp.ca
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        13. Dispute Resolution
                        Any disputes arising under these Terms will be resolved through arbitration in accordance with the rules of the Arbitration Act, 1991 (Ontario), or any successor legislation. If arbitration is not required, disputes will be resolved in the courts of Ontario.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        By using Focus, you acknowledge that you have read, understood, and agree to be bound by these Terms.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        Focus Inc.
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

struct ToSView_Preview: PreviewProvider {
    static var previews: some View {
        ToSView()
    }
}
