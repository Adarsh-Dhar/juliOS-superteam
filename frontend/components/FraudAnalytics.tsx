'use client';

import { motion, useMotionValue, useTransform } from 'framer-motion';
import { useState, useEffect } from 'react';
import { TrendingDown, AlertTriangle, Shield, Zap } from 'lucide-react';

interface FraudPattern {
  id: number;
  x: number;
  y: number;
  severity: 'low' | 'medium' | 'high';
  connections: number[];
}

export default function FraudAnalytics() {
  const [trustScore, setTrustScore] = useState(87);
  const [fraudPatterns, setFraudPatterns] = useState<FraudPattern[]>([]);
  const [timelineData, setTimelineData] = useState([
    { time: '00:00', authentic: 45, suspicious: 12, fake: 3 },
    { time: '04:00', authentic: 52, suspicious: 18, fake: 7 },
    { time: '08:00', authentic: 89, suspicious: 24, fake: 11 },
    { time: '12:00', authentic: 134, suspicious: 31, fake: 15 },
    { time: '16:00', authentic: 98, suspicious: 28, fake: 9 },
    { time: '20:00', authentic: 76, suspicious: 22, fake: 8 },
  ]);

  const mouseX = useMotionValue(0);
  const mouseY = useMotionValue(0);
  const rotateX = useTransform(mouseY, [-300, 300], [10, -10]);
  const rotateY = useTransform(mouseX, [-300, 300], [-10, 10]);

  useEffect(() => {
    // Initialize fraud constellation
    const patterns: FraudPattern[] = Array.from({ length: 15 }, (_, i) => ({
      id: i,
      x: 100 + Math.random() * 400,
      y: 100 + Math.random() * 300,
      severity: ['low', 'medium', 'high'][Math.floor(Math.random() * 3)] as 'low' | 'medium' | 'high',
      connections: []
    }));

    // Create connections between suspicious patterns
    patterns.forEach(pattern => {
      if (Math.random() > 0.7) {
        const nearbyPatterns = patterns
          .filter(p => p.id !== pattern.id)
          .filter(p => {
            const distance = Math.sqrt((p.x - pattern.x) ** 2 + (p.y - pattern.y) ** 2);
            return distance < 150;
          })
          .slice(0, 2);
        
        pattern.connections = nearbyPatterns.map(p => p.id);
      }
    });

    setFraudPatterns(patterns);

    // Animate trust score changes
    const interval = setInterval(() => {
      setTrustScore(prev => {
        const change = (Math.random() - 0.5) * 4;
        return Math.max(75, Math.min(95, prev + change));
      });
    }, 3000);

    return () => clearInterval(interval);
  }, []);

  const handleMouseMove = (e: React.MouseEvent) => {
    const rect = e.currentTarget.getBoundingClientRect();
    mouseX.set(e.clientX - rect.left - rect.width / 2);
    mouseY.set(e.clientY - rect.top - rect.height / 2);
  };

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'low': return '#4C6EF5';
      case 'medium': return '#FF9500';
      case 'high': return '#FF2A6D';
      default: return '#4C6EF5';
    }
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
            Fraud Analytics
          </h2>
          <p className="text-xl text-gray-400 font-exo2">
            Advanced pattern recognition and threat analysis
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-12">
          {/* Trust Orb */}
          <motion.div
            className="glassmorphism rounded-2xl p-8 h-[400px] flex flex-col items-center justify-center relative overflow-hidden"
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
            onMouseMove={handleMouseMove}
            style={{ rotateX, rotateY }}
          >
            <h3 className="text-xl font-orbitron font-semibold mb-8 text-center">
              Trust Orb
            </h3>

            <motion.div
              className="trust-orb w-48 h-48 relative cursor-pointer"
              whileHover={{ scale: 1.1 }}
              onClick={() => {
                // Simulate orb explosion effect
                setTrustScore(prev => Math.min(95, prev + 5));
              }}
            >
              {/* Orb Core */}
              <div className="absolute inset-0 rounded-full bg-gradient-to-br from-green-400/80 to-blue-600/80 shadow-2xl">
                <div className="absolute inset-4 rounded-full bg-gradient-to-tr from-green-300/60 to-blue-500/60 backdrop-blur-sm">
                  <div className="absolute inset-6 rounded-full bg-gradient-to-b from-green-200/40 to-blue-400/40">
                    {/* Terrain-like patterns */}
                    <div className="absolute inset-0 rounded-full opacity-30">
                      {Array.from({ length: 20 }, (_, i) => (
                        <motion.div
                          key={i}
                          className="absolute w-2 h-2 bg-white rounded-full"
                          style={{
                            left: `${20 + (i * 13) % 60}%`,
                            top: `${30 + (i * 7) % 40}%`,
                          }}
                          animate={{
                            scale: [0.5, 1.2, 0.5],
                            opacity: [0.3, 0.8, 0.3],
                          }}
                          transition={{
                            duration: 2 + i * 0.1,
                            repeat: Infinity,
                            ease: "easeInOut"
                          }}
                        />
                      ))}
                    </div>
                  </div>
                </div>
              </div>

              {/* Trust Score Display */}
              <div className="absolute inset-0 flex items-center justify-center">
                <motion.div 
                  className="text-center"
                  key={Math.floor(trustScore)}
                  initial={{ scale: 1.2, opacity: 0.8 }}
                  animate={{ scale: 1, opacity: 1 }}
                >
                  <div className="text-3xl font-orbitron font-bold text-white">
                    {Math.floor(trustScore)}%
                  </div>
                  <div className="text-sm text-white/80 font-exo2">
                    Trust Score
                  </div>
                </motion.div>
              </div>

              {/* Floating particles */}
              {Array.from({ length: 8 }, (_, i) => (
                <motion.div
                  key={i}
                  className="absolute w-1 h-1 bg-white rounded-full"
                  style={{
                    left: `${50 + 30 * Math.cos(i * Math.PI / 4)}%`,
                    top: `${50 + 30 * Math.sin(i * Math.PI / 4)}%`,
                  }}
                  animate={{
                    x: [0, 10, -10, 0],
                    y: [0, -10, 10, 0],
                    scale: [1, 1.5, 1],
                  }}
                  transition={{
                    duration: 3,
                    delay: i * 0.2,
                    repeat: Infinity,
                    ease: "easeInOut"
                  }}
                />
              ))}
            </motion.div>

            <div className="mt-6 text-center">
              <div className="text-lg font-exo2 text-gray-300 mb-2">
                Network Authenticity
              </div>
              <div className="flex items-center justify-center space-x-4 text-sm">
                <div className="flex items-center space-x-1 text-green-400">
                  <Shield className="w-4 h-4" />
                  <span>Secure</span>
                </div>
                <div className="flex items-center space-x-1 text-blue-400">
                  <Zap className="w-4 h-4" />
                  <span>Active</span>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Fraud Constellation */}
          <motion.div
            className="glassmorphism rounded-2xl p-6 h-[400px] relative overflow-hidden"
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8, delay: 0.4 }}
          >
            <h3 className="text-xl font-orbitron font-semibold mb-6 text-center">
              Fraud Constellation
            </h3>

            <svg className="absolute inset-0 w-full h-full">
              {/* Connections */}
              {fraudPatterns.map(pattern =>
                pattern.connections.map(connId => {
                  const targetPattern = fraudPatterns.find(p => p.id === connId);
                  if (!targetPattern) return null;

                  return (
                    <motion.line
                      key={`${pattern.id}-${connId}`}
                      x1={pattern.x}
                      y1={pattern.y}
                      x2={targetPattern.x}
                      y2={targetPattern.y}
                      stroke={getSeverityColor(pattern.severity)}
                      strokeWidth="1"
                      opacity="0.6"
                      initial={{ pathLength: 0 }}
                      animate={{ pathLength: 1 }}
                      transition={{ duration: 2, delay: Math.random() * 2 }}
                    />
                  );
                })
              )}

              {/* Patterns */}
              {fraudPatterns.map(pattern => (
                <motion.g key={pattern.id}>
                  <motion.circle
                    cx={pattern.x}
                    cy={pattern.y}
                    r={pattern.severity === 'high' ? 8 : pattern.severity === 'medium' ? 6 : 4}
                    fill={getSeverityColor(pattern.severity)}
                    className="cursor-pointer"
                    initial={{ scale: 0, opacity: 0 }}
                    animate={{ scale: 1, opacity: 0.8 }}
                    whileHover={{ scale: 1.5, opacity: 1 }}
                    transition={{ 
                      duration: 0.5,
                      delay: pattern.id * 0.1
                    }}
                  />
                  {pattern.severity === 'high' && (
                    <motion.circle
                      cx={pattern.x}
                      cy={pattern.y}
                      r="12"
                      fill="none"
                      stroke={getSeverityColor(pattern.severity)}
                      strokeWidth="2"
                      opacity="0.5"
                      animate={{
                        r: [12, 20, 12],
                        opacity: [0.5, 0.8, 0.5]
                      }}
                      transition={{
                        duration: 2,
                        repeat: Infinity,
                        ease: "easeInOut"
                      }}
                    />
                  )}
                </motion.g>
              ))}
            </svg>

            {/* Legend */}
            <div className="absolute bottom-4 right-4 space-y-2 text-xs">
              <div className="flex items-center space-x-2">
                <div className="w-2 h-2 rounded-full bg-blue-500"></div>
                <span className="text-gray-400">Low Risk</span>
              </div>
              <div className="flex items-center space-x-2">
                <div className="w-2 h-2 rounded-full bg-orange-500"></div>
                <span className="text-gray-400">Medium Risk</span>
              </div>
              <div className="flex items-center space-x-2">
                <div className="w-2 h-2 rounded-full bg-pink-500"></div>
                <span className="text-gray-400">High Risk</span>
              </div>
            </div>
          </motion.div>
        </div>

        {/* Timeline Graph */}
        <motion.div
          className="glassmorphism rounded-2xl p-6"
          initial={{ opacity: 0, y: 50 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.6 }}
        >
          <h3 className="text-xl font-orbitron font-semibold mb-6 text-center">
            Detection Timeline
          </h3>

          <div className="h-64 relative">
            <svg className="w-full h-full">
              {/* Grid lines */}
              {Array.from({ length: 5 }, (_, i) => (
                <line
                  key={i}
                  x1="0"
                  y1={i * 50}
                  x2="100%"
                  y2={i * 50}
                  stroke="rgba(255,255,255,0.1)"
                  strokeWidth="1"
                />
              ))}

              {/* Data bars */}
              {timelineData.map((data, index) => {
                const x = (index / (timelineData.length - 1)) * 100;
                const maxValue = Math.max(...timelineData.map(d => d.authentic + d.suspicious + d.fake));
                
                return (
                  <g key={data.time}>
                    {/* Authentic bars */}
                    <motion.rect
                      x={`${x - 2}%`}
                      y="100%"
                      width="4%"
                      height="0%"
                      fill="url(#authenticGradient)"
                      initial={{ height: "0%" }}
                      animate={{ 
                        height: `${(data.authentic / maxValue) * 80}%`,
                        y: `${100 - (data.authentic / maxValue) * 80}%`
                      }}
                      transition={{ duration: 1, delay: index * 0.2 }}
                    />
                    
                    {/* Suspicious bars */}
                    <motion.rect
                      x={`${x - 1}%`}
                      y="100%"
                      width="2%"
                      height="0%"
                      fill="url(#suspiciousGradient)"
                      initial={{ height: "0%" }}
                      animate={{ 
                        height: `${(data.suspicious / maxValue) * 80}%`,
                        y: `${100 - (data.suspicious / maxValue) * 80}%`
                      }}
                      transition={{ duration: 1, delay: index * 0.2 + 0.5 }}
                    />
                    
                    {/* Fake bars */}
                    <motion.rect
                      x={`${x}%`}
                      y="100%"
                      width="1%"
                      height="0%"
                      fill="url(#fakeGradient)"
                      initial={{ height: "0%" }}
                      animate={{ 
                        height: `${(data.fake / maxValue) * 80}%`,
                        y: `${100 - (data.fake / maxValue) * 80}%`
                      }}
                      transition={{ duration: 1, delay: index * 0.2 + 1 }}
                    />

                    {/* Time labels */}
                    <text
                      x={`${x}%`}
                      y="95%"
                      textAnchor="middle"
                      className="text-xs fill-gray-400 font-exo2"
                    >
                      {data.time}
                    </text>
                  </g>
                );
              })}

              <defs>
                <linearGradient id="authenticGradient" x1="0%" y1="100%" x2="0%" y2="0%">
                  <stop offset="0%" stopColor="#00F5A0" stopOpacity="0.8" />
                  <stop offset="100%" stopColor="#00F5A0" stopOpacity="0.3" />
                </linearGradient>
                <linearGradient id="suspiciousGradient" x1="0%" y1="100%" x2="0%" y2="0%">
                  <stop offset="0%" stopColor="#FF9500" stopOpacity="0.8" />
                  <stop offset="100%" stopColor="#FF9500" stopOpacity="0.3" />
                </linearGradient>
                <linearGradient id="fakeGradient" x1="0%" y1="100%" x2="0%" y2="0%">
                  <stop offset="0%" stopColor="#FF2A6D" stopOpacity="0.8" />
                  <stop offset="100%" stopColor="#FF2A6D" stopOpacity="0.3" />
                </linearGradient>
              </defs>
            </svg>
          </div>

          {/* Legend */}
          <div className="flex items-center justify-center space-x-6 mt-4 text-sm font-exo2">
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 bg-green-400 rounded"></div>
              <span className="text-gray-400">Authentic</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 bg-orange-400 rounded"></div>
              <span className="text-gray-400">Suspicious</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 bg-pink-400 rounded"></div>
              <span className="text-gray-400">Fake</span>
            </div>
          </div>
        </motion.div>
      </motion.div>
    </div>
  );
}