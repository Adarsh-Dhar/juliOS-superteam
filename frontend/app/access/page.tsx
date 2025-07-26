'use client';

import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useWallet } from '@solana/wallet-adapter-react';
import { useConnection } from '@solana/wallet-adapter-react';
import { Keypair, PublicKey } from '@solana/web3.js';
import { useContract } from '@/hooks/useContract';
import { WalletMultiButton } from '@solana/wallet-adapter-react-ui';
import { 
  Sparkles, 
  Shield, 
  Key, 
  Users, 
  Link as LinkIcon, 
  CheckCircle, 
  AlertCircle,
  Loader2,
  ArrowLeft
} from 'lucide-react';
import Link from 'next/link';

interface MintFormData {
  campaignId: string;
  name: string;
  symbol: string;
  uri: string;
  agentCount: number;
}

export default function AccessMintPage() {
  const { publicKey, connected, signTransaction } = useWallet();
  const { connection } = useConnection();
  const { mintNFT, loading, error, clearError } = useContract(connection);
  
  const [formData, setFormData] = useState<MintFormData>({
    campaignId: '',
    name: '',
    symbol: '',
    uri: '',
    agentCount: 1
  });
  
  const [mintSuccess, setMintSuccess] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleInputChange = (field: keyof MintFormData, value: string | number) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    if (error) clearError();
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!connected || !publicKey || !signTransaction) return;

    setIsSubmitting(true);
    clearError();

    try {
      const signature = await mintNFT({
        campaignId: formData.campaignId,
        name: formData.name,
        symbol: formData.symbol,
        uri: formData.uri,
        agentCount: formData.agentCount,
        payer: publicKey,
        mintAuthority: publicKey,
        signTransaction
      });

      if (signature) {
        setMintSuccess(signature);
        setFormData({
          campaignId: '',
          name: '',
          symbol: '',
          uri: '',
          agentCount: 1
        });
      }
    } catch (err) {
      console.error('Minting failed:', err);
    } finally {
      setIsSubmitting(false);
    }
  };

  const isFormValid = () => {
    return formData.campaignId && 
           formData.name && 
           formData.symbol && 
           formData.uri && 
           formData.agentCount > 0;
  };

  return (
    <div className="min-h-screen bg-[#0A0F1F] text-white relative overflow-x-hidden">
      {/* Starfield Background */}
      <div className="starfield" />
      
      {/* Navigation */}
      <motion.nav
        className="fixed top-0 left-0 right-0 z-40 px-6 py-4"
        initial={{ opacity: 0, y: -50 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 1 }}
      >
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <Link href="/" className="flex items-center space-x-2">
            <motion.div
              className="font-orbitron font-bold text-lg holographic-text"
              whileHover={{ scale: 1.05 }}
            >
              TRUSTGUARD
            </motion.div>
          </Link>
          
          <div className="flex items-center space-x-4">
            <WalletMultiButton />
          </div>
        </div>
      </motion.nav>

      {/* Main Content */}
      <div className="pt-24 pb-12 px-6">
        <div className="max-w-4xl mx-auto">
          {/* Header */}
          <motion.div
            className="text-center mb-12"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            <motion.div
              className="inline-flex items-center space-x-3 mb-6"
              whileHover={{ scale: 1.05 }}
            >
              <Sparkles className="w-8 h-8 text-purple-400" />
              <h1 className="font-orbitron text-4xl font-bold bg-gradient-to-r from-purple-400 via-blue-400 to-cyan-400 bg-clip-text text-transparent">
                Mint Access NFT
              </h1>
            </motion.div>
            <p className="font-exo2 text-lg text-gray-300 max-w-2xl mx-auto">
              Create exclusive access tokens for your campaigns. Each NFT grants special privileges 
              and serves as a digital key to your verified content ecosystem.
            </p>
          </motion.div>

          {/* Success Message */}
          <AnimatePresence>
            {mintSuccess && (
              <motion.div
                className="mb-8 p-6 bg-gradient-to-r from-green-500/20 to-emerald-500/20 border border-green-500/40 rounded-xl"
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
              >
                <div className="flex items-center space-x-3">
                  <CheckCircle className="w-6 h-6 text-green-400" />
                  <div>
                    <h3 className="font-exo2 font-semibold text-green-400">NFT Minted Successfully!</h3>
                    <p className="text-sm text-gray-300 mt-1">
                      Transaction: {mintSuccess.slice(0, 8)}...{mintSuccess.slice(-8)}
                    </p>
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Error Message */}
          <AnimatePresence>
            {error && (
              <motion.div
                className="mb-8 p-6 bg-gradient-to-r from-red-500/20 to-pink-500/20 border border-red-500/40 rounded-xl"
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
              >
                <div className="flex items-center space-x-3">
                  <AlertCircle className="w-6 h-6 text-red-400" />
                  <div>
                    <h3 className="font-exo2 font-semibold text-red-400">Minting Failed</h3>
                    <p className="text-sm text-gray-300 mt-1">{error}</p>
                  </div>
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          {/* Form Card */}
          <motion.div
            className="bg-gradient-to-br from-gray-900/50 to-gray-800/50 backdrop-blur-xl border border-gray-700/50 rounded-2xl p-8"
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              {/* Form */}
              <div>
                <h2 className="font-orbitron text-2xl font-semibold mb-6 text-white">
                  Campaign Details
                </h2>
                
                <form onSubmit={handleSubmit} className="space-y-6">
                  {/* Campaign ID */}
                  <div>
                    <label className="block font-exo2 text-sm font-medium text-gray-300 mb-2">
                      Campaign ID
                    </label>
                    <input
                      type="text"
                      value={formData.campaignId}
                      onChange={(e) => handleInputChange('campaignId', e.target.value)}
                      className="w-full px-4 py-3 bg-gray-800/50 border border-gray-600/50 rounded-lg font-exo2 text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-purple-500/50 focus:border-transparent transition-all duration-200"
                      placeholder="Enter unique campaign identifier"
                      required
                    />
                  </div>

                  {/* Name */}
                  <div>
                    <label className="block font-exo2 text-sm font-medium text-gray-300 mb-2">
                      NFT Name
                    </label>
                    <input
                      type="text"
                      value={formData.name}
                      onChange={(e) => handleInputChange('name', e.target.value)}
                      className="w-full px-4 py-3 bg-gray-800/50 border border-gray-600/50 rounded-lg font-exo2 text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-purple-500/50 focus:border-transparent transition-all duration-200"
                      placeholder="e.g., TrustGuard Access Pass"
                      required
                    />
                  </div>

                  {/* Symbol */}
                  <div>
                    <label className="block font-exo2 text-sm font-medium text-gray-300 mb-2">
                      NFT Symbol
                    </label>
                    <input
                      type="text"
                      value={formData.symbol}
                      onChange={(e) => handleInputChange('symbol', e.target.value)}
                      className="w-full px-4 py-3 bg-gray-800/50 border border-gray-600/50 rounded-lg font-exo2 text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-purple-500/50 focus:border-transparent transition-all duration-200"
                      placeholder="e.g., TGAP"
                      required
                    />
                  </div>

                  {/* URI */}
                  <div>
                    <label className="block font-exo2 text-sm font-medium text-gray-300 mb-2">
                      Metadata URI
                    </label>
                    <input
                      type="url"
                      value={formData.uri}
                      onChange={(e) => handleInputChange('uri', e.target.value)}
                      className="w-full px-4 py-3 bg-gray-800/50 border border-gray-600/50 rounded-lg font-exo2 text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-purple-500/50 focus:border-transparent transition-all duration-200"
                      placeholder="https://ipfs.io/ipfs/..."
                      required
                    />
                  </div>

                  {/* Agent Count */}
                  <div>
                    <label className="block font-exo2 text-sm font-medium text-gray-300 mb-2">
                      Agent Count
                    </label>
                    <input
                      type="number"
                      min="1"
                      value={formData.agentCount}
                      onChange={(e) => handleInputChange('agentCount', parseInt(e.target.value))}
                      className="w-full px-4 py-3 bg-gray-800/50 border border-gray-600/50 rounded-lg font-exo2 text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-purple-500/50 focus:border-transparent transition-all duration-200"
                      placeholder="Number of agents in campaign"
                      required
                    />
                  </div>

                  {/* Submit Button */}
                  <motion.button
                    type="submit"
                    disabled={!connected || !isFormValid() || isSubmitting}
                    className="w-full py-4 px-6 bg-gradient-to-r from-purple-500 to-blue-500 hover:from-blue-500 hover:to-purple-500 disabled:from-gray-600 disabled:to-gray-600 disabled:cursor-not-allowed rounded-lg font-exo2 font-semibold text-white shadow-lg border border-purple-500/40 hover:shadow-purple-500/25 transition-all duration-300 flex items-center justify-center space-x-2"
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                  >
                    {isSubmitting ? (
                      <>
                        <Loader2 className="w-5 h-5 animate-spin" />
                        <span>Minting NFT...</span>
                      </>
                    ) : (
                      <>
                        <Sparkles className="w-5 h-5" />
                        <span>Mint Access NFT</span>
                      </>
                    )}
                  </motion.button>
                </form>
              </div>

              {/* Info Panel */}
              <div className="space-y-6">
                <div>
                  <h3 className="font-orbitron text-xl font-semibold mb-4 text-white">
                    What You&apos;re Creating
                  </h3>
                  
                  <div className="space-y-4">
                    <div className="flex items-start space-x-3 p-4 bg-gray-800/30 rounded-lg border border-gray-700/50">
                      <Shield className="w-5 h-5 text-purple-400 mt-0.5" />
                      <div>
                        <h4 className="font-exo2 font-semibold text-white">Access Control</h4>
                        <p className="text-sm text-gray-300 mt-1">
                          This NFT serves as a digital key for accessing your campaign&apos;s verified content.
                        </p>
                      </div>
                    </div>

                    <div className="flex items-start space-x-3 p-4 bg-gray-800/30 rounded-lg border border-gray-700/50">
                      <Key className="w-5 h-5 text-blue-400 mt-0.5" />
                      <div>
                        <h4 className="font-exo2 font-semibold text-white">Unique Identifier</h4>
                        <p className="text-sm text-gray-300 mt-1">
                          Each campaign gets a unique NFT that can be verified on-chain for authenticity.
                        </p>
                      </div>
                    </div>

                    <div className="flex items-start space-x-3 p-4 bg-gray-800/30 rounded-lg border border-gray-700/50">
                      <Users className="w-5 h-5 text-green-400 mt-0.5" />
                      <div>
                        <h4 className="font-exo2 font-semibold text-white">Agent Management</h4>
                        <p className="text-sm text-gray-300 mt-1">
                          Track and manage the number of AI agents participating in your campaign.
                        </p>
                      </div>
                    </div>

                    <div className="flex items-start space-x-3 p-4 bg-gray-800/30 rounded-lg border border-gray-700/50">
                      <LinkIcon className="w-5 h-5 text-cyan-400 mt-0.5" />
                      <div>
                        <h4 className="font-exo2 font-semibold text-white">Metadata Storage</h4>
                        <p className="text-sm text-gray-300 mt-1">
                          Store campaign metadata on IPFS for decentralized and permanent access.
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Requirements */}
                <div className="p-4 bg-gradient-to-r from-purple-500/10 to-blue-500/10 border border-purple-500/20 rounded-lg">
                  <h4 className="font-exo2 font-semibold text-white mb-2">Requirements</h4>
                  <ul className="text-sm text-gray-300 space-y-1">
                    <li>• Connected Solana wallet</li>
                    <li>• Sufficient SOL for transaction fees</li>
                    <li>• Valid metadata URI (IPFS recommended)</li>
                    <li>• Unique campaign identifier</li>
                  </ul>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Back to Dashboard */}
          <motion.div
            className="text-center mt-8"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.8, delay: 0.4 }}
          >
            <Link href="/">
              <motion.button
                className="inline-flex items-center space-x-2 text-gray-400 hover:text-white transition-colors duration-200"
                whileHover={{ scale: 1.05 }}
              >
                <ArrowLeft className="w-4 h-4" />
                <span className="font-exo2">Back to Dashboard</span>
              </motion.button>
            </Link>
          </motion.div>
        </div>
      </div>
    </div>
  );
}
