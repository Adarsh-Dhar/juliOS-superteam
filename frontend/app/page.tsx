'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { useState } from 'react';
import HeroHeader from '@/components/HeroHeader';
import VerificationHub from '@/components/VerificationHub';
import SwarmVisualization from '@/components/SwarmVisualization';
import FraudAnalytics from '@/components/FraudAnalytics';
import CertificationGallery from '@/components/CertificationGallery';
import { WalletMultiButton } from "@solana/wallet-adapter-react-ui";

export default function TrustGuardDashboard() {
  const [currentSection, setCurrentSection] = useState(0);
  
  const sections = [
    { id: 'hero', component: HeroHeader, name: 'Hero' },
    { id: 'verification', component: VerificationHub, name: 'Verification' },
    { id: 'swarm', component: SwarmVisualization, name: 'Swarm Intelligence' },
    { id: 'analytics', component: FraudAnalytics, name: 'Fraud Analytics' },
    { id: 'gallery', component: CertificationGallery, name: 'Certification Gallery' },
  ];

  return (
    <div className="min-h-screen bg-[#0A0F1F] text-white relative overflow-x-hidden">
      {/* Starfield Background */}
      <div className="starfield" />
      
      {/* Navigation */}
      <motion.nav
        className="fixed top-0 left-0 right-0 z-40 px-6 py-4"
        initial={{ opacity: 0, y: -50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 1, delay: 2 }}
      >
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <motion.div
            className="font-orbitron font-bold text-lg holographic-text"
            whileHover={{ scale: 1.05 }}
          >
            TRUSTGUARD
          </motion.div>
          
          <div className="hidden md:flex items-center space-x-8">
            {sections.slice(1).map((section, index) => (
              <motion.a
                key={section.id}
                href={`#${section.id}`}
                className="font-exo2 text-sm text-gray-400 hover:text-white transition-colors cursor-pointer"
                whileHover={{ scale: 1.05 }}
                onClick={(e) => {
                  e.preventDefault();
                  document.getElementById(section.id)?.scrollIntoView({ behavior: 'smooth' });
                }}
              >
                {section.name}
              </motion.a>
            ))}
          </div>

          {/* <motion.div
            className="flex items-center space-x-2 text-sm font-exo2"
            whileHover={{ scale: 1.05 }}
          >
            <motion.button
              className="liquid-fill bg-gradient-to-r from-purple-500 to-blue-500 px-5 py-2 rounded-full font-exo2 font-semibold text-white shadow-md border border-purple-500/40 hover:from-blue-500 hover:to-purple-500 transition-colors duration-300"
              whileHover={{ scale: 1.08, boxShadow: '0 0 20px rgba(76,110,245,0.3)' }}
              whileTap={{ scale: 0.97 }}
            >
              Connect Wallet
            </motion.button>
          </motion.div> */}
          <WalletMultiButton />
        </div>
      </motion.nav>

      {/* Main Content */}
      <main>
        {/* Hero Section */}
        <section id="hero">
          <HeroHeader />
        </section>

        {/* Verification Hub */}
        <section id="verification" className="relative">
          <VerificationHub />
        </section>

        {/* Swarm Intelligence */}
        <section id="swarm" className="relative">
          <SwarmVisualization />
        </section>

        {/* Fraud Analytics */}
        <section id="analytics" className="relative">
          <FraudAnalytics />
        </section>

        {/* Certification Gallery */}
        <section id="gallery" className="relative">
          <CertificationGallery />
        </section>

        {/* Footer */}
        <footer className="relative py-20 px-4">
          <motion.div
            className="max-w-7xl mx-auto text-center"
            initial={{ opacity: 0, y: 50 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            viewport={{ once: true }}
          >
            <div className="glassmorphism rounded-2xl p-12">
              <h2 className="text-3xl font-orbitron font-bold mb-6 holographic-text">
                Join the Verification Network
              </h2>
              <p className="text-xl text-gray-400 font-exo2 mb-8 max-w-2xl mx-auto">
                Become part of the decentralized content verification ecosystem. 
                Help build a more trustworthy digital world.
              </p>
              
              <div className="flex flex-col sm:flex-row items-center justify-center space-y-4 sm:space-y-0 sm:space-x-6">
                <motion.button
                  className="liquid-fill bg-gradient-to-r from-purple-500 to-blue-500 px-8 py-4 rounded-xl font-exo2 font-semibold text-lg"
                  whileHover={{ scale: 1.05, boxShadow: "0 0 30px rgba(138, 43, 226, 0.5)" }}
                  whileTap={{ scale: 0.95 }}
                >
                  Become a Validator
                </motion.button>
                <motion.button
                  className="liquid-fill border border-gray-500/50 bg-transparent px-8 py-4 rounded-xl font-exo2 font-semibold text-lg"
                  whileHover={{ scale: 1.05, borderColor: "rgba(76, 110, 245, 0.8)" }}
                  whileTap={{ scale: 0.95 }}
                >
                  Learn More
                </motion.button>
              </div>

              <div className="mt-12 grid grid-cols-1 md:grid-cols-3 gap-8 text-sm text-gray-400">
                <div>
                  <div className="text-2xl font-bold text-blue-400 mb-2">10,000+</div>
                  <div>Content Items Verified</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-green-400 mb-2">98.7%</div>
                  <div>Accuracy Rate</div>
                </div>
                <div>
                  <div className="text-2xl font-bold text-purple-400 mb-2">24/7</div>
                  <div>Network Uptime</div>
                </div>
              </div>
            </div>

            <div className="mt-12 text-center text-gray-500 font-exo2">
              <p>© 2024 TrustGuard. Securing digital truth through decentralized verification.</p>
            </div>
          </motion.div>
        </footer>
      </main>
    </div>
  );
}