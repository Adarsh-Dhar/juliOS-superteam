'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { useState, useEffect } from 'react';
import { Twitter, Instagram, Facebook, TrendingUp, Users, Clock, CheckCircle, AlertTriangle } from 'lucide-react';

interface ContentItem {
  id: number;
  platform: 'twitter' | 'instagram' | 'facebook';
  content: string;
  engagement: number;
  timestamp: string;
  status: 'pending' | 'authentic' | 'suspicious';
  confidence: number;
}

const mockContent: ContentItem[] = [
  {
    id: 1,
    platform: 'twitter',
    content: 'Breaking: Major tech announcement at CES 2024...',
    engagement: 15420,
    timestamp: '2m ago',
    status: 'pending',
    confidence: 0
  },
  {
    id: 2,
    platform: 'instagram',
    content: 'Influencer promoting crypto investment...',
    engagement: 8930,
    timestamp: '5m ago',
    status: 'suspicious',
    confidence: 85
  },
  {
    id: 3,
    platform: 'facebook',
    content: 'News article about climate change...',
    engagement: 23150,
    timestamp: '8m ago',
    status: 'authentic',
    confidence: 92
  },
];

export default function VerificationHub() {
  const [contentItems, setContentItems] = useState<ContentItem[]>(mockContent);
  const [selectedItem, setSelectedItem] = useState<ContentItem | null>(null);

  const getPlatformIcon = (platform: string) => {
    switch (platform) {
      case 'twitter': return <Twitter className="w-5 h-5 text-blue-400" />;
      case 'instagram': return <Instagram className="w-5 h-5 text-pink-400" />;
      case 'facebook': return <Facebook className="w-5 h-5 text-blue-600" />;
      default: return null;
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'authentic': return 'bg-green-500/20 border-green-500/50 text-green-400';
      case 'suspicious': return 'bg-red-500/20 border-red-500/50 text-red-400';
      case 'pending': return 'bg-yellow-500/20 border-yellow-500/50 text-yellow-400';
      default: return 'bg-gray-500/20 border-gray-500/50 text-gray-400';
    }
  };

  const handleVote = (itemId: number, vote: 'authentic' | 'fake') => {
    setContentItems(prev => prev.map(item => 
      item.id === itemId 
        ? { ...item, status: vote === 'authentic' ? 'authentic' : 'suspicious' }
        : item
    ));
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
            Content Verification Hub
          </h2>
          <p className="text-xl text-gray-400 font-exo2">
            Real-time AI analysis of social media content
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Real-time Crawl Feed */}
          <div className="lg:col-span-1">
            <motion.div
              className="glassmorphism rounded-2xl p-6 h-[600px] overflow-hidden"
              initial={{ opacity: 0, x: -50 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
            >
              <h3 className="text-xl font-orbitron font-semibold mb-6 text-center">
                Live Feed
              </h3>
              
              <div className="space-y-4 overflow-y-auto h-[500px] custom-scrollbar">
                <AnimatePresence>
                  {contentItems.map((item, index) => (
                    <motion.div
                      key={item.id}
                      className="glassmorphism rounded-xl p-4 cursor-pointer hover:scale-105 transition-transform"
                      initial={{ opacity: 0, y: 50 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0, y: -50 }}
                      transition={{ delay: index * 0.1 }}
                      onClick={() => setSelectedItem(item)}
                      whileHover={{ 
                        rotateY: 5,
                        rotateX: 5,
                        scale: 1.02
                      }}
                    >
                      <div className="flex items-center justify-between mb-3">
                        <div className="flex items-center space-x-2">
                          {getPlatformIcon(item.platform)}
                          <span className="text-sm font-exo2 text-gray-400">{item.timestamp}</span>
                        </div>
                        <div className={`px-2 py-1 rounded-full text-xs border ${getStatusColor(item.status)}`}>
                          {item.status}
                        </div>
                      </div>
                      
                      <p className="text-sm text-gray-300 mb-3 line-clamp-2">
                        {item.content}
                      </p>
                      
                      <div className="flex items-center space-x-4 text-xs text-gray-400">
                        <div className="flex items-center space-x-1">
                          <Users className="w-3 h-3" />
                          <motion.span
                            key={item.engagement}
                            initial={{ scale: 0.8 }}
                            animate={{ scale: 1 }}
                          >
                            {item.engagement.toLocaleString()}
                          </motion.span>
                        </div>
                        <div className="flex items-center space-x-1">
                          <TrendingUp className="w-3 h-3" />
                          <span>High</span>
                        </div>
                      </div>
                    </motion.div>
                  ))}
                </AnimatePresence>
              </div>
            </motion.div>
          </div>

          {/* Verification Theater */}
          <div className="lg:col-span-2">
            <motion.div
              className="glassmorphism rounded-2xl p-6 h-[600px]"
              initial={{ opacity: 0, x: 50 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.4 }}
            >
              <h3 className="text-xl font-orbitron font-semibold mb-6 text-center">
                Verification Theater
              </h3>

              {selectedItem ? (
                <motion.div
                  className="h-full flex flex-col"
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ duration: 0.5 }}
                >
                  <div className="flex-1 mb-6">
                    <div className="glassmorphism rounded-xl p-6 mb-4">
                      <div className="flex items-center justify-between mb-4">
                        <div className="flex items-center space-x-3">
                          {getPlatformIcon(selectedItem.platform)}
                          <span className="font-exo2 text-gray-300 capitalize">
                            {selectedItem.platform}
                          </span>
                        </div>
                        <span className="text-sm text-gray-400">{selectedItem.timestamp}</span>
                      </div>
                      
                      <p className="text-gray-200 mb-4">{selectedItem.content}</p>
                      
                      <div className="grid grid-cols-3 gap-4 text-sm">
                        <div className="text-center">
                          <div className="text-2xl font-bold text-blue-400">
                            {selectedItem.engagement.toLocaleString()}
                          </div>
                          <div className="text-gray-400">Engagement</div>
                        </div>
                        <div className="text-center">
                          <div className="text-2xl font-bold text-green-400">
                            {selectedItem.confidence}%
                          </div>
                          <div className="text-gray-400">AI Confidence</div>
                        </div>
                        <div className="text-center">
                          <div className="text-2xl font-bold text-purple-400">
                            {Math.floor(Math.random() * 100)}
                          </div>
                          <div className="text-gray-400">Validators</div>
                        </div>
                      </div>
                    </div>

                    {/* Confidence Ring */}
                    <div className="relative w-32 h-32 mx-auto mb-6">
                      <svg className="w-full h-full transform -rotate-90">
                        <circle
                          cx="64"
                          cy="64"
                          r="56"
                          stroke="rgba(255,255,255,0.1)"
                          strokeWidth="8"
                          fill="none"
                        />
                        <motion.circle
                          cx="64"
                          cy="64"
                          r="56"
                          stroke="url(#gradient)"
                          strokeWidth="8"
                          fill="none"
                          strokeLinecap="round"
                          initial={{ strokeDasharray: 0, strokeDashoffset: 0 }}
                          animate={{
                            strokeDasharray: 2 * Math.PI * 56,
                            strokeDashoffset: 2 * Math.PI * 56 * (1 - selectedItem.confidence / 100)
                          }}
                          transition={{ duration: 1, ease: "easeOut" }}
                        />
                        <defs>
                          <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                            <stop offset="0%" stopColor="#8A2BE2" />
                            <stop offset="100%" stopColor="#4C6EF5" />
                          </linearGradient>
                        </defs>
                      </svg>
                      <div className="absolute inset-0 flex items-center justify-center">
                        <span className="text-2xl font-bold">{selectedItem.confidence}%</span>
                      </div>
                    </div>
                  </div>

                  {/* Voting Buttons */}
                  <div className="flex space-x-4">
                    <motion.button
                      className="flex-1 liquid-fill bg-green-500/20 border border-green-500/50 rounded-xl p-4 text-green-400 font-exo2 font-semibold"
                      onClick={() => handleVote(selectedItem.id, 'authentic')}
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                    >
                      <CheckCircle className="w-5 h-5 mx-auto mb-2" />
                      Authentic
                    </motion.button>
                    <motion.button
                      className="flex-1 liquid-fill bg-red-500/20 border border-red-500/50 rounded-xl p-4 text-red-400 font-exo2 font-semibold"
                      onClick={() => handleVote(selectedItem.id, 'fake')}
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                    >
                      <AlertTriangle className="w-5 h-5 mx-auto mb-2" />
                      Suspicious
                    </motion.button>
                  </div>
                </motion.div>
              ) : (
                <div className="h-full flex items-center justify-center">
                  <p className="text-gray-400 font-exo2 text-lg">
                    Select content from the feed to begin verification
                  </p>
                </div>
              )}
            </motion.div>
          </div>
        </div>
      </motion.div>
    </div>
  );
}