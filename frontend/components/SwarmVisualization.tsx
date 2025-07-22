'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { useState, useEffect } from 'react';
import { Activity, Zap, Globe, Database } from 'lucide-react';

interface Node {
  id: number;
  type: 'crawler' | 'validator';
  x: number;
  y: number;
  active: boolean;
  connections: number[];
}

interface Connection {
  from: number;
  to: number;
  active: boolean;
}

export default function SwarmVisualization() {
  const [nodes, setNodes] = useState<Node[]>([]);
  const [connections, setConnections] = useState<Connection[]>([]);
  const [stats, setStats] = useState({
    activeAgents: 13,
    verifiedToday: 2847,
    trustScore: 87,
    networkHealth: 94
  });

  useEffect(() => {
    // Initialize nodes
    const crawlerNodes: Node[] = Array.from({ length: 8 }, (_, i) => ({
      id: i,
      type: 'crawler',
      x: 150 + (i % 4) * 100,
      y: 100 + Math.floor(i / 4) * 100,
      active: Math.random() > 0.3,
      connections: []
    }));

    const validatorNodes: Node[] = Array.from({ length: 5 }, (_, i) => ({
      id: i + 8,
      type: 'validator',
      x: 200 + (i % 3) * 80,
      y: 250 + Math.floor(i / 3) * 80,
      active: Math.random() > 0.2,
      connections: []
    }));

    const allNodes = [...crawlerNodes, ...validatorNodes];

    // Create connections
    const nodeConnections: Connection[] = [];
    allNodes.forEach(node => {
      const connectionCount = Math.floor(Math.random() * 3) + 1;
      for (let i = 0; i < connectionCount; i++) {
        const targetId = Math.floor(Math.random() * allNodes.length);
        if (targetId !== node.id) {
          nodeConnections.push({
            from: node.id,
            to: targetId,
            active: Math.random() > 0.5
          });
        }
      }
    });

    setNodes(allNodes);
    setConnections(nodeConnections);

    // Animate network activity
    const interval = setInterval(() => {
      setNodes(prev => prev.map(node => ({
        ...node,
        active: Math.random() > 0.3
      })));

      setConnections(prev => prev.map(conn => ({
        ...conn,
        active: Math.random() > 0.5
      })));

      setStats(prev => ({
        ...prev,
        activeAgents: 10 + Math.floor(Math.random() * 8),
        verifiedToday: prev.verifiedToday + Math.floor(Math.random() * 5),
        trustScore: 85 + Math.floor(Math.random() * 10),
        networkHealth: 90 + Math.floor(Math.random() * 10)
      }));
    }, 3000);

    return () => clearInterval(interval);
  }, []);

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
            Swarm Intelligence
          </h2>
          <p className="text-xl text-gray-400 font-exo2">
            Distributed AI network processing content verification
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Network Visualization */}
          <div className="lg:col-span-2">
            <motion.div
              className="glassmorphism rounded-2xl p-6 h-[500px] relative overflow-hidden"
              initial={{ opacity: 0, x: -50 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.2 }}
            >
              <h3 className="text-xl font-orbitron font-semibold mb-6 text-center">
                Neural Network
              </h3>

              <svg className="absolute inset-0 w-full h-full">
                {/* Connections */}
                {connections.map((connection, index) => {
                  const fromNode = nodes.find(n => n.id === connection.from);
                  const toNode = nodes.find(n => n.id === connection.to);
                  
                  if (!fromNode || !toNode) return null;

                  return (
                    <motion.line
                      key={`${connection.from}-${connection.to}-${index}`}
                      x1={fromNode.x}
                      y1={fromNode.y}
                      x2={toNode.x}
                      y2={toNode.y}
                      className="neural-connection"
                      initial={{ opacity: 0 }}
                      animate={{
                        opacity: connection.active ? 1 : 0.3,
                        strokeWidth: connection.active ? 3 : 1
                      }}
                      transition={{ duration: 0.5 }}
                    />
                  );
                })}

                {/* Nodes */}
                {nodes.map(node => (
                  <motion.g key={node.id}>
                    <motion.circle
                      cx={node.x}
                      cy={node.y}
                      r={node.type === 'crawler' ? 8 : 10}
                      fill={node.type === 'crawler' ? '#4C6EF5' : '#FFD700'}
                      className="filter drop-shadow-lg"
                      animate={{
                        scale: node.active ? [1, 1.3, 1] : 1,
                        opacity: node.active ? 1 : 0.6
                      }}
                      transition={{
                        scale: { duration: 2, repeat: Infinity },
                        opacity: { duration: 0.5 }
                      }}
                    />
                    <motion.circle
                      cx={node.x}
                      cy={node.y}
                      r={node.type === 'crawler' ? 16 : 20}
                      fill="none"
                      stroke={node.type === 'crawler' ? '#4C6EF5' : '#FFD700'}
                      strokeWidth="1"
                      opacity="0.3"
                      animate={{
                        r: node.active ? [16, 25, 16] : 16,
                        opacity: node.active ? [0.3, 0.6, 0.3] : 0.3
                      }}
                      transition={{
                        duration: 2,
                        repeat: Infinity,
                        ease: "easeInOut"
                      }}
                    />
                  </motion.g>
                ))}
              </svg>

              {/* Legend */}
              <div className="absolute bottom-4 left-4 space-y-2">
                <div className="flex items-center space-x-2">
                  <div className="w-3 h-3 rounded-full bg-blue-500"></div>
                  <span className="text-xs text-gray-400">Crawler Nodes</span>
                </div>
                <div className="flex items-center space-x-2">
                  <div className="w-3 h-3 rounded-full bg-yellow-500"></div>
                  <span className="text-xs text-gray-400">Validator Nodes</span>
                </div>
              </div>
            </motion.div>
          </div>

          {/* Stats Panel */}
          <div className="space-y-6">
            <motion.div
              className="glassmorphism rounded-2xl p-6"
              initial={{ opacity: 0, x: 50 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.4 }}
            >
              <h3 className="text-xl font-orbitron font-semibold mb-6">
                Network Stats
              </h3>

              <div className="space-y-6">
                {/* Active Agents */}
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-gray-400 font-exo2">Active Agents</span>
                    <motion.span 
                      className="text-blue-400 font-bold"
                      key={stats.activeAgents}
                      initial={{ scale: 1.2 }}
                      animate={{ scale: 1 }}
                    >
                      {stats.activeAgents}
                    </motion.span>
                  </div>
                  <div className="w-full bg-gray-700/50 rounded-full h-2">
                    <motion.div
                      className="bg-gradient-to-r from-blue-500 to-purple-500 h-2 rounded-full"
                      initial={{ width: 0 }}
                      animate={{ width: `${(stats.activeAgents / 20) * 100}%` }}
                      transition={{ duration: 1, ease: "easeOut" }}
                    />
                  </div>
                </div>

                {/* Verified Today */}
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-gray-400 font-exo2">Verified Today</span>
                    <motion.span 
                      className="text-green-400 font-bold"
                      key={stats.verifiedToday}
                      initial={{ scale: 1.2 }}
                      animate={{ scale: 1 }}
                    >
                      {stats.verifiedToday.toLocaleString()}
                    </motion.span>
                  </div>
                  <div className="w-full bg-gray-700/50 rounded-full h-2">
                    <motion.div
                      className="bg-gradient-to-r from-green-500 to-teal-500 h-2 rounded-full"
                      animate={{ width: `${Math.min((stats.verifiedToday / 3000) * 100, 100)}%` }}
                      transition={{ duration: 1, ease: "easeOut" }}
                    />
                  </div>
                </div>

                {/* Trust Score */}
                <div>
                  <div className="flex items-center justify-between mb-4">
                    <span className="text-gray-400 font-exo2">Trust Score</span>
                    <motion.span 
                      className="text-purple-400 font-bold"
                      key={stats.trustScore}
                      initial={{ scale: 1.2 }}
                      animate={{ scale: 1 }}
                    >
                      {stats.trustScore}%
                    </motion.span>
                  </div>
                  <div className="relative w-24 h-24 mx-auto">
                    <svg className="w-full h-full transform -rotate-90">
                      <circle
                        cx="48"
                        cy="48"
                        r="40"
                        stroke="rgba(255,255,255,0.1)"
                        strokeWidth="6"
                        fill="none"
                      />
                      <motion.circle
                        cx="48"
                        cy="48"
                        r="40"
                        stroke="#8A2BE2"
                        strokeWidth="6"
                        fill="none"
                        strokeLinecap="round"
                        initial={{ strokeDasharray: 0, strokeDashoffset: 0 }}
                        animate={{
                          strokeDasharray: 2 * Math.PI * 40,
                          strokeDashoffset: 2 * Math.PI * 40 * (1 - stats.trustScore / 100)
                        }}
                        transition={{ duration: 2, ease: "easeOut" }}
                      />
                    </svg>
                  </div>
                </div>

                {/* Network Health */}
                <div>
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-gray-400 font-exo2">Network Health</span>
                    <motion.span 
                      className="text-cyan-400 font-bold"
                      key={stats.networkHealth}
                      initial={{ scale: 1.2 }}
                      animate={{ scale: 1 }}
                    >
                      {stats.networkHealth}%
                    </motion.span>
                  </div>
                  <div className="flex space-x-1">
                    {Array.from({ length: 10 }, (_, i) => (
                      <motion.div
                        key={i}
                        className="flex-1 h-3 rounded"
                        style={{
                          backgroundColor: i < (stats.networkHealth / 10) ? '#00F5A0' : 'rgba(255,255,255,0.1)'
                        }}
                        initial={{ height: 0 }}
                        animate={{ height: 12 }}
                        transition={{ delay: i * 0.1, duration: 0.5 }}
                      />
                    ))}
                  </div>
                </div>
              </div>
            </motion.div>

            {/* Quick Actions */}
            <motion.div
              className="glassmorphism rounded-2xl p-6"
              initial={{ opacity: 0, x: 50 }}
              whileInView={{ opacity: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.6 }}
            >
              <h4 className="font-orbitron font-semibold mb-4">Network Control</h4>
              <div className="space-y-3">
                <motion.button
                  className="w-full liquid-fill bg-blue-500/20 border border-blue-500/50 rounded-xl p-3 text-blue-400 font-exo2 text-sm"
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                >
                  <Activity className="w-4 h-4 inline mr-2" />
                  Boost Crawlers
                </motion.button>
                <motion.button
                  className="w-full liquid-fill bg-yellow-500/20 border border-yellow-500/50 rounded-xl p-3 text-yellow-400 font-exo2 text-sm"
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                >
                  <Zap className="w-4 h-4 inline mr-2" />
                  Fast Track
                </motion.button>
                <motion.button
                  className="w-full liquid-fill bg-green-500/20 border border-green-500/50 rounded-xl p-3 text-green-400 font-exo2 text-sm"
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                >
                  <Globe className="w-4 h-4 inline mr-2" />
                  Global Sync
                </motion.button>
              </div>
            </motion.div>
          </div>
        </div>
      </motion.div>
    </div>
  );
}