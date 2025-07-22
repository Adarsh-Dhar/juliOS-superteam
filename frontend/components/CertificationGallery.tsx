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

const mockNFTs: NFTCard[] = [
  {
    id: 1,
    title: "Climate Report Verification",
    platform: "Twitter",
    trustScore: 94,
    verifiedAt: "2024-01-15",
    imageUrl: "https://images.pexels.com/photos/1108572/pexels-photo-1108572.jpeg?auto=compress&cs=tinysrgb&w=400",
    description: "Peer-reviewed climate data report verified by scientific community",
    metadata: {
      tokenId: "0x1a2b3c4d",
      blockchain: "Ethereum",
      ipfsHash: "QmX7Y8Z9...",
      validators: 12
    }
  },
  {
    id: 2,
    title: "Election News Certification",
    platform: "Facebook",
    trustScore: 89,
    verifiedAt: "2024-01-14",
    imageUrl: "https://images.pexels.com/photos/6963944/pexels-photo-6963944.jpeg?auto=compress&cs=tinysrgb&w=400",
    description: "Election coverage verified by multiple news organizations",
    metadata: {
      tokenId: "0x5e6f7g8h",
      blockchain: "Polygon",
      ipfsHash: "QmA4B5C6...",
      validators: 8
    }
  },
  {
    id: 3,
    title: "Medical Research Validation",
    platform: "LinkedIn",
    trustScore: 97,
    verifiedAt: "2024-01-13",
    imageUrl: "https://images.pexels.com/photos/3825456/pexels-photo-3825456.jpeg?auto=compress&cs=tinysrgb&w=400",
    description: "Medical research paper validated by peer review network",
    metadata: {
      tokenId: "0x9i0j1k2l",
      blockchain: "Ethereum",
      ipfsHash: "QmD7E8F9...",
      validators: 15
    }
  },
  {
    id: 4,
    title: "Financial Report Audit",
    platform: "Twitter",
    trustScore: 91,
    verifiedAt: "2024-01-12",
    imageUrl: "https://images.pexels.com/photos/3760263/pexels-photo-3760263.jpeg?auto=compress&cs=tinysrgb&w=400",
    description: "Corporate financial disclosure audited by blockchain validators",
    metadata: {
      tokenId: "0x3m4n5o6p",
      blockchain: "Arbitrum",
      ipfsHash: "QmG0H1I2...",
      validators: 10
    }
  },
  {
    id: 5,
    title: "Product Launch Verification",
    platform: "Instagram",
    trustScore: 88,
    verifiedAt: "2024-01-11",
    imageUrl: "https://images.pexels.com/photos/3153201/pexels-photo-3153201.jpeg?auto=compress&cs=tinysrgb&w=400",
    description: "Tech product announcement verified by industry experts",
    metadata: {
      tokenId: "0x7q8r9s0t",
      blockchain: "Polygon",
      ipfsHash: "QmJ3K4L5...",
      validators: 7
    }
  }
];

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
            {mockNFTs.map((nft, index) => (
              <motion.div
                key={nft.id}
                className="flex-none w-80 cursor-pointer"
                initial={{ opacity: 0, x: 100, rotateY: -15 }}
                whileInView={{ 
                  opacity: 1, 
                  x: 0, 
                  rotateY: hoveredId === nft.id ? 0 : -5
                }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                whileHover={{ 
                  scale: 1.05,
                  rotateY: 5,
                  z: 50
                }}
                onHoverStart={() => setHoveredId(nft.id)}
                onHoverEnd={() => setHoveredId(null)}
                onClick={() => setSelectedNFT(nft)}
                style={{
                  transformStyle: 'preserve-3d'
                }}
              >
                <div className="glassmorphism rounded-2xl overflow-hidden h-[400px] relative">
                  {/* Card Front */}
                  <motion.div
                    className="absolute inset-0 backface-hidden"
                    animate={{ rotateY: hoveredId === nft.id ? 180 : 0 }}
                    transition={{ duration: 0.6 }}
                  >
                    <div className="relative h-48 overflow-hidden">
                      <img
                        src={nft.imageUrl}
                        alt={nft.title}
                        className="w-full h-full object-cover"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                      <div className="absolute top-4 right-4">
                        <motion.div
                          className={`px-3 py-1 rounded-full text-sm font-bold bg-gradient-to-r ${getTrustScoreGradient(nft.trustScore)}`}
                          animate={{ scale: [1, 1.1, 1] }}
                          transition={{ duration: 2, repeat: Infinity }}
                        >
                          {nft.trustScore}%
                        </motion.div>
                      </div>
                    </div>

                    <div className="p-6">
                      <h3 className="text-lg font-orbitron font-semibold mb-2 line-clamp-2">
                        {nft.title}
                      </h3>
                      <p className="text-sm text-gray-400 font-exo2 mb-4 line-clamp-2">
                        {nft.description}
                      </p>
                      
                      <div className="flex items-center justify-between text-xs text-gray-500">
                        <span>{nft.platform}</span>
                        <span>{nft.verifiedAt}</span>
                      </div>

                      {/* Trust Score Rings */}
                      <div className="mt-4 relative w-16 h-16 mx-auto">
                        <svg className="w-full h-full transform -rotate-90">
                          <circle
                            cx="32"
                            cy="32"
                            r="28"
                            stroke="rgba(255,255,255,0.1)"
                            strokeWidth="3"
                            fill="none"
                          />
                          <motion.circle
                            cx="32"
                            cy="32"
                            r="28"
                            stroke={nft.trustScore >= 95 ? '#00F5A0' : nft.trustScore >= 90 ? '#4C6EF5' : '#FF9500'}
                            strokeWidth="3"
                            fill="none"
                            strokeLinecap="round"
                            initial={{ strokeDasharray: 0, strokeDashoffset: 0 }}
                            animate={{
                              strokeDasharray: 2 * Math.PI * 28,
                              strokeDashoffset: 2 * Math.PI * 28 * (1 - nft.trustScore / 100)
                            }}
                            transition={{ duration: 2, delay: index * 0.2 }}
                          />
                        </svg>
                        <div className="absolute inset-0 flex items-center justify-center">
                          <Shield className="w-6 h-6 text-white" />
                        </div>
                      </div>
                    </div>
                  </motion.div>

                  {/* Card Back */}
                  <motion.div
                    className="absolute inset-0 backface-hidden bg-gradient-to-br from-purple-900/80 to-blue-900/80 p-6"
                    style={{ transform: 'rotateY(180deg)' }}
                    animate={{ rotateY: hoveredId === nft.id ? 0 : 180 }}
                    transition={{ duration: 0.6 }}
                  >
                    <div className="h-full flex flex-col justify-center text-center space-y-4">
                      <Award className="w-12 h-12 mx-auto text-yellow-400" />
                      <h4 className="font-orbitron font-semibold">Metadata</h4>
                      
                      <div className="space-y-2 text-sm">
                        <div className="flex justify-between">
                          <span className="text-gray-400">Token ID:</span>
                          <span className="font-mono">{nft.metadata.tokenId}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-400">Blockchain:</span>
                          <span>{nft.metadata.blockchain}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-400">Validators:</span>
                          <span>{nft.metadata.validators}</span>
                        </div>
                        <div className="flex justify-between">
                          <span className="text-gray-400">IPFS:</span>
                          <span className="font-mono text-xs">{nft.metadata.ipfsHash}</span>
                        </div>
                      </div>

                      <motion.button
                        className="mt-4 px-4 py-2 bg-gradient-to-r from-purple-500 to-blue-500 rounded-lg font-exo2 text-sm"
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                      >
                        View Details
                      </motion.button>
                    </div>
                  </motion.div>
                </div>
              </motion.div>
            ))}
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