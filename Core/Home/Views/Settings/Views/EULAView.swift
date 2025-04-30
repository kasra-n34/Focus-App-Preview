//
//  EULAView.swift
//  Focus
//
//  Created by Kasra on 2024-07-12.
//

import SwiftUI

struct EULAView: View {
    var body: some View {
        
        
        
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                
                ZStack {
                    
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack(alignment: .center, spacing: 20) {
                        Text("End-User License Agreement (EULA)")
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding()
                            
                        
                        Text("Last Updated: August 4, 2024")
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        1. Introduction
                        This End-User License Agreement ("Agreement") is a legal agreement between you ("User") and Focus ("we", "our", "us") for the use of Focus App ("App").
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        2. License Grant
                        We grant you a non-exclusive, non-transferable, revocable license to use the App solely for your personal, non-commercial purposes, subject to the terms of this Agreement.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        3. Restrictions
                        You may not:
                        - Modify, copy, or create derivative works based on the App.
                        - Distribute, transfer, sublicense, lease, lend, or rent the App to any third party.
                        - Reverse engineer, decompile, or disassemble the App.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        4. Ownership
                        We retain all rights, title, and interest in and to the App, including all intellectual property rights. This Agreement does not transfer any ownership rights to you.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        5. Termination
                        We may terminate this Agreement at any time if you breach any of its terms. Upon termination, you must cease all use of the App and delete all copies in your possession.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        6. Disclaimer of Warranties
                        The App is provided "as is" without warranties of any kind. We disclaim all warranties, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, and non-infringement.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        7. Limitation of Liability
                        To the maximum extent permitted by law, we are not liable for any indirect, incidental, special, or consequential damages arising out of or related to your use of the App.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        8. Governing Law
                        This Agreement is governed by the laws of the Province of Ontario and the federal laws of Canada applicable therein.
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        9. Contact Information
                        If you have any questions or concerns about this Agreement, please contact us at:
                        contact@focusapp.ca
                        """)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("""
                        By using the App, you acknowledge that you have read, understood, and agree to be bound by this Agreement.
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

struct EULAView_Preview: PreviewProvider {
    static var previews: some View {
        EULAView()
    }
}
