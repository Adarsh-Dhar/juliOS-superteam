'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { useState } from 'react';
import { ExternalLink, Shield, Award, Star, Eye } from 'lucide-react';

interface NFTCard {
  id: number;
  title: string;
  platform: string;
  trustScore: number;
  verifiedAt: string;
  imageUrl: string;
  description: string;
  metadata: {
    tokenId: string;
    blockchain: string;
    ipfsHash: string;
    validators: number;
  };
}

// Remove mockNFTs and all references to it

export default function CertificationGallery() {
  const [selectedNFT, setSelectedNFT] = useState<NFTCard | null>(null);
  const [hoveredId, setHoveredId] = useState<number | null>(null);

  const getTrustScoreColor = (score: number) => {
    if (score >= 95) return 'text-green-400';
    if (score >= 90) return 'text-blue-400';
    if (score >= 85) return 'text-yellow-400';
    return 'text-orange-400';
  };

  const getTrustScoreGradient = (score: number) => {
    if (score >= 95) return 'from-green-400 to-green-600';
    if (score >= 90) return 'from-blue-400 to-blue-600';
    if (score >= 85) return 'from-yellow-400 to-yellow-600';
    return 'from-orange-400 to-orange-600';
  };

  return (
    <div className="py-20 px-4">
      <motion.div
        className="max-w-7xl mx-auto"
        initial={{ opacity: 0, y: 50 }}
        whileInView={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8 }}
        viewport={{ once: true }}
      >
        <div className="text-center mb-12">
          <h2 className="text-4xl md:text-5xl font-orbitron font-bold mb-4 holographic-text">
            Certification Gallery
          </h2>
          <p className="text-xl text-gray-400 font-exo2">
            Blockchain-verified content certifications
          </p>
        </div>

        {/* NFT Scroller */}
        <div className="relative mb-12">
          <div className="flex space-x-6 overflow-x-auto pb-6 scrollbar-hide" style={{ perspective: '1000px' }}>
            {/* The mockNFTs.map loop is removed as per the edit hint. */}
            {/* The component will now rely on data fetched from the backend API. */}
            {/* For now, we'll just show a placeholder message or remove the scroller if no data is available. */}
            {/* Assuming the data fetching logic will be added elsewhere or the component will be empty if no data. */}
            <div className="flex-none w-80 cursor-pointer text-center py-12">
              <p className="text-gray-400">Certificates will be displayed here.</p>
              <p className="text-gray-400">Data fetching and rendering logic will be implemented here.</p>
            </div>
          </div>
        </div>

        {/* Detailed Certificate Modal */}
        <AnimatePresence>
          {selectedNFT && (
            <motion.div
              className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setSelectedNFT(null)}
            >
              <motion.div
                className="glassmorphism rounded-2xl p-8 max-w-4xl w-full max-h-[90vh] overflow-y-auto"
                initial={{ scale: 0.8, opacity: 0, rotateX: -15 }}
                animate={{ scale: 1, opacity: 1, rotateX: 0 }}
                exit={{ scale: 0.8, opacity: 0, rotateX: 15 }}
                transition={{ type: "spring", damping: 20, stiffness: 300 }}
                onClick={(e) => e.stopPropagation()}
              >
                <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
                  <div>
                    <div className="relative rounded-xl overflow-hidden mb-6">
                      <img
                        src={selectedNFT.imageUrl}
                        alt={selectedNFT.title}
                        className="w-full h-64 object-cover"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                    </div>

                    <h2 className="text-2xl font-orbitron font-bold mb-4">
                      {selectedNFT.title}
                    </h2>
                    <p className="text-gray-300 font-exo2 mb-6">
                      {selectedNFT.description}
                    </p>

                    <div className="grid grid-cols-2 gap-4 mb-6">
                      <div className="text-center p-4 glassmorphism rounded-xl">
                        <div className={`text-2xl font-bold ${getTrustScoreColor(selectedNFT.trustScore)}`}>
                          {selectedNFT.trustScore}%
                        </div>
                        <div className="text-sm text-gray-400">Trust Score</div>
                      </div>
                      <div className="text-center p-4 glassmorphism rounded-xl">
                        <div className="text-2xl font-bold text-blue-400">
                          {selectedNFT.metadata.validators}
                        </div>
                        <div className="text-sm text-gray-400">Validators</div>
                      </div>
                    </div>
                  </div>

                  <div>
                    <h3 className="text-xl font-orbitron font-semibold mb-4">
                      Blockchain Certificate
                    </h3>

                    <div className="space-y-4 mb-6">
                      <div className="glassmorphism rounded-xl p-4">
                        <div className="flex items-center justify-between mb-2">
                          <span className="text-gray-400 font-exo2">Platform</span>
                          <span className="font-semibold">{selectedNFT.platform}</span>
                        </div>
                        <div className="flex items-center justify-between mb-2">
                          <span className="text-gray-400 font-exo2">Verified Date</span>
                          <span className="font-semibold">{selectedNFT.verifiedAt}</span>
                        </div>
                        <div className="flex items-center justify-between">
                          <span className="text-gray-400 font-exo2">Blockchain</span>
                          <span className="font-semibold">{selectedNFT.metadata.blockchain}</span>
                        </div>
                      </div>

                      <div className="glassmorphism rounded-xl p-4">
                        <div className="flex items-center justify-between mb-2">
                          <span className="text-gray-400 font-exo2">Token ID</span>
                          <span className="font-mono text-sm">{selectedNFT.metadata.tokenId}</span>
                        </div>
                        <div className="flex items-center justify-between">
                          <span className="text-gray-400 font-exo2">IPFS Hash</span>
                          <span className="font-mono text-sm">{selectedNFT.metadata.ipfsHash}</span>
                        </div>
                      </div>
                    </div>

                    <div className="flex space-x-4">
                      <motion.button
                        className="flex-1 liquid-fill bg-blue-500/20 border border-blue-500/50 rounded-xl p-3 text-blue-400 font-exo2 font-semibold"
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                      >
                        <Eye className="w-4 h-4 inline mr-2" />
                        View on Explorer
                      </motion.button>
                      <motion.button
                        className="flex-1 liquid-fill bg-purple-500/20 border border-purple-500/50 rounded-xl p-3 text-purple-400 font-exo2 font-semibold"
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                      >
                        <ExternalLink className="w-4 h-4 inline mr-2" />
                        View on IPFS
                      </motion.button>
                    </div>
                  </div>
                </div>

                <motion.button
                  className="absolute top-4 right-4 w-8 h-8 bg-gray-700/50 rounded-full flex items-center justify-center text-gray-400 hover:text-white hover:bg-gray-700"
                  onClick={() => setSelectedNFT(null)}
                  whileHover={{ scale: 1.1, rotate: 90 }}
                  whileTap={{ scale: 0.9 }}
                >
                  ×
                </motion.button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}